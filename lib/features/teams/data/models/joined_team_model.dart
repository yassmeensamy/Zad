import 'dart:convert';

import '../../../../core/utils/date_parsing.dart';

class JoinedTeamModel {
  const JoinedTeamModel({
    required this.teamId,
    required this.teamName,
    this.joinedAt,
  });

  final String teamId;
  final String teamName;
  final DateTime? joinedAt;

  factory JoinedTeamModel.fromMap(Map<String, dynamic> map) => JoinedTeamModel(
    teamId: map['teamId'] as String? ?? '',
    teamName: map['teamName'] as String? ?? '',
    joinedAt: parseIsoDate(map['joinedAt']),
  );

  factory JoinedTeamModel.fromJson(String source) =>
      JoinedTeamModel.fromMap(json.decode(source) as Map<String, dynamic>);

  Map<String, dynamic> toMap() => {
    'teamId': teamId,
    'teamName': teamName,
    if (joinedAt != null) 'joinedAt': joinedAt!.toIso8601String(),
  };

  String toJson() => json.encode(toMap());

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is JoinedTeamModel &&
        other.teamId == teamId &&
        other.teamName == teamName &&
        other.joinedAt == joinedAt;
  }

  @override
  int get hashCode => Object.hash(teamId, teamName, joinedAt);

  @override
  String toString() =>
      'JoinedTeamModel(teamId: $teamId, teamName: $teamName)';
}
