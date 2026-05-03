import 'dart:convert';

import 'choice_model.dart';

class QuestionModel {
  const QuestionModel({
    required this.id,
    required this.text,
    required this.choices,
    required this.correctIndex,
    this.isAnsweredCorrectly = false,
    this.explanation,
    this.source,
  });

  final int id;
  final String text;
  final List<ChoiceModel> choices;
  final int correctIndex;
  final bool isAnsweredCorrectly;
  final String? explanation;
  final String? source;

  bool isCorrect(int choiceIndex) => choiceIndex == correctIndex;

  factory QuestionModel.fromMap(Map<String, dynamic> map) => QuestionModel(
        id: (map['id'] as num).toInt(),
        text: (map['text'] ?? '') as String,
        choices: (map['choices'] as List<dynamic>? ?? const [])
            .map((e) => ChoiceModel.fromMap(e as Map<String, dynamic>))
            .toList(),
        correctIndex: (map['correctIndex'] as num).toInt(),
        isAnsweredCorrectly: (map['isAnsweredCorrectly'] as bool?) ?? false,
        explanation: map['explanation'] as String?,
        source: map['source'] as String?,
      );

  factory QuestionModel.fromJson(String source) =>
      QuestionModel.fromMap(json.decode(source) as Map<String, dynamic>);

  Map<String, dynamic> toMap() => {
        'id': id,
        'text': text,
        'choices': choices.map((c) => c.toMap()).toList(),
        'correctIndex': correctIndex,
        'isAnsweredCorrectly': isAnsweredCorrectly,
        if (explanation != null) 'explanation': explanation,
        if (source != null) 'source': source,
      };

  String toJson() => json.encode(toMap());

  QuestionModel copyWith({
    int? id,
    String? text,
    List<ChoiceModel>? choices,
    int? correctIndex,
    bool? isAnsweredCorrectly,
    String? explanation,
    String? source,
  }) =>
      QuestionModel(
        id: id ?? this.id,
        text: text ?? this.text,
        choices: choices ?? this.choices,
        correctIndex: correctIndex ?? this.correctIndex,
        isAnsweredCorrectly: isAnsweredCorrectly ?? this.isAnsweredCorrectly,
        explanation: explanation ?? this.explanation,
        source: source ?? this.source,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is QuestionModel &&
        other.id == id &&
        other.text == text &&
        other.correctIndex == correctIndex &&
        other.isAnsweredCorrectly == isAnsweredCorrectly &&
        other.explanation == explanation &&
        other.source == source &&
        _listEq(other.choices, choices);
  }

  static bool _listEq(List<ChoiceModel> a, List<ChoiceModel> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(
        id,
        text,
        Object.hashAll(choices),
        correctIndex,
        isAnsweredCorrectly,
        explanation,
        source,
      );

  @override
  String toString() =>
      'QuestionModel(id: $id, choices: ${choices.length}, correctIndex: $correctIndex)';
}
