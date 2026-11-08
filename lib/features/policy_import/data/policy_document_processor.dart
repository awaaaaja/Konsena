import 'dart:convert';
import 'dart:math' as math;
import 'dart:ui' show Rect;

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image/image.dart' as img;
import 'package:pdfrx/pdfrx.dart';

import '../../../domain/audit/audit_entities.dart';
import '../domain/policy_import_models.dart';

typedef OcrPage = Future<OcrPageText> Function(
  Uint8List bytes, {
  int? width,
  int? height,
});

class OcrPageText {
  const OcrPageText(this.text, {this.blocks = const []});
  final String text;
  final List<OcrTextBlock> blocks;
}

class OcrTextBlock {
  const OcrTextBlock({
    required this.text,
    required this.bounds,
    this.confidence,
  });
  final String text;
  final Rect bounds;
  final double? confidence;
}

/// Local-only import pipeline. It never writes source content to logs.
class PolicyDocumentProcessor {
  PolicyDocumentProcessor({OcrPage? ocrPage})
    : _ocrPage = ocrPage ?? _recognize;

  static const maxPdfBytes = 25 * 1024 * 1024;
  static const maxImageBytes = 15 * 1024 * 1024;
  static const maxTextBytes = 5 * 1024 * 1024;
  static const maxPdfPages = 100;
  static const maxImagePixels = 8 * 1024 * 1024;
  static const _maxRenderEdge = 2048;

  final OcrPage _ocrPage;

  /// Runs the existing local ML Kit image recognizer without creating an
  /// import/source record. LiveScan uses this for short-lived cropped frames.
  Future<OcrPageText> recognizeImage(Uint8List bytes) => _ocrPage(bytes);

  Future<PolicyImportResult> processFile({
    required Uint8List bytes,
    required String fileName,
    required PolicyImportCancellationToken cancellation,
    void Function(PolicyImportProgress progress)? onProgress,
    String? pdfPassword,
  }) async {
    cancellation.throwIfCancelled();
    if (bytes.isEmpty) {
      throw PolicyImportException('empty', 'Berkas kosong. Pilih berkas lain.');
    }
    final lowerName = fileName.toLowerCase();
    if (_hasPdfSignature(bytes)) {
      if (lowerName.split('.').last != 'pdf') _throwMimeMismatch();
      _enforceLimit(bytes, maxPdfBytes);
      return _processPdf(
        bytes,
        cancellation: cancellation,
        onProgress: onProgress,
        password: pdfPassword,
      );
    }
    if (_hasPngSignature(bytes) || _hasJpegSignature(bytes)) {
      final extension = lowerName.split('.').last;
      if ((_hasPngSignature(bytes) && extension != 'png') ||
          (_hasJpegSignature(bytes) &&
              extension != 'jpg' &&
              extension != 'jpeg')) {
        _throwMimeMismatch();
      }
      _enforceLimit(bytes, maxImageBytes);
      late final OcrPageText text;
      try {
        text = await _ocrPage(bytes);
      } on PolicyImportException {
        rethrow;
      } on Object {
        throw const PolicyImportException(
          'ocr_failed',
          'OCR lokal gagal memproses gambar. Pilih gambar lain atau masukkan teks manual.',
        );
      }
      cancellation.throwIfCancelled();
      if (text.text.trim().isEmpty) {
        throw const PolicyImportException(
          'no_text',
          'Teks tidak terdeteksi. Coba gambar yang lebih jelas atau masukkan teks manual.',
        );
      }
      final page = _pageResult(
        1,
        text.text,
        PolicyExtractionMethod.ocrImage,
        blocks: text.blocks,
        warning: 'Hasil OCR perlu diperiksa dan dikoreksi sebelum digunakan.',
      );
      onProgress?.call(const PolicyImportProgress(completed: 1, total: 1));
      return PolicyImportResult(
        kind: PolicyImportKind.image,
        pages: [page],
        warnings: [page.warning!],
      );
    }
    if (lowerName.endsWith('.txt')) {
      _enforceLimit(bytes, maxTextBytes);
      if (!_looksLikeText(bytes)) {
        throw const PolicyImportException(
          'invalid_text',
          'Berkas TXT berisi format yang tidak dapat dibaca.',
        );
      }
      final text = _decodeText(bytes);
      final page = _pageResult(1, text, PolicyExtractionMethod.textFile);
      onProgress?.call(const PolicyImportProgress(completed: 1, total: 1));
      return PolicyImportResult(
        kind: PolicyImportKind.plainText,
        pages: [page],
        warnings: const [],
      );
    }
    throw const PolicyImportException(
      'unsupported',
      'Format tidak didukung. Pilih PDF, JPG, PNG, atau TXT.',
    );
  }

