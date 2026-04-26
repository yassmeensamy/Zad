import 'package:flutter/material.dart';
import 'app_color_scheme.dart';

extension ThemeContextX on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  TextTheme get textTheme => Theme.of(this).textTheme;

  /// Custom semantic tokens. Falls back to light theme if the extension
  /// isn't registered (defensive — shouldn't happen in practice).
  AppColorsTheme get appColors =>
      Theme.of(this).extension<AppColorsTheme>() ?? AppColorsTheme.light;
}
