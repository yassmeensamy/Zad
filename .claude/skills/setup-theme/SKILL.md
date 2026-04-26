---
name: setup-theme
description: Set up a clean, scalable theme system in any Flutter project — raw palette, ThemeExtension for semantic colors, Material 3 ColorScheme, text styles, and BuildContext extensions. Use when bootstrapping theming in a new Flutter app or migrating an existing app to a structured theme.
argument-hint: "target lib path (e.g. lib, packages/ui_kit/lib) — defaults to ./lib"
---

You are a senior Flutter architect setting up a project-agnostic theme system. The output must work in any Flutter project — no monorepo assumptions, no custom packages, no project-specific widgets. The goal: a clean 3-layer theme that is type-safe, dark-mode-ready, and easy to extend.

## Before Writing Any Code

1. **Inspect the target project**:
   - Read `pubspec.yaml` — confirm Flutter SDK is present. Do NOT assume any third-party deps.
   - Find the `MaterialApp` (or `MaterialApp.router`) in `lib/main.dart` (or `lib/app.dart`).
   - If `lib/theme/` already exists, read existing files and prefer editing over overwriting.

2. **Resolve the target lib path** from `$ARGUMENTS`. Default to `./lib`.

3. **Ask only if ambiguous**: brand seed color, whether dark mode is needed now, font family. Otherwise pick sensible defaults (indigo-ish primary, light + dark, system font).

---

## Architecture (3 Layers)

```
Layer 1 — AppColors (raw palette)
    Static const Color values. Used ONLY by files in theme/.

Layer 2 — AppColorsTheme (ThemeExtension) + Material 3 ColorScheme
    Semantic tokens (textPrimary, borderSubtle, success…) registered on ThemeData.

Layer 3 — BuildContext extensions
    context.colorScheme.X    → Material 3 roles
    context.appColors.Y      → Custom semantic tokens
    context.textTheme.Z      → Text styles
```

| File | Uses raw `AppColors.X` | Purpose |
|---|---|---|
| `theme/app_colors.dart` | YES | Raw palette constants |
| `theme/app_color_scheme.dart` | YES | `AppColorsTheme` + light/dark schemes |
| `theme/app_text_styles.dart` | YES | TextStyle constants + `TextTheme` builder |
| `theme/app_theme.dart` | YES | Builds `ThemeData` for light + dark |
| `theme/theme_context_extensions.dart` | NO | `appColors`, `colorScheme`, `textTheme` getters |
| **All widgets / screens** | **NEVER** | Always go through `context.X` |

---

## Files to Create

Create under `<target>/theme/`. If the project uses `lib/src/theme/` or similar, follow its convention.

### 1. `theme/app_colors.dart`

```dart
import 'package:flutter/material.dart';

/// Raw palette. Internal to the theme layer.
/// Outside `theme/`, use `context.colorScheme.X` or `context.appColors.Y`.
class AppColors {
  AppColors._();

  // Brand
  static const Color primary = Color(0xFF2E4A85);
  static const Color primaryDark = Color(0xFF1F3360);
  static const Color primaryLight = Color(0xFFE8EEF9);
  static const Color secondary = Color(0xFF4CAF93);

  // Neutrals
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF111111);
  static const Color grey50 = Color(0xFFFAFAFA);
  static const Color grey100 = Color(0xFFF2F4F7);
  static const Color grey200 = Color(0xFFE5E7EB);
  static const Color grey300 = Color(0xFFD1D5DB);
  static const Color grey400 = Color(0xFF9CA3AF);
  static const Color grey500 = Color(0xFF6B7280);
  static const Color grey600 = Color(0xFF4B5563);
  static const Color grey700 = Color(0xFF374151);
  static const Color grey800 = Color(0xFF1F2937);
  static const Color grey900 = Color(0xFF111827);

  // Status
  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFDC2626);
  static const Color info = Color(0xFF2563EB);
}
```

### 2. `theme/app_color_scheme.dart`

