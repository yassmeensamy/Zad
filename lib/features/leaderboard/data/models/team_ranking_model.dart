import 'dart:convert';

/// A single row in the global team leaderboard.
class TeamRankingModel {
  const TeamRankingModel({
    required this.rank,
    required this.teamId,
    required this.teamName,
    required this.memberCount,
    required this.totalCompletedLevels,
    required this.totalLevels,
  });

  final int rank;
  final String teamId;
  final String teamName;
  final int memberCount;
  final int totalCompletedLevels;
  final int totalLevels;

  double get progress {
    if (totalLevels <= 0) return 0;
    return (totalCompletedLevels / totalLevels).clamp(0, 1);
  }

  int get progressPercent => (progress * 100).round();

  factory TeamRankingModel.fromMap(Map<String, dynamic> map) =>
      TeamRankingModel(
        rank: (map['rank'] as num?)?.toInt() ?? 0,
        teamId: map['teamId'] as String? ?? '',
        teamName: map['teamName'] as String? ?? '',
        memberCount: (map['memberCount'] as num?)?.toInt() ?? 0,
        totalCompletedLevels:
            (map['totalCompletedLevels'] as num?)?.toInt() ?? 0,
        totalLevels: (map['totalLevels'] as num?)?.toInt() ?? 0,
      );

  factory TeamRankingModel.fromJson(String source) =>
      TeamRankingModel.fromMap(json.decode(source) as Map<String, dynamic>);

  Map<String, dynamic> toMap() => {
    'rank': rank,
    'teamId': teamId,
    'teamName': teamName,
    'memberCount': memberCount,
    'totalCompletedLevels': totalCompletedLevels,
    'totalLevels': totalLevels,
  };

  String toJson() => json.encode(toMap());

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TeamRankingModel &&
        other.rank == rank &&
        other.teamId == teamId &&
        other.teamName == teamName &&
        other.memberCount == memberCount &&
        other.totalCompletedLevels == totalCompletedLevels &&
        other.totalLevels == totalLevels;
  }

  @override
  int get hashCode => Object.hash(
    rank,
    teamId,
    teamName,
    memberCount,
    totalCompletedLevels,
    totalLevels,
  );

  @override
  String toString() =>
      'TeamRankingModel(#$rank $teamName, '
      '$totalCompletedLevels/$totalLevels, $memberCount members)';
}

/// The authenticated user's team position in the team leaderboard.
/// The API omits `teamId` here, so highlighting the row in the list requires
/// the current team id from the session.
class MyTeamRank {
  const MyTeamRank({
    required this.rank,
    required this.teamName,
    required this.totalCompletedLevels,
    required this.totalLevels,
  });

  final int rank;
  final String teamName;
  final int totalCompletedLevels;
  final int totalLevels;

  double get progress {
    if (totalLevels <= 0) return 0;
    return (totalCompletedLevels / totalLevels).clamp(0, 1);
  }

  factory MyTeamRank.fromMap(Map<String, dynamic> map) => MyTeamRank(
    rank: (map['rank'] as num?)?.toInt() ?? 0,
    teamName: map['teamName'] as String? ?? '',
    totalCompletedLevels: (map['totalCompletedLevels'] as num?)?.toInt() ?? 0,
    totalLevels: (map['totalLevels'] as num?)?.toInt() ?? 0,
  );

  Map<String, dynamic> toMap() => {
    'rank': rank,
    'teamName': teamName,
    'totalCompletedLevels': totalCompletedLevels,
    'totalLevels': totalLevels,
  };

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MyTeamRank &&
        other.rank == rank &&
        other.teamName == teamName &&
        other.totalCompletedLevels == totalCompletedLevels &&
        other.totalLevels == totalLevels;
  }

  @override
  int get hashCode =>
      Object.hash(rank, teamName, totalCompletedLevels, totalLevels);
}
