import 'dart:convert';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:konsena_ai/app/app_router.dart';
import 'package:konsena_ai/data/audit/audit_repository.dart';
import 'package:konsena_ai/data/audit/local_data_cipher.dart';
import 'package:konsena_ai/data/audit/local_source_file_store.dart';
import 'package:konsena_ai/data/local/app_database.dart';
import 'package:konsena_ai/domain/audit/audit_entities.dart';
import 'package:konsena_ai/features/consent_ui/domain/screenshot_review.dart';
import 'package:konsena_ai/features/consent_ui/presentation/screenshot_pages.dart';
import 'package:konsena_ai/features/live_scan/domain/live_scan_stitcher.dart';
import 'package:konsena_ai/features/policy_import/presentation/policy_import_pages.dart';

class _ScanRepo extends AuditRepository {
  _ScanRepo(AppDatabase db, LocalDataCipher cipher)
    : super(
        database: db,
        files: LocalSourceFileStore(root: Directory.systemTemp, cipher: cipher),
        cipher: cipher,
      ) {
    audits['audit-a'] = _audit(
      'audit-a',
      'Audit aplikasi A',
      AuditFocus.combined,
    );
  }

  final date = DateTime.utc(2026, 11, 8);
  final audits = <String, AuditSession>{};
  String? attachedTo;
  AuditSourceType? attachedType;
  String? attachedText;
  String? attachedName;
  String? attachedMediaType;
  bool reviewed = false;
  String savedText = '';
  String originalText = '';
  List<int> screenshotBytes = [];
  ScreenshotReview? screenshotReview;

  AuditSession _audit(String id, String name, AuditFocus focus) => AuditSession(
    id: id,
    name: name,
    focus: focus,
    status: AuditStatus.draft,
    createdAt: date,
    updatedAt: date,
  );

  @override
  Future<AuditSession> create({
    String name = '',
    AuditFocus focus = AuditFocus.combined,
  }) async => audits['audit-b'] = _audit('audit-b', name, focus);

  @override
  Future<AuditSession?> get(String id) async => audits[id];

  @override
  Future<List<AuditSession>> listSessions() async => audits.values.toList();

  @override
  Future<List<ApplicationSnapshotRecord>> applicationSnapshots(
    String auditId,
  ) async => [];

  @override
  Future<List<DocumentSource>> sources(String auditId) async =>
      attachedTo == auditId ? [await source('doc')] : [];

  @override
  Future<DocumentSource> source(String sourceId) async => DocumentSource(
    id: 'doc',
    auditId: attachedTo!,
    type: attachedType!,
    lifecycle: SourceLifecycle.active,
    reviewStatus: reviewed
        ? SourceReviewStatus.reviewed
        : SourceReviewStatus.pending,
    originalName: attachedName,
    sha256: 'f' * 64,
    localPath: 'unused',
    mediaType: attachedMediaType!,
    byteLength: attachedText!.length,
    createdAt: date,
    updatedAt: date,
  );

  @override
  Future<DocumentSource> attachSource({
    required String auditId,
    required List<int> bytes,
    required AuditSourceType type,
    required String mediaType,
    String? originalName,
    String? language,
    int? page,
    int? frame,
    String? locator,
    String? sourceUrl,
    String? documentVersion,
    String? importWarnings,
  }) async {
    attachedTo = auditId;
    attachedType = type;
    attachedName = originalName;
    attachedMediaType = mediaType;
    attachedText = utf8.decode(bytes);
    return source('doc');
  }

  @override
  Future<void> updateImportWarnings({
    required String sourceId,
    required List<String> warnings,
  }) async {}

  @override
  Future<List<int>> readSource(String sourceId) async => screenshotBytes;

  @override
  Future<List<({ScreenshotReview review, DateTime at})>> screenshotHistory(
    String auditId,
    String sourceId,
  ) async => [
    if (screenshotReview case final review?) (review: review, at: date),
  ];

  @override
  Future<void> saveScreenshotReview({
    required String auditId,
    required String sourceId,
    required ScreenshotReview review,
  }) async {
    screenshotReview = review;
    reviewed = true;
  }

  @override
  Future<void> saveImportedSegments({
    required String sourceId,
    required List<ImportedTextSegment> segments,
    required bool reviewed,
  }) async {
    savedText = segments.single.text;
    originalText = segments.single.originalText;
    this.reviewed = reviewed;
  }

  @override
  Future<List<DocumentSegment>> documentSegments(String sourceId) async => [
    DocumentSegment(
      id: 'segment',
      sourceId: sourceId,
      sequence: 0,
      text: savedText,
      originalText: originalText,
      reviewedAt: reviewed ? date : null,
    ),
  ];

