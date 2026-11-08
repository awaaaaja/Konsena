import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:konsena_ai/domain/audit/audit_entities.dart';
import 'package:konsena_ai/features/audit/domain/audit_snapshot.dart';
import 'package:konsena_ai/features/report/data/audit_pdf_export.dart';
import 'package:konsena_ai/features/model_qa/data/onnx_tensor_harness.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
    'PDF is generated from actual fact snapshot with no model results',
    (tester) async {
      final now = DateTime.utc(2026, 11, 8);
      final snapshot = AuditSnapshot(
        audit: AuditSession(
          id: 'audit',
          name: 'Fixture audit',
          focus: AuditFocus.combined,
          status: AuditStatus.draft,
          createdAt: now,
          updatedAt: now,
        ),
        sources: [],
        apps: [],
        segments: {},
        evidence: [],
        reviews: {},
        generatedAt: now,
      );
      final bytes = await tester.runAsync(() => AuditPdfExport.build(snapshot));
      expect(String.fromCharCodes(bytes!.take(5)), '%PDF-');
      expect(bytes.length, greaterThan(1000));
      expect(
        snapshot.reportLines.join('\n'),
        contains('Analisis AI belum tersedia'),
      );
    },
  );
  test(
    'share channel contains PDF bytes only and cache cleanup is explicit',
    () async {
      final calls = <MethodCall>[];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(AuditPdfExport.channel, (call) async {
            calls.add(call);
            return call.method == 'sharePdf' ? true : null;
          });
      addTearDown(
        () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(AuditPdfExport.channel, null),
      );
      await AuditPdfExport.share(Uint8List.fromList('%PDF-fixture'.codeUnits));
      await AuditPdfExport.clearCache();
      expect(calls.map((c) => c.method), ['sharePdf', 'clearExportCache']);
      expect((calls.first.arguments as Map).keys, ['bytes']);
    },
  );
  test(
    'QA harness defaults off and cannot activate quarantined inference',
    () async {
      expect(OnnxTensorHarness.enabled, isFalse);
      await expectLater(
        const OnnxTensorHarness().run(modelId: 'consent_nli'),
        throwsStateError,
      );
    },
  );
}
