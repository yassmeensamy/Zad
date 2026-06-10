import 'dart:convert';

/// Per-level outcome inside a [QuizSyncResponse]. `skippedLocked` flags an
/// attempt the server ignored because the level was not unlocked for the user.
class QuizSyncLevelResult {
  const QuizSyncLevelResult({
    required this.levelId,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.passed,
    required this.nextLevelUnlocked,
    required this.pointsEarned,
    required this.skippedLocked,
    required this.shouldPromptSignup,
    this.nextLevelId,
  });

  final int levelId;
  final int totalQuestions;
  final int correctAnswers;
  final bool passed;
  final int? nextLevelId;
  final bool nextLevelUnlocked;
  final int pointsEarned;
  final bool skippedLocked;
  final bool shouldPromptSignup;

  factory QuizSyncLevelResult.fromMap(Map<String, dynamic> map) =>
      QuizSyncLevelResult(
        levelId: (map['levelId'] as num?)?.toInt() ?? 0,
        totalQuestions: (map['totalQuestions'] as num?)?.toInt() ?? 0,
        correctAnswers: (map['correctAnswers'] as num?)?.toInt() ?? 0,
        passed: (map['passed'] as bool?) ?? false,
        nextLevelId: (map['nextLevelId'] as num?)?.toInt(),
        nextLevelUnlocked: (map['nextLevelUnlocked'] as bool?) ?? false,
        pointsEarned: (map['pointsEarned'] as num?)?.toInt() ?? 0,
        skippedLocked: (map['skippedLocked'] as bool?) ?? false,
        shouldPromptSignup: (map['shouldPromptSignup'] as bool?) ?? false,
      );
}

/// Response body for `POST /api/quiz/sync`.
class QuizSyncResponse {
  const QuizSyncResponse({
    required this.userId,
    required this.totalPointsEarned,
    required this.totalPoints,
    required this.results,
  });

  final String userId;
  final int totalPointsEarned;
  final int totalPoints;
  final List<QuizSyncLevelResult> results;

  factory QuizSyncResponse.fromMap(Map<String, dynamic> map) => QuizSyncResponse(
        userId: (map['userId'] ?? '') as String,
        totalPointsEarned: (map['totalPointsEarned'] as num?)?.toInt() ?? 0,
        totalPoints: (map['totalPoints'] as num?)?.toInt() ?? 0,
        results: ((map['results'] as List<dynamic>?) ?? const [])
            .map((e) => QuizSyncLevelResult.fromMap(e as Map<String, dynamic>))
            .toList(),
      );

  factory QuizSyncResponse.fromJson(String source) =>
      QuizSyncResponse.fromMap(json.decode(source) as Map<String, dynamic>);
}
