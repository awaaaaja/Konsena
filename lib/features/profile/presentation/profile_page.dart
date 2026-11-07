import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../theme/konsena_spacing.dart';

/// S21 — useful in guest mode. Authentication is strictly optional and Phase 07.
class ProfilePage extends StatelessWidget {
  const ProfilePage({this.showSyncNotice = false, super.key});

  final bool showSyncNotice;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Profil')),
    body: ListView(
      padding: const EdgeInsets.all(KonsenaSpacing.lg),
      children: [
        if (showSyncNotice) ...[
          const Card(
            child: ListTile(
              leading: Icon(Icons.info_outline_rounded),
              title: Text('Sinkronisasi belum diaktifkan'),
              subtitle: Text(
                'Login dan persetujuan eksplisit diperlukan. Fitur lokal tetap dapat digunakan.',
              ),
            ),
          ),
          const SizedBox(height: KonsenaSpacing.sm),
        ],
        const CircleAvatar(
          radius: 34,
          child: Icon(Icons.person_outline_rounded, size: 34),
        ),
        const SizedBox(height: KonsenaSpacing.md),
        Text(
          'Mode tamu — data di perangkat',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: KonsenaSpacing.xs),
        const Text(
          'Kamu dapat memakai alur lokal tanpa membuat akun. Data tidak disinkronkan otomatis.',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: KonsenaSpacing.lg),
        _ProfileLink(
          icon: Icons.tune_rounded,
          title: 'Pengaturan privasi',
          onTap: () => context.push('/settings'),
        ),
        _ProfileLink(
          icon: Icons.storage_outlined,
          title: 'Kontrol data',
          onTap: () => context.push('/settings/data'),
        ),
        _ProfileLink(
          icon: Icons.info_outline_rounded,
          title: 'Tentang dan batasan',
          onTap: () => context.push('/about'),
        ),
        _ProfileLink(
          icon: Icons.cloud_outlined,
          title: 'Sinkronisasi pilihan',
          onTap: () => context.push('/sync'),
        ),
        const SizedBox(height: KonsenaSpacing.md),
        OutlinedButton.icon(
          onPressed: () => showDialog<void>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Login opsional'),
              content: const Text(
                'Login dan sinkronisasi belum diaktifkan. Mode tamu tetap dapat digunakan; login tidak akan mengunggah data otomatis.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Mengerti'),
                ),
              ],
            ),
          ),
          icon: const Icon(Icons.login_rounded),
          label: const Text('Masuk atau buat akun (opsional)'),
        ),
        const SizedBox(height: KonsenaSpacing.sm),
        Text(
          'Login cloud direncanakan pada Phase 07.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    ),
  );
}

class _ProfileLink extends StatelessWidget {
  const _ProfileLink({
    required this.icon,
    required this.title,
    required this.onTap,
  });
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      minTileHeight: 56,
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    ),
  );
}
