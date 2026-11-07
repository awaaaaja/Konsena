import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../theme/konsena_spacing.dart';

/// S20 — settings entry points; destructive operations are not simulated.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Pengaturan')),
    body: ListView(
      padding: const EdgeInsets.all(KonsenaSpacing.md),
      children: [
        _SettingsLink(
          title: 'Aksesibilitas dan tampilan',
          detail: 'Tema saat ini mengikuti desain KONSENA; opsi bahasa tambahan menyusul.',
          icon: Icons.accessibility_new_rounded,
          onTap: () => _explain(
            context,
            'Preferensi tampilan tambahan belum tersedia pada fase ini.',
          ),
        ),
        _SettingsLink(
          title: 'Privasi dan persetujuan',
          detail: 'Pilihan cloud dan analitik tersimpan terpisah.',
          icon: Icons.privacy_tip_outlined,
          onTap: () => context.push('/privacy-setup'),
        ),
        _SettingsLink(
          title: 'Akun',
          detail: 'Login bersifat opsional.',
          icon: Icons.person_outline_rounded,
          onTap: () => context.push('/profile'),
        ),
        _SettingsLink(
          title: 'Sinkronisasi',
          detail: 'Hanya tersedia setelah login dan opt-in.',
          icon: Icons.cloud_outlined,
          onTap: () => context.push('/sync'),
        ),
        _SettingsLink(
          title: 'Kelola data perangkat',
          detail: 'Lihat cakupan penyimpanan dan kontrol yang tersedia.',
          icon: Icons.storage_outlined,
          onTap: () => context.push('/settings/data'),
        ),
        _SettingsLink(
          title: 'Tentang KONSENA AI',
          detail: 'Batasan, privasi, dan informasi aplikasi.',
          icon: Icons.info_outline_rounded,
          onTap: () => context.push('/about'),
        ),
        _SettingsLink(
          title: 'Lihat tutorial',
          detail: 'Tutorial onboarding dapat dibuka kembali.',
          icon: Icons.school_outlined,
          onTap: () => context.push('/welcome'),
        ),
      ],
    ),
  );

  static void _explain(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}

class _SettingsLink extends StatelessWidget {
  const _SettingsLink({
    required this.title,
    required this.detail,
    required this.icon,
    required this.onTap,
  });
  final String title;
  final String detail;
  final IconData icon;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      minTileHeight: 72,
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(detail),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    ),
  );
}
