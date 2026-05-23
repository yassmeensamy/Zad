import 'dart:convert';

import '../../../../core/utils/date_parsing.dart';
import 'team_role_enum.dart';

class TeamModel {
  const TeamModel({
    required this.id,
    required this.name,
    required this.joinCode,
    required this.memberCount,
    required this.yourRole,
    this.createdAt,
  });

  final String id;
  final String name;
  final String joinCode;
  final int memberCount;
  final TeamRoleEnum yourRole;
  final DateTime? createdAt;

  bool get isOwner => yourRole == TeamRoleEnum.owner;

  factory TeamModel.fromMap(Map<String, dynamic> map) => TeamModel(
    id: map['id'] as String? ?? '',
    name: map['name'] as String? ?? '',
    joinCode: map['joinCode'] as String? ?? '',
    memberCount: (map['memberCount'] as num?)?.toInt() ?? 0,
    yourRole: TeamRoleEnum.fromApi(map['yourRole'] as String?),
    createdAt: parseIsoDate(map['createdAt']),
  );

  factory TeamModel.fromJson(String source) =>
      TeamModel.fromMap(json.decode(source) as Map<String, dynamic>);

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'joinCode': joinCode,
    'memberCount': memberCount,
    'yourRole': yourRole.toApi(),
    if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
  };

  String toJson() => json.encode(toMap());

  TeamModel copyWith({
    String? id,
    String? name,
    String? joinCode,
    int? memberCount,
    TeamRoleEnum? yourRole,
    DateTime? createdAt,
  }) => TeamModel(
    id: id ?? this.id,
    name: name ?? this.name,
    joinCode: joinCode ?? this.joinCode,
    memberCount: memberCount ?? this.memberCount,
    yourRole: yourRole ?? this.yourRole,
    createdAt: createdAt ?? this.createdAt,
  );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TeamModel &&
        other.id == id &&
        other.name == name &&
        other.joinCode == joinCode &&
        other.memberCount == memberCount &&
        other.yourRole == yourRole &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode =>
      Object.hash(id, name, joinCode, memberCount, yourRole, createdAt);

  @override
  String toString() =>
      'TeamModel(id: $id, name: $name, memberCount: $memberCount, '
      'yourRole: $yourRole)';
}