```dart
import 'package:flutter/material.dart';
import 'app_colors.dart';

@immutable
class AppColorsTheme extends ThemeExtension<AppColorsTheme> {
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color textPlaceholder;
  final Color textInverse;

  final Color borderSubtle;
  final Color borderDefault;
  final Color borderStrong;

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
    required this.borderSubtle,
    required this.borderDefault,
    required this.borderStrong,
    required this.success,
    required this.warning,
    required this.info,
    required this.overlayLight,
    required this.overlayDark,
  });

  static const AppColorsTheme light = AppColorsTheme(
    textPrimary: AppColors.grey900,
    textSecondary: AppColors.grey600,
    textTertiary: AppColors.grey500,
    textPlaceholder: AppColors.grey400,
    textInverse: AppColors.white,
    borderSubtle: AppColors.grey100,
    borderDefault: AppColors.grey200,
    borderStrong: AppColors.grey400,
    success: AppColors.success,
    warning: AppColors.warning,
    info: AppColors.info,
    overlayLight: Color(0x14FFFFFF),
    overlayDark: Color(0x14000000),
  );

  static const AppColorsTheme dark = AppColorsTheme(
    textPrimary: AppColors.white,
    textSecondary: AppColors.grey300,
    textTertiary: AppColors.grey400,
    textPlaceholder: AppColors.grey500,
    textInverse: AppColors.grey900,
    borderSubtle: AppColors.grey800,
    borderDefault: AppColors.grey700,
    borderStrong: AppColors.grey500,
    success: AppColors.success,
    warning: AppColors.warning,
    info: AppColors.info,
    overlayLight: Color(0x14FFFFFF),
    overlayDark: Color(0x14000000),
  );

  @override
  AppColorsTheme copyWith({
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? textPlaceholder,
    Color? textInverse,
    Color? borderSubtle,
    Color? borderDefault,
    Color? borderStrong,
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
        borderSubtle: borderSubtle ?? this.borderSubtle,
        borderDefault: borderDefault ?? this.borderDefault,
        borderStrong: borderStrong ?? this.borderStrong,
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
      borderSubtle: Color.lerp(borderSubtle, other.borderSubtle, t)!,
      borderDefault: Color.lerp(borderDefault, other.borderDefault, t)!,
      borderStrong: Color.lerp(borderStrong, other.borderStrong, t)!,
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
    primary: AppColors.primary,
    onPrimary: AppColors.white,
    primaryContainer: AppColors.primaryLight,
    onPrimaryContainer: AppColors.primaryDark,
    secondary: AppColors.secondary,
    onSecondary: AppColors.white,
    error: AppColors.error,
    onError: AppColors.white,
    surface: AppColors.white,
    onSurface: AppColors.grey900,
    onSurfaceVariant: AppColors.grey600,
    surfaceContainerLow: AppColors.grey50,
    surfaceContainerHighest: AppColors.grey100,
    outline: AppColors.grey300,
    outlineVariant: AppColors.grey200,
    inverseSurface: AppColors.grey900,
    onInverseSurface: AppColors.white,
    shadow: AppColors.black,
  );

  static const ColorScheme dark = ColorScheme.dark(
    primary: AppColors.primary,
    onPrimary: AppColors.white,
    primaryContainer: AppColors.primaryDark,
    onPrimaryContainer: AppColors.primaryLight,
    secondary: AppColors.secondary,
    onSecondary: AppColors.white,
    error: AppColors.error,
    onError: AppColors.white,
    surface: AppColors.grey900,
    onSurface: AppColors.white,
    onSurfaceVariant: AppColors.grey300,
    surfaceContainerLow: AppColors.grey800,
    surfaceContainerHighest: AppColors.grey700,
    outline: AppColors.grey600,
    outlineVariant: AppColors.grey700,
    inverseSurface: AppColors.white,
    onInverseSurface: AppColors.grey900,
    shadow: AppColors.black,
  );
}
```

### 3. `theme/app_text_styles.dart`

```dart
import 'package:flutter/material.dart';

/// Reusable text style constants. Color is intentionally omitted —
/// resolve at call site via `.copyWith(color: context.colorScheme.X)`.
class AppTextStyles {
  AppTextStyles._();

  static const TextStyle displayLarge =
      TextStyle(fontSize: 32, fontWeight: FontWeight.w700, height: 1.2);
  static const TextStyle displayMedium =
      TextStyle(fontSize: 28, fontWeight: FontWeight.w700, height: 1.2);
  static const TextStyle headlineLarge =
      TextStyle(fontSize: 24, fontWeight: FontWeight.w600, height: 1.3);
  static const TextStyle headlineMedium =
      TextStyle(fontSize: 20, fontWeight: FontWeight.w600, height: 1.3);
  static const TextStyle titleLarge =
      TextStyle(fontSize: 18, fontWeight: FontWeight.w600, height: 1.4);
  static const TextStyle titleMedium =
      TextStyle(fontSize: 16, fontWeight: FontWeight.w600, height: 1.4);
  static const TextStyle bodyLarge =
      TextStyle(fontSize: 16, fontWeight: FontWeight.w400, height: 1.5);
  static const TextStyle bodyMedium =
      TextStyle(fontSize: 14, fontWeight: FontWeight.w400, height: 1.5);
  static const TextStyle bodySmall =
      TextStyle(fontSize: 12, fontWeight: FontWeight.w400, height: 1.5);
  static const TextStyle labelLarge =
      TextStyle(fontSize: 14, fontWeight: FontWeight.w500, height: 1.4);
  static const TextStyle labelMedium =
      TextStyle(fontSize: 12, fontWeight: FontWeight.w500, height: 1.4);
  static const TextStyle labelSmall =
      TextStyle(fontSize: 10, fontWeight: FontWeight.w500, height: 1.4);

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
```

