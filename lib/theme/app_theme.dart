import 'package:flutter/material.dart';

import 'app_color_scheme.dart';
import 'app_text_styles.dart';
import 'custom_button_theme.dart';
import 'zaad_radii.dart';

class AppTheme {
  AppTheme._();

  static ThemeData light = _build(
    colorScheme: AppColorSchemes.light,
    appColors: AppColorsTheme.light,
    brightness: Brightness.light,
  );

  static ThemeData dark = _build(
    colorScheme: AppColorSchemes.dark,
    appColors: AppColorsTheme.dark,
    brightness: Brightness.dark,
  );

  static ThemeData _build({
    required ColorScheme colorScheme,
    required AppColorsTheme appColors,
    required Brightness brightness,
  }) {
    final textTheme = AppTextStyles.buildTextTheme(colorScheme.onSurface);
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      fontFamily: 'ElMessiri',
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      textTheme: textTheme,
      extensions: <ThemeExtension<dynamic>>[
        appColors,
        _buildCustomButtonTheme(appColors),
      ],
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTextStyles.titleLarge.copyWith(
          color: colorScheme.onSurface,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFFFFFFF).withValues(alpha: 0.5),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),
        hintStyle: AppTextStyles.bodyMedium.copyWith(
          color: appColors.oliveSoft.withValues(alpha: 0.55),
        ),
        labelStyle: AppTextStyles.labelMedium.copyWith(
          color: appColors.oliveSoft,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.32 * 12,
        ),
        floatingLabelStyle: AppTextStyles.labelSmall.copyWith(
          color: appColors.oliveSoft,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.32 * 9,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ZaadRadii.lg),
          borderSide: BorderSide(
            color: appColors.oliveSoft.withValues(alpha: 0.28),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ZaadRadii.lg),
          borderSide: BorderSide(
            color: appColors.oliveSoft.withValues(alpha: 0.28),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ZaadRadii.lg),
          borderSide: BorderSide(color: appColors.olive, width: 1.4),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ZaadRadii.lg),
          borderSide: BorderSide(color: appColors.warning),
        ),
        prefixIconColor: appColors.oliveSoft,
        suffixIconColor: appColors.oliveSoft,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ZaadRadii.md),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: AppTextStyles.labelLarge,
          elevation: 0,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          textStyle: AppTextStyles.labelLarge,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          side: BorderSide(color: colorScheme.outline),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ZaadRadii.md),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: AppTextStyles.labelLarge,
        ),
      ),
      cardTheme: CardThemeData(
        color: colorScheme.surfaceContainerLow,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ZaadRadii.lg),
          side: BorderSide(color: colorScheme.outlineVariant),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),
    );
  }

  static CustomButtonTheme _buildCustomButtonTheme(AppColorsTheme c) {
    return CustomButtonTheme(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      borderRadius: ZaadRadii.lg,
      useGradient: true,
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        stops: const [0.0, 0.5, 1.0],
        colors: [c.oliveSoft, c.olive, c.oliveDeep],
      ),
      backgroundColor: c.olive,
      textColor: c.canvas,
      textStyle: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 14 * 0.14,
      ),
    );
  }
}
