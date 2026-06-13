/// One offline-saved draft row read back from the pending queue. [localId] is
/// the SQLite autoincrement primary key (used to mark the row synced); it is
/// unrelated to the server-assigned draft id, which only exists after sync.
class PendingDraft {
  const PendingDraft({
    required this.localId,
    required this.questionId,
    this.note,
    this.createdAt,
  });

  final int localId;
  final int questionId;
  final String? note;

  /// When the row was queued, used to order and timestamp offline drafts in the
  /// UI. Null only for legacy rows written before the column was read back.
  final DateTime? createdAt;

  factory PendingDraft.fromMap(Map<String, Object?> map) => PendingDraft(
        localId: (map['id'] as num).toInt(),
        questionId: (map['question_id'] as num).toInt(),
        note: map['note'] as String?,
        createdAt: map['created_at'] == null
            ? null
            : DateTime.fromMillisecondsSinceEpoch(
                (map['created_at'] as num).toInt(),
              ),
      );
}
