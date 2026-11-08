import '../../../domain/audit/audit_entities.dart';

enum PolicyImportKind { pdf, image, plainText }

enum PolicyExtractionMethod { pdfText, ocrPdf, ocrImage, pastedText, textFile }

class PolicyPageResult {
  const PolicyPageResult({
    required this.page,
    required this.rawText,
    required this.textSha256,
    required this.method,
    required this.segments,
    this.warning,
  });

  final int page;
  final String rawText;
  final String textSha256;
  final PolicyExtractionMethod method;
  final List<ImportedTextSegment> segments;
  final String? warning;
}

class PolicyImportResult {
  const PolicyImportResult({
    required this.kind,
    required this.pages,
    required this.warnings,
  });

  final PolicyImportKind kind;
  final List<PolicyPageResult> pages;
  final List<String> warnings;

  List<ImportedTextSegment> get segments {
    final flattened = pages.expand((page) => page.segments).toList();
    return [
      for (var index = 0; index < flattened.length; index++)
        _withSequence(flattened[index], index),
    ];
  }

  ImportedTextSegment _withSequence(ImportedTextSegment item, int sequence) =>
      ImportedTextSegment(
        sequence: sequence,
        text: item.text,
        originalText: item.originalText,
        page: item.page,
        startOffset: item.startOffset,
        endOffset: item.endOffset,
        pageTextSha256: item.pageTextSha256,
        extractionMethod: item.extractionMethod,
        confidence: item.confidence,
        boundingBoxJson: item.boundingBoxJson,
      );
}

class PolicyImportProgress {
  const PolicyImportProgress({required this.completed, required this.total});

  final int completed;
  final int total;
  double get fraction => total == 0 ? 0 : completed / total;
}

class PolicyImportException implements Exception {
  const PolicyImportException(this.code, this.message);

  final String code;
  final String message;

  @override
  String toString() => 'PolicyImportException($code)';
}

class PolicyImportCancelled implements Exception {
  const PolicyImportCancelled();
}

class PolicyImportCancellationToken {
  bool _cancelled = false;
  bool get isCancelled => _cancelled;
  void cancel() => _cancelled = true;

  void throwIfCancelled() {
    if (_cancelled) throw const PolicyImportCancelled();
  }
}
