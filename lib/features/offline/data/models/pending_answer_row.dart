/// One persisted offline answer row, satisfying the requirement that each
/// stored answer carry `{questionId, selectedAnswer, timestamp, synced}`.
class PendingAnswerRow {
  const PendingAnswerRow({
    required this.questionId,
    required this.selectedAnswer,
    required this.isCorrect,
    this.id,
    this.createdAt,
  });

  final int? id;
  final int questionId;
  final int selectedAnswer;
  final bool isCorrect;
  final DateTime? createdAt;

  factory PendingAnswerRow.fromMap(Map<String, Object?> map) => PendingAnswerRow(
    id: (map['id'] as num?)?.toInt(),
    questionId: (map['question_id'] as num).toInt(),
    selectedAnswer: (map['selected_answer'] as num).toInt(),
    isCorrect: ((map['is_correct'] as num?)?.toInt() ?? 0) == 1,
    createdAt: map['created_at'] == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch((map['created_at'] as num).toInt()),
  );
}
