import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'team_member_progress_model.dart';

class TeamProgressSummaryModel {
  const TeamProgressSummaryModel({
    required this.teamRank,
    required this.totalTeams,
    this.members = const [],
  });

  final int teamRank;
  final int totalTeams;
  final List<TeamMemberProgressModel> members;

  factory TeamProgressSummaryModel.fromMap(Map<String, dynamic> map) =>
      TeamProgressSummaryModel(
        teamRank: (map['teamRank'] as num?)?.toInt() ?? 0,
        totalTeams: (map['totalTeams'] as num?)?.toInt() ?? 0,
        members:
            (map['members'] as List<dynamic>?)
                ?.map(
                  (e) => TeamMemberProgressModel.fromMap(
                    e as Map<String, dynamic>,
                  ),
                )
                .toList() ??
            const [],
      );

  factory TeamProgressSummaryModel.fromJson(String source) =>
      TeamProgressSummaryModel.fromMap(
        json.decode(source) as Map<String, dynamic>,
      );

  Map<String, dynamic> toMap() => {
    'teamRank': teamRank,
    'totalTeams': totalTeams,
    'members': members.map((e) => e.toMap()).toList(),
  };

  String toJson() => json.encode(toMap());

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TeamProgressSummaryModel &&
        other.teamRank == teamRank &&
        other.totalTeams == totalTeams &&
        listEquals(other.members, members);
  }

  @override
  int get hashCode =>
      Object.hash(teamRank, totalTeams, Object.hashAll(members));

  @override
  String toString() =>
      'TeamProgressSummaryModel(rank: $teamRank/$totalTeams, '
      'members: ${members.length})';
}
