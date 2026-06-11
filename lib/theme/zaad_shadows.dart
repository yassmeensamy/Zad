import 'package:flutter/material.dart';

import 'app_color_scheme.dart';

/// Canonical card / surface elevation recipes, derived from the shadow
/// histogram across the app's cards. All recipes are theme-aware: they take the
/// resolved [AppColorsTheme] so the shadow tint (olive ink in light, near-black
/// in dark) tracks the active brightness.
///
/// Usage:
/// ```dart
/// final colors = context.appColors;
/// boxShadow: ZaadShadows.card(colors),
/// ```
class ZaadShadows {
  ZaadShadows._();

  /// Whisper of depth for small tiles / chips that sit close to the surface.
  /// (blur 12, y+5, olive ink @ 6%).
  static List<BoxShadow> subtle(AppColorsTheme c) => [
    BoxShadow(
      color: c.oliveDeep.withValues(alpha: 0.06),
      blurRadius: 12,
      offset: const Offset(0, 5),
    ),
  ];

  /// The default card lift — list rows, feed items, notifications.
  /// (blur 20, y+10, olive ink @ 8%).
  static List<BoxShadow> card(AppColorsTheme c) => [
    BoxShadow(
      color: c.oliveDeep.withValues(alpha: 0.08),
      blurRadius: 20,
      offset: const Offset(0, 10),
    ),
  ];

  /// Premium two-layer lift for primary / hero-ish surfaces: a grounding olive
  /// shadow plus a warm tint halo. Pass [tint] (defaults to the accent) to tune
  /// the halo to the card's identity colour.
  static List<BoxShadow> elevated(AppColorsTheme c, {Color? tint}) => [
    BoxShadow(
      color: c.oliveDeep.withValues(alpha: 0.06),
      blurRadius: 18,
      offset: const Offset(0, 8),
    ),
    BoxShadow(
      color: (tint ?? c.accent).withValues(alpha: 0.04),
      blurRadius: 30,
      offset: const Offset(0, 14),
    ),
  ];

  /// Accent glow used when an interactive card becomes selected.
  /// (blur 24, y+12, accent @ 18%). Pass [tint] to override the accent.
  static List<BoxShadow> selected(AppColorsTheme c, {Color? tint}) => [
    BoxShadow(
      color: (tint ?? c.accent).withValues(alpha: 0.18),
      blurRadius: 24,
      offset: const Offset(0, 12),
    ),
  ];

  /// Deep, full-bleed grounding for hero banners — a far grounding shadow plus a
  /// near lift, both in the hero shadow tone.
  static List<BoxShadow> hero(AppColorsTheme c) => [
    BoxShadow(
      color: c.heroShadow.withValues(alpha: 0.45),
      blurRadius: 50,
      offset: const Offset(0, 26),
    ),
    BoxShadow(
      color: c.heroShadow.withValues(alpha: 0.30),
      blurRadius: 18,
      offset: const Offset(0, 8),
    ),
  ];
}