  @override
  Future<void> updateImportedSegment({
    required String sourceId,
    required String segmentId,
    required String text,
    required bool reviewed,
  }) async {
    savedText = text;
    this.reviewed = reviewed;
  }
}

Future<(_ScanRepo, GoRouter)> _start(
  WidgetTester tester, {
  String route = '/scan',
}) async {
  tester.view.physicalSize = const Size(393, 852);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final db = AppDatabase(NativeDatabase.memory());
  addTearDown(db.close);
  final repo = _ScanRepo(
    db,
    LocalDataCipher(
      keyProvider: MemoryEncryptionKeyProvider(List.filled(32, 7)),
    ),
  );
  final router = createAppRouter(auditRepository: repo, initialLocation: route);
  addTearDown(router.dispose);
  await tester.pumpWidget(MaterialApp.router(routerConfig: router));
  await tester.pumpAndSettle();
  return (repo, router);
}

Future<void> _tap(WidgetTester tester, String label) async {
  final text = find.text(label);
  if (text.evaluate().isEmpty) {
    await tester.scrollUntilVisible(text, 150);
  }
  final finder = text.last;
  await Scrollable.ensureVisible(tester.element(finder), alignment: .5);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    'screenshot can create a named audit and Back returns to Pindai',
    (tester) async {
      final (repo, _) = await _start(tester);
      await _tap(tester, 'Screenshot persetujuan');
      await _tap(tester, 'Buat audit baru');
      await tester.enterText(find.byType(TextField), 'Audit visual baru');
      await _tap(tester, 'Buat dan lanjutkan');
      expect(repo.audits['audit-b']?.focus, AuditFocus.visual);
      expect(find.text('Audit visual baru'), findsOneWidget);
      expect(
        tester
            .widget<ScreenshotImportPage>(find.byType(ScreenshotImportPage))
            .auditId,
        'audit-b',
      );
      expect(find.text('Pilih PNG / JPEG'), findsOneWidget);

      await tester.tap(find.byTooltip('Kembali'));
      await tester.pumpAndSettle();
      expect(find.text('Pindai Sumber'), findsOneWidget);
    },
  );

  testWidgets(
    'document flow saves a reviewed paste and opens the chosen audit',
    (tester) async {
      final (repo, router) = await _start(tester);
      await _tap(tester, 'Dokumen atau teks');
      expect(find.text('Lanjut ke impor'), findsNothing);
      await _tap(tester, 'Audit aplikasi A');
      final next = find.widgetWithText(FilledButton, 'Lanjut ke impor');
      expect(tester.widget<FilledButton>(next).onPressed, isNull);
      await _tap(tester, 'Terms of Service');
      await _tap(tester, 'Lanjut ke impor');
      expect(find.text('Audit aplikasi A'), findsOneWidget);
      await tester.enterText(
        find.byType(TextField),
        'Aplikasi menyimpan data selama 30 hari.',
      );
      await _tap(tester, 'Proses teks tempel');
      expect(repo.attachedTo, 'audit-a');
      expect(repo.attachedType, AuditSourceType.terms);
      expect(find.text('Review Teks'), findsOneWidget);

      await tester.enterText(
        find.byType(TextField),
        'Aplikasi menyimpan data selama 7 hari.',
      );
      await _tap(tester, 'Kembali ke audit');
      expect(find.text('Buang perubahan teks?'), findsOneWidget);
      await _tap(tester, 'Lanjut edit');
      await _tap(tester, 'Simpan koreksi dan tandai ditinjau');
      expect(repo.savedText, contains('7 hari'));
      expect(find.text('Tersimpan dan ditinjau'), findsOneWidget);
      await _tap(tester, 'Tambah sumber lain');
      expect(find.text('Pindai Sumber'), findsOneWidget);
      await _tap(tester, 'Screenshot persetujuan');
      expect(find.text('Audit aplikasi A'), findsOneWidget);
      expect(find.text('Pilih audit tujuan'), findsNothing);
      for (var i = 0; i < 2; i++) {
        await tester.tap(find.byTooltip('Kembali'));
        await tester.pumpAndSettle();
      }
      await _tap(tester, 'Buka audit');
      expect(
        router.routeInformationProvider.value.uri.path,
        '/audit/audit-a/sources',
      );
    },
  );

  testWidgets(
    'LiveScan requires a destination and preserves it in permission recovery',
    (tester) async {
      await _start(tester, route: '/scan/camera/live');
      expect(find.text('Panduan LiveScan'), findsOneWidget);
      await _tap(tester, 'Audit aplikasi A');
      await _tap(tester, 'Siapkan kamera');
      await _tap(tester, 'Bantuan izin kamera');
      await _tap(tester, 'Impor dokumen sebagai alternatif');
      expect(
        tester
            .widget<PolicyDocumentTypePage>(find.byType(PolicyDocumentTypePage))
            .auditId,
        'audit-a',
      );
      expect(find.text('Audit aplikasi A'), findsOneWidget);
    },
  );

  final cases = jsonDecode(
    File('docs/phase-reports/simulasi-pindai/manifest.json').readAsStringSync(),
  ) as Map<String, dynamic>;
  for (final id in ['L01', 'L02']) {
    testWidgets('$id LiveScan joins frames and preserves OCR and correction', (
      tester,
    ) async {
      final (repo, router) = await _start(tester);
      final frameRows = (cases[id] as Map<String, dynamic>)['frames'] as List;
      final stitcher = LiveScanStitcher();
      for (final (index, rows) in frameRows.indexed) {
        stitcher.add(
          LiveScanObservation(
            frame: index + 1,
            capturedAt: repo.date.add(Duration(seconds: index)),
            text: (rows as List).join('\n'),
            roi: const [0, 0, 1, 1],
            confidence: .91,
          ),
        );
      }
      final result = stitcher.build();
      expect(result.gaps, isEmpty);
      expect(result.observations, hasLength(2));
      expect('Kendali Data dan Izin'.allMatches(result.text), hasLength(1));
      router.push('/scan/camera/merge?auditId=audit-a', extra: result);
      await tester.pumpAndSettle();
      final corrected = result.text.replaceFirst(
        'Kendali Data dan Izin',
        'Kendali data dan izin.',
      );
      await tester.enterText(find.byType(TextField), corrected);
      await _tap(tester, 'Kembali ke kamera');
      expect(find.text('Buang koreksi LiveScan?'), findsOneWidget);
      await _tap(tester, 'Lanjut edit');
      await tester.tap(find.byType(DropdownButtonFormField<AuditSourceType>));
      await tester.pumpAndSettle();
      await _tap(tester, 'Privacy Policy');
      await _tap(
        tester,
        'Saya sudah memeriksa teks dan bagian yang mungkin terlewat',
      );
      await _tap(tester, 'Simpan hasil tinjauan');
      expect(repo.attachedTo, 'audit-a');
      expect(repo.attachedText, result.text);
      expect(repo.savedText, corrected);
      expect(repo.originalText, result.text);
      expect(repo.reviewed, isTrue);
      expect(find.text('Tersimpan dan ditinjau'), findsOneWidget);
    });
  }

  testWidgets('pending screenshot must open review before analysis', (
    tester,
  ) async {
    final (repo, router) = await _start(tester);
    final fixture = (cases['S02'] as Map<String, dynamic>)['file'] as String;
    repo
      ..attachedTo = 'audit-a'
      ..attachedType = AuditSourceType.consentUi
      ..attachedName = 'Pilihan cookie'
      ..attachedMediaType = 'image/png'
      ..attachedText = ''
      ..screenshotBytes = File('docs/phase-reports/simulasi-pindai/$fixture')
          .readAsBytesSync();
    router.go('/audit/audit-a/sources');
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.text('Pilihan cookie'), 200);
    expect(find.byTooltip('Tandai sudah ditinjau'), findsNothing);
    expect(find.byTooltip('Hapus sumber'), findsOneWidget);
    await _tap(tester, 'Pilihan cookie');
    expect(find.text('Area yang diperiksa'), findsOneWidget);
    await _tap(tester, 'Putar 90°');
    await tester.tap(find.byTooltip('Kembali'));
    await tester.pumpAndSettle();
    expect(find.text('Tinggalkan perubahan?'), findsOneWidget);
    await _tap(tester, 'Lanjut edit');
    await _tap(tester, 'Tambah anotasi manual');
    await tester.enterText(
      find.widgetWithText(TextField, 'Label manual'),
      'Pilihan menolak tersembunyi',
    );
    await _tap(tester, 'Terapkan');
    await _tap(tester, 'Simpan dan buka audit');
    expect(repo.screenshotReview?.quarterTurns, 1);
    expect(
      repo.screenshotReview?.annotations.single.label,
      'Pilihan menolak tersembunyi',
    );
    expect(repo.reviewed, isTrue);
    await tester.pumpAndSettle(const Duration(seconds: 5));
    await _tap(tester, 'Pilihan cookie');
    await tester.scrollUntilVisible(find.text('Tersimpan dan ditinjau'), 180);
    expect(find.text('Simpan dan buka audit'), findsNothing);
    await _tap(tester, 'Buka audit');
    expect(find.text('Workspace audit'), findsOneWidget);
  });
}
