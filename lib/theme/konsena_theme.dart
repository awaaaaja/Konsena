import 'package:flutter/material.dart';

import 'konsena_colors.dart';
import 'konsena_spacing.dart';
import 'konsena_typography.dart';

/// Builds the KONSENA `ThemeData` from approved tokens.
///
/// Light palette is mandatory (DESIGN_SYSTEM §1); dark mode is a separate QA
/// gate and is intentionally not enabled here.
abstract final class KonsenaTheme {
  static ThemeData light() {
    final textTheme = KonsenaTypography.textTheme();

    final scheme =
        ColorScheme.fromSeed(
          seedColor: KonsenaColors.royalViolet,
          brightness: Brightness.light,
        ).copyWith(
          primary: KonsenaColors.royalViolet,
          onPrimary: KonsenaColors.textOnPrimary,
          secondary: KonsenaColors.electricViolet,
          onSecondary: KonsenaColors.textOnPrimary,
          surface: KonsenaColors.cloudWhite,
          onSurface: KonsenaColors.textPrimary,
          error: KonsenaColors.dangerRed,
          onError: KonsenaColors.textPrimary, // white on red is below AA (§1)
          outline: KonsenaColors.lavender,
          outlineVariant: KonsenaColors.lavender,
          surfaceContainerLowest: KonsenaColors.white,
          surfaceContainerLow: KonsenaColors.cloudWhite,
          surfaceContainer: KonsenaColors.cloudWhite,
          surfaceContainerHigh: KonsenaColors.paleLavender,
          surfaceContainerHighest: KonsenaColors.softLilac,
        );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: KonsenaColors.backgroundPage,
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: KonsenaColors.backgroundPage,
        surfaceTintColor: Colors.transparent,
        foregroundColor: KonsenaColors.textPrimary,
        titleTextStyle: textTheme.titleLarge,
      ),
      cardTheme: CardThemeData(
        color: KonsenaColors.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(KonsenaRadii.cardLarge),
          side: const BorderSide(color: KonsenaColors.lavender),
        ),
      ),
      // Every primary action is a pill CTA with a guaranteed 48dp target.
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: KonsenaColors.primary,
          foregroundColor: KonsenaColors.textOnPrimary,
          minimumSize: const Size(
            KonsenaTouch.minTarget,
            KonsenaTouch.minTarget,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: KonsenaSpacing.xl,
            vertical: KonsenaSpacing.sm,
          ),
          textStyle: textTheme.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(KonsenaRadii.pill),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: KonsenaColors.primary,
          minimumSize: const Size(
            KonsenaTouch.minTarget,
            KonsenaTouch.minTarget,
          ),
          side: const BorderSide(color: KonsenaColors.borderInteractive),
          textStyle: textTheme.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(KonsenaRadii.pill),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: KonsenaColors.primary,
          minimumSize: const Size(
            KonsenaTouch.minTarget,
            KonsenaTouch.minTarget,
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? KonsenaColors.white
              : KonsenaColors.cloudWhite,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? KonsenaColors.primary
              : KonsenaColors.lavender,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: KonsenaColors.lavender,
        thickness: 1,
        space: 1,
      ),
    );
  }
}
