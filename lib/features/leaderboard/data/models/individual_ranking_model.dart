import 'dart:convert';

class IndividualRankingModel {
  const IndividualRankingModel({
    required this.rank,
    required this.userId,
    required this.username,
    required this.completedLevels,
    required this.totalLevels,
  });

  final int rank;
  final String userId;
  final String username;
  final int completedLevels;
  final int totalLevels;

  double get progress {
    if (totalLevels <= 0) return 0;
    return (completedLevels / totalLevels).clamp(0, 1);
  }

  int get progressPercent => (progress * 100).round();

  factory IndividualRankingModel.fromMap(Map<String, dynamic> map) =>
      IndividualRankingModel(
        rank: (map['rank'] as num?)?.toInt() ?? 0,
        userId: map['userId'] as String? ?? '',
        username: map['username'] as String? ?? '',
        completedLevels: (map['completedLevels'] as num?)?.toInt() ?? 0,
        totalLevels: (map['totalLevels'] as num?)?.toInt() ?? 0,
      );

  factory IndividualRankingModel.fromJson(String source) =>
      IndividualRankingModel.fromMap(
        json.decode(source) as Map<String, dynamic>,
      );

  Map<String, dynamic> toMap() => {
    'rank': rank,
    'userId': userId,
    'username': username,
    'completedLevels': completedLevels,
    'totalLevels': totalLevels,
  };

  String toJson() => json.encode(toMap());

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is IndividualRankingModel &&
        other.rank == rank &&
        other.userId == userId &&
        other.username == username &&
        other.completedLevels == completedLevels &&
        other.totalLevels == totalLevels;
  }

  @override
  int get hashCode =>
      Object.hash(rank, userId, username, completedLevels, totalLevels);

  @override
  String toString() =>
      'IndividualRankingModel(#$rank $username, '
      '$completedLevels/$totalLevels)';
}

class MyIndividualRank {
  const MyIndividualRank({
    required this.rank,
    required this.completedLevels,
    required this.totalLevels,
  });

  final int rank;
  final int completedLevels;
  final int totalLevels;

  double get progress {
    if (totalLevels <= 0) return 0;
    return (completedLevels / totalLevels).clamp(0, 1);
  }

  factory MyIndividualRank.fromMap(Map<String, dynamic> map) =>
      MyIndividualRank(
        rank: (map['rank'] as num?)?.toInt() ?? 0,
        completedLevels: (map['completedLevels'] as num?)?.toInt() ?? 0,
        totalLevels: (map['totalLevels'] as num?)?.toInt() ?? 0,
      );

  Map<String, dynamic> toMap() => {
    'rank': rank,
    'completedLevels': completedLevels,
    'totalLevels': totalLevels,
  };

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MyIndividualRank &&
        other.rank == rank &&
        other.completedLevels == completedLevels &&
        other.totalLevels == totalLevels;
  }

  @override
  int get hashCode => Object.hash(rank, completedLevels, totalLevels);
}
