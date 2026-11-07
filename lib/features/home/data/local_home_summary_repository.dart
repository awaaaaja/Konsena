import '../../../data/audit/audit_repository.dart';
import '../domain/home_summary_repository.dart';

class LocalHomeSummaryRepository implements HomeSummaryRepository {
  const LocalHomeSummaryRepository(this._audits);

  final AuditRepository _audits;

  @override
  Future<HomeSummary> load() async => HomeSummary(
    auditCount: await _audits.sessionCount(),
    // Findings are intentionally zero until a real analysis engine exists.
    findingCount: 0,
  );
}
