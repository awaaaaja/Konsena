import 'package:flutter/material.dart';

import 'konsena_colors.dart';

/// Violet-tinted ambient shadows (luminous_violet_guardian/DESIGN.md +
/// DESIGN_SYSTEM §1 "shadows subtle").
///
/// Gray/black drop shadows are avoided in favour of brand-tinted elevation.
abstract final class KonsenaShadows {
  /// Surface level 1 — resting cards and tiles.
  static const List<BoxShadow> card = [
    BoxShadow(
      color: Color(0x145A3DAD), // royal violet @ 8%
      offset: Offset(0, 8),
      blurRadius: 24,
      spreadRadius: -4,
    ),
    BoxShadow(
      color: Color(0x0A5A3DAD), // royal violet @ 4%
      offset: Offset(0, 2),
      blurRadius: 6,
      spreadRadius: -1,
    ),
  ];

  /// Surface level 2 — floating actions and prominent cards.
  static const List<BoxShadow> raised = [
    BoxShadow(
      color: Color(0x385A3DAD), // royal violet @ 22%
      offset: Offset(0, 16),
      blurRadius: 36,
      spreadRadius: -6,
    ),
  ];

  /// Hero gradient surface (S03) — deep, low-spread lift.
  static const List<BoxShadow> hero = [
    BoxShadow(
      color: Color(0x2E252148), // midnight purple @ 18%
      offset: Offset(0, 10),
      blurRadius: 24,
      spreadRadius: -6,
    ),
  ];

  /// Decorative violet glow used behind the splash emblem and hero accents.
  static const List<BoxShadow> glow = [
    BoxShadow(
      color: Color(0x597838D8), // electric violet @ 35%
      offset: Offset.zero,
      blurRadius: 32,
      spreadRadius: 4,
    ),
  ];

  /// Hairline elevation for small chips/pills on light surfaces.
  static const List<BoxShadow> subtle = [
    BoxShadow(
      color: Color(0x0F5A3DAD), // royal violet @ 6%
      offset: Offset(0, 1),
      blurRadius: 3,
      spreadRadius: 0,
    ),
  ];
}

/// Gradient fills shared by splash and hero surfaces, expressed with approved
/// palette tokens only (no ad-hoc hex in feature widgets).
abstract final class KonsenaGradients {
  /// S03 hero: Midnight Purple → Deep Indigo → Royal Violet (§8.2).
  static const LinearGradient hero = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      KonsenaColors.midnightPurple,
      KonsenaColors.deepIndigo,
      KonsenaColors.royalViolet,
    ],
    stops: [0.0, 0.55, 1.0],
  );

  /// S00 splash: dark radial violet (base Midnight Purple + violet glow).
  static const RadialGradient splashGlow = RadialGradient(
    center: Alignment(0.0, -0.35),
    radius: 0.95,
    colors: [
      Color(0x8C5A3DAD), // royal violet @ 55%
      Color(0x40342D61), // deep indigo @ 25%
      Color(0x00252148), // midnight purple transparent
    ],
    stops: [0.0, 0.45, 1.0],
  );

  /// Curved "planetary horizon" crest at the bottom of the splash (from the
  /// Stitch reference, rebuilt with palette tokens).
  static const RadialGradient planetaryHorizon = RadialGradient(
    center: Alignment.topCenter,
    radius: 1.0,
    colors: [
      KonsenaColors.royalViolet,
      KonsenaColors.deepIndigo,
      KonsenaColors.midnightPurple,
    ],
    stops: [0.0, 0.45, 1.0],
  );
}
