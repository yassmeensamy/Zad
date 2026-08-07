import 'package:flutter/material.dart';

class AppTextStyles {
  AppTextStyles._();

  static const TextStyle numericLarge = TextStyle(
    fontSize: 96,
    fontWeight: FontWeight.w300,
    height: 1.0,
    letterSpacing: -3.0,
  );
  static const TextStyle displayLarge = TextStyle(
    fontSize: 34,
    fontWeight: FontWeight.w600,
    height: 1.25,
    letterSpacing: -0.4,
  );
  static const TextStyle displayMedium = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    height: 1.25,
    letterSpacing: -0.3,
  );
  static const TextStyle displaySmall = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.w300,
    fontStyle: FontStyle.italic,
    height: 1.15,
    letterSpacing: -0.4,
  );
  static const TextStyle headlineLarge = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.35,
    letterSpacing: -0.2,
  );
  static const TextStyle headlineMedium = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.35,
  );

  /// The quiet 24 — dialog header titles and the custom app-bar title.
  /// [headlineLarge] is the emphatic (w600) 24; this is its w500 counterpart.
  static const TextStyle headlineSmall = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w500,
    height: 1.2,
    letterSpacing: -0.3,
  );

  static const TextStyle titleLarge = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    height: 1.4,
  );
  static const TextStyle titleMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.4,
  );

  /// Lead-paragraph role — the same 18 as [titleLarge] but at regular weight,
  /// so it reads as running copy rather than a heading.
  static const TextStyle titleSmall = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );

  /// Alias for [titleSmall], which is its Material 3 slot. Kept so existing
  /// call sites keep working; new code should use `context.titleSmall`.
  static const TextStyle bodyXLarge = titleSmall;
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.6,
  );
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.6,
  );
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.55,
  );
  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 0.1,
  );
  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 0.2,
  );
  static const TextStyle labelSmall = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 0.3,
  );

  /// Small, tracked "eyebrow" label used above the home cards (streak, team,
  /// verse, hadith, play). Built on [labelSmall].
  ///
  /// [tracking] is the letter-spacing expressed as a fraction of [fontSize]
  /// — the recurring `fontSize * ratio` idiom across those cards — and is
  /// resolved here to an absolute `letterSpacing` so call sites stay
  /// declarative. Pass [color] to tint it; [weight] defaults to bold.
  static TextStyle eyebrow({
    double fontSize = 10,
    required double tracking,
    FontWeight weight = FontWeight.w700,
    Color? color,
  }) => labelSmall.copyWith(
    fontSize: fontSize,
    fontWeight: weight,
    letterSpacing: fontSize * tracking,
    color: color,
  );

  /// The app's single source of truth for typography.
  ///
  /// All 15 Material 3 roles are filled, so framework widgets (app bars,
  /// buttons, inputs, dialogs, snack bars) resolve their text from here
  /// instead of needing per-component overrides in [AppTheme]. It also lets
  /// `context.bodyMedium` & friends return non-nullable styles.
  ///
  /// [numericLarge] is deliberately absent — a 96pt hero numeral is a
  /// component style, not a typography role.
  static TextTheme buildTextTheme(Color onSurface) => TextTheme(
    displayLarge: displayLarge.copyWith(color: onSurface),
    displayMedium: displayMedium.copyWith(color: onSurface),
    displaySmall: displaySmall.copyWith(color: onSurface),
    headlineLarge: headlineLarge.copyWith(color: onSurface),
    headlineMedium: headlineMedium.copyWith(color: onSurface),
    headlineSmall: headlineSmall.copyWith(color: onSurface),
    titleLarge: titleLarge.copyWith(color: onSurface),
    titleMedium: titleMedium.copyWith(color: onSurface),
    titleSmall: titleSmall.copyWith(color: onSurface),
    bodyLarge: bodyLarge.copyWith(color: onSurface),
    bodyMedium: bodyMedium.copyWith(color: onSurface),
    bodySmall: bodySmall.copyWith(color: onSurface),
    labelLarge: labelLarge.copyWith(color: onSurface),
    labelMedium: labelMedium.copyWith(color: onSurface),
    labelSmall: labelSmall.copyWith(color: onSurface),
  );
}
