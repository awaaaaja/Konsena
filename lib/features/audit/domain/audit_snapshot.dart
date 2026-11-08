import '../../../data/audit/audit_repository.dart';
import '../../../domain/audit/audit_entities.dart';
import '../../consent_ui/domain/screenshot_review.dart';

class AuditSnapshot {
  const AuditSnapshot({
    required this.audit,
    required this.sources,
    required this.apps,
    required this.segments,
    required this.evidence,
    required this.reviews,
    required this.generatedAt,
    this.unavailableSources = const {},
    this.dataRevision = 0,
  });
  final AuditSession audit;
  final List<DocumentSource> sources;
  final List<ApplicationSnapshotRecord> apps;
  final Map<String, List<DocumentSegment>> segments;
  final List<EvidenceReference> evidence;
  final Map<String, ScreenshotReview> reviews;
  final DateTime generatedAt;
  final Set<String> unavailableSources;
  final int dataRevision;

  static Future<AuditSnapshot> load(AuditRepository repo, String id) async {
    final revision = repo.revision;
    final audit = await repo.get(id);
    if (audit == null) throw AuditNotFoundException();
    final sources = await repo.sources(id);
    final segments = <String, List<DocumentSegment>>{};
    final reviews = <String, ScreenshotReview>{};
    final unavailable = <String>{};
    for (final source in sources) {
      try {
        await repo.readSource(source.id);
      } on Object {
        unavailable.add(source.id);
      }
      if (unavailable.contains(source.id)) continue;
      segments[source.id] = await repo.documentSegments(source.id);
      if (source.type == AuditSourceType.consentUi) {
        final history = await repo.screenshotHistory(id, source.id);
        if (history.isNotEmpty) reviews[source.id] = history.first.review;
      }
    }
    final result = AuditSnapshot(
      audit: audit,
      sources: sources,
      apps: await repo.applicationSnapshots(id),
      segments: segments,
      evidence: await repo.evidence(id),
      reviews: reviews,
      generatedAt: DateTime.now().toUtc(),
      unavailableSources: unavailable,
      dataRevision: revision,
    );
    final after = await repo.get(id);
    if (after == null ||
        after.updatedAt != audit.updatedAt ||
        repo.revision != revision) {
      throw StateError('Audit changed; reload');
    }
    return result;
  }

  List<String> get reportLines => [
    'KONSENA AI — Laporan faktual lokal',
    'Audit: ${audit.name}',
    'ID audit: ${audit.id}',
    'Dibuat: ${generatedAt.toIso8601String()}',
    'Revisi audit: ${audit.updatedAt.toIso8601String()}',
    'Analisis AI belum tersedia. Tidak ada skor risiko, inferensi, atau kesimpulan hukum.',
    'Sumber yang belum lengkap tidak membuktikan ketidaksesuaian. Snapshot izin bukan bukti penggunaan izin.',
    'Sumber aktif: ${sources.length}; snapshot Android: ${apps.length}.',
    for (final app in apps) ...[
      'FAKTA SNAPSHOT: ${app.appLabel} (${app.packageName}) versi ${app.versionName ?? "unknown"}',
      'Waktu ${app.capturedAt.toIso8601String()} · ${app.snapshotStatus} · ${app.visibilityScope}',
      for (final permission in app.permissions)
        '${permission.permissionName}: ${permission.grantStatus}',
    ],
    for (final source in sources) ...[
      'SUMBER ${source.type.name}: ${source.originalName ?? source.id}',
      'ID ${source.id} · audit ${source.auditId} · SHA-256 ${source.sha256}',
      'Versi/tanggal sumber: ${source.documentVersion ?? "unknown"}; review ${source.reviewStatus.name}',
      'Disimpan ${source.createdAt.toIso8601String()}; diperbarui ${source.updatedAt.toIso8601String()}',
      'Locator: ${source.provenanceLocator ?? "unknown"}',
      if (source.type == AuditSourceType.consentUi)
        'Rute lokal: /consent-ui/review?auditId=${audit.id}&sourceId=${source.id}'
      else
        'Rute lokal: /scan/review/${source.id}',
      if (unavailableSources.contains(source.id))
        'MISSING / CORRUPT: file sumber tidak tersedia; bukan evidence aktif.',
      for (final segment in segments[source.id] ?? <DocumentSegment>[]) ...[
        'SEGMENT ${segment.id} · halaman ${segment.page ?? "unknown"} · frame ${segment.frame ?? "unknown"}',
        'Metode ${segment.extractionMethod ?? "unknown"}; ROI ${segment.boundingBoxJson ?? "unknown"}',
        'Kutipan saat ini: ${segment.text}',
        if (segment.editedAt != null)
          'KOREKSI PENGGUNA ${segment.editedAt}: ${segment.originalText ?? ""}',
      ],
      if (reviews[source.id] case final review?) ...[
        'ANOTASI MANUAL — bukan inferensi AI; crop ${review.crop.toJson()}, rotasi ${review.quarterTurns * 90}°',
        for (final annotation in review.annotations)
          '${annotation.kind}: ${annotation.label} · ROI asli ${annotation.rect.toJson()}',
      ],
    ],
    for (final item in evidence)
      'EVIDENCE ${item.id}: ${item.quote ?? "Tanpa kutipan teks"} · sumber ${item.sourceId} · ${item.location}',
    'Kontrol privasi: laporan dibuat lokal. Salinan yang dibagikan ke aplikasi lain tidak dapat dihapus oleh KONSENA.',
  ];
}
