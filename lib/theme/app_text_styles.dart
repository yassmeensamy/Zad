import 'package:flutter/material.dart';

/// Reusable text style constants. Color is intentionally omitted —
/// resolve at call site via `.copyWith(color: context.colorScheme.X)`.
///
/// Heights are slightly generous to fit the "quiet type, generous whitespace"
/// hand-made feel of the Desert Sand palette.
class AppTextStyles {
  AppTextStyles._();

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

  static TextTheme buildTextTheme(Color onSurface) => TextTheme(
        displayLarge: displayLarge.copyWith(color: onSurface),
        displayMedium: displayMedium.copyWith(color: onSurface),
        headlineLarge: headlineLarge.copyWith(color: onSurface),
        headlineMedium: headlineMedium.copyWith(color: onSurface),
        titleLarge: titleLarge.copyWith(color: onSurface),
        titleMedium: titleMedium.copyWith(color: onSurface),
        bodyLarge: bodyLarge.copyWith(color: onSurface),
        bodyMedium: bodyMedium.copyWith(color: onSurface),
        bodySmall: bodySmall.copyWith(color: onSurface),
        labelLarge: labelLarge.copyWith(color: onSurface),
        labelMedium: labelMedium.copyWith(color: onSurface),
        labelSmall: labelSmall.copyWith(color: onSurface),
      );
}
