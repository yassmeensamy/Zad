import 'package:flutter/material.dart';

import '../../../../theme/theme.dart';

/// Role-based palette shared by the Date & Ember team surfaces.
///
/// Dark mode returns the exact [DateEmber] values so the original design is
/// preserved pixel-for-pixel; light mode maps each role onto the app's semantic
/// [AppColorsTheme] tokens. Decorative *metallic* ramps (gold crest, avatar
/// discs) are kept literal by callers — they're objects, not theme surfaces.
class DateEmberRoles {
  DateEmberRoles(BuildContext context)
      : _c = context.appColors,
        dark = context.isDark;

  final AppColorsTheme _c;
  final bool dark;

  /// Bright olive used for success dots / avatars in dark mode.
  static const Color oliveLight = Color(0xFFA6B584);

  // Dark-mode trend tints (the design's `--up` / `--down`).
  static const Color _up = Color(0xFF9CCB8E);
  static const Color _down = Color(0xFFD98A6F);

  // Screen vignette (top glow → mid surface → base).
  Color get bgTop => dark ? DateEmber.raised : _c.backdropTop;
  Color get bgMid => dark ? DateEmber.surface : _c.backdropMid;
  Color get bgBottom => dark ? DateEmber.base : _c.backdropBottom;

  // Ink.
  Color get ink => _c.textPrimary;
  Color get inkMute => _c.textSecondary;
  Color get inkFaint => _c.textTertiary;

  // Borders / hairlines.
  Color get hairline => dark ? DateEmber.hairline : _c.borderSubtle;
  Color get glassBorder => dark ? DateEmber.glassBorder : _c.borderDefault;

  // Amber / gold accents.
  Color get amber => _c.accent;
  Color get gold => dark ? DateEmber.amberLight : _c.accentDeep;
  Color get amberDeep => _c.accentDeep;
  Color get washAmber => dark ? DateEmber.washAmber : _c.accent;

  // Ember (kept warm in both modes).
  Color get ember => dark ? DateEmber.ember : _c.accentDeep;
  Color get emberLight => dark ? DateEmber.emberLight : _c.accent;
  Color get emberInk => dark ? DateEmber.emberInk : _c.goldInk;

  // Success green.
  Color get green => dark ? oliveLight : AppColors.olive;
  Color get greenSurface => dark ? DateEmber.olive : AppColors.olive;
  Color get up => dark ? _up : AppColors.success;
  Color get down => dark ? _down : AppColors.warning;

  // Translucent card fills (ivory films in dark; semantic glass in light).
  Color get cardFill => dark ? const Color(0x0DF4ECD8) : _c.cardSurface;
  Color get cardFillStrong => dark ? const Color(0x12F4ECD8) : _c.cardSurface;
  Color get cardFillFaint => dark ? const Color(0x05F4ECD8) : _c.cardSurface;
}
