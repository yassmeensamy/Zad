import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'team_category_progress_model.dart';

class TeamProgressModel {
  const TeamProgressModel({
    required this.teamId,
    required this.teamName,
    required this.teamRank,
    required this.totalTeams,
    this.categories = const [],
  });

  final String teamId;
  final String teamName;
  final int teamRank;
  final int totalTeams;
  final List<TeamCategoryProgressModel> categories;

  int get totalLevels =>
      categories.fold(0, (sum, c) => sum + c.totalLevels * c.members.length);

  int get totalCompleted => categories.fold(
    0,
    (sum, c) => sum + c.members.fold(0, (s, m) => s + m.completedLevels),
  );

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
        categories:
            (map['categories'] as List<dynamic>?)
                ?.map(
                  (e) => TeamCategoryProgressModel.fromMap(
                    e as Map<String, dynamic>,
                  ),
                )
                .toList() ??
            const [],
      );

  factory TeamProgressModel.fromJson(String source) =>
      TeamProgressModel.fromMap(json.decode(source) as Map<String, dynamic>);

  Map<String, dynamic> toMap() => {
    'teamId': teamId,
    'teamName': teamName,
    'teamRank': teamRank,
    'totalTeams': totalTeams,
    'categories': categories.map((e) => e.toMap()).toList(),
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
        listEquals(other.categories, categories);
  }

  @override
  int get hashCode => Object.hash(
    teamId,
    teamName,
    teamRank,
    totalTeams,
    Object.hashAll(categories),
  );

  @override
  String toString() =>
      'TeamProgressModel(teamId: $teamId, teamName: $teamName, '
      'teamRank: $teamRank/$totalTeams)';
}
