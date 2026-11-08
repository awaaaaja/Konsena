import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:konsena_ai/data/audit/audit_repository.dart';
import 'package:konsena_ai/data/audit/local_data_cipher.dart';
import 'package:konsena_ai/data/audit/local_source_file_store.dart';
import 'package:konsena_ai/data/local/app_database.dart';
import 'package:konsena_ai/domain/audit/audit_entities.dart';
import 'package:konsena_ai/features/policy_import/presentation/policy_import_pages.dart';

class _ReviewRepository extends AuditRepository {
  _ReviewRepository(AppDatabase db, LocalDataCipher cipher)
    : super(
        database: db,
        files: LocalSourceFileStore(root: Directory.systemTemp, cipher: cipher),
        cipher: cipher,
      );

  String text = 'Klausul asli.';
  bool reviewed = false;
  bool failSave = false;
  final now = DateTime.utc(2026, 11, 8);

  @override
  Future<DocumentSource> source(String sourceId) async => DocumentSource(
    id: sourceId,
    auditId: 'audit',
    type: AuditSourceType.privacyPolicy,
    reviewStatus: reviewed
        ? SourceReviewStatus.reviewed
        : SourceReviewStatus.needsReview,
    lifecycle: SourceLifecycle.active,
    sha256: '0' * 64,
    localPath: 'unused',
    mediaType: 'text/plain',
    byteLength: 1,
    createdAt: now,
    updatedAt: now,
  );

  @override
  Future<List<DocumentSegment>> documentSegments(String sourceId) async => [
    DocumentSegment(
      id: 'segment',
      sourceId: sourceId,
      sequence: 0,
      text: text,
      reviewedAt: reviewed ? now : null,
    ),
  ];

  @override
  Future<void> updateImportedSegment({
    required String sourceId,
    required String segmentId,
    required String text,
    required bool reviewed,
  }) async {
    if (failSave) throw StateError('fixture write failure');
    this.text = text;
    this.reviewed = reviewed;
  }
}

void main() {
  testWidgets('S11 shows saved state until the user edits again', (
    tester,
  ) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repo = _ReviewRepository(
      db,
      LocalDataCipher(
        keyProvider: MemoryEncryptionKeyProvider(List.filled(32, 8)),
      ),
    );
    Widget page() => MaterialApp(
      home: PolicyReviewPage(sourceId: 'source', repository: repo),
    );
    final save = find.text('Simpan koreksi dan tandai ditinjau');
    final saved = find.text('Tersimpan dan ditinjau');
    await tester.pumpWidget(page());
    await tester.pumpAndSettle();
    await tester.tap(save);
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<FilledButton>(
            find.ancestor(of: saved, matching: find.byType(FilledButton)),
          )
          .onPressed,
      isNull,
    );
    expect(repo.reviewed, isTrue);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(page());
    await tester.pumpAndSettle();
    expect(saved, findsOneWidget);
    await tester.enterText(find.byType(TextField), 'Klausul diperbarui.');
    await tester.pumpAndSettle();
    expect(saved, findsNothing);
    repo.failSave = true;
    await tester.tap(save);
    await tester.pumpAndSettle();
    expect(saved, findsNothing);
    expect(find.textContaining('Perubahan belum tersimpan'), findsOneWidget);
    expect(repo.text, 'Klausul asli.');
    repo.failSave = false;
    await tester.tap(save);
    await tester.pumpAndSettle();
    expect(saved, findsOneWidget);
    expect(repo.text, 'Klausul diperbarui.');
  });

  testWidgets('S25 asks for the audit before showing document fields', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: PolicyDocumentTypePage(auditId: null)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Pilih audit tujuan'), findsOneWidget);
    expect(find.text('Buat audit baru'), findsOneWidget);
    expect(find.text('Privacy Policy'), findsNothing);
    expect(find.text('Lanjut ke impor'), findsNothing);
  });

  testWidgets('S07 without context offers a path to choose the destination', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: PolicyImportPage(auditId: null, type: null, repository: null),
      ),
    );
    expect(find.text('Pilih audit dan jenis dokumen'), findsOneWidget);
    expect(find.text('Pilih PDF, JPG, PNG, atau TXT'), findsNothing);
    expect(find.text('Proses teks tempel'), findsNothing);
  });
}
