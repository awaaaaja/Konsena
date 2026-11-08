import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../data/audit/audit_repository.dart';
import '../../../domain/audit/audit_entities.dart';
import '../../../theme/konsena_spacing.dart';
import '../../scan/presentation/scan_audit_target.dart';
import '../../shared/widgets/konsena_back_button.dart';
import 'audit_summary_panel.dart';
import 'audit_workspace_cubit.dart';

class AuditWorkspacePage extends StatelessWidget {
  const AuditWorkspacePage({
    required this.auditId,
    required this.repository,
    this.onAuditDeleted,
    super.key,
  });

  final String auditId;
  final AuditRepository repository;
  final Future<void> Function()? onAuditDeleted;

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => AuditWorkspaceCubit(repository, auditId)..load(),
    child: _WorkspaceBody(
      repository: repository,
      auditId: auditId,
      onAuditDeleted: onAuditDeleted,
    ),
  );
}

class _WorkspaceBody extends StatelessWidget {
  const _WorkspaceBody({
    required this.repository,
    required this.auditId,
    this.onAuditDeleted,
  });

  final AuditRepository repository;
  final String auditId;
  final Future<void> Function()? onAuditDeleted;

  Future<void> _editName(
    BuildContext context,
    AuditWorkspaceCubit cubit,
    String current,
  ) async {
    var name = current;
    final value = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Ubah nama audit'),
        content: TextFormField(
          initialValue: current,
          onChanged: (value) => name = value,
          maxLength: 60,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Nama audit'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, name),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
    if (value != null && context.mounted) await cubit.rename(value);
  }

  @override
  Widget build(
    BuildContext context,
  ) => BlocBuilder<AuditWorkspaceCubit, AuditWorkspaceState>(
    builder: (context, state) {
      final cubit = context.read<AuditWorkspaceCubit>();
      if (state.loading) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }
      if (state.session == null) {
        return Scaffold(
          appBar: AppBar(title: const Text('Workspace audit')),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(KonsenaSpacing.lg),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(state.error ?? 'Sesi audit tidak tersedia.'),
                  TextButton(
                    onPressed: () => context.go('/history'),
                    child: const Text('Kembali ke riwayat'),
                  ),
                ],
              ),
            ),
          ),
        );
      }
      final session = state.session!;
      return Scaffold(
        appBar: AppBar(
          leading: const KonsenaBackButton(fallback: '/history'),
          title: const Text('Workspace audit'),
          actions: [
            IconButton(
              tooltip: 'Ubah nama audit',
              onPressed: state.busy
                  ? null
                  : () => _editName(context, cubit, session.name),
              icon: const Icon(Icons.edit_outlined),
            ),
            IconButton(
              tooltip: 'Hapus audit',
              onPressed: state.busy
                  ? null
                  : () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (dialogContext) => AlertDialog(
                          title: const Text('Hapus audit?'),
                          content: const Text(
                            'Sesi dan semua sumber lokalnya akan dihapus dari riwayat.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () =>
                                  Navigator.pop(dialogContext, false),
                              child: const Text('Batal'),
                            ),
                            FilledButton(
                              onPressed: () =>
                                  Navigator.pop(dialogContext, true),
                              child: const Text('Hapus'),
                            ),
                          ],
                        ),
                      );
                      if (confirmed == true && context.mounted) {
                        final deleted = await cubit.deleteAudit();
                        if (deleted) await onAuditDeleted?.call();
                        if (deleted && context.mounted) context.go('/history');
                      }
                    },
              icon: const Icon(Icons.delete_outline),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(KonsenaSpacing.lg),
          children: [
            AuditSummaryPanel(
              name: session.name,
              sources: state.sources,
              snapshotCount: state.snapshots.length,
              updatedAt: session.updatedAt,
            ),
            const SizedBox(height: KonsenaSpacing.xs),
            Text(
              '${_focusLabel(session.focus)} · Draft lokal · ${state.sources.length} sumber',
            ),
            if (state.error != null) ...[
              const SizedBox(height: KonsenaSpacing.sm),
              Text(
                state.error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
            const SizedBox(height: KonsenaSpacing.md),
            FilledButton.icon(
              onPressed: state.busy
                  ? null
                  : () => context.push(scanLocation('/scan', auditId)),
              icon: const Icon(Icons.document_scanner_outlined),
              label: const Text('Pindai sumber'),
            ),
            const SizedBox(height: KonsenaSpacing.xs),
            OutlinedButton.icon(
              onPressed: state.busy
                  ? null
                  : () => context.push('/audit/apps?auditId=$auditId'),
              icon: const Icon(Icons.apps),
              label: const Text('Tambah snapshot izin Android'),
            ),
            const Text(
              'File dan teks sensitif dienkripsi AES-GCM di penyimpanan privat aplikasi. Data tidak dikirim ke cloud.',
            ),
            const SizedBox(height: KonsenaSpacing.md),
            if (state.sources.isEmpty && state.snapshots.isEmpty)
              const Card(
                child: ListTile(
                  leading: Icon(Icons.folder_open_outlined),
                  title: Text('Belum ada sumber'),
                  subtitle: Text(
                    'Tambahkan dokumen atau screenshot. Tidak ada hasil analisis yang dibuat.',
                  ),
                ),
              ),
            for (final snapshot in state.snapshots)
              Card(
                child: ListTile(
                  leading: const Icon(Icons.android),
                  title: Text(snapshot.appLabel),
                  subtitle: Text(
                    '${snapshot.packageName} · versi ${snapshot.versionName ?? "unknown"} · snapshot ${snapshot.capturedAt.toLocal()} · ${snapshot.snapshotStatus}',
                  ),
                  onTap: () => context.push(
                    '/audit/apps/${snapshot.packageName}?auditId=$auditId',
                  ),
                ),
              ),
            const Text(
              'Association dipilih pengguna. Tanggal/versi berbeda perlu ditinjau; tidak ada pencocokan otomatis.',
            ),
            for (final source in state.sources)
              Card(
                child: ListTile(
                  leading: Icon(
                    source.type == AuditSourceType.consentUi
                        ? Icons.image_outlined
                        : Icons.description_outlined,
                  ),
                  title: Text(source.originalName ?? _sourceLabel(source.type)),
                  onTap:
                      source.type == AuditSourceType.privacyPolicy ||
                          source.type == AuditSourceType.terms ||
                          source.type == AuditSourceType.otherDocument
                      ? () => context.push('/scan/review/${source.id}')
                      : () => context.push(
                          '/consent-ui/review?auditId=$auditId&sourceId=${source.id}',
                        ),
                  subtitle: Text(
                    '${_sourceLabel(source.type)} · ${_reviewLabel(source.reviewStatus)}'
                    '${source.reviewStatus == SourceReviewStatus.reviewed ? '' : '\nKetuk untuk lanjutkan review'}',
                  ),
                  trailing: IconButton(
                    tooltip: 'Hapus sumber',
                    onPressed: state.busy
                        ? null
                        : () async {
                            final confirmed = await showDialog<bool>(
                              context: context,
                              builder: (dialogContext) => AlertDialog(
                                title: const Text('Hapus sumber lokal?'),
                                content: const Text(
                                  'Sumber, segmen, evidence dan revisi terkait akan dihapus. Salinan yang sudah dibagikan ke aplikasi lain tidak ikut terhapus.',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(dialogContext, false),
                                    child: const Text('Batal'),
                                  ),
                                  FilledButton(
                                    onPressed: () =>
                                        Navigator.pop(dialogContext, true),
                                    child: const Text('Hapus'),
                                  ),
                                ],
                              ),
                            );
                            if (confirmed == true) {
                              await cubit.detach(source.id);
                            }
                          },
                    icon: const Icon(Icons.delete_outline),
                  ),
                ),
              ),
            const SizedBox(height: KonsenaSpacing.md),
            if (state.sources.any(
              (source) =>
                  source.type == AuditSourceType.consentUi &&
                  source.reviewStatus == SourceReviewStatus.reviewed,
            ))
              OutlinedButton.icon(
                onPressed: () => context.push('/audit/$auditId/dark-pattern'),
                icon: const Icon(Icons.fact_check_outlined),
                label: const Text('Review antarmuka'),
              ),
            OutlinedButton.icon(
              onPressed: () => context.push('/audit/$auditId/results'),
              icon: const Icon(Icons.info_outline),
              label: const Text('Lihat status analisis'),
            ),
            OutlinedButton.icon(
              onPressed: () => context.push('/audit/$auditId/report'),
              icon: const Icon(Icons.picture_as_pdf_outlined),
              label: const Text('Preview dan ekspor laporan'),
            ),
          ],
        ),
      );
    },
  );

  String _sourceLabel(AuditSourceType type) => switch (type) {
    AuditSourceType.androidPermission => 'Snapshot izin aplikasi',
    AuditSourceType.privacyPolicy => 'Privacy Policy',
    AuditSourceType.terms => 'Terms of Service',
    AuditSourceType.otherDocument => 'Dokumen lain',
    AuditSourceType.consentUi => 'Screenshot consent UI',
  };

  String _focusLabel(AuditFocus focus) => switch (focus) {
    AuditFocus.permissions => 'Izin aplikasi',
    AuditFocus.documents => 'Dokumen',
    AuditFocus.visual => 'Visual',
    AuditFocus.combined => 'Gabungan',
  };

  String _reviewLabel(SourceReviewStatus status) => switch (status) {
    SourceReviewStatus.pending => 'Menunggu ditinjau',
    SourceReviewStatus.needsReview => 'Perlu ditinjau',
    SourceReviewStatus.reviewed => 'Sudah ditinjau',
    SourceReviewStatus.unavailable => 'Tidak tersedia',
  };
}
