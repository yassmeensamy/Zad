import 'dart:convert';

class QuizSubmissionResponse {
  const QuizSubmissionResponse({
    required this.levelId,
    required this.userId,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.passed,
    required this.nextLevelUnlocked,
    required this.pointsEarned,
    required this.totalPoints,
    this.nextLevelId,
  });

  final int levelId;
  final String userId;
  final int totalQuestions;
  final int correctAnswers;
  final bool passed;
  final int? nextLevelId;
  final bool nextLevelUnlocked;
  final int pointsEarned;
  final int totalPoints;

  factory QuizSubmissionResponse.fromMap(Map<String, dynamic> map) =>
      QuizSubmissionResponse(
        levelId: (map['levelId'] as num?)?.toInt() ?? 0,
        userId: (map['userId'] ?? '') as String,
        totalQuestions: (map['totalQuestions'] as num?)?.toInt() ?? 0,
        correctAnswers: (map['correctAnswers'] as num?)?.toInt() ?? 0,
        passed: (map['passed'] as bool?) ?? false,
        nextLevelId: (map['nextLevelId'] as num?)?.toInt(),
        nextLevelUnlocked: (map['nextLevelUnlocked'] as bool?) ?? false,
        pointsEarned: (map['pointsEarned'] as num?)?.toInt() ?? 0,
        totalPoints: (map['totalPoints'] as num?)?.toInt() ?? 0,
      );

  factory QuizSubmissionResponse.fromJson(String source) =>
      QuizSubmissionResponse.fromMap(
        json.decode(source) as Map<String, dynamic>,
      );

  Map<String, dynamic> toMap() => {
        'levelId': levelId,
        'userId': userId,
        'totalQuestions': totalQuestions,
        'correctAnswers': correctAnswers,
        'passed': passed,
        if (nextLevelId != null) 'nextLevelId': nextLevelId,
        'nextLevelUnlocked': nextLevelUnlocked,
        'pointsEarned': pointsEarned,
        'totalPoints': totalPoints,
      };

  String toJson() => json.encode(toMap());

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is QuizSubmissionResponse &&
        other.levelId == levelId &&
        other.userId == userId &&
        other.totalQuestions == totalQuestions &&
        other.correctAnswers == correctAnswers &&
        other.passed == passed &&
        other.nextLevelId == nextLevelId &&
        other.nextLevelUnlocked == nextLevelUnlocked &&
        other.pointsEarned == pointsEarned &&
        other.totalPoints == totalPoints;
  }

  @override
  int get hashCode => Object.hash(
        levelId,
        userId,
        totalQuestions,
        correctAnswers,
        passed,
        nextLevelId,
        nextLevelUnlocked,
        pointsEarned,
        totalPoints,
      );

  @override
  String toString() =>
      'QuizSubmissionResponse(levelId: $levelId, passed: $passed, '
      'correctAnswers: $correctAnswers/$totalQuestions, '
      'pointsEarned: $pointsEarned, totalPoints: $totalPoints)';
}
