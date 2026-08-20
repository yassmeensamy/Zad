import 'dart:convert';

import 'choice_model.dart';

class QuestionModel {
  const QuestionModel({
    required this.id,
    required this.text,
    required this.choices,
    required this.correctIndex,
    this.isAnsweredCorrectly = 0,
    this.isAnsweredBefore10s = false,
    this.isDrafted = false,
    this.explanation,
    this.source,
    this.missingLocales = const [],
  });

  final int id;
  final String text;
  final List<ChoiceModel> choices;
  final int correctIndex;
  /// Where this question stands for the current user:
  ///
  /// * `1` — cleared, answered correctly.
  /// * `0` — never answered.
  /// * `-n` — answered wrong `n` times and still unresolved, so `-1` is one
  ///   wrong attempt, `-2` is two, and so on.
  ///
  /// The sign carries the meaning and the magnitude carries the attempt count,
  /// so the value is stored as sent rather than flattened to a flag.
  final int isAnsweredCorrectly;
  final bool isAnsweredBefore10s;
  final bool isDrafted;
  final String? explanation;
  final String? source;
  final List<String> missingLocales;

  bool isCorrect(int choiceIndex) => choiceIndex == correctIndex;

  /// Answered correctly already, so a resumed level doesn't serve it again.
  /// A question sitting on wrong attempts is not cleared and comes back.
  bool get isCleared => isAnsweredCorrectly > 0;

  /// How many times this question has already been answered wrong: `0` for a
  /// cleared or untouched question, `n` for a value of `-n`.
  int get wrongAttempts =>
      isAnsweredCorrectly < 0 ? -isAnsweredCorrectly : 0;

  bool get hasFeedback =>
      (explanation != null && explanation!.isNotEmpty) ||
      (source != null && source!.isNotEmpty);

  factory QuestionModel.fromMap(Map<String, dynamic> map) => QuestionModel(
        id: (map['id'] as num).toInt(),
        text: (map['text'] ?? '') as String,
        choices: (map['choices'] as List<dynamic>? ?? const [])
            .map((e) => ChoiceModel.fromMap(e as Map<String, dynamic>))
            .toList(),
        correctIndex: (map['correctIndex'] as num).toInt(),
        isAnsweredCorrectly: _answerState(map['isAnsweredCorrectly']),
        isAnsweredBefore10s: _flag(map['isAnsweredBefore10s']),
        isDrafted: _flag(map['isDrafted']),
        explanation: map['explanation'] as String?,
        source: map['source'] as String?,
        missingLocales: [
          for (final e in map['missingLocales'] as List<dynamic>? ?? const [])
            '$e',
        ],
      );

  static bool _flag(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    return false;
  }

  static int _answerState(dynamic value) {
    if (value is num) return value.toInt();
    // Questions cached for offline use were persisted through [toMap] while
    // this was a boolean, so old rows still decode.
    if (value is bool) return value ? 1 : 0;
    return 0;
  }

  factory QuestionModel.fromJson(String source) =>
      QuestionModel.fromMap(json.decode(source) as Map<String, dynamic>);

  Map<String, dynamic> toMap() => {
        'id': id,
        'text': text,
        'choices': choices.map((c) => c.toMap()).toList(),
        'correctIndex': correctIndex,
        'isAnsweredCorrectly': isAnsweredCorrectly,
        'isAnsweredBefore10s': isAnsweredBefore10s,
        'isDrafted': isDrafted,
        if (explanation != null) 'explanation': explanation,
        if (source != null) 'source': source,
        if (missingLocales.isNotEmpty) 'missingLocales': missingLocales,
      };

  String toJson() => json.encode(toMap());

  QuestionModel copyWith({
    int? id,
    String? text,
    List<ChoiceModel>? choices,
    int? correctIndex,
    int? isAnsweredCorrectly,
    bool? isAnsweredBefore10s,
    bool? isDrafted,
    String? explanation,
    String? source,
    List<String>? missingLocales,
  }) =>
      QuestionModel(
        id: id ?? this.id,
        text: text ?? this.text,
        choices: choices ?? this.choices,
        correctIndex: correctIndex ?? this.correctIndex,
        isAnsweredCorrectly: isAnsweredCorrectly ?? this.isAnsweredCorrectly,
        isAnsweredBefore10s: isAnsweredBefore10s ?? this.isAnsweredBefore10s,
        isDrafted: isDrafted ?? this.isDrafted,
        explanation: explanation ?? this.explanation,
        source: source ?? this.source,
        missingLocales: missingLocales ?? this.missingLocales,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is QuestionModel &&
        other.id == id &&
        other.text == text &&
        other.correctIndex == correctIndex &&
        other.isAnsweredCorrectly == isAnsweredCorrectly &&
        other.isAnsweredBefore10s == isAnsweredBefore10s &&
        other.isDrafted == isDrafted &&
        other.explanation == explanation &&
        other.source == source &&
        _listEq(other.choices, choices) &&
        _listEq(other.missingLocales, missingLocales);
  }

  static bool _listEq<T>(List<T> a, List<T> b) {
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
        isAnsweredBefore10s,
        isDrafted,
        explanation,
        source,
        Object.hashAll(missingLocales),
      );

  @override
  String toString() =>
      'QuestionModel(id: $id, choices: ${choices.length}, correctIndex: $correctIndex)';
}
