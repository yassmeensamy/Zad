import 'dart:convert';

import '../../../../core/utils/date_parsing.dart';

class CreatedTeamModel {
  const CreatedTeamModel({
    required this.id,
    required this.name,
    required this.joinCode,
    this.createdAt,
  });

  final String id;
  final String name;
  final String joinCode;
  final DateTime? createdAt;

  factory CreatedTeamModel.fromMap(Map<String, dynamic> map) =>
      CreatedTeamModel(
        id: map['id'] as String? ?? '',
        name: map['name'] as String? ?? '',
        joinCode: map['joinCode'] as String? ?? '',
        createdAt: parseIsoDate(map['createdAt']),
      );

  factory CreatedTeamModel.fromJson(String source) =>
      CreatedTeamModel.fromMap(json.decode(source) as Map<String, dynamic>);

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'joinCode': joinCode,
    if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
  };

  String toJson() => json.encode(toMap());

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CreatedTeamModel &&
        other.id == id &&
        other.name == name &&
        other.joinCode == joinCode &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode => Object.hash(id, name, joinCode, createdAt);

  @override
  String toString() =>
      'CreatedTeamModel(id: $id, name: $name, joinCode: $joinCode)';
}
