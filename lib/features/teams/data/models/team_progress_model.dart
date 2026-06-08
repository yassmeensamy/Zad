import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'team_category_progress_model.dart';
import 'team_member_progress_model.dart';

class TeamProgressModel {
  const TeamProgressModel({
    required this.teamId,
    required this.teamName,
    required this.teamRank,
    required this.totalTeams,
    this.members = const [],
    this.category,
  });

  final String teamId;
  final String teamName;
  final int teamRank;
  final int totalTeams;

  /// Leaderboard-style summary: total progress per member across all
  /// categories. Present in both modes.
  final List<TeamMemberProgressModel> members;

  /// Per-category breakdown, only populated when the request was scoped to a
  /// specific category id via [TeamsRemoteDataSource.getMyTeamProgress].
  final TeamCategoryProgressModel? category;

  int get totalLevels => members.fold(0, (sum, m) => sum + m.totalLevels);

  int get totalCompleted =>
      members.fold(0, (sum, m) => sum + m.completedLevels);

  double get overallProgress {
    if (totalLevels <= 0) return 0;
    return (totalCompleted / totalLevels).clamp(0, 1);
  }

  int get overallProgressPercent => (overallProgress * 100).round();

  factory TeamProgressModel.fromMap(Map<String, dynamic> map) =>
      TeamProgressModel(
        teamId: map['teamId'] as String? ?? '',
        teamName: map['teamName'] as String? ?? '',
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
        category: map['category'] == null
            ? null
            : TeamCategoryProgressModel.fromMap(
                map['category'] as Map<String, dynamic>,
              ),
      );

  factory TeamProgressModel.fromJson(String source) =>
      TeamProgressModel.fromMap(json.decode(source) as Map<String, dynamic>);

  Map<String, dynamic> toMap() => {
    'teamId': teamId,
    'teamName': teamName,
    'teamRank': teamRank,
    'totalTeams': totalTeams,
    'members': members.map((e) => e.toMap()).toList(),
    if (category != null) 'category': category!.toMap(),
  };

  String toJson() => json.encode(toMap());

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TeamProgressModel &&
        other.teamId == teamId &&
        other.teamName == teamName &&
        other.teamRank == teamRank &&
        other.totalTeams == totalTeams &&
        listEquals(other.members, members) &&
        other.category == category;
  }

  @override
  int get hashCode => Object.hash(
    teamId,
    teamName,
    teamRank,
    totalTeams,
    Object.hashAll(members),
    category,
  );

  @override
  String toString() =>
      'TeamProgressModel(teamId: $teamId, teamName: $teamName, '
      'teamRank: $teamRank/$totalTeams)';
}
