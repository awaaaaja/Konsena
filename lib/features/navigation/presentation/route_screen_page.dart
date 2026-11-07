import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/navigation/audit_draft_store.dart';
import '../../../app/navigation/route_registry.dart';
import '../../../data/audit/audit_repository.dart';
import '../../../theme/konsena_spacing.dart';
import '../../shared/widgets/konsena_state_panel.dart';

/// Honest, screen-specific page for routes whose technical feature belongs to
/// a later phase. This is not a generic blank/"coming soon" page: every route
/// supplies its own purpose, current capability boundary and recovery actions.
class RouteScreenPage extends StatelessWidget {
  const RouteScreenPage({
    required this.spec,
    required this.parameters,
    required this.drafts,
    this.queryAuditId,
    this.auditRepository,
    this.validatedAudit = false,
    super.key,
  });

  final ScreenSpec spec;
  final Map<String, String> parameters;
  final AuditDraftStore drafts;
  final String? queryAuditId;
  final AuditRepository? auditRepository;
  final bool validatedAudit;

  @override
  Widget build(BuildContext context) {
    final invalid = RouteRegistry.validateParameters(spec, parameters);
    if (invalid != null) return _RecoveryPage(message: invalid);

    final auditId = parameters['id'] ?? queryAuditId ?? parameters['auditId'];
    if (auditId != null && auditRepository != null && !validatedAudit) {
      return FutureBuilder(
        future: auditRepository!.get(auditId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (snapshot.data == null) {
            return _RecoveryPage(
              title: 'Audit tidak ditemukan',
              message: 'Sesi lokal sudah tidak tersedia. Tidak ada data contoh yang dibuka.',
              actions: const [
                RouteAction('Mulai audit baru', '/audit/new'),
                RouteAction('Lihat riwayat', '/history'),
              ],
            );
          }
          return RouteScreenPage(
            spec: spec,
            parameters: parameters,
            drafts: drafts,
            queryAuditId: queryAuditId,
            auditRepository: auditRepository,
            validatedAudit: true,
          ).build(context);
        },
      );
    }
    if (auditId != null &&
        auditRepository == null &&
        !drafts.contains(auditId)) {
      return _RecoveryPage(
        title: 'Audit tidak ditemukan',
        message:
            'Sesi "$auditId" tidak ada di draft lokal yang tersedia. Tidak ada data contoh yang dibuka.',
        actions: const [
          RouteAction('Mulai audit baru', '/audit/new'),
          RouteAction('Lihat riwayat', '/history'),
        ],
      );
    }

    if (spec.id == ScreenId.s16) {
      return _RecoveryPage(
        title: 'Bukti belum tersedia',
        message: 'Belum ada evidence tersimpan untuk sesi ini. KONSENA tidak membuat kutipan atau temuan contoh.',
        actions: auditId == null
            ? const [RouteAction('Pilih sumber', '/scan')]
            : [
                RouteAction('Kembali ke hasil', '/audit/$auditId/results'),
                RouteAction('Buka workspace', '/audit/$auditId/sources'),
              ],
      );
    }

    if (spec.id == ScreenId.s37 || spec.id == ScreenId.s22) {
      return _RecoveryPage(
        title: 'Sinkronisasi belum diaktifkan',
        message: 'Rute ini memerlukan akun dan persetujuan sinkronisasi. Mode tamu dan data lokal tetap dapat digunakan.',
        actions: const [
          RouteAction('Buka Profil', '/profile'),
          RouteAction('Kembali ke Beranda', '/home'),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(spec.title)),
      body: ListView(
        padding: const EdgeInsets.all(KonsenaSpacing.lg),
        children: [
          Semantics(
            header: true,
            child: Text(
              spec.title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          const SizedBox(height: KonsenaSpacing.sm),
          Text(spec.summary, style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: KonsenaSpacing.md),
          KonsenaStatePanel(
            kind: KonsenaStateKind.unavailable,
            title: 'Status fitur',
            message: spec.availability,
            compact: true,
          ),
          if (auditId != null) ...[
            const SizedBox(height: KonsenaSpacing.md),
            Text(
              'Draft audit: $auditId',
              key: const ValueKey('active-audit-id'),
            ),
          ],
          const SizedBox(height: KonsenaSpacing.lg),
          Text(
            'Aksi dan navigasi',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: KonsenaSpacing.xs),
          for (final action in _actionsFor(spec.id, auditId))
            Card(
              child: ListTile(
                minTileHeight: 56,
                title: Text(action.label),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {
                  if (_isRootLocation(action.location)) {
                    context.go(action.location);
                  } else {
                    context.push(action.location);
                  }
                },
              ),
            ),
          const SizedBox(height: KonsenaSpacing.lg),
          OutlinedButton.icon(
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/home');
              }
            },
            icon: const Icon(Icons.arrow_back_rounded),
            label: const Text('Kembali'),
          ),
        ],
      ),
    );
  }

  bool _isRootLocation(String location) => const {
    '/home',
    '/audit/new',
    '/scan',
    '/history',
    '/profile',
  }.contains(location);

  List<RouteAction> _actionsFor(ScreenId id, String? auditId) {
    final session = auditId;
    switch (id) {
      case ScreenId.s04:
        return [
          RouteAction(
            'Pilih aplikasi yang terlihat',
            session == null ? '/audit/apps' : '/audit/apps?auditId=$session',
          ),
          const RouteAction('Pilih jenis dokumen', '/scan/document-type'),
          if (session != null)
            RouteAction('Buka workspace audit', '/audit/$session/sources'),
        ];
      case ScreenId.s05:
        return [
          const RouteAction('Pilih dokumen', '/scan/document-type'),
          if (session != null)
            RouteAction('Kembali ke workspace', '/audit/$session/sources'),
        ];
      case ScreenId.s07:
      case ScreenId.s25:
        return [
          const RouteAction('Kembali ke sumber', '/scan'),
          if (session != null)
            RouteAction('Lihat workspace audit', '/audit/$session/sources'),
        ];
      case ScreenId.s11:
        return [
          const RouteAction('Kembali ke impor', '/scan/import'),
          if (session != null)
            RouteAction('Workspace audit', '/audit/$session/sources'),
        ];
      case ScreenId.s08:
      case ScreenId.s09:
      case ScreenId.s10:
      case ScreenId.s27:
        return [
          const RouteAction('Buka bantuan kamera', '/scan/camera/troubleshoot'),
          const RouteAction('Pilih impor dokumen', '/scan/import'),
        ];
      case ScreenId.s12:
        return [const RouteAction('Kembali ke Scan Hub', '/scan')];
      case ScreenId.s13:
        return [
          const RouteAction('Impor screenshot', '/consent-ui/import'),
          if (session != null)
            RouteAction('Workspace audit', '/audit/$session/sources'),
        ];
      case ScreenId.s14:
        return [
          RouteAction(
            'Tambah aplikasi',
            session == null ? '/audit/apps' : '/audit/apps?auditId=$session',
          ),
          const RouteAction('Tambah dokumen', '/scan/document-type'),
          const RouteAction('Impor screenshot', '/consent-ui/import'),
          if (session != null)
            RouteAction('Lihat status analisis', '/audit/$session/results'),
        ];
      case ScreenId.s15:
        return [
          if (session != null) ...[
            RouteAction(
              'Bukti sumber — belum ada bukti tersimpan',
              '/audit/$session/evidence/unavailable',
            ),
            RouteAction(
              'Bandingkan sumber — belum tersedia',
              '/audit/$session/compare',
            ),
            RouteAction('Faktor privasi — tanpa skor', '/audit/$session/risk'),
            RouteAction(
              'Review antarmuka — tanpa klasifikasi',
              '/audit/$session/dark-pattern',
            ),
            RouteAction('Tindakan', '/audit/$session/actions'),
            RouteAction('Laporan', '/audit/$session/report'),
          ],
        ];
      case ScreenId.s16:
        return [
          if (session != null)
            RouteAction('Kembali ke hasil', '/audit/$session/results'),
          const RouteAction('Lihat dokumen', '/scan'),
        ];
      case ScreenId.s17:
        return [
          if (session != null) ...[
            RouteAction(
              'Detail tindakan — belum ada rekomendasi',
              '/audit/$session/actions/action_unavailable',
            ),
            RouteAction('Lihat hasil', '/audit/$session/results'),
          ],
          const RouteAction('Lihat bantuan', '/about'),
        ];
      case ScreenId.s18:
        return [
          if (session != null)
            RouteAction(
              'Opsi ekspor (belum aktif)',
              '/audit/$session/report/export',
            ),
          if (session != null)
            RouteAction('Kembali ke hasil', '/audit/$session/results'),
        ];
      case ScreenId.s19:
        final latest = drafts.latest;
        return latest == null
            ? [const RouteAction('Buat audit pertama', '/audit/new')]
            : [RouteAction('Buka ${latest.name}', '/history/${latest.id}')];
      case ScreenId.s20:
        return const [
          RouteAction('Kontrol data', '/settings/data'),
          RouteAction('Profil guest', '/profile'),
          RouteAction('Tentang', '/about'),
        ];
      case ScreenId.s21:
        return const [
          RouteAction('Pengaturan', '/settings'),
          RouteAction('Kontrol data', '/settings/data'),
          RouteAction('Tentang', '/about'),
          RouteAction('Sinkronisasi (perlu opt-in)', '/sync'),
        ];
      case ScreenId.s23:
        return const [
          RouteAction('Buka Pengaturan', '/settings'),
          RouteAction('Kembali ke Beranda', '/home'),
        ];
      case ScreenId.s26:
        return const [
          RouteAction('Pilih berkas', '/scan/import'),
          RouteAction('Kembali ke Scan Hub', '/scan'),
        ];
      case ScreenId.s28:
        return [
          const RouteAction('Pilih/import dokumen', '/scan'),
          if (session != null)
            RouteAction('Workspace audit', '/audit/$session/sources'),
        ];
      case ScreenId.s29:
      case ScreenId.s30:
      case ScreenId.s38:
        return [
          if (session != null)
            RouteAction('Kembali ke workspace', '/audit/$session/sources'),
          if (session != null)
            RouteAction(
              'Buka bukti (jika tersedia)',
              '/audit/$session/evidence/unavailable',
            ),
          const RouteAction('Baca batasan analisis', '/about'),
        ];
      case ScreenId.s31:
        return [
          const RouteAction('Review anotasi screenshot', '/consent-ui/review'),
          if (session != null) ...[
            RouteAction(
              'Buka bukti (jika tersedia)',
              '/audit/$session/evidence/unavailable',
            ),
            RouteAction('Lihat tindakan', '/audit/$session/actions'),
          ],
          const RouteAction('Baca batasan analisis', '/about'),
        ];
      case ScreenId.s32:
        return [
          if (session != null) ...[
            RouteAction(
              'Kembali ke daftar tindakan',
              '/audit/$session/actions',
            ),
            RouteAction('Buka workspace', '/audit/$session/sources'),
          ],
          const RouteAction('Baca batasan analisis', '/about'),
        ];
      case ScreenId.s33:
        return [
          if (session != null)
            RouteAction('Kembali ke preview laporan', '/audit/$session/report'),
        ];
      case ScreenId.s34:
        return [
          if (session != null) ...[
            RouteAction('Lanjutkan workspace', '/audit/$session/sources'),
            RouteAction('Buka laporan', '/audit/$session/report'),
          ],
        ];
      case ScreenId.s35:
        return const [
          RouteAction('Pilih dokumen sebagai alternatif', '/scan/import'),
          RouteAction('Kembali ke Scan Hub', '/scan'),
        ];
      case ScreenId.s36:
        return const [
          RouteAction('Pengaturan privasi', '/settings'),
          RouteAction('Tentang penyimpanan lokal', '/about'),
        ];
      case ScreenId.s39:
        return const [
          RouteAction('Lanjut ke persiapan LiveScan', '/scan/camera/setup'),
          RouteAction('Pindai file sebagai alternatif', '/scan/import'),
        ];
      case ScreenId.s00:
      case ScreenId.s01:
      case ScreenId.s02:
      case ScreenId.s03:
      case ScreenId.s06:
      case ScreenId.s24:
      case ScreenId.s22:
      case ScreenId.s37:
        return const [];
    }
  }
}

class RouteAction {
  const RouteAction(this.label, this.location);
  final String label;
  final String location;
}

class _RecoveryPage extends StatelessWidget {
  const _RecoveryPage({
    this.title = 'Tidak dapat membuka layar',
    required this.message,
    this.actions = const [],
  });
  final String title;
  final String message;
  final List<RouteAction> actions;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(title)),
    body: ListView(
      padding: const EdgeInsets.all(KonsenaSpacing.lg),
      children: [
        const Icon(Icons.warning_amber_rounded, size: 40),
        const SizedBox(height: KonsenaSpacing.md),
        Text(message),
        const SizedBox(height: KonsenaSpacing.lg),
        for (final action in [
          ...actions,
          const RouteAction('Ke Beranda', '/home'),
        ])
          Padding(
            padding: const EdgeInsets.only(bottom: KonsenaSpacing.xs),
            child: FilledButton(
              onPressed: () => context.go(action.location),
              child: Text(action.label),
            ),
          ),
      ],
    ),
  );
}
