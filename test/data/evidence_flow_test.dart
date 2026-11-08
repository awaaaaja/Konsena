import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:konsena_ai/data/audit/audit_repository.dart';
import 'package:konsena_ai/data/audit/local_data_cipher.dart';
import 'package:konsena_ai/data/audit/local_source_file_store.dart';
import 'package:konsena_ai/data/local/app_database.dart';
import 'package:konsena_ai/domain/audit/analysis_engine.dart';
import 'package:konsena_ai/domain/audit/audit_entities.dart';
import 'package:konsena_ai/features/audit/domain/audit_snapshot.dart';
import 'package:konsena_ai/features/consent_ui/domain/screenshot_review.dart';
import 'package:konsena_ai/features/model_qa/data/onnx_tensor_harness.dart';
import 'package:konsena_ai/features/model_qa/data/source_bound_dark_pattern.dart';
import 'package:konsena_ai/features/model_qa/data/source_bound_nli_engine.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory temp;
  late AppDatabase db;
  late AuditRepository repo;
  late LocalSourceFileStore files;
  setUp(() async {
    temp = await Directory.systemTemp.createTemp('konsena_evidence_');
    db = AppDatabase(NativeDatabase.memory());
    final cipher = LocalDataCipher(
      keyProvider: MemoryEncryptionKeyProvider(List.filled(32, 8)),
    );
    files = LocalSourceFileStore(root: temp, cipher: cipher);
    repo = AuditRepository(database: db, files: files, cipher: cipher);
  });
  tearDown(() async {
    await db.close();
    await temp.delete(recursive: true);
  });

  test(
    'Dark Pattern QA verifies screenshot ownership and rejects stale ROI',
    () async {
      final audit = await repo.create();
      final other = await repo.create();
      final source = await repo.attachSource(
        auditId: audit.id,
        bytes: img.encodePng(img.Image(width: 3, height: 4, numChannels: 3)),
        type: AuditSourceType.consentUi,
        mediaType: 'image/png',
      );
      const review = ScreenshotReview(crop: SourceRect(.1, .2, .7, .6));
      final messenger =
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
      var calls = 0;
      messenger.setMockMethodCallHandler(OnnxTensorHarness.channel, (
        call,
      ) async {
        calls++;
        expect(call.method, 'runTensor');
        expect(call.arguments['modelId'], 'dark_pattern');
        expect(call.arguments['pixels'], hasLength(3 * 224 * 224 * 4));
        if (calls == 2) {
          await repo.saveScreenshotReview(
            auditId: audit.id,
            sourceId: source.id,
            review: const ScreenshotReview(quarterTurns: 1),
          );
        }
        return {
          'status': 'QA_ONLY',
          'modelId': 'dark_pattern',
          'logits': [0.2, 1.1],
          'loadAndInferenceMs': 20,
        };
      });
      addTearDown(
        () =>
            messenger.setMockMethodCallHandler(OnnxTensorHarness.channel, null),
      );
      Future<AnalysisResult> run({bool optedIn = true, String? auditId}) =>
          SourceBoundDarkPattern(repo).run(
            optedIn: optedIn,
            auditId: auditId ?? audit.id,
            sourceId: source.id,
            sourceRevision: repo.revision,
          );

      expect(await run(optedIn: false), isA<AnalysisUnavailable>());
      if (!OnnxTensorHarness.enabled) {
        expect(await run(), isA<AnalysisUnavailable>());
        expect(calls, 0);
        return;
      }
      expect((await run()).outcome, AnalysisOutcome.insufficientSources);
      await repo.saveScreenshotReview(
        auditId: audit.id,
        sourceId: source.id,
        review: review,
      );
      expect(
        (await run(auditId: other.id)).outcome,
        AnalysisOutcome.insufficientSources,
      );
      expect(calls, 0);
      final result = await run() as DarkPatternQaResult;
      expect(result.label, 'potential_dark_pattern');
      expect(result.review.crop.toJson(), review.crop.toJson());
      expect(
        result.probabilities[0] + result.probabilities[1],
        closeTo(1, 1e-10),
      );
      expect((await run()).reason, 'source_changed_during_inference');
      expect(calls, 2);
    },
  );

  test('NLI requires debug opt-in and discards inference after source edits', () async {
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    final audit = await repo.create();
    final otherAudit = await repo.create();
    final source = await repo.attachSource(
      auditId: audit.id,
      bytes: [65],
      type: AuditSourceType.privacyPolicy,
      mediaType: 'text/plain',
    );
    await repo.addSegment(sourceId: source.id, sequence: 0, text: 'A clause.');
    await repo.setSourceReviewStatus(source.id, SourceReviewStatus.reviewed);
    final segment = (await repo.documentSegments(source.id)).single;
    final capturedAt = DateTime.utc(2026, 11, 8);
    const permission = 'android.permission.CAMERA';
    const package = 'id.konsena.fixture';
    final snapshot = await repo.saveApplicationSnapshot(
      auditId: audit.id,
      packageName: package,
      appLabel: 'Fixture',
      versionName: '1',
      snapshotStatus: 'available',
      visibilityScope: 'launcher',
      androidSdk: 36,
      capturedAt: capturedAt,
      permissions: [
        AppPermissionSnapshot(
          id: '',
          auditId: audit.id,
          packageName: package,
          permissionName: permission,
          grantStatus: 'denied',
          capturedAt: capturedAt,
        ),
      ],
    );
    var calls = 0;
    var correctDuringInference = false;
    messenger.setMockMethodCallHandler(OnnxTensorHarness.channel, (call) async {
      calls++;
      expect(call.method, 'analyzePair');
      expect(call.arguments, {
        'modelId': 'consent_nli',
        'premise': segment.text,
        'hypothesis':
            'The application requests the Android permission $permission.',
      });
      if (correctDuringInference) {
        await repo.updateImportedSegment(
          sourceId: source.id,
          segmentId: segment.id,
          text: 'Corrected clause.',
          reviewed: true,
        );
      }
      return {
        'status': 'QA_ONLY',
        'modelId': 'consent_nli',
        'modelVersion':
            'fd543a14deab68081bedc6a9f848932e69594f9993384dd16fdac6bb6900c12c',
        'label': 'neutral',
        'probabilities': [.1, .7, .2],
        'loadAndInferenceMs': 20,
      };
    });
    addTearDown(
      () => messenger.setMockMethodCallHandler(OnnxTensorHarness.channel, null),
    );

    Future<AnalysisResult> compare({
      required bool optedIn,
      String? auditId,
      String permissionName = permission,
    }) => SourceBoundNliEngine(repo).compare(
      optedIn: optedIn,
      auditId: auditId ?? audit.id,
      sourceId: source.id,
      segmentId: segment.id,
      snapshotId: snapshot.id,
      permissionName: permissionName,
      sourceRevision: repo.revision,
    );
    expect(await compare(optedIn: false), isA<AnalysisUnavailable>());
    expect(calls, 0);
    if (!OnnxTensorHarness.enabled) {
      expect(await compare(optedIn: true), isA<AnalysisUnavailable>());
      expect(calls, 0);
      return;
    }
    expect(
      (await compare(optedIn: true, auditId: otherAudit.id)).outcome,
      AnalysisOutcome.insufficientSources,
    );
    expect(
      (await compare(optedIn: true, permissionName: 'missing')).outcome,
      AnalysisOutcome.insufficientSources,
    );
    expect(calls, 0);
    final result = await compare(optedIn: true) as NliSourceResult;
    expect(result.source.id, source.id);
    expect(result.segment.id, segment.id);
    expect(result.snapshot.id, snapshot.id);
    expect(result.label, 'neutral');
    correctDuringInference = true;
    expect(
      (await compare(optedIn: true)).reason,
      'source_changed_during_inference',
    );
    expect(calls, 2);
  });

  test('reject wrong audit association and invented quote; correction suppresses stale evidence', () async {
    final audit = await repo.create(name: 'A');
    final other = await repo.create(name: 'B');
    final source = await repo.attachSource(
      auditId: audit.id,
      bytes: [1],
      type: AuditSourceType.privacyPolicy,
      mediaType: 'text/plain',
    );
    await repo.addSegment(
      sourceId: source.id,
      sequence: 0,
      text: 'We retain data for thirty days.',
      page: 1,
    );
    final segment = (await repo.documentSegments(source.id)).single;
    Future<void> evidence(String id, String quote) => repo.addEvidence(
      auditId: id,
      sourceId: source.id,
      sourceSha256: source.sha256,
      segmentId: segment.id,
      quote: quote,
      location: 'page 1',
    );
    await expectLater(
      evidence(other.id, 'We retain data'),
      throwsA(isA<SourceNotFoundException>()),
    );
    await expectLater(evidence(audit.id, 'forever'), throwsArgumentError);
    await evidence(audit.id, segment.text);
    expect((await repo.evidence(audit.id)).single.quote, segment.text);
    final row = await db.select(db.evidenceReferences).getSingle();
    expect(row.location, startsWith('enc:v1:'));
    await repo.updateImportedSegment(
      sourceId: source.id,
      segmentId: segment.id,
      text: 'We retain data for seven days.',
      reviewed: true,
    );
    expect(await repo.evidence(audit.id), isEmpty);
    await repo.detachSource(source.id);
    expect(await repo.evidence(audit.id), isEmpty);
  });
  test('screenshot revisions encrypt metadata and delete with source; report reflects active data', () async {
    final audit = await repo.create(name: 'QA screenshot');
    final source = await repo.attachSource(
      auditId: audit.id,
      bytes: [1, 2],
      type: AuditSourceType.consentUi,
      mediaType: 'image/png',
    );
    final review = ScreenshotReview(
      title: 'Private title',
      version: 'v2',
      annotations: [
        const ManualAnnotation(
          kind: 'checkbox',
          label: 'Private annotation',
          rect: SourceRect(.1, .2, .3, .4),
        ),
      ],
    );
    await repo.saveScreenshotReview(
      auditId: audit.id,
      sourceId: source.id,
      review: review,
    );
    await repo.saveScreenshotReview(
      auditId: audit.id,
      sourceId: source.id,
      review: const ScreenshotReview(title: 'v3'),
    );
    final history = await repo.screenshotHistory(audit.id, source.id);
    expect(history.length, 2);
    expect(history.first.review.title, 'v3');
    expect(
      (await db.select(db.userActions).get()).every(
        (row) => !row.details!.contains('Private'),
      ),
      isTrue,
    );
    final snapshot = await AuditSnapshot.load(repo, audit.id);
    expect(snapshot.reportLines.join('\n'), contains('v3'));
    expect(
      snapshot.reportLines,
      contains(
        'Rute lokal: /consent-ui/review?auditId=${audit.id}&sourceId=${source.id}',
      ),
    );
    expect(
      snapshot.reportLines.join('\n'),
      contains('Analisis AI belum tersedia'),
    );
    await repo.detachSource(source.id);
    expect(await db.select(db.userActions).get(), isEmpty);
    expect(await files.listStoredRelativePaths(), isEmpty);
    expect((await AuditSnapshot.load(repo, audit.id)).sources, isEmpty);
    await repo.deleteAudit(audit.id);
    await expectLater(
      AuditSnapshot.load(repo, audit.id),
      throwsA(isA<AuditNotFoundException>()),
    );
  });
  test('missing original file cannot be used as active evidence', () async {
    final audit = await repo.create();
    final source = await repo.attachSource(
      auditId: audit.id,
      bytes: [3, 4],
      type: AuditSourceType.terms,
      mediaType: 'text/plain',
    );
    await repo.addSegment(
      sourceId: source.id,
      sequence: 0,
      text: 'Exact source',
    );
    final segment = (await repo.documentSegments(source.id)).single;
    await repo.addEvidence(
      auditId: audit.id,
      sourceId: source.id,
      sourceSha256: source.sha256,
      segmentId: segment.id,
      location: 'segment 0',
      quote: 'Exact source',
    );
    await files.delete(source.localPath);
    expect(await repo.evidence(audit.id), isEmpty);
    final snapshot = await AuditSnapshot.load(repo, audit.id);
    expect(snapshot.unavailableSources, contains(source.id));
    expect(snapshot.reportLines.join('\n'), contains('MISSING / CORRUPT'));
  });
}
