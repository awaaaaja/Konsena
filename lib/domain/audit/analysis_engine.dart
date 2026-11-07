import 'audit_entities.dart';

class EngineCapabilities {
  const EngineCapabilities({required this.available, required this.reason});

  final bool available;
  final String reason;
}

class AnalysisUnavailable {
  const AnalysisUnavailable({required this.reason});
  final String reason;
}

abstract interface class AnalysisEngine {
  EngineCapabilities capabilities();

  Future<AnalysisUnavailable> classifyPolicy({required String sourceId});

  Future<AnalysisUnavailable> analyzeConsentGap({
    required List<String> sourceIds,
  });

  Future<AnalysisUnavailable> detectDarkPatterns({required String sourceId});

  /// Generic future-facing seam for other model-backed audit tasks.
  Future<AnalysisUnavailable> analyze({required List<String> sourceIds});
}

/// Honest provider until the evaluated on-device model is integrated.
class UnavailableAnalysisEngine implements AnalysisEngine {
  const UnavailableAnalysisEngine();

  static const reason = 'on_device_model_not_installed';

  @override
  EngineCapabilities capabilities() =>
      const EngineCapabilities(available: false, reason: reason);

  @override
  Future<AnalysisUnavailable> classifyPolicy({
    required String sourceId,
  }) async => const AnalysisUnavailable(reason: reason);

  @override
  Future<AnalysisUnavailable> analyzeConsentGap({
    required List<String> sourceIds,
  }) async => const AnalysisUnavailable(reason: reason);

  @override
  Future<AnalysisUnavailable> detectDarkPatterns({
    required String sourceId,
  }) async => const AnalysisUnavailable(reason: reason);

  @override
  Future<AnalysisUnavailable> analyze({
    required List<String> sourceIds,
  }) async => const AnalysisUnavailable(reason: reason);

  /// Persists a record of the unavailable attempt, never a successful run.
  AnalysisRun unavailableRun({
    required String id,
    required String auditId,
    required List<String> sourceIds,
    required DateTime now,
  }) => AnalysisRun(
    id: id,
    auditId: auditId,
    sourceIds: List.unmodifiable(sourceIds),
    status: AnalysisStatus.unavailable,
    engine: 'none',
    reason: reason,
    createdAt: now,
  );
}
