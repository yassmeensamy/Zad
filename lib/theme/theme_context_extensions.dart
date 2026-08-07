import 'package:flutter/material.dart';
import 'app_color_scheme.dart';

extension ThemeContextX on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  TextTheme get textTheme => Theme.of(this).textTheme;

  /// True when the active theme is dark. Prefer semantic [appColors] tokens
  /// over branching on this — reserve it for genuinely structural choices
  /// (e.g. a layout that only exists in one brightness).
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  /// Custom semantic tokens. Falls back to light theme if the extension
  /// isn't registered (defensive — shouldn't happen in practice).
  AppColorsTheme get appColors =>
      Theme.of(this).extension<AppColorsTheme>() ?? AppColorsTheme.light;
}

/// Non-nullable accessors for the 15 Material 3 typography roles.
///
/// `Theme.of(context).textTheme.bodyMedium` is a `TextStyle?`, which forces a
/// `!` at every call site. `AppTextStyles.buildTextTheme` fills all 15 roles,
/// so these are safe to unwrap once here instead.
///
/// Pick the role, then layer variants from [TextStyleVariants]:
/// ```dart
/// Text('...', style: context.labelSmall.tracked(0.32).bold)
/// ```
extension TypographyContextX on BuildContext {
  TextTheme get _text => Theme.of(this).textTheme;

  // ── Display ───────────────────────────────────────────────────────
  TextStyle get displayLarge => _text.displayLarge!;
  TextStyle get displayMedium => _text.displayMedium!;
  TextStyle get displaySmall => _text.displaySmall!;

  // ── Headline ──────────────────────────────────────────────────────
  TextStyle get headlineLarge => _text.headlineLarge!;
  TextStyle get headlineMedium => _text.headlineMedium!;
  TextStyle get headlineSmall => _text.headlineSmall!;

  // ── Title ─────────────────────────────────────────────────────────
  TextStyle get titleLarge => _text.titleLarge!;
  TextStyle get titleMedium => _text.titleMedium!;
  TextStyle get titleSmall => _text.titleSmall!;

  // ── Body ──────────────────────────────────────────────────────────
  TextStyle get bodyLarge => _text.bodyLarge!;
  TextStyle get bodyMedium => _text.bodyMedium!;
  TextStyle get bodySmall => _text.bodySmall!;

  // ── Label ─────────────────────────────────────────────────────────
  TextStyle get labelLarge => _text.labelLarge!;
  TextStyle get labelMedium => _text.labelMedium!;
  TextStyle get labelSmall => _text.labelSmall!;
}

/// Weight, slant and tracking modifiers for the Material 3 roles.
///
/// These are *variants*, not new typography roles — they never change
/// `fontSize`. Reach for a different role when you need a different size.
extension TextStyleVariants on TextStyle {
  TextStyle get semiBold => copyWith(fontWeight: FontWeight.w600);
  TextStyle get bold => copyWith(fontWeight: FontWeight.w700);
  TextStyle get extraBold => copyWith(fontWeight: FontWeight.w800);
  TextStyle get light => copyWith(fontWeight: FontWeight.w300);

  TextStyle get italic => copyWith(fontStyle: FontStyle.italic);

  /// Letter-spacing expressed as a fraction of [fontSize] — the recurring
  /// `fontSize * ratio` idiom across the eyebrow/kicker labels. Keeping it
  /// relative means tracking stays proportional if a role is ever resized.
  TextStyle tracked(double ratio) {
    assert(
      fontSize != null,
      'tracked() resolves against fontSize — call it on a TextTheme role.',
    );
    return copyWith(letterSpacing: (fontSize ?? 0) * ratio);
  }

  /// Tint helper, so a role and its color read as one expression:
  /// `context.bodyMedium.tinted(context.appColors.oliveSoft)`.
  TextStyle tinted(Color color) => copyWith(color: color);
}
