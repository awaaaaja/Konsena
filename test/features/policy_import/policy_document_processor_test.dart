import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:konsena_ai/features/policy_import/data/policy_document_processor.dart';
import 'package:konsena_ai/features/policy_import/domain/policy_import_models.dart';
import 'package:pdfium_flutter/pdfium_flutter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const pathProviderChannel = MethodChannel('plugins.flutter.io/path_provider');
  Link? testPdfiumLink;
  setUpAll(() {
    if (Platform.isLinux) {
      final buildRoot = Directory(
        '.dart_tool/hooks_runner/shared/pdfium_dart/build',
      );
      final pdfium = buildRoot
          .listSync(recursive: true)
          .whereType<File>()
          .where((file) => file.path.endsWith('/linux-x64/libpdfium.so'))
          .firstOrNull;
      if (pdfium != null) {
        loadPdfium(modulePath: pdfium.path);
        // Flutter's VM test runner does not publish the code-assets manifest
        // to the PDFium worker isolate. Make the hook-built test library
        // discoverable at the exact sibling location used by pdfium_dart.
        final target = File(
          '${File(Platform.resolvedExecutable).parent.path}/lib/libpdfium.so',
        );
        if (!target.existsSync()) {
          target.parent.createSync(recursive: true);
          final link = Link(target.path);
          link.createSync(pdfium.absolute.path);
          testPdfiumLink = link;
        }
      }
    }
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathProviderChannel, (call) async {
          if (call.method == 'getTemporaryDirectory') {
            return Directory.systemTemp.path;
          }
          return null;
        });
  });
  tearDownAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathProviderChannel, null);
    testPdfiumLink?.deleteSync();
  });

  group('PolicyDocumentProcessor', () {
    test(
      'QA PDF and TXT pairs retain their opposite permission clauses',
      () async {
        const root = 'docs/phase-reports/simulasi-pindai';
        final manifest = jsonDecode(
          File('$root/manifest.json').readAsStringSync(),
        ) as Map<String, dynamic>;
        final processor = PolicyDocumentProcessor();
        for (final id in ['D01', 'D02', 'D03', 'D04']) {
          final fixture = manifest[id] as Map<String, dynamic>;
          final name = fixture['file'] as String;
          final result = await processor.processFile(
            bytes: File('$root/$name').readAsBytesSync(),
            fileName: name,
            cancellation: PolicyImportCancellationToken(),
          );
          final extracted = result.segments.map((s) => s.text).join(' ');
          expect(extracted, contains(fixture['clause'] as String), reason: id);
          expect(result.pages, hasLength(1), reason: id);
        }
      },
    );

    test(
      'text file preserves page offsets, original text and paragraph breaks',
      () async {
        const raw =
            'Bagian pertama\r\nbaris kedua.\r\n\r\nBagian kedua dengan bukti.';
        final processor = PolicyDocumentProcessor();
        final result = await processor.processFile(
          bytes: Uint8List.fromList(utf8.encode(raw)),
          fileName: 'policy.txt',
          cancellation: PolicyImportCancellationToken(),
        );

        expect(result.pages, hasLength(1));
        expect(result.segments, hasLength(2));
        expect(
          result.segments[0].originalText,
          'Bagian pertama\r\nbaris kedua.',
        );
        expect(result.segments[0].text, 'Bagian pertama baris kedua.');
        expect(
          raw.substring(
            result.segments[0].startOffset,
            result.segments[0].endOffset,
          ),
          result.segments[0].originalText,
        );
        expect(
          result.segments[0].pageTextSha256,
          result.pages.single.textSha256,
        );
        expect(result.segments[1].sequence, 1);
      },
    );

    test(
      'UTF-16 and legacy Latin-1 text decode without losing Indonesian text',
      () async {
        final utf16le = Uint8List.fromList([
          0xff,
          0xfe,
          ...'Kebijakan privasi berlaku.'.codeUnits.expand(
            (c) => [c & 0xff, c >> 8],
          ),
        ]);
        final latin1 = Uint8List.fromList(
          latin1Encode('Kebijakan berlaku untuk pengguna.'),
        );
        final processor = PolicyDocumentProcessor();
        final first = await processor.processFile(
          bytes: utf16le,
          fileName: 'utf16.txt',
          cancellation: PolicyImportCancellationToken(),
        );
        final second = await processor.processFile(
          bytes: latin1,
          fileName: 'legacy.txt',
          cancellation: PolicyImportCancellationToken(),
        );
        expect(first.segments.single.text, 'Kebijakan privasi berlaku.');
        expect(
          second.segments.single.text,
          'Kebijakan berlaku untuk pengguna.',
        );
      },
    );

    test(
      'image is OCRed and marked for review with source bounding box',
      () async {
        final processor = PolicyDocumentProcessor(
          ocrPage: (bytes, {width, height}) async => const OcrPageText(
            'Kebijakan data pengguna.',
            blocks: [
              OcrTextBlock(
                text: 'Kebijakan data pengguna.',
                bounds: Rect.fromLTRB(4, 8, 100, 40),
                confidence: 0.81,
              ),
            ],
          ),
        );
        final result = await processor.processFile(
          bytes: Uint8List.fromList([137, 80, 78, 71, 13, 10, 26, 10, 1]),
          fileName: 'scan.png',
          cancellation: PolicyImportCancellationToken(),
        );

        expect(result.pages.single.method, PolicyExtractionMethod.ocrImage);
        expect(result.warnings, isNotEmpty);
        expect(result.segments.single.confidence, 0.81);
        expect(result.segments.single.boundingBoxJson, contains('"left":4.0'));
      },
    );

    test('born-digital PDF uses text layer and does not call OCR', () async {
      var ocrCalls = 0;
      final processor = PolicyDocumentProcessor(
        ocrPage: (bytes, {width, height}) async {
          ocrCalls++;
          return const OcrPageText('should not be used');
        },
      );
      final result = await processor.processFile(
        bytes: _textPdf(
          'Privacy Policy. We retain personal data only as needed.',
        ),
        fileName: 'privacy.pdf',
        cancellation: PolicyImportCancellationToken(),
      );
      expect(result.pages.single.method, PolicyExtractionMethod.pdfText);
      expect(result.segments, isNotEmpty);
      expect(result.segments.single.text, contains('Privacy Policy'));
      expect(result.segments.single.page, 1);
      expect(ocrCalls, 0);
    });

    test('scanned PDF image page renders and uses OCR fallback', () async {
      final processor = PolicyDocumentProcessor(
        ocrPage: (bytes, {width, height}) async {
          expect(width, greaterThan(0));
          expect(height, greaterThan(0));
          expect(width, lessThanOrEqualTo(2048));
          expect(height, lessThanOrEqualTo(2048));
          return const OcrPageText(
            'Kebijakan privasi hasil scan.',
            blocks: [
              OcrTextBlock(
                text: 'Kebijakan privasi hasil scan.',
                bounds: Rect.fromLTRB(2, 2, 180, 30),
                confidence: 0.75,
              ),
            ],
          );
        },
      );
      final result = await processor.processFile(
        bytes: await _scannedPdf(),
        fileName: 'scanned.pdf',
        cancellation: PolicyImportCancellationToken(),
      );
      expect(result.pages.single.method, PolicyExtractionMethod.ocrPdf);
      expect(result.segments.single.text, 'Kebijakan privasi hasil scan.');
      expect(result.segments.single.confidence, 0.75);
      expect(result.warnings, isNotEmpty);
    });

    test(
      'password protected PDF is recoverable and never accepts wrong password',
      () async {
        final processor = PolicyDocumentProcessor(
          ocrPage: (bytes, {width, height}) async => const OcrPageText(''),
        );
        final bytes = await File(
          'test/features/policy_import/fixtures/password_protected.pdf',
        ).readAsBytes();
        Future<PolicyImportException> run(String? password) async {
          try {
            await processor.processFile(
              bytes: bytes,
              fileName: 'locked.pdf',
              cancellation: PolicyImportCancellationToken(),
              pdfPassword: password,
            );
          } on PolicyImportException catch (error) {
            return error;
          }
          throw StateError('expected a password error');
        }

        expect((await run(null)).code, 'password');
        expect((await run('wrong-password')).code, 'password');
        final unlocked = await processor.processFile(
          bytes: bytes,
          fileName: 'locked.pdf',
          cancellation: PolicyImportCancellationToken(),
          pdfPassword: 'user',
        );
        expect(unlocked.kind, PolicyImportKind.pdf);
      },
    );

    test(
      'PDF over the product page cap is rejected before extraction',
      () async {
        final error = await _captureImportError(
          PolicyDocumentProcessor().processFile(
            bytes: _blankPdf(PolicyDocumentProcessor.maxPdfPages + 1),
            fileName: 'long-policy.pdf',
            cancellation: PolicyImportCancellationToken(),
          ),
        );
        expect(error.code, 'page_limit');
      },
    );

    test('invalid image data returns a recoverable error', () async {
      final error = await _captureImportError(
        PolicyDocumentProcessor().processFile(
          bytes: Uint8List.fromList([137, 80, 78, 71, 13, 10, 26, 10, 1]),
          fileName: 'broken.png',
          cancellation: PolicyImportCancellationToken(),
        ),
      );
      expect(error.code, 'invalid_image');
    });

    test('pasted text supports Indonesian and English in one source', () async {
      final result = await PolicyDocumentProcessor().processPastedText(
        text: 'Kami memproses data Anda.\n\nWe retain personal data only as needed.',
        cancellation: PolicyImportCancellationToken(),
      );
      expect(result.segments, hasLength(2));
      expect(result.segments.last.text, contains('We retain personal data'));
      expect(result.segments.every((segment) => segment.page == 1), isTrue);
      expect(
        result.segments.every(
          (segment) => segment.extractionMethod == 'pastedText',
        ),
        isTrue,
      );
    });

    test(
      'empty, corrupt signature, unsupported and oversize errors are typed',
      () async {
        final processor = PolicyDocumentProcessor();
        Future<PolicyImportException> capture(
          Future<void> Function() action,
        ) async {
          try {
            await action();
          } on PolicyImportException catch (error) {
            return error;
          }
          throw StateError('expected typed import error');
        }

        expect(
          (await capture(
            () => processor.processFile(
              bytes: Uint8List(0),
              fileName: 'empty.pdf',
              cancellation: PolicyImportCancellationToken(),
            ),
          )).code,
          'empty',
        );
        expect(
          (await capture(
            () => processor.processFile(
              bytes: Uint8List.fromList(utf8.encode('%PDF-corrupt')),
              fileName: 'corrupt.pdf',
              cancellation: PolicyImportCancellationToken(),
            ),
          )).code,
          'corrupt_pdf',
        );
        expect(
          (await capture(
            () => processor.processFile(
              bytes: Uint8List.fromList([1, 2, 3, 4]),
              fileName: 'unknown.bin',
              cancellation: PolicyImportCancellationToken(),
            ),
          )).code,
          'unsupported',
        );
        expect(
          (await capture(
            () => processor.processFile(
              bytes: Uint8List(PolicyDocumentProcessor.maxPdfBytes + 1)
                ..setRange(0, 5, ascii.encode('%PDF-')),
              fileName: 'large.pdf',
              cancellation: PolicyImportCancellationToken(),
            ),
          )).code,
          'oversize',
        );
      },
    );

    test('cancellation before parsing is honored', () async {
      final token = PolicyImportCancellationToken()..cancel();
      await expectLater(
        PolicyDocumentProcessor().processPastedText(
          text: 'Some legal text',
          cancellation: token,
        ),
        throwsA(isA<PolicyImportCancelled>()),
      );
    });
  });
}

