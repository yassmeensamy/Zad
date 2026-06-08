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
