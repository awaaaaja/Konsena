import 'package:flutter/material.dart';

import '../../../theme/konsena_colors.dart';
import '../../../theme/konsena_spacing.dart';
import '../../../theme/konsena_typography.dart';

/// Primary pill CTA (Royal Violet, white label, ≥48dp).
///
/// This is the reusable form of the rounded violet CTA seen in the Stitch
/// onboarding reference — rebuilt from tokens, not copied from HTML.
class KonsenaPrimaryButton extends StatelessWidget {
  const KonsenaPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.expand = true,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  /// When true the button fills the available width (default app CTA shape).
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final button = FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: KonsenaColors.primary,
        foregroundColor: KonsenaColors.textOnPrimary,
        minimumSize: const Size(
          KonsenaTouch.minTarget,
          KonsenaTouch.minTarget + 4,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: KonsenaSpacing.xl,
          vertical: KonsenaSpacing.sm,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(KonsenaRadii.pill),
        ),
      ),
      child: icon == null
          ? Text(label)
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(child: Text(label, softWrap: true)),
                const SizedBox(width: KonsenaSpacing.xs),
                Icon(icon, size: 18),
              ],
            ),
    );

    if (!expand) return button;
    return SizedBox(width: double.infinity, child: button);
  }
}

/// White pill CTA used on dark/gradient surfaces (S03 hero `Mulai Audit`).
class KonsenaOnDarkButton extends StatelessWidget {
  const KonsenaOnDarkButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final largeText = MediaQuery.textScalerOf(context).scale(1) >= 1.3;
    final button = FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: KonsenaColors.white,
        foregroundColor: KonsenaColors.primary,
        elevation: 2,
        minimumSize: const Size(
          KonsenaTouch.minTarget,
          KonsenaTouch.minTarget - 4,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: KonsenaSpacing.lg,
          vertical: KonsenaSpacing.xs,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(KonsenaRadii.control),
        ),
      ),
      child: icon == null || largeText
          ? Text(label)
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(child: Text(label, softWrap: true)),
                const SizedBox(width: KonsenaSpacing.xs),
                Icon(icon, size: 16),
              ],
            ),
    );
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.sizeOf(context).width - 64,
      ),
      child: button,
    );
  }
}

/// Circular violet CTA from the onboarding reference (56dp ≥ 48dp target).
class KonsenaRoundCta extends StatelessWidget {
  const KonsenaRoundCta({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.semanticsLabel,
  });

  final VoidCallback? onPressed;
  final IconData icon;
  final String semanticsLabel;

  static const double size = 56;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticsLabel,
      child: Material(
        color: Colors.transparent,
        child: Ink(
          width: size,
          height: size,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [KonsenaColors.deepIndigo, KonsenaColors.primary],
            ),
            boxShadow: [
              BoxShadow(
                color: Color(0x385A3DAD),
                offset: Offset(0, 8),
                blurRadius: 18,
                spreadRadius: -4,
              ),
            ],
          ),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onPressed,
            child: Icon(icon, color: KonsenaColors.white, size: 24),
          ),
        ),
      ),
    );
  }
}

/// Quiet secondary text action with a guaranteed 48dp target
/// (onboarding `Lewati`).
class KonsenaTextAction extends StatelessWidget {
  const KonsenaTextAction({
    super.key,
    required this.label,
    required this.onPressed,
    this.color,
    this.semanticsLabel,
  });

  final String label;
  final VoidCallback? onPressed;
  final Color? color;

  /// Accessibility label override (the visible text stays [label]).
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticsLabel ?? label,
      excludeSemantics: true,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          foregroundColor: color ?? KonsenaColors.primary,
          minimumSize: const Size(
            KonsenaTouch.minTarget,
            KonsenaTouch.minTarget,
          ),
          padding: const EdgeInsets.symmetric(horizontal: KonsenaSpacing.sm),
          textStyle: KonsenaTypography.style(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: color ?? KonsenaColors.primary,
          ),
        ),
        child: Text(label),
      ),
    );
  }
}
