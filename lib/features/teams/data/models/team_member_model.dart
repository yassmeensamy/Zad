import 'dart:convert';

import '../../../../core/utils/date_parsing.dart';
import 'team_role_enum.dart';

class TeamMemberModel {
  const TeamMemberModel({
    required this.userId,
    required this.username,
    required this.role,
    this.joinedAt,
  });

  final String userId;
  final String username;
  final TeamRoleEnum role;
  final DateTime? joinedAt;

  bool get isOwner => role == TeamRoleEnum.owner;

  factory TeamMemberModel.fromMap(Map<String, dynamic> map) => TeamMemberModel(
    userId: map['userId'] as String? ?? '',
    username: map['username'] as String? ?? '',
    role: TeamRoleEnum.fromApi(map['role'] as String?),
    joinedAt: parseIsoDate(map['joinedAt']),
  );

  factory TeamMemberModel.fromJson(String source) =>
      TeamMemberModel.fromMap(json.decode(source) as Map<String, dynamic>);

  Map<String, dynamic> toMap() => {
    'userId': userId,
    'username': username,
    'role': role.toApi(),
    if (joinedAt != null) 'joinedAt': joinedAt!.toIso8601String(),
  };

  String toJson() => json.encode(toMap());

  TeamMemberModel copyWith({
    String? userId,
    String? username,
    TeamRoleEnum? role,
    DateTime? joinedAt,
  }) => TeamMemberModel(
    userId: userId ?? this.userId,
    username: username ?? this.username,
    role: role ?? this.role,
    joinedAt: joinedAt ?? this.joinedAt,
  );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TeamMemberModel &&
        other.userId == userId &&
        other.username == username &&
        other.role == role &&
        other.joinedAt == joinedAt;
  }

  @override
  int get hashCode => Object.hash(userId, username, role, joinedAt);

  @override
  String toString() =>
      'TeamMemberModel(userId: $userId, username: $username, role: $role)';
}
