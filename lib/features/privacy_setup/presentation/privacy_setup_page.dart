import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/journey/journey_store.dart';
import '../../../theme/konsena_colors.dart';
import '../../../theme/konsena_shadows.dart';
import '../../../theme/konsena_spacing.dart';
import '../../shared/widgets/konsena_buttons.dart';

/// S02 — Privacy Setup dan Persetujuan Data.
///
/// **There is no Stitch source for this screen** (only S00/S01/S03 have one);
/// the layout is derived from `docs/DESIGN_SYSTEM.md` §8.1 — compact app bar,
/// 16–24dp padding, rounded cards, one dominant CTA.
///
/// Contract (PAGE_BY_PAGE S02):
///  * guest-first: `Lanjut sebagai tamu` always works;
///  * `cloud_opt_in = false` and `analytics_opt_in = false` by default;
///  * consents are **separate** — nothing silently enables cloud;
///  * **no camera permission is requested here** (camera is requested
///    just-in-time at S08); the page states that explicitly.
class PrivacySetupPage extends StatefulWidget {
  const PrivacySetupPage({super.key, required this.store});

  final JourneyStore store;

  static const String routePath = '/privacy-setup';
  static const String nextRoute = '/home';

  @override
  State<PrivacySetupPage> createState() => _PrivacySetupPageState();
}

class _PrivacySetupPageState extends State<PrivacySetupPage> {
  bool _cloudOptIn = false;
  bool _analyticsOptIn = false;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _restore();
  }

  Future<void> _restore() async {
    final snapshot = await widget.store.load();
    if (!mounted) return;
    setState(() {
      _cloudOptIn = snapshot.cloudOptIn;
      _analyticsOptIn = snapshot.analyticsOptIn;
      _loaded = true;
    });
  }

  Future<void> _continueAsGuest() async {
    await widget.store.setPrivacySetupSeen(cloudOptIn: _cloudOptIn);
    await widget.store.setAnalyticsOptIn(_analyticsOptIn);
    if (!mounted) return;
    context.go(PrivacySetupPage.nextRoute);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: KonsenaColors.backgroundPage,
      appBar: AppBar(
        title: const Text('Pengaturan Privasi'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: 'Kembali',
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/welcome');
            }
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            KonsenaSpacing.lg,
            KonsenaSpacing.sm,
            KonsenaSpacing.lg,
            KonsenaSpacing.xl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pilihan privasi untuk penggunaan lokal',
                style: theme.textTheme.headlineMedium?.copyWith(fontSize: 22),
              ),
              const SizedBox(height: KonsenaSpacing.sm),
              _LocalDataCard(
                message:
                    'Impor dokumen, pemrosesan sumber, dan penyimpanan audit '
                    'belum aktif pada versi ini. Pilihan cloud tetap nonaktif '
                    'sampai kamu memberi persetujuan.',
              ),
              const SizedBox(height: KonsenaSpacing.xl),
              Text(
                'Pilih persetujuan secara terpisah',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: KonsenaSpacing.xs),
              _ConsentCard(
                icon: Icons.phone_android_rounded,
                title: 'Alur lokal',
                subtitle:
                    'Mode tamu tersedia. Pemrosesan dokumen dan audit belum '
                    'tersedia pada versi ini.',
                trailing: const _NotAvailableBadge(),
              ),
              const SizedBox(height: KonsenaSpacing.sm),
              _ConsentCard(
                icon: Icons.cloud_off_rounded,
                title: 'Sinkronisasi cloud',
                subtitle:
                    'Nonaktif secara bawaan. Bila kamu nyalakan, hanya data '
                    'yang kamu pilih yang dapat diunggah — tersedia setelah '
                    'fase login.',
                trailing: Switch(
                  value: _cloudOptIn,
                  onChanged: _loaded
                      ? (value) => setState(() => _cloudOptIn = value)
                      : null,
                ),
              ),
              const SizedBox(height: KonsenaSpacing.sm),
              _ConsentCard(
                icon: Icons.insights_rounded,
                title: 'Statistik penggunaan',
                subtitle:
                    'Pilihan persetujuan tersimpan. Pengiriman statistik belum '
                    'aktif pada versi ini.',
                trailing: Switch(
                  value: _analyticsOptIn,
                  onChanged: _loaded
                      ? (value) => setState(() => _analyticsOptIn = value)
                      : null,
                ),
              ),
              const SizedBox(height: KonsenaSpacing.sm),
              // Explicit statement: camera permission is NOT part of S02.
              _ConsentCard(
                icon: Icons.photo_camera_outlined,
                title: 'Kamera',
                subtitle:
                    'Belum diminta di halaman ini. Izin kamera hanya diminta '
                    'saat kamu memulai pindai.',
                trailing: const _NotRequestedBadge(),
              ),
              const SizedBox(height: KonsenaSpacing.xl),
              KonsenaPrimaryButton(
                label: 'Lanjut sebagai tamu',
                onPressed: _continueAsGuest,
              ),
              const SizedBox(height: KonsenaSpacing.xs),
              Center(
                child: Text(
                  'Tidak perlu akun. Kamu bisa mengubah pilihan ini kapan '
                  'saja lewat Pengaturan.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LocalDataCard extends StatelessWidget {
  const _LocalDataCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(KonsenaSpacing.cardPadding),
      decoration: BoxDecoration(
        color: KonsenaColors.paleLavender,
        borderRadius: BorderRadius.circular(KonsenaRadii.cardLarge),
        border: Border.all(color: KonsenaColors.lavender),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.devices_rounded,
            color: KonsenaColors.primary,
            size: 22,
          ),
          const SizedBox(width: KonsenaSpacing.sm),
          Expanded(child: Text(message, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }
}

class _ConsentCard extends StatelessWidget {
  const _ConsentCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(KonsenaSpacing.cardPadding),
      decoration: BoxDecoration(
        color: KonsenaColors.surface,
        borderRadius: BorderRadius.circular(KonsenaRadii.card),
        border: Border.all(color: KonsenaColors.lavender),
        boxShadow: KonsenaShadows.subtle,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: KonsenaColors.softLilac,
              borderRadius: BorderRadius.circular(KonsenaRadii.tile),
            ),
            child: Icon(icon, color: KonsenaColors.primary, size: 20),
          ),
          const SizedBox(width: KonsenaSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.titleSmall),
                const SizedBox(height: KonsenaSpacing.xxs),
                Text(subtitle, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
          const SizedBox(width: KonsenaSpacing.xs),
          // The whole row keeps a ≥48dp interactive height via the switch.
          trailing,
        ],
      ),
    );
  }
}

class _NotAvailableBadge extends StatelessWidget {
  const _NotAvailableBadge();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Belum tersedia',
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: KonsenaSpacing.xs,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: KonsenaColors.softLilac,
          borderRadius: BorderRadius.circular(KonsenaRadii.pill),
        ),
        child: const Text(
          'Belum aktif',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: KonsenaColors.primary,
          ),
        ),
      ),
    );
  }
}

class _NotRequestedBadge extends StatelessWidget {
  const _NotRequestedBadge();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Belum diminta',
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: KonsenaSpacing.xs,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: KonsenaColors.cloudWhite,
          borderRadius: BorderRadius.circular(KonsenaRadii.pill),
          border: Border.all(color: KonsenaColors.borderInteractive),
        ),
        child: const Text(
          'Belum diminta',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: KonsenaColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
