import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../data/audit/audit_repository.dart';
import '../../../domain/audit/audit_entities.dart';
import '../../report/data/audit_pdf_export.dart';
import '../../shared/widgets/konsena_back_button.dart';

class DataControlsPage extends StatefulWidget {
  const DataControlsPage({required this.repository, super.key});
  final AuditRepository? repository;
  @override
  State<DataControlsPage> createState() => _DataControlsPageState();
}

class _DataControlsPageState extends State<DataControlsPage> {
  late Future<List<AuditSession>> _items =
      widget.repository?.listSessions() ?? Future.value([]);
  String? _status;
  bool _busy = false;
  Future<void> _deleteAll() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus seluruh audit lokal?'),
        content: const Text(
          'Semua sumber, teks, evidence, histori revisi dan cache ekspor aplikasi dihapus. Preferensi onboarding tetap disimpan. Salinan di aplikasi lain tidak dapat ditarik kembali. Tidak ada undo.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Hapus seluruh audit'),
          ),
        ],
      ),
    );
    if (confirmed != true || widget.repository == null) return;
    setState(() => _busy = true);
    try {
      // Clear plaintext exports first. Failure must be visible, not claim deletion.
      await AuditPdfExport.clearCache();
      for (final audit in await widget.repository!.listSessions()) {
        await widget.repository!.deleteAudit(audit.id);
      }
      await widget.repository!.recoverFileLifecycle();
      final remaining = await widget.repository!.sessionCount();
      if (remaining != 0) throw StateError('Delete verification failed');
      if (mounted) {
        setState(() {
          _status = 'Seluruh audit dan sumber lokal terhapus. Preferensi tetap disimpan.';
          _items = widget.repository!.listSessions();
        });
      }
    } on Object {
      if (mounted) {
        setState(
          () => _status = 'Penghapusan belum lengkap. Coba lagi; tidak ada klaim semua data telah terhapus.',
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      leading: const KonsenaBackButton(fallback: '/settings'),
      title: const Text('Kontrol Data'),
    ),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'File sumber dan isi sensitif disimpan AES-GCM pada penyimpanan privat aplikasi. SQLite tidak dienkripsi seluruhnya. Backup Android dinonaktifkan. Cloud dan telemetry audit tidak aktif.',
        ),
        const Text(
          'Retensi audit: sampai Anda menghapusnya. Cache PDF plaintext dikelola aplikasi, dibersihkan saat proses baru dan tersedia tombol hapus. Salinan yang dibagikan berada di luar kendali aplikasi.',
        ),
        if (_status != null) Text(_status!),
        FutureBuilder<List<AuditSession>>(
          future: _items,
          builder: (context, snapshot) => Column(
            children: [
              if (snapshot.hasError)
                const Text('Data lokal tidak dapat dibaca.'),
              Text('${snapshot.data?.length ?? 0} audit tersimpan'),
              for (final audit in snapshot.data ?? <AuditSession>[])
                ListTile(
                  title: Text(audit.name),
                  subtitle: const Text(
                    'Buka untuk ekspor terpilih atau hapus audit',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/history/${audit.id}'),
                ),
            ],
          ),
        ),
        OutlinedButton(
          onPressed: _busy
              ? null
              : () async {
                  try {
                    await AuditPdfExport.clearCache();
                    if (mounted) {
                      setState(
                        () => _status = 'Cache ekspor aplikasi dibersihkan.',
                      );
                    }
                  } on Object {
                    if (mounted) {
                      setState(
                        () => _status = 'Cache belum dapat dibersihkan.',
                      );
                    }
                  }
                },
          child: const Text('Hapus cache ekspor aplikasi'),
        ),
        FilledButton(
          onPressed: _busy ? null : _deleteAll,
          child: const Text('Hapus seluruh audit lokal'),
        ),
      ],
    ),
  );
}
