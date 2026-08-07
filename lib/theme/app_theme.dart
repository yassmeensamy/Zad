import 'package:flutter/material.dart';

import 'app_color_scheme.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';
import 'custom_button_theme.dart';
import 'theme_context_extensions.dart';
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
    final isDark = brightness == Brightness.dark;
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      fontFamily: 'ElMessiri',
      colorScheme: colorScheme,
      scaffoldBackgroundColor: isDark ? Colors.transparent : colorScheme.surface,
      textTheme: textTheme,
      extensions: <ThemeExtension<dynamic>>[
        appColors,
        _buildCustomButtonTheme(appColors, textTheme),
      ],
      // No titleTextStyle — Material 3 resolves it from textTheme.titleLarge,
      // which already carries onSurface. Same for the button themes below and
      // their labelLarge.
      appBarTheme: AppBarTheme(
        backgroundColor: isDark ? Colors.transparent : colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        centerTitle: true,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: brightness == Brightness.dark
            ? appColors.inputSurface
            : const Color(0xFFFFFFFF).withValues(alpha: 0.5),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),
        // Kept (not removed): Material 3 would default the hint to bodyLarge
        // (16) and the labels to bodySmall, which would resize the inputs.
        // Sourced from textTheme so the roles stay the single source of truth.
        hintStyle: textTheme.bodyMedium!.tinted(
          appColors.oliveSoft.withValues(alpha: 0.55),
        ),
        labelStyle: textTheme.labelMedium!
            .semiBold
            .tracked(0.32)
            .tinted(appColors.oliveSoft),
        // Tracking is deliberately resolved against 9, not labelSmall's own
        // 10 — a pre-existing quirk, preserved so the float doesn't shift.
        floatingLabelStyle: textTheme.labelSmall!.semiBold
            .copyWith(letterSpacing: 0.32 * 9)
            .tinted(appColors.oliveSoft),
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
          elevation: 0,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
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
        ),
      ),
      cardTheme: CardThemeData(
        color: brightness == Brightness.dark
            ? appColors.canvasRaised
            : Colors.white.withValues(alpha: 0.6),
        surfaceTintColor: Colors.transparent,
        // Warm espresso shadow in dark (not pure black) so elevation reads
        // cohesive against the beige surfaces; soft olive tint in light.
        shadowColor: brightness == Brightness.dark
            ? AppColors.shadowDeep.withValues(alpha: 0.6)
            : appColors.oliveDeep.withValues(alpha: 0.05),
        elevation: brightness == Brightness.dark ? 3 : 1,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ZaadRadii.card),
          // Warm hairline: a soft ivory edge in dark, olive tint in light.
          side: BorderSide(
            color: brightness == Brightness.dark
                ? appColors.borderDefault
                : appColors.olive.withValues(alpha: 0.10),
          ),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),
    );
  }

  static CustomButtonTheme _buildCustomButtonTheme(
    AppColorsTheme c,
    TextTheme textTheme,
  ) {
    return CustomButtonTheme(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      borderRadius: ZaadRadii.lg,
      useGradient: true,
      // Diagonal sweep (top-left → bottom-right) reads more premium than a
      // flat vertical fill — it gives the CTA a subtle directional sheen.
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        stops: const [0.0, 0.55, 1.0],
        colors: [c.ctaTop, c.ctaMid, c.ctaBottom],
      ),
      backgroundColor: c.ctaMid,
      textColor: c.onCta,
      // labelLarge (14) is already the CTA size; the CTA only differs by
      // weight and tracking, so express it as variants rather than a literal.
      // Color comes from [textColor] above — CustomButton applies it last.
      textStyle: textTheme.labelLarge!.semiBold.tracked(0.14),
    );
  }
}