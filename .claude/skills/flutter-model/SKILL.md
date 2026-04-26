---
name: flutter-model
description: Create a Dart data model with manual serialization (fromMap/toMap), null safety, copyWith, and proper equality. Use when creating API models, entities, or DTOs.
argument-hint: "[model-name]"
---

# Flutter Data Model Builder

Create a data model named `$ARGUMENTS`. No code generation — use manual serialization.

## Rules

- All fields `final`, immutable.
- Sound null safety. Avoid `!`.
- `PascalCase` class, `snake_case` file, `camelCase` fields.
- Models handle ALL casting (no `as` in data/presentation layers).
- Use `parseToLocal()` from `date_utils.dart` for DateTime fields — never `DateTime.parse()`.
- Include: `fromMap`, `fromJson`, `toMap`, `toJson`, `copyWith`, `==`, `hashCode`, `toString`.
- `fromMap` parameter must be typed `Map<String, dynamic>`, never `dynamic`.
- `hashCode` must use `Object.hash()` / `Object.hashAll()` — never XOR (`^`).
- For `List` fields: use `listEquals()` in `==` and `Object.hashAll(list)` in `hashCode` to keep the contract consistent.
- `copyWith` must not contain dead/unused parameters — every param must map to a field.
- `toString()` must have balanced parentheses.
- Derived data belongs on the model, not in the UI. If a value can be computed from a model's fields (e.g., `age` from `birthDate`), expose it as a getter on the model. If the calculation is reused across unrelated models, extract the math into a shared utility and have each model's getter delegate to it.

## Template

```dart
import 'dart:convert';

class FeatureModel {
  final String id;
  final String name;
  final String? description;

  const FeatureModel({
    required this.id,
    required this.name,
    this.description,
  });

  factory FeatureModel.fromMap(Map<String, dynamic> map) => FeatureModel(
    id: map['id'] as String,
    name: map['name'] as String,
    description: map['description'] as String?,
    // For DateTime: parseToLocal(map['createdAt'] as String)
  );

  factory FeatureModel.fromJson(String source) =>
      FeatureModel.fromMap(json.decode(source) as Map<String, dynamic>);

  FeatureModel copyWith({
    String? id,
    String? name,
    String? description,
  }) => FeatureModel(
    id: id ?? this.id,
    name: name ?? this.name,
    description: description ?? this.description,
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'description': description,
  };

  String toJson() => json.encode(toMap());

  @override
  String toString() => 'FeatureModel(id: $id, name: $name, description: $description)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FeatureModel &&
        other.id == id &&
        other.name == name &&
        other.description == description;
  }

  @override
  int get hashCode => Object.hash(id, name, description);
}
```

## Steps

1. Create file in `models/` as `snake_case.dart`.
2. Define class with `const` constructor and named parameters.
3. Add `fromMap` with all casting handled inside the factory.
4. Add `fromJson`, `toMap`, `toJson`, `copyWith`.
5. Add `==`, `hashCode`, `toString`.
6. Run `dart format .` then `flutter analyze`.
