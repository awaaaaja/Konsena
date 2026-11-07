import 'package:flutter/material.dart';

import 'konsena_colors.dart';

/// Typography tokens for KONSENA AI.
///
/// Primary family is **Plus Jakarta Sans** (SIL OFL 1.1, bundled in
/// `fonts/` with `fonts/OFL.txt`). The fallback list is explicit and ordered
/// so a missing/incomplete font asset degrades to a consistent platform face
/// instead of silently rendering with an unknown default.
abstract final class KonsenaTypography {
  /// Bundled family name (must match the `fonts:` entry in pubspec.yaml).
  static const String fontFamily = 'PlusJakartaSans';

  /// Explicit, ordered fallbacks when the bundled asset cannot be loaded.
  static const List<String> fontFamilyFallback = [
    'Roboto', // Android platform default
    'Noto Sans',
    'sans-serif',
  ];

  /// Base style helper used by every text style in the app.
  static TextStyle style({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? height,
    double? letterSpacing,
  }) {
    return TextStyle(
      fontFamily: fontFamily,
      fontFamilyFallback: fontFamilyFallback,
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  /// `TextTheme` from DESIGN_SYSTEM §1 + luminous DESIGN.md typography scale.
  static TextTheme textTheme() {
    const body = KonsenaColors.textSecondary;

    return TextTheme(
      // headline-xl 32/40 w800
      displaySmall: style(
        fontSize: 32,
        height: 40 / 32,
        fontWeight: FontWeight.w800,
        color: KonsenaColors.textPrimary,
        letterSpacing: -0.4,
      ),
      // headline-lg 24/32 w700
      headlineMedium: style(
        fontSize: 24,
        height: 32 / 24,
        fontWeight: FontWeight.w700,
        color: KonsenaColors.textPrimary,
        letterSpacing: -0.3,
      ),
      // headline-md 20/28 w700
      headlineSmall: style(
        fontSize: 20,
        height: 28 / 20,
        fontWeight: FontWeight.w700,
        color: KonsenaColors.textPrimary,
      ),
      // headline-sm 18/24 w600
      titleLarge: style(
        fontSize: 18,
        height: 24 / 18,
        fontWeight: FontWeight.w600,
        color: KonsenaColors.textPrimary,
      ),
      // label-lg 15/20 w600
      titleMedium: style(
        fontSize: 15,
        height: 20 / 15,
        fontWeight: FontWeight.w600,
        color: KonsenaColors.textPrimary,
      ),
      // label-md 13/18 w600
      titleSmall: style(
        fontSize: 13,
        height: 18 / 13,
        fontWeight: FontWeight.w600,
        color: KonsenaColors.textPrimary,
      ),
      // body-lg 16/24 w400
      bodyLarge: style(
        fontSize: 16,
        height: 24 / 16,
        fontWeight: FontWeight.w400,
        color: body,
      ),
      // body-md 14/20 w400
      bodyMedium: style(
        fontSize: 14,
        height: 20 / 14,
        fontWeight: FontWeight.w400,
        color: body,
      ),
      // body-sm 12/16 w400
      bodySmall: style(
        fontSize: 12,
        height: 16 / 12,
        fontWeight: FontWeight.w400,
        color: body,
      ),
      // label-lg 15/20 w600
      labelLarge: style(
        fontSize: 15,
        height: 20 / 15,
        fontWeight: FontWeight.w600,
        color: KonsenaColors.textPrimary,
      ),
      // label-md 13/18 w600
      labelMedium: style(
        fontSize: 13,
        height: 18 / 13,
        fontWeight: FontWeight.w600,
        color: KonsenaColors.textPrimary,
      ),
      // label-sm 11/14 w700 (overline, pill labels)
      labelSmall: style(
        fontSize: 11,
        height: 14 / 11,
        fontWeight: FontWeight.w700,
        color: KonsenaColors.textPrimary,
        letterSpacing: 0.6,
      ),
    );
  }
}
