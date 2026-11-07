import 'package:flutter/material.dart';

import '../../../../theme/konsena_colors.dart';
import '../../../../theme/konsena_shadows.dart';
import '../../../../theme/konsena_spacing.dart';
import '../../domain/home_summary_repository.dart';

/// S03 "Ringkasan aktivitas": two cards whose numbers come from
/// [HomeSummary] (repository state) — never from literals in this widget.
///
/// Responsive: single column below 340dp of available width **or** when the
/// system text scale is large (≥1.3×), so 320dp and 200% text never overflow.
class SummarySection extends StatelessWidget {
  const SummarySection({
    super.key,
    required this.summary,
    required this.isEmpty,
  });

  final HomeSummary summary;

  /// Whether the device has no audit data yet (shows the empty-state copy).
  final bool isEmpty;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                'Ringkasan aktivitas',
                style: theme.textTheme.titleSmall,
              ),
            ),
            const SizedBox(width: KonsenaSpacing.xs),
            Flexible(
              child: Text(
                'Tersimpan di perangkat',
                textAlign: TextAlign.end,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 11,
                  color: KonsenaColors.accent,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: KonsenaSpacing.sm),
        LayoutBuilder(
          builder: (context, constraints) {
            final textScale = MediaQuery.textScalerOf(context).scale(1);
            final singleColumn = constraints.maxWidth < 340 || textScale >= 1.3;

            final cards = [
              SummaryCard(
                icon: Icons.assignment_outlined,
                value: summary.auditCount,
                label: 'Audit tersimpan',
              ),
              SummaryCard(
                icon: Icons.rule_rounded,
                value: summary.findingCount,
                label: 'Temuan tersimpan',
              ),
            ];

            if (singleColumn) {
              return Column(
                children: [
                  cards[0],
                  const SizedBox(height: KonsenaSpacing.md),
                  cards[1],
                ],
              );
            }
            return Row(
              children: [
                Expanded(child: cards[0]),
                const SizedBox(width: KonsenaSpacing.cardGap),
                Expanded(child: cards[1]),
              ],
            );
          },
        ),
        if (isEmpty) ...[
          const SizedBox(height: KonsenaSpacing.md),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(KonsenaSpacing.cardPadding),
            decoration: BoxDecoration(
              color: KonsenaColors.paleLavender,
              borderRadius: BorderRadius.circular(KonsenaRadii.card),
              border: Border.all(color: KonsenaColors.lavender),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Belum ada audit. Pilih aplikasi atau pindai dokumen.',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: KonsenaSpacing.xxs),
                Text(
                  'Semua angka di atas berasal dari data lokal perangkat ini.',
                  style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

/// One summary metric card (icon chip, value, label).
class SummaryCard extends StatelessWidget {
  const SummaryCard({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;

  /// Value read from state — the widget never invents a number.
  final int value;

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      constraints: const BoxConstraints(minHeight: KonsenaTouch.minTarget),
      padding: const EdgeInsets.all(KonsenaSpacing.cardPadding),
      decoration: BoxDecoration(
        color: KonsenaColors.surface,
        borderRadius: BorderRadius.circular(KonsenaRadii.cardLarge),
        border: Border.all(color: KonsenaColors.lavender),
        boxShadow: KonsenaShadows.subtle,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: KonsenaColors.softLilac,
              borderRadius: BorderRadius.circular(KonsenaRadii.tile),
            ),
            child: Icon(icon, color: KonsenaColors.primary, size: 20),
          ),
          const SizedBox(height: KonsenaSpacing.sm),
          Text(
            '$value',
            style: theme.textTheme.headlineSmall?.copyWith(height: 1),
          ),
          const SizedBox(height: KonsenaSpacing.xxs),
          Text(label, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}
