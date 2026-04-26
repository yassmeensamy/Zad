---
name: flutter-state
description: Create Cubit state management with BaseCubit, status enum, state extensions, and anti-patterns. Use when adding state management to a feature or reviewing Cubit code.
argument-hint: "[feature-name]"
---

# Flutter State Management (Cubit)

Create state management for `$ARGUMENTS` using Cubit (extends `BaseCubit`).

## Design Rules

1. **Store only source data.** If a field can be computed from other state fields → make it a getter, not a stored field.
2. **One field = one source of truth.** If changing field A requires manually updating field B → B should be a getter.
3. **Cubit owns decisions, not transformations.** Cubit should fetch, filter, validate, decide, and emit. It should NOT build display-specific data.
4. **State getters for derivations, model statics for reusable logic.** State getter ties model logic to current state. Model static is reusable and state-agnostic.
5. **Primitive cubit for single-value state.** Index, toggle, count → `BaseCubit<int>`, `BaseCubit<bool>`. Don't create a full state class for one value.
6. **Every stored field must serve the UI.** If no widget reads it, don't store it. Don't store caller parameters that are only used for the API call.
7. **Every emit must cause a meaningful UI change.** If no widget cares, don't emit.

### Decision Flowchart

```
Store a value in state?
  → Derivable from other fields? → YES → getter
                                 → NO  → UI reads it? → YES → store
                                                       → NO  → don't store
```

## State Class

```dart
enum FeatureStatus { initial, loading, loaded, error }

class FeatureState {
  final FeatureStatus status;
  final FeatureModel? data;
  final String? errorMessage;

  const FeatureState({required this.status, this.data, this.errorMessage});

  // Nullable fields must use factory pattern for null reset
  FeatureState copyWith({
    FeatureStatus? status,
    FeatureModel? data,
    String? Function()? errorMessage,
  }) => FeatureState(
    status: status ?? this.status,
    data: data ?? this.data,
    errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
  );

  // Derived data → getter, not stored field
  // Example: List<ChartData> get chartPoints => data?.toChartData() ?? [];

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FeatureState &&
        other.status == status &&
        other.data == data &&
        other.errorMessage == errorMessage;
  }

  @override
  int get hashCode => Object.hashAll([status, data, errorMessage]);
}

extension FeatureStateX on FeatureState {
  bool get isInitial => status == FeatureStatus.initial;
  bool get isLoading => status == FeatureStatus.loading;
  bool get isLoaded => status == FeatureStatus.loaded;
  bool get isError => status == FeatureStatus.error;
}
```

## Cubit

```dart
class FeatureCubit extends BaseCubit<FeatureState> {
  final FeatureRepository _repo;
  FeatureCubit(this._repo) : super(const FeatureState(status: FeatureStatus.initial));

  Future<void> loadData() async {
    emit(state.copyWith(status: FeatureStatus.loading));
    try {
      final result = await _repo.getData();
      emit(state.copyWith(status: FeatureStatus.loaded, data: result));
    } on ServerException catch (e) {
      emit(state.copyWith(
        status: FeatureStatus.error,
        errorMessage: () => e.errors[0].detail,
      ));
    } catch (e) {
      logger.debug(e.toString());
    }
  }
}
```

### Primitive Cubit (single-value state)

```dart
class SelectIndexCubit extends BaseCubit<int> {
  SelectIndexCubit() : super(0);

  void select(int index) {
    if (index < 0) return;
    emit(index);
  }
}
```

## Best Practices

1. **State is immutable.** Always `emit(state.copyWith(...))`, never mutate.
2. **Manual `==` and `hashCode`** on all state classes. No Equatable. Use `Object.hashAll` (not XOR).
3. **One Cubit per feature.** No multi-responsibility Cubits.
4. **Data belongs in state classes**, not as fields on the Cubit.
5. **Cubit methods return `void` or `Future<void>`.** Never return data.
6. **Preserve data on error** — single state class with status enum so previous data persists.
7. **Use `BlocSelector`** to listen to a specific property and reduce rebuilds.
8. **Nullable fields in copyWith** must use factory pattern `T? Function()?` to support null reset.

## Rebuild Prevention Rules

1. **Every `BlocBuilder` needs a `buildWhen` or use `BlocSelector`.** Never use a bare `BlocBuilder`. Always ask: "what state change should actually rebuild this widget?"
2. **Don't share `errorMessage` across concerns.** One shared field means unrelated widgets react to each other's errors. Each concern should have its own error field, or widgets should read `errorMessage` inline only when their own status is error.
3. **Widgets own their own data.** Don't pass computed/derived data from parent to child. If a child can read from the cubit itself — let it. Parent should only pass identity (`profileId`) or UI-only concerns (`isLoading` for skeleton).
4. **Don't forward — let children subscribe.** If a parent method has 4+ params just passing state fields to children, each child should subscribe to exactly what it needs via `BlocSelector`/`buildWhen`.
5. **Local UI state doesn't need a Cubit.** A dropdown index, a toggle, an expanded flag — use `StatefulWidget` with `setState`. Reserve cubits for data that crosses widget boundaries or involves async.
6. **Don't put business logic in `build()`.** Data transformation (`ChartData.fromResponses(...)`) belongs in cubit/state getters, not inside the widget's build method.

## Cubit vs Controller — Source of Truth Rule

