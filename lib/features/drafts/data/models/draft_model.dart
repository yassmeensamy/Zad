import 'dart:convert';

import '../../../quiz/data/models/question_model.dart';

class DraftModel {
  const DraftModel({
    required this.id,
    required this.question,
    this.note,
    this.createdAt,
    this.updatedAt,
  });

  final int id;
  final QuestionModel question;
  final String? note;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory DraftModel.fromMap(Map<String, dynamic> map) => DraftModel(
        id: (map['id'] as num).toInt(),
        question: QuestionModel.fromMap(
          map['question'] as Map<String, dynamic>,
        ),
        note: map['note'] as String?,
        createdAt: _parseDate(map['createdAt']),
        updatedAt: _parseDate(map['updatedAt']),
      );

  factory DraftModel.fromJson(String source) =>
      DraftModel.fromMap(json.decode(source) as Map<String, dynamic>);

  Map<String, dynamic> toMap() => {
        'id': id,
        'question': question.toMap(),
        if (note != null) 'note': note,
        if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
        if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
      };

  String toJson() => json.encode(toMap());

  DraftModel copyWith({
    int? id,
    QuestionModel? question,
    String? note,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      DraftModel(
        id: id ?? this.id,
        question: question ?? this.question,
        note: note ?? this.note,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  static DateTime? _parseDate(dynamic value) {
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value);
    }
    return null;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DraftModel &&
        other.id == id &&
        other.question == question &&
        other.note == note &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode => Object.hash(id, question, note, createdAt, updatedAt);

  @override
  String toString() => 'DraftModel(id: $id, questionId: ${question.id})';
}
