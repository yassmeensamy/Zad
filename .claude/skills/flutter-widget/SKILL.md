---
name: flutter-widget
description: Create a Flutter widget following composition, immutability, const constructors, and EramDoctor custom component patterns. Use when building a new reusable UI component.
argument-hint: "[widget-name]"
---

# Flutter Widget Builder

Create a widget named `$ARGUMENTS` following EramDoctor conventions.

## Rules

### Widget Structure
- Prefer `StatelessWidget`. Use `StatefulWidget` only for ephemeral state.
- Use `const` constructors on every widget that allows it.
- All fields must be `final` — widgets are immutable.
- Use composition: build complex widgets from smaller ones.
- Use small, private `Widget` classes — NOT private helper methods returning Widget.

### Build Method
- Keep `build()` small and focused.
- Break large `build()` into smaller private widget classes.
- Never perform expensive operations inside `build()`.

### Performance
- Use `const` constructors to reduce unnecessary rebuilds.
- Use `ListView.builder` for long lists (lazy loading).
- Use `compute()` for expensive calculations.

### Required Custom Components (Never Use Native)
- `ResponsiveText('key'.tr(), style: AppTextStyles.font16weight400)` — NOT `Text`
- `CustomButton(onPressed: (){}, text: 'key'.tr())` — NOT `ElevatedButton`
- `CustomTextFormField(context: context, controller: c, hintText: 'key'.tr())` — NOT `TextField`
- `AppImage.svg(assetPath: Assets.icon)` — NOT `Image.asset`

### Colors (CRITICAL)
- `context.colorScheme.primary` or `context.appColors.warning` — NEVER `AppColors.X` or hardcoded hex.
- Constructor color params: make nullable, resolve in `build()`:

```dart
const MyWidget({this.color});
final Color? color;

@override
Widget build(BuildContext context) {
  final resolvedColor = color ?? context.colorScheme.surface;
}
```

### Layout
- Use `Expanded` to fill remaining space, `Flexible` to shrink.
- Don't combine `Expanded` and `Flexible` in the same `Row`/`Column`.
- Use `Wrap` when widgets would overflow.
- Use `EdgeInsetsDirectional` for RTL-safe padding.
- No fixed heights — use responsive sizing.

### State (if needed)
- Ephemeral/local state: `setState` or `ValueNotifier` + `ValueListenableBuilder`.
- Feature/app state: Cubit via `BlocBuilder` / `BlocListener`.

### Strings
- All user-visible strings in `en.json` + `ar.json`, accessed with `.tr()`.

### Prefer Built-in Widgets

| Manual Workaround | Built-in Solution |
|---|---|
| `Stack` + `Positioned` to overlay loading | `OverlayPortal`, `showDialog`, or `showModalBottomSheet` |
| Manual size calculation with `LayoutBuilder` + `setState` | `IntrinsicHeight` / `IntrinsicWidth` or `FittedBox` |
| Rebuilding entire subtree for theme/locale change | `Theme.of(context)` / `Localizations.of(context)` (auto-rebuilds) |
| Manual show/hide with `Visibility` + bool flag | `AnimatedCrossFade` or `AnimatedSwitcher` |
| `WidgetStateProperty.resolveWith` for a single state | `WidgetStateProperty.all()` if same for all states |
| `WidgetStateProperty.resolveWith` for active/inactive only | `WidgetStatePropertyAll` or early return |
| Custom animations with `Timer.periodic` | `AnimationController` / `Ticker` / `TweenAnimationBuilder` |
| Recreating widget subtrees manually to reset state | Use `Key` (`ValueKey` / `ObjectKey`) to force rebuild |
| `GlobalKey` used everywhere for accessing state | Local keys or scoped state — reserve `GlobalKey` for cross-tree access only |

## Steps

1. Determine if the widget needs state (Stateless vs Stateful).
2. Create the widget file in `snake_case.dart`.
3. Add a `const` constructor with named parameters.
4. Use only custom components (ResponsiveText, CustomButton, etc.).
5. Use `context.colorScheme.X` / `context.appColors.Y` for all colors.
6. Extract complex subtrees into private widget classes.
7. Run `dart format .` then `flutter analyze`.