**Cubit is always the single source of truth for data.** Controllers are only a UI-level bridge when a widget requires one.

### When to use Cubit only (default — 90% of cases)

The field value is **data** — something you store, submit, or derive from:
- Dropdowns / selection widgets
- Checkboxes / toggles / radio buttons
- Date pickers (the `DateTime` value itself)
- Chips / multi-select
- Any value that goes into an API request

```
User taps → cubit.updateX(value) → state changes → UI rebuilds
```

### When to add a Controller (exception — only when widget forces it)

A widget **requires** a `TextEditingController` to function:
- `TextFormField` / `CustomTextFormField`
- `DatePickerField` (wraps `CustomTextFormField` internally)
- `Pinput` / OTP fields
- Search bars with clear/programmatic text changes

```
User types → onChanged → cubit.updateX(value)    (UI → Cubit)
Cubit resets → BlocListener → controller.clear()  (Cubit → UI, rare)
```

### Controller rules

1. **Create** in `initState`, seed from cubit state
2. **Push to cubit** via `onChanged` (UI → Cubit)
3. **Sync back** only for external resets via `BlocListener` (Cubit → UI), not for every emission
4. **Never rebuild** controllers inside `BlocBuilder` — kills cursor position and focus
5. **Dispose** in `dispose()`

### Custom selection widgets (no controller)

Wrap in `FormField<T>` inside a `Form` for validation:
- Use `field.didChange(value)` on selection (not `field.validate()`)
- Validator reads `value` param (not widget parameter) for correct same-frame validation
- `AutovalidateMode` handles error display timing

### Local UI state (not cubit, not controller)

These belong in `StatefulWidget` with `setState`:
- `_hasValidated` flag (when to show errors)
- `_formKey` (form validation trigger)
- Expanded/collapsed toggle
- Dropdown open/close

### Decision checklist

| Question | Yes | No |
|---|---|---|
| Does the widget require a `TextEditingController`? | Controller + Cubit | Cubit only |
| Do you need cursor position / text selection? | Controller | Cubit only |
| Is it a selection (tap to pick)? | Cubit only | — |
| Is it UI-only (form key, validation flag)? | Local `setState` | — |

> **If no widget forces you to use a controller, don't create one.**

## Anti-Patterns (NEVER DO)

1. **Never store derived data.** If it's computable from other fields, use a getter.
2. **Never store unused fields.** If no widget reads it from state, remove it.
3. **Never have a Cubit listen to another Cubit.** Use `BlocListener` in UI or shared repository stream.
4. **Never mutate state in place.** Always create new collections: `List.of(state.items)..add(newItem)`.
5. **No navigation/UI logic in Cubits.** Use `BlocListener` in presentation layer.
6. **Don't access Cubit from the same context that provides it.** Wrap with `Builder`.
7. **Don't use XOR for hashCode.** Use `Object.hashAll([...])`.

## Pagination (When Needed)

Add to state: `loadingMore` status, `PaginatableModel<T>? data`, `bool hasMore`, `isLoadingMore` getter.

```dart
Future<void> loadMore() async {
  if (state.data == null || !state.hasMore || state.isLoadingMore) return;
  emit(state.copyWith(status: FeatureStatus.loadingMore));
  try {
    final newData = await _repo.getData(cursor: state.data!.next);
    final merged = newData.copyWith(
      results: () => [...state.data!.results, ...newData.results],
    );
    emit(state.copyWith(
      status: FeatureStatus.loaded,
      data: merged,
      hasMore: newData.next?.isNotEmpty ?? false,
    ));
  } on ServerException catch (e) {
    emit(state.copyWith(
      status: FeatureStatus.error,
      errorMessage: () => e.errors[0].detail,
    ));
  }
}
```

## Prefer Built-in APIs

| Manual Workaround | Built-in Solution |
|---|---|
| Manual `dispose()` of `TextEditingController` / `FocusNode` created inline | `late final` with `StatefulWidget` lifecycle |
| Re-creating widget subtrees to "reset" state | `Key` change (`ValueKey` / `ObjectKey`) to force rebuild |
| Manual `WidgetsBindingObserver` for app lifecycle | `AppLifecycleListener` (Flutter 3.13+) |
| `Timer.periodic` for animation | `AnimationController` / `Ticker` / `TweenAnimationBuilder` |
| Manual `GlobalKey<FormState>` validation loops | `Form.of(context)` / `FormField` auto-validation |
| Manual `setState` deep in widget tree rebuilding large subtrees | `ValueListenableBuilder`, `BlocSelector`, or `Consumer` |
| `GlobalKey` overuse everywhere | Local keys or scoped state — only use `GlobalKey` when truly needed |

## Steps

1. **Decide:** primitive cubit or full state class? (single value → primitive)
2. Create state class in `presentation/cubit/` — status enum, manual `==`/`hashCode` with `Object.hashAll`.
3. Add state extensions (`isLoading`, `isLoaded`, etc.).
4. Identify derived data → make getters, not stored fields.
5. Create Cubit extending `BaseCubit<State>` with repository injected via constructor.
6. Add methods with try-catch: catch `ServerException` + generic catch with `logger.debug`.
7. Use `BlocProvider` to provide, `BlocBuilder` to rebuild UI, `BlocListener` for side effects.
8. Run `dart format .` then `flutter analyze`.
