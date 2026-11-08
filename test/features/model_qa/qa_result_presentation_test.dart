import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:konsena_ai/data/audit/audit_repository.dart';
import 'package:konsena_ai/data/audit/local_data_cipher.dart';
import 'package:konsena_ai/data/audit/local_source_file_store.dart';
import 'package:konsena_ai/data/local/app_database.dart';
import 'package:konsena_ai/domain/audit/audit_entities.dart';
import 'package:konsena_ai/features/audit/domain/audit_snapshot.dart';
import 'package:konsena_ai/features/model_qa/data/onnx_tensor_harness.dart';
import 'package:konsena_ai/features/model_qa/presentation/nli_qa_panel.dart';

const _permission = 'android.permission.CAMERA';
const _quote = 'The camera is used during an account check.';
final _at = DateTime.utc(2026, 11, 8);
final _audit = AuditSession(
  id: 'audit',
  name: 'Audit uji',
  focus: AuditFocus.combined,
  status: AuditStatus.draft,
  createdAt: _at,
  updatedAt: _at,
);
final _source = DocumentSource(
  id: 'source',
  auditId: _audit.id,
  type: AuditSourceType.privacyPolicy,
  lifecycle: SourceLifecycle.active,
  reviewStatus: SourceReviewStatus.reviewed,
  originalName: 'Kebijakan uji',
  sha256: 'a' * 64,
  localPath: 'unused',
  mediaType: 'text/plain',
  byteLength: _quote.length,
  createdAt: _at,
  updatedAt: _at,
);
final _app = ApplicationSnapshotRecord(
  id: 'snapshot',
  auditId: _audit.id,
  packageName: 'id.fixture',
  appLabel: 'Aplikasi uji',
  permissions: [
    AppPermissionSnapshot(
      id: 'permission',
      auditId: _audit.id,
      packageName: 'id.fixture',
      permissionName: _permission,
      grantStatus: 'denied',
      capturedAt: _at,
    ),
  ],
  snapshotStatus: 'available',
  visibilityScope: 'launcher',
  androidSdk: 36,
  capturedAt: _at,
);
const _segment = DocumentSegment(
  id: 'segment',
  sourceId: 'source',
  sequence: 0,
  text: _quote,
);

class _ReviewRepo extends AuditRepository {
  _ReviewRepo(AppDatabase db, LocalDataCipher cipher)
    : super(
        database: db,
        files: LocalSourceFileStore(root: Directory.systemTemp, cipher: cipher),
        cipher: cipher,
      );

  @override
  Future<AuditSession?> get(String id) async => _audit;
  @override
  Future<DocumentSource> source(String sourceId) async => _source;
  @override
  Future<List<int>> readSource(String sourceId) async => _quote.codeUnits;
  @override
  Future<List<DocumentSegment>> documentSegments(String sourceId) async => [
    _segment,
  ];
  @override
  Future<List<ApplicationSnapshotRecord>> applicationSnapshots(
    String auditId,
  ) async => [_app];
}

void main() {
  testWidgets(
    'NLI presents meaning and a next check before raw QA labels at 320dp and 200%',
    (tester) async {
      tester.view.physicalSize = const Size(320, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final repo = _ReviewRepo(
        db,
        LocalDataCipher(
          keyProvider: MemoryEncryptionKeyProvider(List.filled(32, 7)),
        ),
      );
      final messenger =
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
      messenger.setMockMethodCallHandler(
        OnnxTensorHarness.channel,
        (_) async => {
          'status': 'QA_ONLY',
          'modelId': 'consent_nli',
          'modelVersion': 'fd543a14deab68081bedc6a9f848932e69594f9993384dd16fdac6bb6900c12c',
          'label': 'neutral',
          'probabilities': [.1, .7, .2],
          'loadAndInferenceMs': 42,
        },
      );
      addTearDown(
        () =>
            messenger.setMockMethodCallHandler(OnnxTensorHarness.channel, null),
      );
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MediaQuery(
              data: const MediaQueryData(textScaler: TextScaler.linear(2)),
              child: SingleChildScrollView(
                child: NliQaPanel(
                  repository: repo,
                  snapshot: AuditSnapshot(
                    audit: _audit,
                    sources: [_source],
                    apps: [_app],
                    segments: {
                      _source.id: [_segment],
                    },
                    evidence: const [],
                    reviews: const {},
                    generatedAt: _at,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      Future<void> tapVisible(Finder finder) async {
        await tester.ensureVisible(finder);
        await tester.tap(finder);
        await tester.pumpAndSettle();
      }

      await tapVisible(find.text('Aktifkan bantuan AI'));
      final dropdowns = find.byType(DropdownButtonFormField<(String, String)>);
      await tapVisible(dropdowns.at(0));
      await tapVisible(find.textContaining('Bagian 1').last);
      await tapVisible(dropdowns.at(1));
      await tapVisible(find.textContaining('Aplikasi uji · Kamera').last);
      await tapVisible(find.text('Bandingkan'));

      expect(find.text('Hasil pemeriksaan'), findsOneWidget);
      expect(find.text('Hubungannya belum jelas'), findsOneWidget);
      expect(find.text('Aplikasi uji · Izin Kamera'), findsOneWidget);
      expect(find.text('Yang bisa dicek'), findsOneWidget);
      expect(find.textContaining('Label NLI: neutral'), findsNothing);
      expect(find.text(_quote), findsNothing);

      await tapVisible(find.text('Lihat kutipan sumber'));
      expect(find.text(_quote), findsOneWidget);
      await tapVisible(find.text('Detail teknis QA'));
      expect(find.textContaining('Label NLI: neutral'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
    skip: !OnnxTensorHarness.enabled,
  );
}
