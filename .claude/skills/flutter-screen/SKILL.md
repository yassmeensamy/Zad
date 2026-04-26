---
name: flutter-screen
description: Create a new screen with Scaffold, BlocBuilder, Skeletonizer loading, and responsive layout following EramDoctor conventions. Use when adding a new page or screen.
argument-hint: "[screen-name]"
---

# Flutter Screen Builder

Create a new screen named `$ARGUMENTS` following EramDoctor conventions.

## Rules

### Screen Structure
- Use `Scaffold` as the screen root.
- Use `BlocBuilder<FeatureCubit, FeatureState>` for state.
- Use `Skeletonizer` with mock data for loading state.
- Use `ErrorWidgetWithRetry` for error state.
- Use `CustomEmptyWidget` for empty state.
- The screen widget is a `StatelessWidget` (use `StatefulWidget` only for `ScrollPaginationMixin`).

### Template

```dart
class FeatureScreen extends StatelessWidget {
  static const _mockData = FeatureModel(id: '0', name: 'Loading placeholder');

  @override
  Widget build(BuildContext context) => Scaffold(
    body: BlocBuilder<FeatureCubit, FeatureState>(
      builder: (ctx, state) {
        if (state.isError) {
          return ErrorWidgetWithRetry(
            errorMessage: state.errorMessage ?? '',
            onRetry: () => ctx.read<FeatureCubit>().loadData(),
          );
        }
        if (state.isLoaded && state.data.isEmpty) {
          return CustomEmptyWidget(
            icon: SharedAppIcons.emptyIcon,
            message: 'no_data'.tr(),
            subMessage: 'no_data_message'.tr(),
          );
        }

        final data = state.isLoading ? _mockData : state.data!;
        return Skeletonizer(
          enabled: state.isLoading,
          child: _FeatureContent(data: data),
        );
      },
    ),
  );
}
```

### Widget Composition
- Break the screen into small, private widget classes.
- Do NOT use private helper methods that return widgets.
- Use `const` constructors on all child widgets.
- Keep `build()` focused on layout orchestration.

### Custom Components (Required)
- `ResponsiveText` instead of `Text`
- `CustomButton` instead of `ElevatedButton`
- `CustomTextFormField` instead of `TextField`
- `AppImage.svg` instead of `Image.asset`

### Layout & Responsiveness
- Use `Expanded`/`Flexible` for proportional sizing — no fixed heights.
- Use `SingleChildScrollView` when content may exceed viewport.
- Use `SafeArea` where needed.
- Use `EdgeInsetsDirectional` for RTL-safe padding.

### Colors & Styling
- `context.colorScheme.X` or `context.appColors.Y` — NEVER `AppColors.X` or hex.
- Use `AppTextStyles` for text styles.

### Strings & Localization
- All strings in `en.json` + `ar.json`, use `.tr()`.
- No manual `textDirection` — Flutter auto-flips for RTL.

### Rebuild Prevention
- **Every `BlocBuilder` needs a `buildWhen` or use `BlocSelector`.** Never bare `BlocBuilder` — always define what state change triggers a rebuild.
- **Widgets own their own data.** Don't pass derived state from parent to child. If a child can read from the cubit — let it. Parent passes only identity (`profileId`) or UI flags (`isLoading`).
- **Don't forward state through params.** If a method has 4+ params just passing cubit state → each child should use its own `BlocSelector`/`buildWhen` instead.
- **Local UI state uses `setState`.** Dropdown index, toggle, expanded — use `StatefulWidget`. Reserve cubits for shared/async state.

### Cubit Access
```dart
// Store once, reuse
final cubit = context.read<FeatureCubit>();
cubit.doA();
cubit.doB();
```

### Pagination (When Needed)
- Use `ScrollPaginationMixin` — override `onLoadMore`.
- Append `AppLoading.loadMoreLoadingWidget()` as last item.
- Wrap with `RefreshIndicator` for pull-to-refresh.

### Prefer Built-in Widgets

| Manual Workaround | Built-in Solution |
|---|---|
| `ScrollController.jumpTo(0)` on page/tab switch | `PageView` or `TabBarView` (each page manages its own scroll) |
| Conditional widget swap to show one child at a time | `IndexedStack` (preserves state of all children) |
| `AnimatedSwitcher` + manual index tracking for pages | `PageView` / `TabBarView` with controller |
| Manual `ScrollController` + listener for pagination | `ScrollPaginationMixin` or `NotificationListener<ScrollNotification>` |
| Manual scroll-to-index math | `Scrollable.ensureVisible()` |
| Manually nesting `ScrollView` inside `ScrollView` | `NestedScrollView` or `CustomScrollView` with Slivers |
| Rebuilding every item in a list manually | `ListView.builder` or `GridView.builder` (lazy building) |
| `ScrollController.jumpTo(0)` for scroll-to-top | `PageController`, `TabBarView`, or `Scrollable.ensureVisible()` |
| `StreamBuilder` + manual `ConnectionState` handling | `AsyncSnapshot` pattern with `.when()` style |
| Manual JSON encoding/decoding scattered in UI | Centralize in model `fromMap` / `toMap` |
| Manual `Future` chaining with nested `.then()` | `async` / `await` |

## Steps

1. Create the screen in `presentation/screens/`.
2. Use `Scaffold` + `BlocBuilder` + `Skeletonizer` pattern.
3. Handle all states: loading (skeleton), error, empty, loaded.
4. Break UI into private widget classes in `presentation/widgets/`.
5. Use only custom components and theme colors.
6. Add strings to `en.json` + `ar.json`.
7. Run `dart format .` then `flutter analyze`.
