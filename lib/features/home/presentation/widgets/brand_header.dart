import 'package:flutter/material.dart';

import '../../../../theme/konsena_colors.dart';
import '../../../../theme/konsena_spacing.dart';

/// S03 brand header: emblem + wordmark + `PRIVACY INTELLIGENCE`, with an
/// honest mode chip on the right (no `DEMO` badge in production —
/// DESIGN_SYSTEM §8.4).
class BrandHeader extends StatelessWidget {
  const BrandHeader({super.key, required this.isGuest});

  final bool isGuest;

  static const String _logoAsset = 'assets/brand/konsena_mark_transparent.png';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textScale = MediaQuery.textScalerOf(context).scale(1);

    if (textScale >= 1.5 || MediaQuery.sizeOf(context).width <= 340) {
      return LayoutBuilder(
        builder: (context, constraints) => Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          runSpacing: KonsenaSpacing.xs,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Semantics(
                  image: true,
                  label: 'Logo KONSENA AI',
                  child: ExcludeSemantics(
                    child: Image.asset(
                      _logoAsset,
                      width: 34,
                      height: 34,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.verified_user_outlined,
                        color: KonsenaColors.primary,
                        size: 30,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: KonsenaSpacing.sm),
                SizedBox(
                  width: constraints.maxWidth - 46,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'KONSENA AI',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.1,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'PRIVACY INTELLIGENCE',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: KonsenaColors.accent,
                          fontSize: 10,
                          letterSpacing: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            _ModeChip(isGuest: isGuest, theme: theme),
          ],
        ),
      );
    }

    return Row(
      children: [
        Semantics(
          image: true,
          label: 'Logo KONSENA AI',
          child: ExcludeSemantics(
            child: Image.asset(
              _logoAsset,
              width: 34,
              height: 34,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.verified_user_outlined,
                color: KonsenaColors.primary,
                size: 30,
              ),
            ),
          ),
        ),
        const SizedBox(width: KonsenaSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'KONSENA AI',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'PRIVACY INTELLIGENCE',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: KonsenaColors.accent,
                  fontSize: 10,
                  letterSpacing: 1.6,
                ),
              ),
            ],
          ),
        ),
        _ModeChip(isGuest: isGuest, theme: theme),
      ],
    );
  }
}

class _ModeChip extends StatelessWidget {
  const _ModeChip({required this.isGuest, required this.theme});
  final bool isGuest;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(
      horizontal: KonsenaSpacing.sm,
      vertical: 6,
    ),
    decoration: BoxDecoration(
      color: KonsenaColors.softLilac,
      borderRadius: BorderRadius.circular(KonsenaRadii.pill),
      border: Border.all(color: KonsenaColors.lavender),
    ),
    child: Text(
      isGuest ? 'Mode tamu' : 'Tersambung',
      style: theme.textTheme.labelSmall?.copyWith(
        color: KonsenaColors.primary,
        fontSize: 10,
      ),
    ),
  );
}
