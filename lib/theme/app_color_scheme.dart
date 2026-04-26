import 'package:flutter/material.dart';
import 'app_colors.dart';

@immutable
class AppColorsTheme extends ThemeExtension<AppColorsTheme> {
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color textPlaceholder;
  final Color textInverse;
  final Color textArabic;

  final Color borderSubtle;
  final Color borderDefault;
  final Color borderStrong;

  final Color canvas;
  final Color canvasRaised;

  final Color accent;
  final Color accentSoft;
  final Color accentDeep;

  final Color success;
  final Color warning;
  final Color info;

  final Color overlayLight;
  final Color overlayDark;

  const AppColorsTheme({
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.textPlaceholder,
    required this.textInverse,
    required this.textArabic,
    required this.borderSubtle,
    required this.borderDefault,
    required this.borderStrong,
    required this.canvas,
    required this.canvasRaised,
    required this.accent,
    required this.accentSoft,
    required this.accentDeep,
    required this.success,
    required this.warning,
    required this.info,
    required this.overlayLight,
    required this.overlayDark,
  });

  static const AppColorsTheme light = AppColorsTheme(
    textPrimary: AppColors.darkOlive,
    textSecondary: AppColors.dustyOlive,
    textTertiary: AppColors.tobacco,
    textPlaceholder: AppColors.dune,
    textInverse: AppColors.ivory,
    textArabic: AppColors.date,
    borderSubtle: AppColors.sand,
    borderDefault: AppColors.dune,
    borderStrong: AppColors.date,
    canvas: AppColors.ivory,
    canvasRaised: AppColors.sand,
    accent: AppColors.amber,
    accentSoft: AppColors.amberSoft,
    accentDeep: AppColors.amberDeep,
    success: AppColors.success,
    warning: AppColors.warning,
    info: AppColors.info,
    overlayLight: Color(0x14F4ECD8),
    overlayDark: Color(0x147A4A29),
  );

  static const AppColorsTheme dark = AppColorsTheme(
    textPrimary: AppColors.ivory,
    textSecondary: AppColors.sand,
    textTertiary: AppColors.dune,
    textPlaceholder: AppColors.tobacco,
    textInverse: AppColors.darkOlive,
    textArabic: AppColors.amberSoft,
    borderSubtle: AppColors.cocoa,
    borderDefault: AppColors.tobacco,
    borderStrong: AppColors.dune,
    canvas: AppColors.inkwell,
    canvasRaised: AppColors.sepia,
    accent: AppColors.amber,
    accentSoft: AppColors.amberSoft,
    accentDeep: AppColors.amberDeep,
    success: AppColors.success,
    warning: AppColors.warning,
    info: AppColors.info,
    overlayLight: Color(0x14F4ECD8),
    overlayDark: Color(0x14000000),
  );

  @override
  AppColorsTheme copyWith({
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? textPlaceholder,
    Color? textInverse,
    Color? textArabic,
    Color? borderSubtle,
    Color? borderDefault,
    Color? borderStrong,
    Color? canvas,
    Color? canvasRaised,
    Color? accent,
    Color? accentSoft,
    Color? accentDeep,
    Color? success,
    Color? warning,
    Color? info,
    Color? overlayLight,
    Color? overlayDark,
  }) =>
      AppColorsTheme(
        textPrimary: textPrimary ?? this.textPrimary,
        textSecondary: textSecondary ?? this.textSecondary,
        textTertiary: textTertiary ?? this.textTertiary,
        textPlaceholder: textPlaceholder ?? this.textPlaceholder,
        textInverse: textInverse ?? this.textInverse,
        textArabic: textArabic ?? this.textArabic,
        borderSubtle: borderSubtle ?? this.borderSubtle,
        borderDefault: borderDefault ?? this.borderDefault,
        borderStrong: borderStrong ?? this.borderStrong,
        canvas: canvas ?? this.canvas,
        canvasRaised: canvasRaised ?? this.canvasRaised,
        accent: accent ?? this.accent,
        accentSoft: accentSoft ?? this.accentSoft,
        accentDeep: accentDeep ?? this.accentDeep,
        success: success ?? this.success,
        warning: warning ?? this.warning,
        info: info ?? this.info,
        overlayLight: overlayLight ?? this.overlayLight,
        overlayDark: overlayDark ?? this.overlayDark,
      );