  Future<PolicyImportResult> processPastedText({
    required String text,
    required PolicyImportCancellationToken cancellation,
  }) async {
    cancellation.throwIfCancelled();
    final bytes = utf8.encode(text);
    if (bytes.isEmpty || text.trim().isEmpty) {
      throw const PolicyImportException(
        'empty',
        'Masukkan teks terlebih dahulu.',
      );
    }
    _enforceLimit(bytes, maxTextBytes);
    final page = _pageResult(1, text, PolicyExtractionMethod.pastedText);
    return PolicyImportResult(
      kind: PolicyImportKind.plainText,
      pages: [page],
      warnings: const [],
    );
  }

  Future<PolicyImportResult> _processPdf(
    Uint8List bytes, {
    required PolicyImportCancellationToken cancellation,
    required void Function(PolicyImportProgress progress)? onProgress,
    required String? password,
  }) async {
    PdfDocument? document;
    try {
      await pdfrxFlutterInitialize();
      var passwordProvided = false;
      document = await PdfDocument.openData(
        bytes,
        sourceName: 'policy-import-${sha256.convert(bytes).toString()}.pdf',
        passwordProvider: () {
          if (passwordProvided) return null;
          passwordProvided = true;
          return password;
        },
        firstAttemptByEmptyPassword: password == null,
        useProgressiveLoading: false,
        maxSizeToCacheOnMemory: 1024 * 1024,
      );
      if (document.pages.isEmpty) {
        throw const PolicyImportException(
          'empty_pdf',
          'PDF tidak memiliki halaman.',
        );
      }
      if (document.pages.length > maxPdfPages) {
        throw const PolicyImportException(
          'page_limit',
          'PDF melebihi batas 100 halaman. Pisahkan dokumen lalu coba lagi.',
        );
      }
      final results = <PolicyPageResult>[];
      for (var index = 0; index < document.pages.length; index++) {
        cancellation.throwIfCancelled();
        final page = document.pages[index];
        final extracted = await page.loadText();
        final raw = extracted?.fullText ?? '';
        final usable = _isValidTextLayer(raw);
        if (usable) {
          results.add(
            _pageResult(index + 1, raw, PolicyExtractionMethod.pdfText),
          );
        } else {
          final image = await _renderBounded(page);
          try {
            cancellation.throwIfCancelled();
            late final OcrPageText recognized;
            try {
              recognized = await _ocrPage(
                image.pixels,
                width: image.width,
                height: image.height,
              );
            } on PolicyImportException {
              rethrow;
            } on Object {
              throw const PolicyImportException(
                'ocr_failed',
                'OCR lokal gagal memproses halaman PDF. Coba ulangi atau masukkan teks manual.',
              );
            }
            cancellation.throwIfCancelled();
            if (recognized.text.trim().isEmpty) {
              results.add(
                _pageResult(
                  index + 1,
                  '',
                  PolicyExtractionMethod.ocrPdf,
                  warning:
                      'Tidak ada teks yang dapat diekstrak dari halaman ini.',
                ),
              );
            } else {
              results.add(
                _pageResult(
                  index + 1,
                  recognized.text,
                  PolicyExtractionMethod.ocrPdf,
                  blocks: recognized.blocks,
                  warning:
                      'OCR perlu diperiksa dan dikoreksi sebelum digunakan.',
                ),
              );
            }
          } finally {
            image.dispose();
          }
        }
        onProgress?.call(
          PolicyImportProgress(
            completed: index + 1,
            total: document.pages.length,
          ),
        );
      }
      return PolicyImportResult(
        kind: PolicyImportKind.pdf,
        pages: results,
        warnings: [
          for (final result in results)
            if (result.warning != null)
              'Halaman ${result.page}: ${result.warning}',
        ],
      );
    } on PolicyImportException {
      rethrow;
    } on PolicyImportCancelled {
      rethrow;
    } on PdfPasswordException {
      throw const PolicyImportException(
        'password',
        'PDF dilindungi kata sandi. Masukkan kata sandi yang benar untuk mencoba lagi.',
      );
    } on PdfException catch (error) {
      throw PolicyImportException(
        error.errorCode == 4 ? 'password' : 'corrupt_pdf',
        error.errorCode == 4
            ? 'PDF dilindungi kata sandi. Masukkan kata sandi yang benar untuk mencoba lagi.'
            : 'PDF tidak dapat dibaca atau rusak. Pastikan berkas benar lalu coba lagi.',
      );
    } on Object {
      throw const PolicyImportException(
        'corrupt_pdf',
        'PDF tidak dapat dibaca atau rusak. Pastikan berkas benar lalu coba lagi.',
      );
    } finally {
      await document?.dispose();
    }
  }

