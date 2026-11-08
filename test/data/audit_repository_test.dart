import 'dart:convert';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/foundation.dart';
import 'package:konsena_ai/data/audit/audit_repository.dart';
import 'package:konsena_ai/data/audit/local_source_file_store.dart';
import 'package:konsena_ai/data/audit/local_data_cipher.dart';
import 'package:konsena_ai/data/local/app_database.dart';
import 'package:konsena_ai/domain/audit/audit_entities.dart';

void main() {
  late Directory temp;
  late AppDatabase db;
  late AuditRepository repository;
  late LocalSourceFileStore files;
  late LocalDataCipher cipher;

  setUp(() async {
    temp = await Directory.systemTemp.createTemp('konsena_phase02_');
    db = AppDatabase(NativeDatabase(File('${temp.path}/test.sqlite')));
    cipher = LocalDataCipher(
      keyProvider: MemoryEncryptionKeyProvider(List.filled(32, 7)),
    );
    files = LocalSourceFileStore(
      root: Directory('${temp.path}/sources'),
      cipher: cipher,
    );
    repository = AuditRepository(database: db, files: files, cipher: cipher);
  });

  tearDown(() async {
    await db.close();
    if (await temp.exists()) await temp.delete(recursive: true);
  });

  test(
    'schema version 3 creates all local tables with FK enforcement',
    () async {
      expect(db.schemaVersion, 3);
      await repository.create(name: 'Migration fixture');
      final version = await db.customSelect('PRAGMA user_version').getSingle();
      expect(version.data.values.single, 3);
      final foreignKeys = await db
          .customSelect('PRAGMA foreign_keys')
          .getSingle();
      expect(foreignKeys.data.values.single, 1);
      final tables = await db
          .customSelect("SELECT name FROM sqlite_master WHERE type='table'")
          .get();
      expect(
        tables.map((row) => row.read<String>('name')),
        containsAll([
          'audit_sessions',
          'application_snapshots',
          'document_sources',
          'document_segments',
          'privacy_preference_rows',
          'pending_file_deletes',
        ]),
      );
    },
  );

  test('schema v1 upgrades permission snapshot storage to v3', () async {
    final audit = await repository.create(name: 'Migration audit');
    await db.close();
    final legacyWithPhase04Columns = AppDatabase(
      NativeDatabase(File('${temp.path}/test.sqlite')),
    );
    for (final column in const [
      'source_url',
      'document_version',
      'import_warnings',
      'reviewed_at',
    ]) {
      await legacyWithPhase04Columns.customStatement(
        'ALTER TABLE document_sources DROP COLUMN $column',
      );
    }
    for (final column in const [
      'original_content',
      'start_offset',
      'end_offset',
      'page_text_sha256',
      'extraction_method',
      'confidence',
      'bounding_box_json',
      'edited_at',
      'reviewed_at',
    ]) {
      await legacyWithPhase04Columns.customStatement(
        'ALTER TABLE document_segments DROP COLUMN $column',
      );
    }
    await legacyWithPhase04Columns.customStatement(
      'DROP TABLE application_snapshots',
    );
    for (final column in const [
      'app_snapshot_id',
      'permission_label',
      'granted',
      'flags_available',
    ]) {
      await legacyWithPhase04Columns.customStatement(
        'ALTER TABLE app_permission_snapshots DROP COLUMN $column',
      );
    }
    await legacyWithPhase04Columns.customStatement('PRAGMA user_version = 1');
    await legacyWithPhase04Columns.close();

    db = AppDatabase(NativeDatabase(File('${temp.path}/test.sqlite')));
    repository = AuditRepository(database: db, files: files, cipher: cipher);
    await repository.get(audit.id);
    expect(db.schemaVersion, 3);
    final version = await db.customSelect('PRAGMA user_version').getSingle();
    expect(version.data.values.single, 3);
    final columns = await db
        .customSelect('PRAGMA table_info(app_permission_snapshots)')
        .get();
    expect(
      columns.map((row) => row.read<String>('name')),
      contains('app_snapshot_id'),
    );
    final tables = await db
        .customSelect("SELECT name FROM sqlite_master WHERE type='table'")
        .get();
    expect(
      tables.map((row) => row.read<String>('name')),
      contains('application_snapshots'),
    );
  });

  test('schema v2 upgrades source and segment provenance to v3', () async {
    await repository.create(name: 'V2 migration');
    await db.close();
    final legacy = AppDatabase(
      NativeDatabase(File('${temp.path}/test.sqlite')),
    );
    for (final column in const [
      'source_url',
      'document_version',
      'import_warnings',
      'reviewed_at',
    ]) {
      await legacy.customStatement(
        'ALTER TABLE document_sources DROP COLUMN $column',
      );
    }
    for (final column in const [
      'original_content',
      'start_offset',
      'end_offset',
      'page_text_sha256',
      'extraction_method',
      'confidence',
      'bounding_box_json',
      'edited_at',
      'reviewed_at',
    ]) {
      await legacy.customStatement(
        'ALTER TABLE document_segments DROP COLUMN $column',
      );
    }
    await legacy.customStatement('PRAGMA user_version = 2');
    await legacy.close();

    db = AppDatabase(NativeDatabase(File('${temp.path}/test.sqlite')));
    repository = AuditRepository(database: db, files: files, cipher: cipher);
    await repository.listSessions();
    final version = await db.customSelect('PRAGMA user_version').getSingle();
    expect(version.data.values.single, 3);
    final segmentColumns = await db
        .customSelect('PRAGMA table_info(document_segments)')
        .get();
    expect(
      segmentColumns.map((row) => row.read<String>('name')),
      containsAll([
        'original_content',
        'start_offset',
        'end_offset',
        'page_text_sha256',
        'extraction_method',
        'confidence',
        'bounding_box_json',
        'edited_at',
        'reviewed_at',
      ]),
    );
  });

  test(
    'application permission snapshots persist encrypted metadata and cascade',
    () async {
      final audit = await repository.create(name: 'Audit izin');
      final capturedAt = DateTime.utc(2026, 11, 8, 10);
      await repository.saveApplicationSnapshot(
        auditId: audit.id,
        packageName: 'com.example.shop',
        appLabel: 'Shop Example',
        versionName: '3.2.1',
        snapshotStatus: 'available',
        visibilityScope: 'launcher_query',
        androidSdk: 36,
        capturedAt: capturedAt,
        permissions: [
          AppPermissionSnapshot(
            id: '',
            auditId: audit.id,
            packageName: 'com.example.shop',
            permissionName: 'android.permission.CAMERA',
            permissionLabel: 'Camera',
            grantStatus: 'declared_not_granted',
            granted: false,
            flagsAvailable: true,
            androidSdk: 36,
            protectionLevel: '1',
            capturedAt: capturedAt,
          ),
        ],
      );
      final persisted = await repository.applicationSnapshots(audit.id);
      expect(persisted, hasLength(1));
      expect(persisted.single.packageName, 'com.example.shop');
      expect(persisted.single.appLabel, 'Shop Example');
      expect(
        persisted.single.permissions.single.permissionName,
        'android.permission.CAMERA',
      );
      expect(
        persisted.single.permissions.single.grantStatus,
        'declared_not_granted',
      );
      expect(persisted.single.permissions.single.permissionLabel, 'Camera');
      expect(persisted.single.permissions.single.granted, isFalse);
      expect(persisted.single.permissions.single.flagsAvailable, isTrue);
      await repository.saveApplicationSnapshot(
        auditId: audit.id,
        packageName: 'com.example.empty',
        appLabel: 'No Permissions App',
        versionName: null,
        snapshotStatus: 'available',
        visibilityScope: 'launcher_query',
        androidSdk: 36,
        capturedAt: capturedAt,
        permissions: const [],
      );
      final includingEmpty = await repository.applicationSnapshots(audit.id);
      expect(includingEmpty, hasLength(2));
      expect(
        includingEmpty
            .singleWhere((item) => item.packageName == 'com.example.empty')
            .permissions,
        isEmpty,
      );
      final rawRows = await db.select(db.applicationSnapshots).get();
      expect(rawRows.first.packageName, isNot('com.example.shop'));
      expect(rawRows.first.appLabel, isNot('Shop Example'));
      await repository.deleteAudit(audit.id);
      expect(await db.select(db.applicationSnapshots).get(), isEmpty);
      expect(await db.select(db.appPermissionSnapshots).get(), isEmpty);
    },
  );

  test('create update close reopen and resume draft locally', () async {
    final audit = await repository.create(
      name: '  Review lokal  ',
      focus: AuditFocus.documents,
    );
    expect(audit.id, matches(RegExp(r'^[0-9a-f-]{36}$')));
    expect(audit.name, 'Review lokal');
    expect(audit.status, AuditStatus.draft);
    final sessionRow = await (db.select(
      db.auditSessions,
    )..where((t) => t.id.equals(audit.id))).getSingle();
    expect(sessionRow.name, isNot('Review lokal'));
    expect(await cipher.decryptText(sessionRow.name), 'Review lokal');
    await repository.update(
      id: audit.id,
      name: 'Diperbarui',
      focus: AuditFocus.visual,
    );
    await db.close();
    db = AppDatabase(NativeDatabase(File('${temp.path}/test.sqlite')));
    repository = AuditRepository(database: db, files: files, cipher: cipher);
    final resumed = await repository.get(audit.id);
    expect(resumed?.name, 'Diperbarui');
    expect(resumed?.focus, AuditFocus.visual);
    expect((await repository.listSessions()).length, 1);
  });

  test(
    'attach persists hash and provenance; segments/evidence detach cascades',
    () async {
      final audit = await repository.create();
      final payload = 'User provided source bytes'.codeUnits;
      final source = await repository.attachSource(
        auditId: audit.id,
        bytes: payload,
        type: AuditSourceType.privacyPolicy,
        mediaType: 'text/plain',
        originalName: 'policy.txt',
        page: 4,
        locator: 'page-4/paragraph-2',
      );
      expect(source.sha256, hasLength(64));
      expect(source.provenancePage, 4);
      final sourceRow = await (db.select(
        db.documentSources,
      )..where((t) => t.id.equals(source.id))).getSingle();
      expect(sourceRow.originalName, isNot('policy.txt'));
      expect(await cipher.decryptText(sourceRow.originalName!), 'policy.txt');
      expect(sourceRow.provenanceLocator, isNot('page-4/paragraph-2'));
      expect(
        await cipher.decryptText(sourceRow.provenanceLocator!),
        'page-4/paragraph-2',
      );
      final encryptedOnDisk = await File(
        '${temp.path}/sources/${source.localPath}',
      ).readAsBytes();
      expect(
        String.fromCharCodes(encryptedOnDisk),
        isNot(contains('User provided source bytes')),
      );
      expect(await repository.readSource(source.id), payload);
      await repository.addSegment(
        sourceId: source.id,
        sequence: 0,
        text: 'Reviewed text',
        page: 4,
      );
      final segmentId = (await db.select(db.documentSegments).getSingle()).id;
      await repository.addEvidence(
        auditId: audit.id,
        sourceId: source.id,
        sourceSha256: source.sha256,
        segmentId: segmentId,
        location: 'page:4',
        quote: 'Reviewed text',
      );
      final segmentRow = await db.select(db.documentSegments).getSingle();
      expect(segmentRow.content, isNot(contains('Reviewed text')));
      expect(await cipher.decryptText(segmentRow.content), 'Reviewed text');
      final evidenceRow = await db.select(db.evidenceReferences).getSingle();
      expect(evidenceRow.quote, isNot(contains('Reviewed text')));
      expect(await cipher.decryptText(evidenceRow.quote!), 'Reviewed text');
      await repository.setSourceReviewStatus(
        source.id,
        SourceReviewStatus.reviewed,
      );
      expect(
        (await repository.sources(audit.id)).single.reviewStatus,
        SourceReviewStatus.reviewed,
      );
      await repository.detachSource(source.id);
      expect(await repository.sources(audit.id), isEmpty);
      expect(await db.select(db.documentSegments).get(), isEmpty);
      expect(await db.select(db.evidenceReferences).get(), isEmpty);
      expect(await files.listStoredRelativePaths(), isEmpty);
    },
  );

  test(
    'imported paragraphs encrypt originals and save edits idempotently',
    () async {
      final audit = await repository.create();
      final source = await repository.attachSource(
        auditId: audit.id,
        bytes: utf8.encode('original source'),
        type: AuditSourceType.terms,
        mediaType: 'text/plain; charset=utf-8',
        sourceUrl: 'https://example.test/terms',
        documentVersion: '2026-11',
        importWarnings: 'OCR needs review',
      );
      expect(source.type, AuditSourceType.terms);
      expect(source.sourceUrl, 'https://example.test/terms');
      expect(source.documentVersion, '2026-11');
      expect(source.importWarnings, 'OCR needs review');
      final segment = ImportedTextSegment(
        sequence: 0,
        text: 'Original paragraph',
        originalText: ' Original paragraph ',
        page: 2,
        startOffset: 4,
        endOffset: 24,
        pageTextSha256: List.filled(64, 'a').join(),
        extractionMethod: 'pdfText',
      );
      await repository.saveImportedSegments(
        sourceId: source.id,
        segments: [segment],
        reviewed: false,
      );
      final firstRows = await db.select(db.documentSegments).get();
      expect(
        firstRows.single.originalContent,
        isNot(contains('Original paragraph')),
      );
      expect(
        await cipher.decryptText(firstRows.single.originalContent!),
        ' Original paragraph ',
      );
      final originalId = firstRows.single.id;
      await repository.saveImportedSegments(
        sourceId: source.id,
        segments: [segment],
        reviewed: false,
      );
      expect(
        (await db.select(db.documentSegments).get()).single.id,
        originalId,
      );
      await repository.updateImportedSegment(
        sourceId: source.id,
        segmentId: originalId,
        text: 'Corrected paragraph',
        reviewed: true,
      );
      final updated = (await repository.documentSegments(source.id)).single;
      expect(updated.text, 'Corrected paragraph');
      expect(updated.originalText, ' Original paragraph ');
      expect(updated.editedAt, isNotNull);
      expect(updated.reviewedAt, isNotNull);
      expect((await repository.source(source.id)).reviewedAt, isNotNull);
    },
  );

  test(
    'delete tombstones session and cascades all records and files',
    () async {
      final audit = await repository.create();
      final source = await repository.attachSource(
        auditId: audit.id,
        bytes: [1, 2, 3],
        type: AuditSourceType.otherDocument,
        mediaType: 'application/octet-stream',
      );
      await repository.addSegment(
        sourceId: source.id,
        sequence: 0,
        text: 'segment',
      );
      await repository.addPermissionSnapshot(
        AppPermissionSnapshot(
          id: 'b8f4a4f2-08ab-4f80-8aa0-fc7f1a95e102',
          auditId: audit.id,
          packageName: 'com.example.app',
          permissionName: 'android.permission.CAMERA',
          grantStatus: 'granted',
          capturedAt: DateTime.utc(2026),
        ),
      );
      final snapshotRow = await db
          .select(db.appPermissionSnapshots)
          .getSingle();
      expect(snapshotRow.packageName, isNot('com.example.app'));
      expect(snapshotRow.permissionName, isNot('android.permission.CAMERA'));
      expect(
        (await repository.permissionSnapshots(audit.id)).single.packageName,
        'com.example.app',
      );
      final uiSource = await repository.attachSource(
        auditId: audit.id,
        bytes: [7, 7],
        type: AuditSourceType.consentUi,
        mediaType: 'image/png',
      );
      await repository.recordUserAction(
        UserAction(
          id: '462d130e-7d4d-4dd4-b060-f4e16d11fa40',
          auditId: audit.id,
          sourceId: uiSource.id,
          actionType: 'source_attached',
          createdAt: DateTime.utc(2026),
          details: 'private action detail',
        ),
      );
      await repository.addReport(
        ReportRecord(
          id: 'e83b1ec4-9db5-4ee5-b8c5-153a9c0dcd43',
          auditId: audit.id,
          status: 'not_generated',
          createdAt: DateTime.utc(2026),
        ),
      );
      final actionRow = await db.select(db.userActions).getSingle();
      expect(actionRow.details, isNot(contains('private action detail')));
      expect(
        await cipher.decryptText(actionRow.details!),
        'private action detail',
      );
      await repository.addUnavailableAnalysis(
        auditId: audit.id,
        sourceIds: [source.id],
      );
      final run = await db.select(db.analysisRuns).getSingle();
      expect(run.status, AnalysisStatus.unavailable.name);
      expect(run.engine, 'none');
      await repository.deleteAudit(audit.id);
      expect(await repository.get(audit.id), isNull);
      expect(await repository.sessionCount(), 0);
      expect(await repository.sources(audit.id), isEmpty);
      expect(await db.select(db.documentSegments).get(), isEmpty);
      expect(await db.select(db.analysisRuns).get(), isEmpty);
      expect(await db.select(db.appPermissionSnapshots).get(), isEmpty);
      expect(await db.select(db.consentUiSources).get(), isEmpty);
      expect(await db.select(db.userActions).get(), isEmpty);
      expect(await db.select(db.reportRecords).get(), isEmpty);
      expect(await db.select(db.pendingFileDeletes).get(), isEmpty);
      expect(await files.listStoredRelativePaths(), isEmpty);
      final tombstone = await (db.select(
        db.auditSessions,
      )..where((t) => t.id.equals(audit.id))).getSingle();
      expect(tombstone.deletedAt, isNotNull);
    },
  );

  test(
    'delete cleanup failure leaves durable tombstone and retry queue',
    () async {
      final audit = await repository.create();
      await repository.attachSource(
        auditId: audit.id,
        bytes: [8, 9],
        type: AuditSourceType.otherDocument,
        mediaType: 'application/octet-stream',
      );
      await db.customStatement(
        "CREATE TRIGGER fail_file_queue BEFORE DELETE ON pending_file_deletes BEGIN SELECT RAISE(ABORT, 'test fail'); END",
      );
      await expectLater(repository.deleteAudit(audit.id), throwsA(anything));
      // The DB transaction itself committed before external file cleanup. The
      // pending file row is retained when cleanup cannot complete.
      expect(await repository.get(audit.id), isNull);
      expect(await db.select(db.pendingFileDeletes).get(), hasLength(1));
      await db.customStatement('DROP TRIGGER fail_file_queue');
      await repository.recoverFileLifecycle();
      expect(await db.select(db.pendingFileDeletes).get(), isEmpty);
      expect(await files.listStoredRelativePaths(), isEmpty);
    },
  );

  test('cascade transaction rollback keeps session and sources when a child delete fails', () async {
    final audit = await repository.create();
    final source = await repository.attachSource(
      auditId: audit.id,
      bytes: [4, 5, 6],
      type: AuditSourceType.otherDocument,
      mediaType: 'application/octet-stream',
    );
    await db.customStatement(
      "CREATE TRIGGER fail_source_delete BEFORE DELETE ON document_sources BEGIN SELECT RAISE(ABORT, 'test rollback'); END",
    );
    await expectLater(repository.deleteAudit(audit.id), throwsA(anything));
    expect(await repository.get(audit.id), isNotNull);
    expect(await repository.sources(audit.id), hasLength(1));
    expect(await db.select(db.pendingFileDeletes).get(), isEmpty);
    expect(await files.read(source.localPath, expectedSha256: source.sha256), [
      4,
      5,
      6,
    ]);
    await db.customStatement('DROP TRIGGER fail_source_delete');
    await repository.deleteAudit(audit.id);
  });

  test('privacy preferences default false and analysis engine never reports success', () async {
    final prefs = await repository.privacyPreferences();
    expect(prefs.cloudOptIn, isFalse);
    expect(prefs.analyticsOptIn, isFalse);
    final updated = await repository.updatePrivacyPreferences(
      cloudOptIn: true,
      analyticsOptIn: false,
    );
    expect(updated.cloudOptIn, isTrue);
    await repository.migratePrivacyPreferences(
      cloudOptIn: false,
      analyticsOptIn: true,
    );
    expect((await repository.privacyPreferences()).cloudOptIn, isFalse);
    expect((await repository.privacyPreferences()).analyticsOptIn, isTrue);
    final audit = await repository.create();
    await repository.addUnavailableAnalysis(
      auditId: audit.id,
      sourceIds: const [],
    );
    final analysis = await db.select(db.analysisRuns).getSingle();
    expect(analysis.status, AnalysisStatus.unavailable.name);
    expect(analysis.reason, 'on_device_model_not_installed');
    expect(analysis.status, isNot(AnalysisStatus.succeeded.name));
    await expectLater(
      db
          .into(db.analysisRuns)
          .insert(
            AnalysisRunsCompanion.insert(
              id: 'bd8cba3e-63f1-4c14-9ce3-388df9980cde',
              auditId: audit.id,
              status: AnalysisStatus.succeeded.name,
              engine: 'none',
              reason: 'invalid',
              sourceIdsJson: '[]',
              createdAt: DateTime.utc(2026),
            ),
          ),
      throwsA(anything),
    );
  });

  test(
    'concurrent creates are unique and validation failures do not mutate DB',
    () async {
      final sessions = await Future.wait(
        List.generate(20, (i) => repository.create(name: 'Audit $i')),
      );
      expect(sessions.map((s) => s.id).toSet(), hasLength(20));
      expect(await repository.sessionCount(), 20);
      await expectLater(repository.create(name: 'x' * 61), throwsArgumentError);
      expect(await repository.sessionCount(), 20);
      await expectLater(
        repository.addSegment(sourceId: 'missing', sequence: 0, text: 'bad'),
        throwsA(anything),
      );
    },
  );

  test('concurrent source attachments and updates serialize safely with cascade delete', () async {
    final audit = await repository.create();
    final sources = await Future.wait(
      List.generate(
        8,
        (index) => repository.attachSource(
          auditId: audit.id,
          bytes: [index + 1, index + 2],
          type: AuditSourceType.otherDocument,
          mediaType: 'application/octet-stream',
        ),
      ),
    );
    expect(sources.map((source) => source.id).toSet(), hasLength(8));
    expect(await repository.sourceCount(audit.id), 8);
    await Future.wait(
      sources.map(
        (source) => repository.setSourceReviewStatus(
          source.id,
          SourceReviewStatus.reviewed,
        ),
      ),
    );
    await repository.deleteAudit(audit.id);
    expect(await repository.sourceCount(audit.id), 0);
    expect(await files.listStoredRelativePaths(), isEmpty);
    expect(await db.select(db.pendingFileDeletes).get(), isEmpty);
  });

  test(
    'missing and corrupted source files are rejected without returning bytes',
    () async {
      final audit = await repository.create();
      final source = await repository.attachSource(
        auditId: audit.id,
        bytes: [1, 2, 3],
        type: AuditSourceType.otherDocument,
        mediaType: 'application/octet-stream',
      );
      final file = File('${temp.path}/sources/${source.localPath}');
      final encrypted = await file.readAsBytes();
      encrypted[encrypted.length - 1] ^= 0xff;
      await file.writeAsBytes(encrypted);
      await expectLater(
        repository.readSource(source.id),
        throwsA(isA<LocalEncryptionAuthenticationException>()),
      );
      await file.delete();
      await expectLater(
        repository.readSource(source.id),
        throwsA(isA<SourceFileMissingException>()),
      );
    },
  );

  test(
    'source file paths reject traversal and raw source content is not logged',
    () async {
      await expectLater(
        files.read('../outside.source', expectedSha256: '0' * 64),
        throwsA(isA<InvalidSourcePathException>()),
      );
      final audit = await repository.create();
      final payload = 'PRIVATE_EVIDENCE_DO_NOT_LOG';
      final logs = <String>[];
      final originalDebugPrint = debugPrint;
      debugPrint = (message, {wrapWidth}) {
        if (message != null) logs.add(message);
      };
      try {
        await repository.attachSource(
          auditId: audit.id,
          bytes: payload.codeUnits,
          type: AuditSourceType.otherDocument,
          mediaType: 'text/plain',
        );
      } finally {
        debugPrint = originalDebugPrint;
      }
      expect(logs.join('\n'), isNot(contains(payload)));
    },
  );

  test(
    'AES-GCM rejects wrong/missing key without resetting valid key material',
    () async {
      final plaintext = 'sensitive local content';
      final encrypted = await cipher.encryptBytes(plaintext.codeUnits);
      final wrongKeyCipher = LocalDataCipher(
        keyProvider: MemoryEncryptionKeyProvider(List.filled(32, 8)),
      );
      await expectLater(
        wrongKeyCipher.decryptBytes(encrypted),
        throwsA(isA<LocalEncryptionAuthenticationException>()),
      );
      await expectLater(
        LocalDataCipher(keyProvider: _MissingKeyProvider())
            .decryptBytes(encrypted),
        throwsA(isA<LocalEncryptionKeyException>()),
      );
      expect(await cipher.decryptBytes(encrypted), plaintext.codeUnits);
    },
  );

  test('startup lifecycle recovery removes orphan sources and interrupted temp files', () async {
    final orphan = await files.write([3, 1, 4]);
    final interrupted = File('${temp.path}/sources/orphan.tmp-interrupted');
    await interrupted.parent.create(recursive: true);
    await interrupted.writeAsBytes([1, 2]);
    await repository.recoverFileLifecycle();
    expect(await files.listStoredRelativePaths(), isEmpty);
    expect(await interrupted.exists(), isFalse);
    expect(orphan.relativePath, isNotEmpty);
  });
}

class _MissingKeyProvider implements LocalEncryptionKeyProvider {
  @override
  Future<List<int>> getOrCreateKey() async =>
      throw const LocalEncryptionKeyException();
}
