import 'dart:convert';

import 'quiz_submission_request.dart';

/// One finished level attempt inside a batch [QuizSyncRequest]. Unlike the
/// per-level submit endpoint, the level id travels in the body here because the
/// whole queue is flushed in a single call.
class QuizLevelSubmission {
  const QuizLevelSubmission({
    required this.levelId,
    required this.pointsEarned,
    required this.answers,
  });

  final int levelId;
  final int pointsEarned;
  final List<QuizAnswerSubmission> answers;

  Map<String, dynamic> toMap() => {
        'levelId': levelId,
        'pointsEarned': pointsEarned,
        'answers': answers.map((a) => a.toMap()).toList(),
      };
}

/// Request body for `POST /api/quiz/sync` — replays every offline-played level
/// attempt in one batch when connectivity is regained.
class QuizSyncRequest {
  const QuizSyncRequest({required this.submissions});

  final List<QuizLevelSubmission> submissions;

  Map<String, dynamic> toMap() => {
        'submissions': submissions.map((s) => s.toMap()).toList(),
      };

  String toJson() => json.encode(toMap());
}
