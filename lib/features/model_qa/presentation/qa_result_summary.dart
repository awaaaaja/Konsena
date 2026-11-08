import 'package:flutter/material.dart';

import '../../../theme/konsena_spacing.dart';

class QaResultSummary extends StatefulWidget {
  const QaResultSummary({
    required this.icon,
    required this.title,
    required this.meaning,
    required this.nextCheck,
    super.key,
  });

  final IconData icon;
  final String title, meaning, nextCheck;

  @override
  State<QaResultSummary> createState() => _QaResultSummaryState();
}

class _QaResultSummaryState extends State<QaResultSummary> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Scrollable.ensureVisible(
        context,
        alignment: 0.1,
        duration: MediaQuery.disableAnimationsOf(context)
            ? Duration.zero
            : const Duration(milliseconds: 240),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          header: true,
          child: Text('Hasil pemeriksaan', style: theme.textTheme.titleSmall),
        ),
        const SizedBox(height: KonsenaSpacing.xs),
        Semantics(
          liveRegion: true,
          child: Container(
            padding: const EdgeInsets.all(KonsenaSpacing.sm),
            decoration: BoxDecoration(
              color: colors.secondaryContainer,
              borderRadius: BorderRadius.circular(KonsenaRadii.control),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(widget.icon, color: colors.onSecondaryContainer),
                const SizedBox(width: KonsenaSpacing.xs),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: colors.onSecondaryContainer,
                        ),
                      ),
                      const SizedBox(height: KonsenaSpacing.xxs),
                      Text(
                        widget.meaning,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colors.onSecondaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: KonsenaSpacing.sm),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.fact_check_outlined, color: colors.primary, size: 20),
            const SizedBox(width: KonsenaSpacing.xs),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Yang bisa dicek', style: theme.textTheme.titleSmall),
                  Text(widget.nextCheck),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
