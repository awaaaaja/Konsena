import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:konsena_ai/app/app_router.dart';
import 'package:konsena_ai/data/audit/audit_repository.dart';
import 'package:konsena_ai/data/audit/local_data_cipher.dart';
import 'package:konsena_ai/data/audit/local_source_file_store.dart';
import 'package:konsena_ai/data/local/app_database.dart';
import 'package:konsena_ai/domain/audit/audit_entities.dart';
import 'package:konsena_ai/features/audit/presentation/audit_detail_pages.dart';
import 'package:konsena_ai/features/audit/presentation/audit_workspace_page.dart';
import 'package:konsena_ai/features/model_qa/data/onnx_tensor_harness.dart';
import 'package:konsena_ai/features/model_qa/presentation/dark_pattern_qa_panel.dart';
import 'package:konsena_ai/features/model_qa/presentation/nli_qa_panel.dart';

class _EmptyAuditRepo extends AuditRepository {
  _EmptyAuditRepo(AppDatabase db, LocalDataCipher cipher)
    : super(
        database: db,
        files: LocalSourceFileStore(
          root: Directory('/tmp/opencode/unused-route-test'),
          cipher: cipher,
        ),
        cipher: cipher,
      );
  static final date = DateTime.utc(2026, 11, 8);
  @override
  Future<AuditSession?> get(String id) async => id == 'audit_1'
      ? AuditSession(
          id: id,
          name: 'Fixture audit',
          focus: AuditFocus.combined,
          status: AuditStatus.draft,
          createdAt: date,
          updatedAt: date,
        )
      : null;
  @override
  Future<List<DocumentSource>> sources(String auditId) async => [];
  @override
  Future<List<ApplicationSnapshotRecord>> applicationSnapshots(
    String auditId,
  ) async => [];
  @override
  Future<List<EvidenceReference>> evidence(String auditId) async => [];
}

void main() {
  testWidgets(
    'repository-backed empty audit detail routes work at 320dp / 200% and return to workspace',
    (tester) async {
      tester.view.physicalSize = const Size(320, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final cipher = LocalDataCipher(
        keyProvider: MemoryEncryptionKeyProvider(List.filled(32, 7)),
      );
      final repo = _EmptyAuditRepo(db, cipher);
      final router = createAppRouter(
        auditRepository: repo,
        initialLocation: '/audit/audit_1/results',
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: router,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: TextScaler.linear(2)),
            child: child!,
          ),
        ),
      );
      for (final suffix in [
        'results',
        'compare',
        'risk',
        'dark-pattern',
        'actions',
        'report',
        'report/export',
        'evidence/missing',
        'source-match',
      ]) {
        router.go('/audit/audit_1/$suffix');
        await tester.pumpAndSettle();
        expect(find.byType(AuditDetailPage), findsOneWidget, reason: suffix);
        expect(tester.takeException(), isNull, reason: suffix);
        expect(find.byTooltip('Kembali'), findsOneWidget);
        if (suffix == 'results' && OnnxTensorHarness.enabled) {
          await tester.scrollUntilVisible(find.byType(NliQaPanel), 200);
        }
        if (suffix == 'dark-pattern' && OnnxTensorHarness.enabled) {
          await tester.scrollUntilVisible(find.byType(DarkPatternQaPanel), 200);
          expect(
            find.text('Tambahkan screenshot yang bisa dibuka untuk mulai.'),
            findsOneWidget,
          );
          expect(find.text('Periksa area ini'), findsNothing);
        }
        if (suffix == 'dark-pattern') {
          expect(find.text('Screenshot'), findsOneWidget);
          expect(find.text('Tambah screenshot'), findsOneWidget);
          await tester.scrollUntilVisible(find.text('Pemeriksaan AI'), 200);
          await tester.scrollUntilVisible(find.text('Catatan manual'), 200);
          expect(find.byIcon(Icons.edit_note_rounded), findsOneWidget);
          expect(tester.takeException(), isNull);
        }
        expect(
          find.byType(NliQaPanel),
          suffix == 'results' && OnnxTensorHarness.enabled
              ? findsOneWidget
              : findsNothing,
        );
        expect(
          find.byType(DarkPatternQaPanel),
          suffix == 'dark-pattern' && OnnxTensorHarness.enabled
              ? findsOneWidget
              : findsNothing,
        );
      }
      await tester.tap(find.byTooltip('Kembali'));
      await tester.pumpAndSettle();
      expect(find.byType(AuditWorkspacePage), findsOneWidget);
      expect(find.text('Fixture audit'), findsOneWidget);
      await tester.tap(find.byTooltip('Ubah nama audit'));
      await tester.pumpAndSettle();
      expect(find.text('Fixture audit'), findsWidgets);
      await tester.tap(find.text('Batal'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      router.go('/audit/deleted/results');
      await tester.pumpAndSettle();
      expect(
        find.textContaining('Audit atau sumber tidak tersedia'),
        findsOneWidget,
      );
    },
  );
}
