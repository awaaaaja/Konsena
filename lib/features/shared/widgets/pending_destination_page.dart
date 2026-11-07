import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../theme/konsena_colors.dart';
import '../../../theme/konsena_spacing.dart';
import 'konsena_buttons.dart';

/// Honest placeholder for a destination whose real screen arrives in a later
/// phase (currently S24 · Pilih Aplikasi, Phase 02/03).
///
/// It exists so required CTAs such as `Mulai Audit` really navigate instead of
/// being dead controls. The copy states plainly that the screen is not built
/// yet — no fake list, no fake analysis, no simulated data.
class PendingDestinationPage extends StatelessWidget {
  const PendingDestinationPage({
    super.key,
    required this.title,
    required this.routeName,
    required this.availableIn,
  });

  final String title;

  /// Route identifier, shown so the navigation contract is testable.
  final String routeName;

  /// Human readable phase label, e.g. `Phase 02`.
  final String availableIn;

  /// Destinations whose real screens do not exist yet share this path shape.
  static const String routePath = '/audit/new';

  /// Dashboard route used by the "back" action.
  static const String homeRoute = '/home';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: KonsenaColors.backgroundPage,
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(KonsenaSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.hourglass_top_rounded,
                size: 40,
                color: KonsenaColors.accent,
              ),
              const SizedBox(height: KonsenaSpacing.md),
              Text(
                'Layar ini belum dibangun',
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: KonsenaSpacing.sm),
              Text(
                'Tujuan $routeName ($title) dijadwalkan pada $availableIn. '
                'Tidak ada data audit yang ditampilkan karena memang belum ada. '
                'Anda kembali ke beranda kapan saja.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: KonsenaSpacing.xl),
              KonsenaPrimaryButton(
                label: 'Kembali ke Beranda',
                onPressed: () => context.go(homeRoute),
                expand: false,
                icon: Icons.arrow_back_rounded,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
