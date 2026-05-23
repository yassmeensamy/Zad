import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'team_member_model.dart';

class TeamMembersModel {
  const TeamMembersModel({
    required this.teamId,
    this.members = const [],
  });

  final String teamId;
  final List<TeamMemberModel> members;

  factory TeamMembersModel.fromMap(Map<String, dynamic> map) =>
      TeamMembersModel(
        teamId: map['teamId'] as String? ?? '',
        members:
            (map['members'] as List<dynamic>?)
                ?.map((e) => TeamMemberModel.fromMap(e as Map<String, dynamic>))
                .toList() ??
            const [],
      );

  factory TeamMembersModel.fromJson(String source) =>
      TeamMembersModel.fromMap(json.decode(source) as Map<String, dynamic>);

  Map<String, dynamic> toMap() => {
    'teamId': teamId,
    'members': members.map((e) => e.toMap()).toList(),
  };

  String toJson() => json.encode(toMap());

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TeamMembersModel &&
        other.teamId == teamId &&
        listEquals(other.members, members);
  }

  @override
  int get hashCode => Object.hash(teamId, Object.hashAll(members));

  @override
  String toString() =>
      'TeamMembersModel(teamId: $teamId, members: ${members.length})';
}
