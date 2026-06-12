import '../../../../core/database/app_database.dart';
import '../../../../core/services/current_user_provider.dart';
import '../models/pending_draft.dart';

/// Reads and writes the offline drafts queue. Each row is one question the user
/// bookmarked while offline; sync replays the unsynced rows as a single
/// `POST /api/drafts/bulk` batch. Rows are namespaced by `user_id` so a draft
/// saved by one account never leaks into another on a shared device.
abstract class PendingDraftsDao {
  /// Queues one offline-marked draft. A repeat mark for the same question while
  /// still unsynced is collapsed (the latest note wins) so a toggle on/off/on
  /// never enqueues duplicates that the bulk endpoint would reject.
  Future<void> insertDraft({required int questionId, String? note});

  /// Removes a still-unsynced draft for [questionId] (offline toggle-off). No-op
  /// once the row has synced — that deletion must go through the remote API.
  Future<void> removeUnsyncedByQuestion(int questionId);

  Future<List<PendingDraft>> getUnsynced();
  Future<void> markSynced(int localId);
  Future<void> deleteSyncedOlderThan(Duration age);
  Future<void> clearAllForUser();
}

class PendingDraftsDaoImpl implements PendingDraftsDao {
  PendingDraftsDaoImpl({
    required AppDatabase database,
    required CurrentUserProvider userProvider,
  })  : _database = database,
        _userProvider = userProvider;

  final AppDatabase _database;
  final CurrentUserProvider _userProvider;

  @override
  Future<void> insertDraft({required int questionId, String? note}) async {
    final db = await _database.database;
    final userId = await _userProvider.userId();

    await db.transaction((txn) async {
      // Collapse a re-mark of the same still-pending question to one row.
      await txn.delete(
        AppDatabase.tablePendingDrafts,
        where: 'user_id = ? AND question_id = ? AND synced = 0',
        whereArgs: [userId, questionId],
      );
      await txn.insert(AppDatabase.tablePendingDrafts, {
        'user_id': userId,
        'question_id': questionId,
        'note': note,
        'created_at': DateTime.now().millisecondsSinceEpoch,
        'synced': 0,
      });
    });
  }

  @override
  Future<void> removeUnsyncedByQuestion(int questionId) async {
    final db = await _database.database;
    final userId = await _userProvider.userId();
    await db.delete(
      AppDatabase.tablePendingDrafts,
      where: 'user_id = ? AND question_id = ? AND synced = 0',
      whereArgs: [userId, questionId],
    );
  }

  @override
  Future<List<PendingDraft>> getUnsynced() async {
    final db = await _database.database;
    final userId = await _userProvider.userId();
    final rows = await db.query(
      AppDatabase.tablePendingDrafts,
      where: 'user_id = ? AND synced = 0',
      whereArgs: [userId],
      orderBy: 'created_at ASC, id ASC',
    );
    return rows.map(PendingDraft.fromMap).toList();
  }

  @override
  Future<void> markSynced(int localId) async {
    final db = await _database.database;
    final userId = await _userProvider.userId();
    await db.update(
      AppDatabase.tablePendingDrafts,
      {'synced': 1},
      where: 'user_id = ? AND id = ?',
      whereArgs: [userId, localId],
    );
  }

  @override
  Future<void> deleteSyncedOlderThan(Duration age) async {
    final db = await _database.database;
    final userId = await _userProvider.userId();
    final cutoff = DateTime.now().subtract(age).millisecondsSinceEpoch;
    await db.delete(
      AppDatabase.tablePendingDrafts,
      where: 'user_id = ? AND synced = 1 AND created_at < ?',
      whereArgs: [userId, cutoff],
    );
  }

  @override
  Future<void> clearAllForUser() async {
    final db = await _database.database;
    final userId = await _userProvider.userId();
    await db.delete(
      AppDatabase.tablePendingDrafts,
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }
}
