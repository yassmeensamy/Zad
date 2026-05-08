import 'dart:convert';

class StreakModel {
  const StreakModel({
    required this.streakDays,
    required this.weekProgress,
    required this.todayIndex,
    required this.personalBest,
    required this.nextMilestone,
  });

  factory StreakModel.fromMap(Map<String, dynamic> map) => StreakModel(
    streakDays: map['streakDays'] as int,
    weekProgress: (map['weekProgress'] as List<dynamic>).cast<bool>(),
    todayIndex: map['todayIndex'] as int,
    personalBest: map['personalBest'] as int,
    nextMilestone: map['nextMilestone'] as int,
  );

  factory StreakModel.fromJson(String source) =>
      StreakModel.fromMap(json.decode(source) as Map<String, dynamic>);

  /// Total consecutive days completed.
  final int streakDays;

  /// 7 booleans, Mon → Sun, indicating completed days this week.
  final List<bool> weekProgress;

  /// Index in [weekProgress] for today (0..6).
  final int todayIndex;

  /// Personal best streak — preserved for future surface area.
  final int personalBest;

  /// Next streak milestone the user is aiming for (e.g. 14 = two weeks).
  final int nextMilestone;

  StreakModel copyWith({
    int? streakDays,
    List<bool>? weekProgress,
    int? todayIndex,
    int? personalBest,
    int? nextMilestone,
  }) => StreakModel(
    streakDays: streakDays ?? this.streakDays,
    weekProgress: weekProgress ?? this.weekProgress,
    todayIndex: todayIndex ?? this.todayIndex,
    personalBest: personalBest ?? this.personalBest,
    nextMilestone: nextMilestone ?? this.nextMilestone,
  );

  Map<String, dynamic> toMap() => {
    'streakDays': streakDays,
    'weekProgress': weekProgress,
    'todayIndex': todayIndex,
    'personalBest': personalBest,
    'nextMilestone': nextMilestone,
  };

  String toJson() => json.encode(toMap());

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! StreakModel) return false;
    if (other.weekProgress.length != weekProgress.length) return false;
    for (var i = 0; i < weekProgress.length; i++) {
      if (other.weekProgress[i] != weekProgress[i]) return false;
    }
    return other.streakDays == streakDays &&
        other.todayIndex == todayIndex &&
        other.personalBest == personalBest &&
        other.nextMilestone == nextMilestone;
  }

  @override
  int get hashCode => Object.hash(
    streakDays,
    Object.hashAll(weekProgress),
    todayIndex,
    personalBest,
    nextMilestone,
  );
}
