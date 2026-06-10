import 'package:uuid/uuid.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/services/current_user_provider.dart';
import '../models/pending_answer_input.dart';
import '../models/pending_answer_row.dart';
import '../models/pending_attempt.dart';

/// Reads and writes the offline answer queue. Each finished offline level
/// attempt is stored as a group of rows sharing one `attempt_id`; sync replays
/// each group as a single per-level batch submission.
abstract class PendingAnswersDao {
  /// Persists one finished offline attempt (all answers share a new attempt id).
  Future<void> insertAttempt({
    required int levelId,
    required int pointsEarned,
    required List<PendingAnswerInput> answers,
  });

  Future<List<PendingAttempt>> getUnsyncedGroupedByAttempt();
  Future<void> markAttemptSynced(String attemptId);
  Future<void> deleteSyncedOlderThan(Duration age);
  Future<void> clearAllForUser();
}

class PendingAnswersDaoImpl implements PendingAnswersDao {
  PendingAnswersDaoImpl({
    required AppDatabase database,
    required CurrentUserProvider userProvider,
    Uuid uuid = const Uuid(),
  }) : _database = database,
       _userProvider = userProvider,
       _uuid = uuid;

  final AppDatabase _database;
  final CurrentUserProvider _userProvider;
  final Uuid _uuid;

  @override
  Future<void> insertAttempt({
    required int levelId,
    required int pointsEarned,
    required List<PendingAnswerInput> answers,
  }) async {
    final db = await _database.database;
    final userId = await _userProvider.userId();
    final attemptId = _uuid.v4();
    final createdAt = DateTime.now().millisecondsSinceEpoch;

    await db.transaction((txn) async {
      for (final answer in answers) {
        await txn.insert(AppDatabase.tablePendingAnswers, {
          'user_id': userId,
          'level_id': levelId,
          'question_id': answer.questionId,
          'selected_answer': answer.selectedAnswer,
          'is_correct': answer.isCorrect ? 1 : 0,
          'points_earned': pointsEarned,
          'attempt_id': attemptId,
          'created_at': createdAt,
          'synced': 0,
        });
      }
    });
  }

  @override
  Future<List<PendingAttempt>> getUnsyncedGroupedByAttempt() async {
    final db = await _database.database;
    final userId = await _userProvider.userId();
    final rows = await db.query(
      AppDatabase.tablePendingAnswers,
      where: 'user_id = ? AND synced = 0',
      whereArgs: [userId],
      orderBy: 'created_at ASC, id ASC',
    );

    final byAttempt = <String, List<Map<String, Object?>>>{};
    for (final row in rows) {
      (byAttempt[row['attempt_id'] as String] ??= []).add(row);
    }

    return byAttempt.entries.map((entry) {
      final first = entry.value.first;
      return PendingAttempt(
        attemptId: entry.key,
        levelId: (first['level_id'] as num).toInt(),
        pointsEarned: (first['points_earned'] as num).toInt(),
        rows: entry.value.map(PendingAnswerRow.fromMap).toList(),
      );
    }).toList();
  }

  @override
  Future<void> markAttemptSynced(String attemptId) async {
    final db = await _database.database;
    final userId = await _userProvider.userId();
    await db.update(
      AppDatabase.tablePendingAnswers,
      {'synced': 1},
      where: 'user_id = ? AND attempt_id = ?',
      whereArgs: [userId, attemptId],
    );
  }

  @override
  Future<void> deleteSyncedOlderThan(Duration age) async {
    final db = await _database.database;
    final userId = await _userProvider.userId();
    final cutoff = DateTime.now().subtract(age).millisecondsSinceEpoch;
    await db.delete(
      AppDatabase.tablePendingAnswers,
      where: 'user_id = ? AND synced = 1 AND created_at < ?',
      whereArgs: [userId, cutoff],
    );
  }

  @override
  Future<void> clearAllForUser() async {
    final db = await _database.database;
    final userId = await _userProvider.userId();
    await db.delete(
      AppDatabase.tablePendingAnswers,
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }
}
