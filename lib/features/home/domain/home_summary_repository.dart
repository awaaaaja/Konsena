/// Summary numbers shown by S03 — always read from a repository, never
/// hard-coded in the widget (DESIGN_SYSTEM §3.1, §8.4).
class HomeSummary {
  const HomeSummary({required this.auditCount, required this.findingCount});

  /// Result for a device with no local data yet (initial empty state).
  const HomeSummary.empty() : auditCount = 0, findingCount = 0;

  /// Number of audit records stored on this device.
  final int auditCount;

  /// Number of findings stored on this device.
  final int findingCount;

  bool get isEmpty => auditCount == 0 && findingCount == 0;

  @override
  bool operator ==(Object other) =>
      other is HomeSummary &&
      other.auditCount == auditCount &&
      other.findingCount == findingCount;

  @override
  int get hashCode => Object.hash(auditCount, findingCount);

  @override
  String toString() =>
      'HomeSummary(audit: $auditCount, finding: $findingCount)';
}

/// Read seam for the dashboard summary.
///
/// Phase 01A ships [EmptyHomeSummaryRepository]; Phase 01B swaps in the
/// Drift-backed implementation behind the same interface without touching
/// the widget.
abstract class HomeSummaryRepository {
  Future<HomeSummary> load();
}

/// Initial empty state: this device has no local audit data yet, so the
/// dashboard honestly shows zeros that come from the repository — no
/// simulated session, no sample numbers, no "contoh" labels.
class EmptyHomeSummaryRepository implements HomeSummaryRepository {
  const EmptyHomeSummaryRepository();

  @override
  Future<HomeSummary> load() async => const HomeSummary.empty();
}
