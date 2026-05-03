import 'dart:convert';

import 'question_model.dart';

class QuizQuestionsResponse {
  const QuizQuestionsResponse({
    required this.levelId,
    required this.title,
    required this.passingGrade,
    required this.questions,
  });

  final int levelId;
  final String title;
  final int passingGrade;
  final List<QuestionModel> questions;

  factory QuizQuestionsResponse.fromMap(Map<String, dynamic> map) =>
      QuizQuestionsResponse(
        levelId: (map['levelId'] as num?)?.toInt() ?? 0,
        title: (map['title'] ?? '') as String,
        passingGrade: (map['passingGrade'] as num?)?.toInt() ?? 0,
        questions: (map['questions'] as List<dynamic>? ?? const [])
            .map((e) => QuestionModel.fromMap(e as Map<String, dynamic>))
            .toList(),
      );

  factory QuizQuestionsResponse.fromJson(String source) =>
      QuizQuestionsResponse.fromMap(
        json.decode(source) as Map<String, dynamic>,
      );

  Map<String, dynamic> toMap() => {
        'levelId': levelId,
        'title': title,
        'passingGrade': passingGrade,
        'questions': questions.map((q) => q.toMap()).toList(),
      };

  String toJson() => json.encode(toMap());

  QuizQuestionsResponse copyWith({
    int? levelId,
    String? title,
    int? passingGrade,
    List<QuestionModel>? questions,
  }) =>
      QuizQuestionsResponse(
        levelId: levelId ?? this.levelId,
        title: title ?? this.title,
        passingGrade: passingGrade ?? this.passingGrade,
        questions: questions ?? this.questions,
      );

  @override
  String toString() =>
      'QuizQuestionsResponse(levelId: $levelId, title: $title, '
      'passingGrade: $passingGrade, questions: ${questions.length})';
}
