import 'package:flutter/material.dart';

import '../../../../theme/konsena_colors.dart';
import '../../../../theme/konsena_shadows.dart';
import '../../../../theme/konsena_spacing.dart';

/// S03 "Bagaimana cara kerjanya?": one card with three numbered rows
/// (DESIGN_SYSTEM §8.2 — rows carry a pill label and are informational; they
/// are not tappable because their destinations arrive in later phases).
class HowItWorksCard extends StatelessWidget {
  const HowItWorksCard({super.key});

  static const List<_Step> _steps = [
    _Step('Pilih sumber audit', 'Direncanakan'),
    _Step('Tinjau izin & dokumen', 'Belum aktif'),
    _Step('Periksa bukti sebelum bertindak', 'Tanpa contoh'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Bagaimana cara kerjanya?', style: theme.textTheme.titleSmall),
        const SizedBox(height: KonsenaSpacing.sm),
        Container(
          padding: const EdgeInsets.all(KonsenaSpacing.cardPadding),
          decoration: BoxDecoration(
            color: KonsenaColors.surface,
            borderRadius: BorderRadius.circular(KonsenaRadii.hero),
            border: Border.all(color: KonsenaColors.lavender),
            boxShadow: KonsenaShadows.subtle,
          ),
          child: Column(
            children: [
              for (var i = 0; i < _steps.length; i++) ...[
                if (i > 0)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: KonsenaSpacing.xxs),
                    child: Divider(height: 1),
                  ),
                _StepRow(index: i + 1, step: _steps[i]),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _Step {
  const _Step(this.title, this.pill);

  final String title;
  final String pill;
}

class _StepRow extends StatelessWidget {
  const _StepRow({required this.index, required this.step});

  final int index;
  final _Step step;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final largeText = MediaQuery.textScalerOf(context).scale(1) >= 1.3;

    if (largeText) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: KonsenaSpacing.xs),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _StepNumber(index: index),
                const SizedBox(width: KonsenaSpacing.sm),
                Expanded(
                  child: Text(step.title, style: theme.textTheme.labelMedium),
                ),
              ],
            ),
            const SizedBox(height: KonsenaSpacing.xs),
            Padding(
              padding: const EdgeInsets.only(left: 36),
              child: _StepPill(label: step.pill),
            ),
          ],
        ),
      );
    }

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: KonsenaTouch.minTarget),
      child: Row(
        children: [
          _StepNumber(index: index),
          const SizedBox(width: KonsenaSpacing.sm),
          Expanded(child: Text(step.title, style: theme.textTheme.labelMedium)),
          const SizedBox(width: KonsenaSpacing.xs),
          _StepPill(label: step.pill),
        ],
      ),
    );
  }
}

class _StepNumber extends StatelessWidget {
  const _StepNumber({required this.index});
  final int index;

  @override
  Widget build(BuildContext context) => Container(
    width: 24,
    height: 24,
    alignment: Alignment.center,
    decoration: const BoxDecoration(
      shape: BoxShape.circle,
      color: KonsenaColors.softLilac,
    ),
    child: Text(
      '$index',
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: KonsenaColors.primary,
        fontSize: 11,
        letterSpacing: 0,
      ),
    ),
  );
}

class _StepPill extends StatelessWidget {
  const _StepPill({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(
      horizontal: KonsenaSpacing.xs,
      vertical: 5,
    ),
    decoration: BoxDecoration(
      color: KonsenaColors.softLilac,
      borderRadius: BorderRadius.circular(KonsenaRadii.pill),
    ),
    child: Text(
      label,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: KonsenaColors.primary,
        fontSize: 10,
        letterSpacing: 0.4,
      ),
    ),
  );
}
