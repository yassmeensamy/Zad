import 'dart:convert';

/// A selectable country returned by `GET /api/countries`. The backend sends a
/// single English [name], an ISO [code] (e.g. "EG") and a ready-made
/// [countryFlag] emoji; there is no localized name, so [name] is used as-is in
/// the picker.
class CountryModel {
  const CountryModel({
    required this.id,
    required this.name,
    required this.code,
    required this.countryFlag,
    required this.createdAt,
  });

  final int id;
  final String name;
  final String code;
  final String? countryFlag;
  final DateTime? createdAt;

  /// Picker label: the server-provided flag followed by the name, falling back
  /// to the bare name when the backend omits the flag.
  String get displayName {
    final flag = countryFlag;
    return flag == null || flag.isEmpty ? name : '$flag  $name';
  }

  factory CountryModel.fromMap(Map<String, dynamic> map) => CountryModel(
    id: (map['id'] as num).toInt(),
    name: (map['name'] ?? '') as String,
    code: (map['code'] ?? '') as String,
    countryFlag: map['countryFlag'] as String?,
    createdAt: map['createdAt'] == null
        ? null
        : DateTime.tryParse(map['createdAt'] as String),
  );

  factory CountryModel.fromJson(String source) =>
      CountryModel.fromMap(json.decode(source) as Map<String, dynamic>);

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'code': code,
    'countryFlag': countryFlag,
    'createdAt': createdAt?.toIso8601String(),
  };

  String toJson() => json.encode(toMap());

  CountryModel copyWith({
    int? id,
    String? name,
    String? code,
    String? countryFlag,
    DateTime? createdAt,
  }) => CountryModel(
    id: id ?? this.id,
    name: name ?? this.name,
    code: code ?? this.code,
    countryFlag: countryFlag ?? this.countryFlag,
    createdAt: createdAt ?? this.createdAt,
  );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CountryModel &&
        other.id == id &&
        other.name == name &&
        other.code == code &&
        other.countryFlag == countryFlag &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode => Object.hash(id, name, code, countryFlag, createdAt);

  @override
  String toString() =>
      'CountryModel(id: $id, name: $name, code: $code, '
      'countryFlag: $countryFlag)';
}
