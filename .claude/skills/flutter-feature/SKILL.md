---
name: flutter-feature
description: Scaffold a new feature following EramDoctor architecture with Cubit state management, data layer, and presentation. Use when creating a new feature or screen group.
argument-hint: "[feature-name]"
---

# Flutter Feature Scaffold

Create a new feature named `$ARGUMENTS` following EramDoctor architecture.

## Before Writing Any Code

1. **Read the reference feature** — `apps/customer_app/lib/features/wallet/`
2. **Read CLAUDE.md** — full architecture guide
3. **Check existing code** for reusable patterns in `packages/shared/`

## Structure

```
features/$ARGUMENTS/
├── data/
│   ├── data_source/${ARGUMENTS}_remote_data_source.dart
│   └── repositories/${ARGUMENTS}_repository_impl.dart
├── models/${ARGUMENTS}_model.dart
└── presentation/
    ├── cubit/${ARGUMENTS}_cubit.dart & ${ARGUMENTS}_state.dart
    ├── screens/${ARGUMENTS}_screen.dart
    └── widgets/${ARGUMENTS}_widget.dart
```

## Layer Rules

**Model** — Immutable, handles all casting in `fromMap`. Use `parseToLocal()` for dates.

**DataSource** — Checks `statusCode` (200/201), creates Model with `.fromMap()`, throws `ServerException`.

**Repository** — Abstract class + Impl. Thin wrapper, no error handling.

**State** — Enum for status, single class, extensions for checks (`isLoading`, `isLoaded`, etc.), manual `==` and `hashCode`. No Equatable.

**Cubit** — Extends `BaseCubit<State>`. try-catch with `ServerException` + generic catch. Calls repository directly.

**Screen** — `Scaffold` + `BlocBuilder` + `Skeletonizer` for loading. Uses mock data for skeleton state.

## Data Flow

```
State DOWN:  Repository → Cubit → Screen
Events UP:   Screen → Cubit → Repository → DataSource
```

Never skip layers.

## Import

```dart
import 'package:core_eram/core_eram.dart';
```

## UI Rules

- `Scaffold` instead of `Scaffold`
- `ResponsiveText` instead of `Text`
- `CustomButton` instead of `ElevatedButton`
- `CustomTextFormField` instead of `TextField`
- `AppImage.svg` instead of `Image.asset`
- `context.colorScheme.X` or `context.appColors.Y` for colors
- `CustomEmptyWidget` for empty states
- `ErrorWidgetWithRetry` for error states
- All strings in `en.json` + `ar.json`, use `.tr()`
- RTL-first: implement in LTR logical order, Flutter auto-flips
- `EdgeInsetsDirectional` for directional padding

## Steps

1. Create model in `models/` with `fromMap`, `toMap`, `copyWith`, `==`, `hashCode`.
2. Create data source in `data/data_source/` — check status, return model, throw `ServerException`.
3. Create repository interface + impl in `data/repositories/`.
4. Create state class in `presentation/cubit/` with status enum + extensions.
5. Create cubit extending `BaseCubit` in `presentation/cubit/`.
6. Create screen with `Scaffold` + `BlocBuilder` + `Skeletonizer` in `presentation/screens/`.
7. Extract private widget classes into `presentation/widgets/`.
8. Add strings to `en.json` + `ar.json`.
9. Run `dart format .` then `flutter analyze`.
