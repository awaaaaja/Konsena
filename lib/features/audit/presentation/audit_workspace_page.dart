import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../data/audit/audit_repository.dart';
import '../../../domain/audit/audit_entities.dart';
import '../../../theme/konsena_spacing.dart';
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

  Future<void> _pickSource(
    BuildContext context,
    AuditWorkspaceCubit cubit,
  ) async {
    PlatformFile? file;
    try {
      file = await FilePicker.pickFile();
    } on Object {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pemilih file tidak dapat dibuka.')),
        );
      }
      return;
    }
    if (file == null) return;
    final length = await file.length();
    if (length == null || length <= 0 || length > 25 * 1024 * 1024) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'File kosong, terlalu besar (maksimum 25 MB), atau tidak dapat dibaca.',
            ),
          ),
        );
      }
      return;
    }
    final bytes = await file.readAsBytes();
    if (!context.mounted) return;
    final ext = file.extension?.toLowerCase() ?? '';
    final type = ext == 'png' || ext == 'jpg' || ext == 'jpeg'
        ? AuditSourceType.consentUi
        : await _chooseDocumentType(context);
    if (type == null || !context.mounted) return;
    await cubit.attach(
      bytes: bytes,
      type: type,
      mediaType: _mediaType(ext),
      originalName: file.name,
    );
  }

  Future<AuditSourceType?> _chooseDocumentType(BuildContext context) =>
      showDialog<AuditSourceType>(
        context: context,
        builder: (dialogContext) => SimpleDialog(
          title: const Text('Pilih jenis sumber'),
          children: [
            for (final item in const [
              (AuditSourceType.privacyPolicy, 'Privacy Policy'),
              (AuditSourceType.terms, 'Terms of Service'),
              (AuditSourceType.otherDocument, 'Dokumen lain / belum tahu'),
            ])
              SimpleDialogOption(
                onPressed: () => Navigator.pop(dialogContext, item.$1),
                child: Text(item.$2),
              ),
          ],
        ),
      );

  Future<void> _editName(
    BuildContext context,
    AuditWorkspaceCubit cubit,
    String current,
  ) async {
    final controller = TextEditingController(text: current);
    final value = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Ubah nama audit'),
        content: TextField(
          controller: controller,
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
            onPressed: () => Navigator.pop(dialogContext, controller.text),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (value != null && context.mounted) await cubit.rename(value);
  }

  String _mediaType(String ext) => switch (ext) {
    'pdf' => 'application/pdf',
    'txt' => 'text/plain',
    'png' => 'image/png',
    'jpg' || 'jpeg' => 'image/jpeg',
    _ => 'application/octet-stream',
  };

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
            Text(
              session.name,
              style: Theme.of(context).textTheme.headlineSmall,
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
              onPressed: state.busy ? null : () => _pickSource(context, cubit),
              icon: const Icon(Icons.attach_file),
              label: const Text('Lampirkan sumber lokal'),
            ),
            const SizedBox(height: KonsenaSpacing.xs),
            const Text(
              'File dan teks sensitif dienkripsi AES-GCM di penyimpanan privat aplikasi. Data tidak dikirim ke cloud.',
            ),
            const SizedBox(height: KonsenaSpacing.md),
            if (state.sources.isEmpty)
              const Card(
                child: ListTile(
                  leading: Icon(Icons.folder_open_outlined),
                  title: Text('Belum ada sumber'),
                  subtitle: Text(
                    'Tambahkan dokumen atau screenshot. Tidak ada hasil analisis yang dibuat.',
                  ),
                ),
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
                  subtitle: Text(
                    '${_reviewLabel(source.reviewStatus)} · SHA-256 ${source.sha256.substring(0, 12)}… · ${source.byteLength} byte',
                  ),
                  trailing: IconButton(
                    tooltip: source.reviewStatus == SourceReviewStatus.reviewed
                        ? 'Lepas sumber'
                        : 'Tandai sudah ditinjau',
                    onPressed: state.busy
                        ? null
                        : () =>
                              source.reviewStatus == SourceReviewStatus.reviewed
                              ? cubit.detach(source.id)
                              : cubit.setReviewed(source.id),
                    icon: Icon(
                      source.reviewStatus == SourceReviewStatus.reviewed
                          ? Icons.link_off
                          : Icons.check_circle_outline,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: KonsenaSpacing.md),
            OutlinedButton.icon(
              onPressed: () async {
                await repository.addUnavailableAnalysis(
                  auditId: auditId,
                  sourceIds: state.sources
                      .map((s) => s.id)
                      .toList(growable: false),
                );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Analisis belum tersedia: model on-device belum dipasang.',
                      ),
                    ),
                  );
                }
              },
              icon: const Icon(Icons.info_outline),
              label: const Text('Lihat status analisis'),
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
