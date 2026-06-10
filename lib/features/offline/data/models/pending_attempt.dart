import 'pending_answer_row.dart';

/// One finished, offline-played level attempt grouped by `attempt_id`. During
/// sync each attempt becomes one `QuizLevelSubmission` inside the batched
/// `POST /api/quiz/sync` payload.
class PendingAttempt {
  const PendingAttempt({
    required this.attemptId,
    required this.levelId,
    required this.pointsEarned,
    required this.rows,
  });

  final String attemptId;
  final int levelId;
  final int pointsEarned;
  final List<PendingAnswerRow> rows;
}
