import '../../../data/audit/audit_repository.dart';
import '../../../domain/audit/analysis_engine.dart';
import '../../../domain/audit/audit_entities.dart';
import 'onnx_tensor_harness.dart';

class NliSourceResult extends AnalysisResult {
  const NliSourceResult({
    required this.source,
    required this.segment,
    required this.snapshot,
    required this.permissionName,
    required this.hypothesis,
    required this.label,
    required this.probabilities,
    required this.modelVersion,
    required this.createdAt,
    required this.elapsedMs,
    required this.sourceRevision,
  }) : super(outcome: AnalysisOutcome.result, reason: 'QA_ONLY');

  final DocumentSource source;
  final DocumentSegment segment;
  final ApplicationSnapshotRecord snapshot;
  final String permissionName, hypothesis, label, modelVersion;
  final List<double> probabilities;
  final DateTime createdAt;
  final double elapsedMs;
  final int sourceRevision;
}

/// Compares a reviewed clause with a permission declaration for debug QA.
class SourceBoundNliEngine extends UnavailableAnalysisEngine {
  const SourceBoundNliEngine(this.repository);

  static const labels = ['entailment', 'neutral', 'contradiction'];
  static const _version =
      'fd543a14deab68081bedc6a9f848932e69594f9993384dd16fdac6bb6900c12c';
  static const _insufficient = AnalysisResult(
    outcome: AnalysisOutcome.insufficientSources,
    reason: 'reviewed_clause_and_permission_required',
  );
  static const _stale = AnalysisResult(
    outcome: AnalysisOutcome.error,
    reason: 'source_changed_during_inference',
  );
  final AuditRepository repository;

  static bool isReviewedDocument(DocumentSource source) =>
      source.reviewStatus == SourceReviewStatus.reviewed &&
      const {
        AuditSourceType.privacyPolicy,
        AuditSourceType.terms,
        AuditSourceType.otherDocument,
      }.contains(source.type);

  Future<AnalysisResult> compare({
    required bool optedIn,
    required String auditId,
    required String sourceId,
    required String segmentId,
    required String snapshotId,
    required String permissionName,
    required int sourceRevision,
  }) async {
    if (!OnnxTensorHarness.enabled || !optedIn) {
      return const AnalysisUnavailable(reason: 'debug_qa_opt_in_required');
    }
    if (repository.revision != sourceRevision) return _stale;

    try {
      final audit = await repository.get(auditId);
      if (audit == null) return _insufficient;
      final source = await repository.source(sourceId);
      if (source.auditId != auditId || !isReviewedDocument(source)) {
        return _insufficient;
      }
      await repository.readSource(sourceId);
      final segments = await repository.documentSegments(sourceId);
      final clause = segments
          .where((segment) => segment.id == segmentId)
          .singleOrNull;
      final apps = await repository.applicationSnapshots(auditId);
      final snapshot = apps.where((app) => app.id == snapshotId).singleOrNull;
      if (clause == null ||
          clause.text.trim().isEmpty ||
          snapshot == null ||
          snapshot.auditId != auditId ||
          !snapshot.permissions.any(
            (p) => p.permissionName == permissionName,
          )) {
        return _insufficient;
      }
      if (repository.revision != sourceRevision) return _stale;

      final hypothesis =
          'The application requests the Android permission $permissionName.';
      final result = await OnnxTensorHarness.channel
          .invokeMapMethod<String, dynamic>('analyzePair', {
            'modelId': 'consent_nli',
            'premise': clause.text,
            'hypothesis': hypothesis,
          });
      final current = await repository.get(auditId);
      if (repository.revision != sourceRevision ||
          current == null ||
          current.updatedAt != audit.updatedAt) {
        return _stale;
      }

      if (result == null ||
          result['status'] != 'QA_ONLY' ||
          result['modelId'] != 'consent_nli' ||
          result['modelVersion'] != _version ||
          !labels.contains(result['label'])) {
        throw StateError('Invalid model result');
      }
      final probabilities = (result['probabilities'] as List)
          .map((p) => (p as num).toDouble())
          .toList();
      final elapsedMs = (result['loadAndInferenceMs'] as num).toDouble();
      final label = result['label'] as String;
      if (probabilities.length != labels.length ||
          probabilities.any((p) => !p.isFinite || p < 0 || p > 1) ||
          (probabilities.reduce((a, b) => a + b) - 1).abs() > .0001 ||
          probabilities.any((p) => p > probabilities[labels.indexOf(label)]) ||
          !elapsedMs.isFinite ||
          elapsedMs < 0) {
        throw StateError('Invalid model metrics');
      }
      return NliSourceResult(
        source: source,
        segment: clause,
        snapshot: snapshot,
        permissionName: permissionName,
        hypothesis: hypothesis,
        label: label,
        probabilities: List.unmodifiable(probabilities),
        modelVersion: _version,
        createdAt: DateTime.now().toUtc(),
        elapsedMs: elapsedMs,
        sourceRevision: sourceRevision,
      );
    } on SourceNotFoundException {
      return _insufficient;
    } on Object {
      return const AnalysisResult(
        outcome: AnalysisOutcome.error,
        reason: 'model_or_source_unavailable',
      );
    }
  }
}
