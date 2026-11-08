import 'dart:math' as math;

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';

import '../../../data/audit/audit_repository.dart';
import '../../../domain/audit/analysis_engine.dart';
import '../../../domain/audit/audit_entities.dart';
import '../../consent_ui/domain/screenshot_review.dart';
import 'dark_pattern_input.dart';
import 'onnx_tensor_harness.dart';

class DarkPatternQaResult extends AnalysisResult {
  const DarkPatternQaResult({
    required this.source,
    required this.review,
    required this.tensorSha256,
    required this.logits,
    required this.probabilities,
    required this.elapsedMs,
    required this.createdAt,
  }) : super(outcome: AnalysisOutcome.result, reason: 'QA_ONLY');

  static const labels = ['no_pattern_detected', 'potential_dark_pattern'];
  static const modelVersion =
      'a0c00228c33327dafed4a74a05bc868b550878b76dbacf5a83045e24f85575f0';

  final DocumentSource source;
  final ScreenshotReview review;
  final String tensorSha256;
  final List<double> logits, probabilities;
  final double elapsedMs;
  final DateTime createdAt;

  String get label => labels[logits[0] >= logits[1] ? 0 : 1];
}

class SourceBoundDarkPattern {
  const SourceBoundDarkPattern(this.repository);

  final AuditRepository repository;

  static bool isReviewedPng(DocumentSource source) =>
      source.type == AuditSourceType.consentUi &&
      source.lifecycle == SourceLifecycle.active &&
      source.reviewStatus == SourceReviewStatus.reviewed &&
      source.mediaType == 'image/png';

  Future<AnalysisResult> run({
    required bool optedIn,
    required String auditId,
    required String sourceId,
    required int sourceRevision,
  }) async {
    const insufficient = AnalysisResult(
      outcome: AnalysisOutcome.insufficientSources,
      reason: 'reviewed_screenshot_required',
    );
    const stale = AnalysisResult(
      outcome: AnalysisOutcome.error,
      reason: 'source_changed_during_inference',
    );
    if (!OnnxTensorHarness.enabled || !optedIn) {
      return const AnalysisUnavailable(reason: 'debug_qa_opt_in_required');
    }
    if (repository.revision != sourceRevision) return stale;
    try {
      if (await repository.get(auditId) == null) return insufficient;
      final source = await repository.source(sourceId);
      if (source.auditId != auditId || !isReviewedPng(source)) {
        return insufficient;
      }
      final history = await repository.screenshotHistory(auditId, sourceId);
      if (history.isEmpty) return insufficient;
      final review = history.first.review;
      final png = Uint8List.fromList(await repository.readSource(sourceId));
      final pixels = await compute(
        (input) => DarkPatternInput.encode(input.png, input.review),
        (png: png, review: review),
      );
      if (repository.revision != sourceRevision) return stale;
      final result = await const OnnxTensorHarness().run(
        modelId: 'dark_pattern',
        pixels: pixels,
      );
      if (repository.revision != sourceRevision) return stale;

      final logits = result['logits'];
      final elapsed = result['loadAndInferenceMs'];
      if (result['status'] != 'QA_ONLY' ||
          result['modelId'] != 'dark_pattern' ||
          logits is! List ||
          logits.length != 2 ||
          logits.any((value) => value is! num || !value.isFinite) ||
          elapsed is! num ||
          !elapsed.isFinite ||
          elapsed < 0) {
        throw StateError('Invalid QA response');
      }

      const temperature = 1.0717734625362934;
      final values = logits
          .cast<num>()
          .map((value) => value.toDouble())
          .toList();
      final peak = math.max(values[0], values[1]);
      final exps = values
          .map((value) => math.exp((value - peak) / temperature))
          .toList();
      final total = exps[0] + exps[1];
      return DarkPatternQaResult(
        source: source,
        review: review,
        tensorSha256: sha256.convert(pixels).toString(),
        logits: List.unmodifiable(values),
        probabilities: List.unmodifiable(exps.map((value) => value / total)),
        elapsedMs: elapsed.toDouble(),
        createdAt: DateTime.now().toUtc(),
      );
    } on SourceNotFoundException {
      return insufficient;
    } on FormatException {
      return const AnalysisUnavailable(reason: 'unsupported_screenshot');
    } on Object {
      return const AnalysisUnavailable(reason: 'model_or_source_unavailable');
    }
  }
}
