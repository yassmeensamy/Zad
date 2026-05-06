import 'dart:convert';

class QuizAnswerSubmission {
  const QuizAnswerSubmission({
    required this.questionId,
    required this.isCorrect,
  });

  final int questionId;
  final bool isCorrect;

  Map<String, dynamic> toMap() => {
        'questionId': questionId,
        'isCorrect': isCorrect,
      };
}

class QuizSubmissionRequest {
  const QuizSubmissionRequest({
    required this.pointsEarned,
    required this.answers,
  });

  final int pointsEarned;
  final List<QuizAnswerSubmission> answers;

  Map<String, dynamic> toMap() => {
        'pointsEarned': pointsEarned,
        'answers': answers.map((a) => a.toMap()).toList(),
      };

  String toJson() => json.encode(toMap());
}
