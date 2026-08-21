import 'dart:convert';

class IndividualRankingModel {
  const IndividualRankingModel({
    required this.rank,
    required this.userId,
    required this.username,
    required this.completedLevels,
    required this.totalLevels,
    required this.countryName,
    required this.countryCode,
    required this.countryFlag,
    this.totalPoints = 0,
  });

  final int rank;
  final String userId;
  final String username;
  final int completedLevels;
  final int totalLevels;

  /// The ranked user's points balance. Defaults to 0: the rankings endpoint
  /// ranks on `completedLevels` and does not send this yet, so rows read zero
  /// until the backend adds `totalPoints` to the payload.
  final int totalPoints;

  /// Country of the ranked user. All three are null when the user never picked
  /// a country — the backend only guarantees them for `country_id` filtered
  /// requests.
  final String? countryName;
  final String? countryCode;
  final String? countryFlag;

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
        countryName: map['countryName'] as String?,
        countryCode: map['countryCode'] as String?,
        countryFlag: map['countryFlag'] as String?,
        totalPoints: (map['totalPoints'] as num?)?.toInt() ?? 0,
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
    'countryName': countryName,
    'countryCode': countryCode,
    'countryFlag': countryFlag,
    'totalPoints': totalPoints,
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
        other.totalLevels == totalLevels &&
        other.countryName == countryName &&
        other.countryCode == countryCode &&
        other.countryFlag == countryFlag &&
        other.totalPoints == totalPoints;
  }

  @override
  int get hashCode => Object.hash(
    rank,
    userId,
    username,
    completedLevels,
    totalLevels,
    countryName,
    countryCode,
    countryFlag,
    totalPoints,
  );

  @override
  String toString() =>
      'IndividualRankingModel(#$rank $username, '
      '$completedLevels/$totalLevels, $totalPoints pts, $countryCode)';
}

class MyIndividualRank {
  const MyIndividualRank({
    required this.rank,
    required this.completedLevels,
    required this.totalLevels,
    this.totalPoints = 0,
  });

  final int rank;
  final int completedLevels;
  final int totalLevels;

  /// See [IndividualRankingModel.totalPoints] — zero until the endpoint sends
  /// it.
  final int totalPoints;

  double get progress {
    if (totalLevels <= 0) return 0;
    return (completedLevels / totalLevels).clamp(0, 1);
  }

  factory MyIndividualRank.fromMap(Map<String, dynamic> map) =>
      MyIndividualRank(
        rank: (map['rank'] as num?)?.toInt() ?? 0,
        completedLevels: (map['completedLevels'] as num?)?.toInt() ?? 0,
        totalLevels: (map['totalLevels'] as num?)?.toInt() ?? 0,
        totalPoints: (map['totalPoints'] as num?)?.toInt() ?? 0,
      );

  Map<String, dynamic> toMap() => {
    'rank': rank,
    'completedLevels': completedLevels,
    'totalLevels': totalLevels,
    'totalPoints': totalPoints,
  };

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MyIndividualRank &&
        other.rank == rank &&
        other.completedLevels == completedLevels &&
        other.totalLevels == totalLevels &&
        other.totalPoints == totalPoints;
  }

  @override
  int get hashCode =>
      Object.hash(rank, completedLevels, totalLevels, totalPoints);
}
