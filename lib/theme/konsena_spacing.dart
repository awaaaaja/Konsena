/// Spacing scale (DESIGN_SYSTEM.md §1): 4 / 8 / 12 / 16 / 20 / 24 / 32.
abstract final class KonsenaSpacing {
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;

  /// Horizontal screen padding for normal widths (DESIGN_SYSTEM §8.2).
  static const double screenHorizontal = 20;

  /// Fallback padding on very narrow widths (≤320dp) and for dense cards.
  static const double screenHorizontalCompact = 16;

  /// Gap between the two summary cards (§8.2).
  static const double cardGap = 16;

  /// Standard card padding (§1: 16–24dp inside cards).
  static const double cardPadding = 16;

  /// Generous card padding for hero surfaces.
  static const double cardPaddingLarge = 24;
}

/// Corner radius scale (DESIGN_SYSTEM.md §1 + §8.2).
abstract final class KonsenaRadii {
  /// Small tiles / icon chips.
  static const double tile = 12;

  /// Buttons and inputs.
  static const double control = 16;

  /// Standard cards.
  static const double card = 16;

  /// Summary cards (§8.2: 20–24dp).
  static const double cardLarge = 20;

  /// Hero surfaces (§8.2: hero S03 radius 24dp).
  static const double hero = 24;

  /// Pill / fully rounded shapes (CTA bundar, dots, chips).
  static const double pill = 999;
}

/// Minimum interactive target (DESIGN_SYSTEM §1, a11y WCAG / TalkBack).
abstract final class KonsenaTouch {
  static const double minTarget = 48;
}
