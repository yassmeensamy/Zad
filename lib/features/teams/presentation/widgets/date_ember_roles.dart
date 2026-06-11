import 'package:flutter/material.dart';

import '../../../../theme/theme.dart';

/// Role-based palette shared by the Date & Ember team surfaces.
///
/// Dark mode returns the exact [AppColors] values so the original design is
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
  static const Color oliveLight = AppColors.discOliveHi;

  // Dark-mode trend tints (the design's `--up` / `--down`).
  static const Color _up = AppColors.trendUp;
  static const Color _down = AppColors.trendDown;

  // Screen vignette (top glow → mid surface → base).
  Color get bgTop => dark ? AppColors.nightRaised : _c.backdropTop;
  Color get bgMid => dark ? AppColors.nightSurface : _c.backdropMid;
  Color get bgBottom => dark ? AppColors.nightLow : _c.backdropBottom;

  // Ink.
  Color get ink => _c.textPrimary;
  Color get inkMute => _c.textSecondary;
  Color get inkFaint => _c.textTertiary;

  // Borders / hairlines.
  Color get hairline => dark ? AppColors.ivory08 : _c.borderSubtle;
  Color get glassBorder => dark ? AppColors.nightOutline : _c.borderDefault;

  // Amber / gold accents.
  Color get amber => _c.accent;
  Color get gold => dark ? AppColors.amberLight : _c.accentDeep;
  Color get amberDeep => _c.accentDeep;
  Color get washAmber => dark ? AppColors.washAmber : _c.accent;

  // Ember (kept warm in both modes).
  Color get ember => dark ? AppColors.ember : _c.accentDeep;
  Color get emberLight => dark ? AppColors.emberBright : _c.accent;
  Color get emberInk => dark ? AppColors.emberInk : _c.goldInk;

  // Success green.
  Color get green => dark ? oliveLight : AppColors.olive;
  Color get greenSurface => dark ? AppColors.oliveLight : AppColors.olive;
  Color get up => dark ? _up : AppColors.success;
  Color get down => dark ? _down : AppColors.warning;

  // Translucent card fills (ivory films in dark; semantic glass in light).
  Color get cardFill =>
      dark ? AppColors.ivory.withValues(alpha: 0.05) : _c.cardSurface;
  Color get cardFillStrong =>
      dark ? AppColors.ivory.withValues(alpha: 0.07) : _c.cardSurface;
  Color get cardFillFaint => dark ? AppColors.ivory02 : _c.cardSurface;
}
