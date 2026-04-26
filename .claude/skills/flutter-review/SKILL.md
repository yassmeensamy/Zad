---
name: flutter-review
description: Review Flutter code against EramDoctor CLAUDE.md conventions. Checks architecture, theme usage, custom components, performance, and accessibility. Use after implementing a feature or before committing.
argument-hint: "[file-or-directory]"
disable-model-invocation: true
---

# Flutter Code Review

Review `$ARGUMENTS` against EramDoctor conventions. Run all checks below.

## Before Reviewing

1. Read the file(s) specified in `$ARGUMENTS`.
2. Read CLAUDE.md for the full architectural guide.
3. Check related files (cubit, state, model, data source) if reviewing a screen.

## Review Checklist

### 1. Architecture & Structure
- [ ] Follows feature-based structure: `data/`, `models/`, `presentation/`
- [ ] DataSource checks statusCode (200/201), throws `ServerException`
- [ ] Repository is thin wrapper, no error handling
- [ ] Models handle all casting in `fromMap` (no `as` in other layers)
- [ ] Uses `parseToLocal()` for DateTime — never `DateTime.parse()`
- [ ] Imports `core_eram` where needed

### 2. State Management
- [ ] Cubit extends `BaseCubit`, not raw `Cubit`
- [ ] State uses enum + extensions (`isLoading`, `isLoaded`, etc.)
- [ ] Manual `==` and `hashCode` — no Equatable
- [ ] try-catch with `ServerException` + generic catch
- [ ] Data preserved on error (single state class with status enum)
- [ ] No Cubit-to-Cubit listening

### 3. UI Components
- [ ] `ResponsiveText` — NOT `Text`
- [ ] `CustomButton` — NOT `ElevatedButton`
- [ ] `CustomTextFormField` — NOT `TextField`
- [ ] `AppImage.svg` — NOT `Image.asset`
- [ ] `CustomEmptyWidget` for empty states
- [ ] `ErrorWidgetWithRetry` for error states
- [ ] `Skeletonizer` with mock data for loading state

### 4. Theme & Colors
- [ ] Colors from `context.colorScheme.X` or `context.appColors.Y`
- [ ] NO `AppColors.X` in widget/presentation code
- [ ] NO hardcoded hex `Color(0xFF...)`
- [ ] `Colors.transparent` instead of `AppColors.transparent`
- [ ] Constructor color params nullable with `build()` resolution
- [ ] Enums use `resolveColor(BuildContext)` pattern

### 5. Localization & RTL
- [ ] All strings in `en.json` + `ar.json` with `.tr()`
- [ ] No manual `textDirection`
- [ ] `EdgeInsetsDirectional` for directional padding
- [ ] RTL-first: Figma-left → code `right` for `Positioned`

### 6. Widget Best Practices
- [ ] Widgets are immutable, fields `final`
- [ ] `const` constructors where possible
- [ ] Private widget classes — NOT helper methods returning Widget
- [ ] No expensive operations in `build()`
- [ ] `ListView.builder` for long lists
- [ ] `Expanded`/`Flexible` for layout, no fixed heights

### 7. Code Quality
- [ ] Meaningful names, no abbreviations
- [ ] Functions < 20 lines, single purpose
- [ ] Null safety — avoid `!` unless guaranteed
- [ ] Arrow syntax for simple one-liners
- [ ] Exhaustive `switch` expressions
- [ ] No trailing comments

### 8. Accessibility
- [ ] `Semantics` labels on interactive elements
- [ ] Text contrast >= 4.5:1
- [ ] Dynamic text scaling supported

### 9. Performance
- [ ] `const` constructors to reduce rebuilds
- [ ] `compute()` for expensive calculations
- [ ] `BlocSelector` to reduce unnecessary rebuilds
- [ ] No manual workarounds where Flutter provides a built-in widget (e.g., `PageView` instead of `ScrollController.jumpTo(0)`, `IndexedStack` instead of conditional build/destroy, `TabBarView` instead of `AnimatedSwitcher` + manual state sync)

## Output Format

For each issue:
```
**[Category] - [Severity: high/medium/low]**
File: <file_path>:<line_number>
Issue: <description>
Fix: <suggested fix with code>
```

End with:
- Total issues by severity
- Overall: **PASS** | **NEEDS WORK** | **MAJOR ISSUES**
