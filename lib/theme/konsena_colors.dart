import 'package:flutter/material.dart';

/// Approved KONSENA palette (DESIGN_SYSTEM.md §1 — VIOLET IDENTITY v3.0).
///
/// Every hex value here comes from the approved palette table. Stitch
/// reference hex values are deliberately ignored (references/README.md), and
/// feature widgets must reference these tokens instead of literal colors.
abstract final class KonsenaColors {
  // ---------------------------------------------------------------------------
  // Palet utama
  // ---------------------------------------------------------------------------

  /// Midnight Purple `#252148` — headline, splash & header.
  static const Color midnightPurple = Color(0xFF252148);

  /// Deep Indigo `#342D61` — secondary heading, pressed, dark surface.
  static const Color deepIndigo = Color(0xFF342D61);

  /// Royal Violet `#5A3DAD` — primary CTA / active primary.
  static const Color royalViolet = Color(0xFF5A3DAD);

  /// Electric Violet `#7838D8` — accent, focus ring, selected control.
  static const Color electricViolet = Color(0xFF7838D8);

  /// Lavender `#C4BDD6` — decorative stroke and border only.
  static const Color lavender = Color(0xFFC4BDD6);

  /// Soft Lilac `#E5E0F9` — selected navigation surface, icon chips.
  static const Color softLilac = Color(0xFFE5E0F9);

  /// Pale Lavender `#EFE6FB` — main canvas / hero group background.
  static const Color paleLavender = Color(0xFFEFE6FB);

  /// Cloud White `#FDFCFE` — page scaffold.
  static const Color cloudWhite = Color(0xFFFDFCFE);

  /// White — card, modal, dialog.
  static const Color white = Color(0xFFFFFFFF);

  // ---------------------------------------------------------------------------
  // Status (hijau hanya untuk status — bukan warna aksi)
  // ---------------------------------------------------------------------------

  static const Color successGreen = Color(0xFF36C77B);
  static const Color warningAmber = Color(0xFFFFB83F);
  static const Color dangerRed = Color(0xFFEF6464);

  /// Accessible control outline (DESIGN_SYSTEM §1).
  static const Color borderStrong = Color(0xFF8F83A8);

  // ---------------------------------------------------------------------------
  // Alias semantik (dipakai widget fitur)
  // ---------------------------------------------------------------------------

  static const Color primary = royalViolet;
  static const Color primaryPressed = deepIndigo;
  static const Color accent = electricViolet;

  static const Color backgroundMain = paleLavender;
  static const Color backgroundPage = cloudWhite;
  static const Color surface = white;
  static const Color surfaceSelected = softLilac;
  static const Color surfaceSubtle = paleLavender;

  static const Color textPrimary = midnightPurple;
  static const Color textSecondary = deepIndigo;
  static const Color textOnPrimary = white;
  static const Color textOnDark = cloudWhite;

  static const Color border = lavender;
  static const Color borderInteractive = borderStrong;
}
