import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'team_category_progress_model.dart';
import 'team_member_progress_model.dart';
import 'team_progress_model.dart';

class TeamProgressSummaryModel {
  const TeamProgressSummaryModel({
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
  /// specific category id.
  final TeamCategoryProgressModel? category;

  factory TeamProgressSummaryModel.fromMap(Map<String, dynamic> map) =>
      TeamProgressSummaryModel(
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

  factory TeamProgressSummaryModel.fromJson(String source) =>
      TeamProgressSummaryModel.fromMap(
        json.decode(source) as Map<String, dynamic>,
      );

  /// Derives the summary from a full [TeamProgressModel] response. The backend
  /// no longer exposes a dedicated `/progress/summary` endpoint, so the summary
  /// is projected from the single `/progress` payload.
  factory TeamProgressSummaryModel.fromProgress(TeamProgressModel progress) =>
      TeamProgressSummaryModel(
        teamId: progress.teamId,
        teamName: progress.teamName,
        teamRank: progress.teamRank,
        totalTeams: progress.totalTeams,
        members: progress.members,
        category: progress.category,
      );

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
    return other is TeamProgressSummaryModel &&
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
      'TeamProgressSummaryModel(teamId: $teamId, teamName: $teamName, '
      'rank: $teamRank/$totalTeams, members: ${members.length})';
}