### 4. `theme/app_theme.dart`

```dart
import 'package:flutter/material.dart';
import 'app_color_scheme.dart';
import 'app_text_styles.dart';

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
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      textTheme: textTheme,
      extensions: <ThemeExtension<dynamic>>[appColors],
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        centerTitle: true,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerLow,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: AppTextStyles.labelLarge,
        ),
      ),
    );
  }
}
```

### 5. `theme/theme_context_extensions.dart`

```dart
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
```

### 6. `theme/theme.dart` — barrel

```dart
export 'app_colors.dart';
export 'app_color_scheme.dart';
export 'app_text_styles.dart';
export 'app_theme.dart';
export 'theme_context_extensions.dart';
```

---

## Wire into `MaterialApp`

```dart
import 'package:flutter/material.dart';
import 'theme/theme.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      home: const Scaffold(),
    );
  }
}
```

---

## Usage Rules (CRITICAL)

### NEVER in widget / screen code
```dart
AppColors.primary           // raw palette leak
Color(0xFF2E4A85)           // hardcoded hex
Colors.grey                 // Flutter default greys
TextStyle(color: ...)       // ad-hoc styles
```

### ALWAYS in widget / screen code
```dart
context.colorScheme.primary
context.colorScheme.onSurface
context.appColors.textSecondary
context.appColors.success
context.textTheme.bodyMedium
AppTextStyles.titleLarge.copyWith(color: context.appColors.textPrimary)
Colors.transparent          // exception — Flutter constant, semantically clear
```

---

## Patterns for Tricky Cases

### 1. Constructor default colors
`const` constructors can't read context. Make the param nullable, resolve in `build`.

```dart
class AppCard extends StatelessWidget {
  final Color? background;
  const AppCard({super.key, this.background});

  @override
  Widget build(BuildContext context) {
    final bg = background ?? context.colorScheme.surface;
    return Container(color: bg);
  }
}
```

### 2. Enums with colors
Don't store `Color` on a const enum field. Use a resolver extension.

```dart
enum Status { pending, done, failed }

extension StatusX on Status {
  Color color(BuildContext c) => switch (this) {
        Status.pending => c.appColors.warning,
        Status.done => c.appColors.success,
        Status.failed => c.colorScheme.error,
      };
}
```

### 3. Top-level color groups (charts, illustrations)
Wrap in a factory class resolved per-build.

```dart
class ChartColors {
  final Color grid;
  final Color line;
  ChartColors._(this.grid, this.line);
  factory ChartColors.of(BuildContext c) =>
      ChartColors._(c.appColors.borderSubtle, c.colorScheme.primary);
}
```

---

## Adding a New Semantic Color

1. Pick a **semantic** name, not a visual one. `borderActive` ✓ — `lightBlue` ✗.
2. Update `AppColorsTheme` in `theme/app_color_scheme.dart`:
   - Add `final Color newToken;`
   - Add to constructor
   - Add to `light` and `dark` static instances
   - Add to `copyWith`
   - Add to `lerp`
3. Use via `context.appColors.newToken`.

If the color maps to a Material 3 role (primary, error, surface…), extend `AppColorSchemes` instead of adding a custom token.

---

## Checklist

- [ ] Files created under `<target>/theme/` and exported via barrel
- [ ] `MaterialApp` wired to `AppTheme.light` (+ `AppTheme.dark` if requested)
- [ ] No widget references `AppColors.X` directly
- [ ] No hardcoded hex (`Color(0xFF...)`) outside `theme/`
- [ ] No `Colors.grey*` etc. in widgets — use semantic tokens
- [ ] All `TextStyle`s come from `AppTextStyles` or `context.textTheme`
- [ ] Constructor color params are nullable, resolved in `build`
- [ ] Enums use resolver extensions, never const `Color` fields
- [ ] New semantic colors added to `AppColorsTheme` (not raw palette) with semantic names
- [ ] App runs and renders correctly in light (and dark, if enabled)