List<int> latin1Encode(String value) => value.codeUnits;

Future<PolicyImportException> _captureImportError(
  Future<Object?> operation,
) async {
  try {
    await operation;
  } on PolicyImportException catch (error) {
    return error;
  }
  throw StateError('expected a typed policy-import error');
}

Uint8List _textPdf(String text) {
  final escaped = text
      .replaceAll(r'\', r'\\')
      .replaceAll('(', r'\(')
      .replaceAll(')', r'\)');
  final content = 'BT /F1 12 Tf 45 700 Td ($escaped) Tj ET';
  return _buildPdf([
    '<< /Type /Catalog /Pages 2 0 R >>',
    '<< /Type /Pages /Kids [3 0 R] /Count 1 >>',
    '<< /Type /Page /Parent 2 0 R /MediaBox [0 0 595 842] '
        '/Resources << /Font << /F1 5 0 R >> >> /Contents 4 0 R >>',
    '<< /Length ${ascii.encode(content).length} >>\nstream\n$content\nendstream',
    '<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica >>',
  ]);
}

Uint8List _blankPdf(int pageCount) => _buildPdf([
  '<< /Type /Catalog /Pages 2 0 R >>',
  '<< /Type /Pages /Kids [${List.generate(pageCount, (i) => '${i + 3} 0 R').join(' ')}] /Count $pageCount >>',
  for (var i = 0; i < pageCount; i++)
    '<< /Type /Page /Parent 2 0 R /MediaBox [0 0 200 300] >>',
]);

Future<Uint8List> _scannedPdf() async {
  final sample = img.Image(width: 220, height: 80);
  img.fill(sample, color: img.ColorRgb8(255, 255, 255));
  final jpeg = img.encodeJpg(sample, quality: 75);
  final pageStream = ascii.encode('q 220 0 0 80 0 0 cm /Im0 Do Q');
  final imageBody = BytesBuilder()
    ..add(
      ascii.encode(
        '<< /Type /XObject /Subtype /Image /Width 220 /Height 80 '
        '/ColorSpace /DeviceRGB /BitsPerComponent 8 /Filter /DCTDecode '
        '/Length ${jpeg.length} >>\nstream\n',
      ),
    )
    ..add(jpeg)
    ..add(ascii.encode('\nendstream'));
  final pageContent = BytesBuilder()
    ..add(ascii.encode('<< /Length ${pageStream.length} >>\nstream\n'))
    ..add(pageStream)
    ..add(ascii.encode('\nendstream'));
  return _buildPdfBytes([
    ascii.encode('<< /Type /Catalog /Pages 2 0 R >>'),
    ascii.encode('<< /Type /Pages /Kids [3 0 R] /Count 1 >>'),
    ascii.encode(
      '<< /Type /Page /Parent 2 0 R /MediaBox [0 0 220 80] '
      '/Resources << /XObject << /Im0 5 0 R >> >> /Contents 4 0 R >>',
    ),
    pageContent.takeBytes(),
    imageBody.takeBytes(),
  ]);
}

Uint8List _buildPdf(List<String> objects) =>
    _buildPdfBytes(objects.map(ascii.encode).toList());

Uint8List _buildPdfBytes(List<List<int>> objects) {
  final builder = BytesBuilder(copy: false)..add(ascii.encode('%PDF-1.4\n'));
  final offsets = <int>[];
  for (var index = 0; index < objects.length; index++) {
    offsets.add(builder.length);
    builder
      ..add(ascii.encode('${index + 1} 0 obj\n'))
      ..add(objects[index])
      ..add(ascii.encode('\nendobj\n'));
  }
  final xrefOffset = builder.length;
  final xref = StringBuffer(
    'xref\n0 ${objects.length + 1}\n0000000000 65535 f \n',
  );
  for (final offset in offsets) {
    xref.write('${offset.toString().padLeft(10, '0')} 00000 n \n');
  }
  xref.write(
    'trailer\n<< /Size ${objects.length + 1} /Root 1 0 R >>\n'
    'startxref\n$xrefOffset\n%%EOF\n',
  );
  builder.add(ascii.encode(xref.toString()));
  return builder.takeBytes();
}
