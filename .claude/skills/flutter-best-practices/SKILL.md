---
name: flutter-best-practices
description: Dart language patterns (null safety, records, pattern matching, SOLID) and documentation/accessibility standards. Auto-applied as background knowledge for Flutter code.
user-invocable: false
---

Apply these Dart and design rules when writing Flutter code.
For widgets, screens, state, models, theme, and reviews — defer to the dedicated skills.

## Dart Language Patterns

- **Null Safety**: Avoid `!` unless value is guaranteed non-null. Use `??` and `?.`.
- **Pattern Matching**: Use pattern matching where it simplifies code.
- **Records**: Use records to return multiple types instead of cumbersome classes.
- **Switch**: Prefer exhaustive `switch` expressions (no `break` needed).
- **Arrow Functions**: Use `=>` for simple one-line functions.
- **Async/Await**: Always use `async`/`await` with proper error handling. Use `Stream` for event sequences.

## SOLID & Code Quality

- **SOLID Principles**: Apply throughout the codebase.
- **Composition over Inheritance**: Favor composition for widgets and logic.
- **Immutability**: Prefer immutable data structures.
- **Naming**: `PascalCase` classes, `camelCase` members, `snake_case` files. No abbreviations.
- **Functions**: Single-purpose, strive for < 20 lines.
- **Line length**: 80 characters or fewer. No trailing comments.

## Documentation

- Use `///` for doc comments on all public APIs.
- First sentence: concise summary ending with period, then blank line.
- Comment **why**, not **what** — code should be self-explanatory.
- No redundant docs that just restate the class/method name.

## Framework-First Principle

- **Always prefer built-in Flutter widgets over manual workarounds.** If Flutter provides a widget that solves the problem (e.g., `PageView`, `IndexedStack`, `TabBarView`, `AutomaticKeepAliveClientMixin`), use it instead of writing custom controller logic, manual state resets, or glue code.

## Visual Design Principles

- **Typography hierarchy**: Distinct sizes for hero, headlines, body, captions.
- **Shadows**: Multi-layered drop shadows for depth; cards should look "lifted".
- **60-30-10 Rule**: 60% primary/neutral, 30% secondary, 10% accent color.
- **FittedBox**: Scale/fit a single child within its parent.
- **Stack**: `Positioned` for edge-anchoring, `Align` for alignment-based placement.

For code examples, see [reference.md](reference.md).
