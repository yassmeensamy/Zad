import 'dart:convert';

import '../../../core/utils/country_flag.dart';

/// A selectable country returned by `GET /api/countries`. The backend sends a
/// single English [name] plus an ISO [code] (e.g. "EG"); there is no localized
/// name, so [name] is used as-is in the picker.
class CountryModel {
  const CountryModel({
    required this.id,
    required this.name,
    required this.code,
  });

  final int id;
  final String name;
  final String code;

  String? get flag => countryFlagEmoji(code);

  String get displayName {
    final emoji = flag;
    return emoji == null ? name : '$emoji  $name';
  }

  factory CountryModel.fromMap(Map<String, dynamic> map) => CountryModel(
    id: (map['id'] as num).toInt(),
    name: (map['name'] ?? '') as String,
    code: (map['code'] ?? '') as String,
  );

  factory CountryModel.fromJson(String source) =>
      CountryModel.fromMap(json.decode(source) as Map<String, dynamic>);

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'code': code,
  };

  String toJson() => json.encode(toMap());

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CountryModel &&
        other.id == id &&
        other.name == name &&
        other.code == code;
  }

  @override
  int get hashCode => Object.hash(id, name, code);

  @override
  String toString() => 'CountryModel(id: $id, name: $name, code: $code)';
}
