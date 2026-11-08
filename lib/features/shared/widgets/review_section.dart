import 'package:flutter/material.dart';

import '../../../theme/konsena_spacing.dart';

class ReviewSection extends StatelessWidget {
  const ReviewSection({
    required this.icon,
    required this.title,
    required this.children,
    this.subtitle,
    super.key,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(KonsenaRadii.cardLarge),
        side: BorderSide(color: colors.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(KonsenaSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: colors.primaryContainer,
                    borderRadius: BorderRadius.circular(KonsenaRadii.tile),
                  ),
                  child: Icon(icon, color: colors.onPrimaryContainer, size: 22),
                ),
                const SizedBox(width: KonsenaSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Semantics(
                        header: true,
                        child: Text(title, style: theme.textTheme.titleMedium),
                      ),
                      if (subtitle case final text?)
                        Text(text, style: theme.textTheme.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
            if (children.isNotEmpty) const SizedBox(height: KonsenaSpacing.md),
            ...children,
          ],
        ),
      ),
    );
  }
}
