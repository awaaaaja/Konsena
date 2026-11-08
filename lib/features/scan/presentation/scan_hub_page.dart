import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../theme/konsena_spacing.dart';
import '../../shared/widgets/konsena_back_button.dart';
import 'scan_audit_target.dart';

/// S06 — local import and camera-to-monitor capture entry points.
class ScanHubPage extends StatelessWidget {
  const ScanHubPage({this.auditId, super.key});

  final String? auditId;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      leading: auditId == null
          ? null
          : KonsenaBackButton(fallback: '/audit/$auditId/sources'),
      title: const Text('Pindai Sumber'),
    ),
    body: ListView(
      padding: const EdgeInsets.all(KonsenaSpacing.lg),
      children: [
        Text(
          'Sumber apa yang ingin ditambahkan?',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: KonsenaSpacing.xs),
        Text(
          auditId == null
              ? 'Pilih cara menambah sumber, lalu tentukan audit tujuan.'
              : 'Sumber akan ditambahkan ke audit yang sedang dibuka.',
        ),
        const SizedBox(height: KonsenaSpacing.lg),
        _ScanChoice(
          icon: Icons.camera_alt_outlined,
          title: 'LiveScan',
          detail: 'Baca teks di layar laptop dengan kamera ponsel.',
          onTap: () =>
              context.push(scanLocation('/scan/camera/how-to', auditId)),
        ),
        _ScanChoice(
          icon: Icons.image_outlined,
          title: 'Screenshot persetujuan',
          detail: 'Pilih gambar, atur area, dan tambahkan catatan.',
          onTap: () =>
              context.push(scanLocation('/consent-ui/import', auditId)),
        ),
        _ScanChoice(
          icon: Icons.description_outlined,
          title: 'Dokumen atau teks',
          detail: 'Impor file atau tempel teks untuk ditinjau.',
          onTap: () =>
              context.push(scanLocation('/scan/document-type', auditId)),
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
