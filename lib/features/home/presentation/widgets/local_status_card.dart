import 'package:flutter/material.dart';

import '../../../../core/config/cloud_status.dart';
import '../../../../theme/konsena_colors.dart';
import '../../../../theme/konsena_shadows.dart';
import '../../../../theme/konsena_spacing.dart';
import '../home_cubit.dart';

/// Honest mode/cloud status card (below the fold on S03).
///
/// Shows the real gateway state and guest mode; it never claims protection,
/// never shows a score, and keeps the Phase 00 startup contract visible.
class LocalStatusCard extends StatelessWidget {
  const LocalStatusCard({super.key, required this.state});

  final HomeState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final live = state.isCloudFeatureEnabled;
    final statusColor = live
        ? KonsenaColors.successGreen
        : KonsenaColors.primary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(KonsenaSpacing.cardPadding),
      decoration: BoxDecoration(
        color: KonsenaColors.paleLavender,
        borderRadius: BorderRadius.circular(KonsenaRadii.card),
        border: Border.all(color: KonsenaColors.lavender),
        boxShadow: KonsenaShadows.subtle,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Mode & sinkronisasi', style: theme.textTheme.titleSmall),
          const SizedBox(height: KonsenaSpacing.sm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                live ? Icons.cloud_done : Icons.cloud_off,
                color: statusColor,
                size: 22,
              ),
              const SizedBox(width: KonsenaSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      live ? 'Cloud tersambung' : 'Cloud tidak aktif',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: statusColor,
                      ),
                    ),
                    const SizedBox(height: KonsenaSpacing.xxs),
                    Text(
                      state.cloudStatus.displayText,
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(height: KonsenaSpacing.xs),
                    Text(
                      state.isGuest
                          ? 'Mode tamu — tidak ada sesi autentikasi. '
                                'Draft audit saat ini hanya bertahan selama '
                                'sesi aplikasi.'
                          : 'Tersambung ke akun — unggahan tetap memerlukan '
                                'persetujuan eksplisit.',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: KonsenaSpacing.sm),
          Text(
            'Sinkronisasi cloud bersifat opt-in dan nonaktif secara bawaan. '
            'Unggahan bukti/OCR baru tersedia setelah persetujuan eksplisit.',
            style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
          ),
        ],
      ),
    );
  }
}