  @override
  AppColorsTheme lerp(ThemeExtension<AppColorsTheme>? other, double t) {
    if (other is! AppColorsTheme) return this;
    return AppColorsTheme(
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      textPlaceholder: Color.lerp(textPlaceholder, other.textPlaceholder, t)!,
      textInverse: Color.lerp(textInverse, other.textInverse, t)!,
      textArabic: Color.lerp(textArabic, other.textArabic, t)!,
      borderSubtle: Color.lerp(borderSubtle, other.borderSubtle, t)!,
      borderDefault: Color.lerp(borderDefault, other.borderDefault, t)!,
      borderStrong: Color.lerp(borderStrong, other.borderStrong, t)!,
      canvas: Color.lerp(canvas, other.canvas, t)!,
      canvasRaised: Color.lerp(canvasRaised, other.canvasRaised, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentSoft: Color.lerp(accentSoft, other.accentSoft, t)!,
      accentDeep: Color.lerp(accentDeep, other.accentDeep, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      info: Color.lerp(info, other.info, t)!,
      overlayLight: Color.lerp(overlayLight, other.overlayLight, t)!,
      overlayDark: Color.lerp(overlayDark, other.overlayDark, t)!,
    );
  }
}

class AppColorSchemes {
  AppColorSchemes._();

  static const ColorScheme light = ColorScheme.light(
    primary: AppColors.amber,
    onPrimary: AppColors.ivory,
    primaryContainer: AppColors.sand,
    onPrimaryContainer: AppColors.date,
    secondary: AppColors.date,
    onSecondary: AppColors.ivory,
    secondaryContainer: AppColors.dune,
    onSecondaryContainer: AppColors.dateDeep,
    tertiary: AppColors.darkOlive,
    onTertiary: AppColors.ivory,
    error: AppColors.error,
    onError: AppColors.ivory,
    surface: AppColors.ivory,
    onSurface: AppColors.darkOlive,
    onSurfaceVariant: AppColors.dustyOlive,
    surfaceContainerLowest: AppColors.ivory,
    surfaceContainerLow: AppColors.sand,
    surfaceContainer: AppColors.sand,
    surfaceContainerHigh: AppColors.dune,
    surfaceContainerHighest: AppColors.dune,
    outline: AppColors.dune,
    outlineVariant: AppColors.sand,
    inverseSurface: AppColors.dateDeep,
    onInverseSurface: AppColors.ivory,
    inversePrimary: AppColors.amberSoft,
    shadow: AppColors.dateDeep,
    scrim: AppColors.dateDeep,
  );

  static const ColorScheme dark = ColorScheme.dark(
    primary: AppColors.amber,
    onPrimary: AppColors.inkwell,
    primaryContainer: AppColors.cocoa,
    onPrimaryContainer: AppColors.amberSoft,
    secondary: AppColors.amberSoft,
    onSecondary: AppColors.inkwell,
    secondaryContainer: AppColors.tobacco,
    onSecondaryContainer: AppColors.ivory,
    tertiary: AppColors.dune,
    onTertiary: AppColors.inkwell,
    error: AppColors.error,
    onError: AppColors.ivory,
    surface: AppColors.inkwell,
    onSurface: AppColors.ivory,
    onSurfaceVariant: AppColors.sand,
    surfaceContainerLowest: AppColors.inkwell,
    surfaceContainerLow: AppColors.sepia,
    surfaceContainer: AppColors.sepia,
    surfaceContainerHigh: AppColors.cocoa,
    surfaceContainerHighest: AppColors.tobacco,
    outline: AppColors.tobacco,
    outlineVariant: AppColors.cocoa,
    inverseSurface: AppColors.ivory,
    onInverseSurface: AppColors.dateDeep,
    inversePrimary: AppColors.amberDeep,
    shadow: AppColors.black,
    scrim: AppColors.black,
  );
}
