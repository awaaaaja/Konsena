import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../theme/konsena_spacing.dart';

/// S06 — the navigation hub is functional even though capture engines are not.
class ScanHubPage extends StatelessWidget {
  const ScanHubPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Pindai Sumber')),
    body: ListView(
      padding: const EdgeInsets.all(KonsenaSpacing.lg),
      children: [
        Text(
          'Pilih sumber yang ingin kamu tinjau',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: KonsenaSpacing.xs),
        const Text(
          'Belum ada berkas yang diunggah atau kamera yang diaktifkan.',
        ),
        const SizedBox(height: KonsenaSpacing.lg),
        _ScanChoice(
          icon: Icons.description_outlined,
          title: 'Dokumen atau teks',
          detail: 'Tentukan jenis dokumen, lalu lanjut ke alur impor saat tersedia.',
          onTap: () => context.push('/scan/document-type'),
        ),
        _ScanChoice(
          icon: Icons.camera_alt_outlined,
          title: 'LiveScan layar laptop',
          detail: 'Buka panduan. Phase ini tidak meminta izin kamera.',
          onTap: () => context.push('/scan/camera/how-to'),
        ),
        _ScanChoice(
          icon: Icons.image_outlined,
          title: 'Screenshot persetujuan',
          detail: 'Impor dan anotasi manual akan tersedia pada Phase 06.',
          onTap: () => context.push('/consent-ui/import'),
        ),
      ],
    ),
  );
}

class _ScanChoice extends StatelessWidget {
  const _ScanChoice({
    required this.icon,
    required this.title,
    required this.detail,
    required this.onTap,
  });
  final IconData icon;
  final String title;
  final String detail;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      minTileHeight: 76,
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(detail),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    ),
  );
}
