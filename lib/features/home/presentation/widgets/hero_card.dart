import 'package:flutter/material.dart';

import '../../../../theme/konsena_colors.dart';
import '../../../../theme/konsena_shadows.dart';
import '../../../../theme/konsena_spacing.dart';
import '../../../shared/widgets/konsena_buttons.dart';

/// S03 hero: Midnight Purple → Deep Indigo → Royal Violet gradient with the
/// mandated overline, headline, description and white `Mulai Audit` CTA
/// (DESIGN_SYSTEM §8.2). The CTA navigates to S24.
class HeroAuditCard extends StatelessWidget {
  const HeroAuditCard({super.key, required this.onStartAudit});

  final VoidCallback onStartAudit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: KonsenaGradients.hero,
        borderRadius: BorderRadius.circular(KonsenaRadii.hero),
        boxShadow: KonsenaShadows.hero,
      ),
      child: Stack(
        children: [
          // Decorative ambient glow (non-interactive).
          Positioned(
            top: -60,
            right: -50,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: KonsenaColors.electricViolet.withValues(alpha: 0.2),
                ),
                child: const SizedBox(width: 180, height: 180),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(KonsenaSpacing.cardPaddingLarge),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AUDIT PERSETUJUAN DIGITAL',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: KonsenaColors.softLilac,
                    letterSpacing: 1.8,
                  ),
                ),
                const SizedBox(height: KonsenaSpacing.xs),
                Text(
                  'Pahami izin.\nLindungi privasi.',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: KonsenaColors.white,
                    fontSize: 26,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: KonsenaSpacing.sm),
                Text(
                  'Siapkan audit izin aplikasi dan kebijakan privasi secara '
                  'berbasis bukti. Pemindaian sumber belum tersedia pada versi ini.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: KonsenaColors.paleLavender,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: KonsenaSpacing.lg),
                KonsenaOnDarkButton(
                  label: 'Mulai Audit',
                  icon: Icons.north_east_rounded,
                  onPressed: onStartAudit,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