  Future<PdfImage> _renderBounded(PdfPage page) async {
    final scale = math.min(
      1.0,
      _maxRenderEdge / math.max(page.width, page.height),
    );
    final image = await page.render(
      fullWidth: math.max(1, page.width * scale),
      fullHeight: math.max(1, page.height * scale),
    );
    if (image == null || image.width <= 0 || image.height <= 0) {
      throw const PolicyImportException(
        'render_failed',
        'Halaman PDF tidak dapat dirender untuk OCR.',
      );
    }
    // ML Kit's bitmap input uses BGRA8888, which is the pdfrx render format.
    return image;
  }

  PolicyPageResult _pageResult(
    int page,
    String rawText,
    PolicyExtractionMethod method, {
    List<OcrTextBlock> blocks = const [],
    String? warning,
  }) {
    final pageHash = sha256.convert(utf8.encode(rawText)).toString();
    final segments = <ImportedTextSegment>[];
    var start = 0;
    final separator = RegExp(r'\r?\n[\t ]*\r?\n+');
    for (final match in separator.allMatches(rawText)) {
      _addParagraph(
        segments,
        rawText: rawText,
        begin: start,
        end: match.start,
        page: page,
        pageHash: pageHash,
        method: method,
        blocks: blocks,
      );
      start = match.end;
    }
    _addParagraph(
      segments,
      rawText: rawText,
      begin: start,
      end: rawText.length,
      page: page,
      pageHash: pageHash,
      method: method,
      blocks: blocks,
    );
    return PolicyPageResult(
      page: page,
      rawText: rawText,
      textSha256: pageHash,
      method: method,
      segments: [
        for (var i = 0; i < segments.length; i++)
          ImportedTextSegment(
            sequence: i,
            text: segments[i].text,
            originalText: segments[i].originalText,
            page: segments[i].page,
            startOffset: segments[i].startOffset,
            endOffset: segments[i].endOffset,
            pageTextSha256: segments[i].pageTextSha256,
            extractionMethod: segments[i].extractionMethod,
            confidence: segments[i].confidence,
            boundingBoxJson: segments[i].boundingBoxJson,
          ),
      ],
      warning: warning,
    );
  }

  void _addParagraph(
    List<ImportedTextSegment> result, {
    required String rawText,
    required int begin,
    required int end,
    required int page,
    required String pageHash,
    required PolicyExtractionMethod method,
    required List<OcrTextBlock> blocks,
  }) {
    while (begin < end && rawText[begin].trim().isEmpty) {
      begin++;
    }
    while (end > begin && rawText[end - 1].trim().isEmpty) {
      end--;
    }
    if (end <= begin) return;
    final original = rawText.substring(begin, end);
    final display = original
        .replaceAll(RegExp(r'\r\n?'), '\n')
        .replaceAll(RegExp(r'[\t\f\v ]+'), ' ')
        .replaceAll(RegExp(r'\n+'), ' ')
        .trim();
    if (display.isEmpty) return;
    final block = blocks.cast<OcrTextBlock?>().firstWhere(
      (candidate) =>
          candidate != null &&
          (candidate.text.contains(display) ||
              display.contains(candidate.text)),
      orElse: () => null,
    );
    result.add(
      ImportedTextSegment(
        sequence: result.length,
        text: display,
        originalText: original,
        page: page,
        startOffset: begin,
        endOffset: end,
        pageTextSha256: pageHash,
        extractionMethod: method.name,
        confidence: block?.confidence,
        boundingBoxJson: block == null
            ? null
            : jsonEncode({
                'left': block.bounds.left,
                'top': block.bounds.top,
                'right': block.bounds.right,
                'bottom': block.bounds.bottom,
              }),
      ),
    );
    // Prevent offset semantics from accidentally drifting when CRLF was present.
    assert(begin <= rawText.length && end <= rawText.length);
  }

  bool _isValidTextLayer(String text) {
    final trimmed = text.trim();
    // Short clauses are valid policy text; only near-empty text-layer output
    // falls back to OCR.
    if (trimmed.length < 6) return false;
    final printable = trimmed.runes
        .where(
          (rune) =>
              rune == 9 ||
              rune == 10 ||
              rune == 13 ||
              (rune >= 32 && rune != 0xfffd),
        )
        .length;
    return printable / trimmed.runes.length >= 0.9 &&
        RegExp(r'[A-Za-z0-9]').hasMatch(trimmed);
  }

  bool _looksLikeText(List<int> bytes) =>
      (bytes.length >= 2 &&
          ((bytes[0] == 0xff && bytes[1] == 0xfe) ||
              (bytes[0] == 0xfe && bytes[1] == 0xff))) ||
      (bytes.isNotEmpty &&
          !bytes.contains(0) &&
          bytes.where((b) => b < 32 && b != 9 && b != 10 && b != 13).length /
                  bytes.length <
              0.01);

