import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../audit/domain/audit_snapshot.dart';

class AuditPdfExport {
  static const channel = MethodChannel('id.konsena/reports');
  static Future<Uint8List> build(AuditSnapshot snapshot) async {
    final font = pw.Font.ttf(
      await rootBundle.load('fonts/PlusJakartaSans-400.ttf'),
    );
    final document = pw.Document();
    // Paragraphs are chunked to prevent a single long OCR paragraph exceeding
    // the page height. Raw originals/screenshots are not embedded by default.
    final lines = <String>[];
    for (final line in snapshot.reportLines) {
      final runes = line.runes.toList();
      for (var offset = 0; offset < runes.length; offset += 600) {
        lines.add(String.fromCharCodes(runes.skip(offset).take(600)));
      }
    }
    for (var start = 0; start < lines.length; start += 15) {
      document.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          maxPages: 200,
          theme: pw.ThemeData.withFont(base: font),
          build: (_) => [
            for (final line in lines.skip(start).take(15))
              pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 6),
                child: pw.Text(line, style: const pw.TextStyle(fontSize: 10)),
              ),
          ],
        ),
      );
    }
    return document.save();
  }

  static Future<void> share(Uint8List bytes) async {
    final result = await channel.invokeMethod<bool>('sharePdf', {
      'bytes': bytes,
    });
    if (result != true) throw StateError('Share unavailable');
  }

  static Future<void> clearCache() async =>
      channel.invokeMethod<void>('clearExportCache');
}
