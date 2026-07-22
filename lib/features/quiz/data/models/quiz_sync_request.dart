import 'dart:convert';

import 'quiz_submission_request.dart';

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

class QuizSyncRequest {
  const QuizSyncRequest({required this.submissions});

  final List<QuizLevelSubmission> submissions;

  Map<String, dynamic> toMap() => {
        'submissions': submissions.map((s) => s.toMap()).toList(),
      };

  String toJson() => json.encode(toMap());
}