  Never _throwMimeMismatch() => throw const PolicyImportException(
    'mime_mismatch',
    'Jenis berkas tidak cocok dengan isi berkas. Pilih berkas PDF, JPG, PNG, atau TXT yang benar.',
  );

  String _decodeText(List<int> bytes) {
    try {
      return utf8.decode(bytes, allowMalformed: false);
    } on FormatException {
      if (bytes.length.isEven &&
          bytes.length >= 2 &&
          bytes[0] == 0xff &&
          bytes[1] == 0xfe) {
        return String.fromCharCodes([
          for (var i = 2; i + 1 < bytes.length; i += 2)
            bytes[i] | (bytes[i + 1] << 8),
        ]);
      }
      if (bytes.length.isEven &&
          bytes.length >= 2 &&
          bytes[0] == 0xfe &&
          bytes[1] == 0xff) {
        return String.fromCharCodes([
          for (var i = 2; i + 1 < bytes.length; i += 2)
            (bytes[i] << 8) | bytes[i + 1],
        ]);
      }
      return latin1.decode(bytes);
    }
  }

  bool _hasPdfSignature(Uint8List bytes) =>
      bytes.length >= 5 &&
      ascii.decode(bytes.sublist(0, 5), allowInvalid: true) == '%PDF-';

  bool _hasPngSignature(Uint8List bytes) =>
      bytes.length >= 8 &&
      listEquals(bytes.sublist(0, 8), const [137, 80, 78, 71, 13, 10, 26, 10]);

  bool _hasJpegSignature(Uint8List bytes) =>
      bytes.length >= 3 &&
      bytes[0] == 0xff &&
      bytes[1] == 0xd8 &&
      bytes[2] == 0xff;

  void _enforceLimit(List<int> bytes, int limit) {
    if (bytes.length > limit) {
      throw const PolicyImportException(
        'oversize',
        'Berkas melebihi batas ukuran untuk format ini.',
      );
    }
  }

  static Future<OcrPageText> _recognize(
    Uint8List imageBytes, {
    int? width,
    int? height,
  }) async {
    late final Uint8List bitmap;
    late final int bitmapWidth;
    late final int bitmapHeight;
    if (width != null && height != null) {
      bitmap = imageBytes;
      bitmapWidth = width;
      bitmapHeight = height;
    } else {
      final decoder = img.findDecoderForData(imageBytes);
      img.DecodeInfo? info;
      try {
        info = decoder?.startDecode(imageBytes);
      } on img.ImageException {
        throw const PolicyImportException(
          'invalid_image',
          'Gambar tidak dapat dibaca.',
        );
      }
      if (decoder == null ||
          info == null ||
          info.width < 1 ||
          info.height < 1) {
        throw const PolicyImportException(
          'invalid_image',
          'Gambar tidak dapat dibaca.',
        );
      }
      if (info.width * info.height > maxImagePixels) {
        throw const PolicyImportException(
          'image_dimensions',
          'Resolusi gambar terlalu besar untuk diproses dengan aman. Kecilkan gambar lalu coba lagi.',
        );
      }
      img.Image? decoded;
      try {
        decoded = decoder.decodeFrame(0);
      } on img.ImageException {
        throw const PolicyImportException(
          'invalid_image',
          'Gambar tidak dapat dibaca.',
        );
      }
      if (decoded == null) {
        throw const PolicyImportException(
          'invalid_image',
          'Gambar tidak dapat dibaca.',
        );
      }
      final oriented = img.bakeOrientation(decoded);
      final scale = math.min(
        1.0,
        _maxRenderEdge / math.max(oriented.width, oriented.height),
      );
      final bounded = scale < 1
          ? img.copyResize(
              oriented,
              width: math.max(1, (oriented.width * scale).round()),
              height: math.max(1, (oriented.height * scale).round()),
            )
          : oriented;
      bitmapWidth = bounded.width;
      bitmapHeight = bounded.height;
      bitmap = Uint8List.fromList(
        bounded.getBytes(order: img.ChannelOrder.bgra),
      );
    }
    final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
    try {
      final image = InputImage.fromBitmap(
        bitmap: bitmap,
        width: bitmapWidth,
        height: bitmapHeight,
      );
      final recognized = await recognizer.processImage(image);
      return OcrPageText(
        recognized.text,
        blocks: [
          for (final block in recognized.blocks)
            OcrTextBlock(
              text: block.text,
              bounds: block.boundingBox,
              confidence: _meanConfidence(
                block.lines.map((line) => line.confidence),
              ),
            ),
        ],
      );
    } finally {
      await recognizer.close();
      bitmap.fillRange(0, bitmap.length, 0);
    }
  }

  static double? _meanConfidence(Iterable<double?> values) {
    final confidence = values.whereType<double>().toList();
    if (confidence.isEmpty) return null;
    return confidence.reduce((left, right) => left + right) / confidence.length;
  }
}
