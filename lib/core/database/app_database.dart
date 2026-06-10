import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../utils/logger.dart';

/// Opens and owns the on-device SQLite database used for offline-first content
/// (downloaded categories/levels/questions) and the pending-answer sync queue.
///
/// Registered as a lazy singleton and warmed once at startup so the first
/// offline read never races the open. The local database is the source of
/// truth for downloaded content while the device is offline.
class AppDatabase {
  AppDatabase();

  static const String _dbName = 'zaad_offline.db';
  static const int _version = 1;

  Database? _db;

  Future<Database> get database async => _db ??= await _open();

  Future<Database> _open() async {
    final path = p.join(await getDatabasesPath(), _dbName);
    logger.database('Opening offline database at $path');
    return openDatabase(
      path,
      version: _version,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    final batch = db.batch();
    batch.execute(_createDownloadedCategories);
    batch.execute(_createDownloadedLevels);
    batch.execute(_createDownloadedLevelsIndex);
    batch.execute(_createDownloadedQuestions);
    batch.execute(_createDownloadedQuestionsIndex);
    batch.execute(_createPendingAnswers);
    batch.execute(_createPendingAnswersIndex);
    await batch.commit(noResult: true);
  }

  // Reserved for future additive migrations. v1 has none.
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {}

  Future<void> close() async {
    await _db?.close();
    _db = null;
  }

  // ---------------------------------------------------------------------------
  // Schema. Hybrid design: indexed identity/order columns we query on, plus a
  // `payload` TEXT column holding the model's own JSON (reuses the existing
  // fromMap/toMap round-trip — no duplicated mapping). Every content row is
  // namespaced by `user_id` so downloads never leak across accounts.
  // ---------------------------------------------------------------------------

  static const String tableCategories = 'downloaded_categories';
  static const String tableLevels = 'downloaded_levels';
  static const String tableQuestions = 'downloaded_questions';
  static const String tablePendingAnswers = 'pending_answers';

  static const String _createDownloadedCategories =
      '''
    CREATE TABLE $tableCategories (
      user_id TEXT NOT NULL,
      category_id INTEGER NOT NULL,
      order_index INTEGER NOT NULL DEFAULT 0,
      downloaded_at INTEGER NOT NULL,
      payload TEXT NOT NULL,
      PRIMARY KEY (user_id, category_id)
    )
  ''';

  static const String _createDownloadedLevels =
      '''
    CREATE TABLE $tableLevels (
      user_id TEXT NOT NULL,
      level_id INTEGER NOT NULL,
      category_id INTEGER NOT NULL,
      order_index INTEGER NOT NULL DEFAULT 0,
      payload TEXT NOT NULL,
      PRIMARY KEY (user_id, level_id)
    )
  ''';

  static const String _createDownloadedLevelsIndex =
      'CREATE INDEX idx_levels_category '
      'ON $tableLevels (user_id, category_id, order_index)';

  static const String _createDownloadedQuestions =
      '''
    CREATE TABLE $tableQuestions (
      user_id TEXT NOT NULL,
      question_id INTEGER NOT NULL,
      level_id INTEGER NOT NULL,
      order_index INTEGER NOT NULL DEFAULT 0,
      payload TEXT NOT NULL,
      PRIMARY KEY (user_id, question_id, level_id)
    )
  ''';

  static const String _createDownloadedQuestionsIndex =
      'CREATE INDEX idx_questions_level '
      'ON $tableQuestions (user_id, level_id, order_index)';

  static const String _createPendingAnswers =
      '''
    CREATE TABLE $tablePendingAnswers (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id TEXT NOT NULL,
      level_id INTEGER NOT NULL,
      question_id INTEGER NOT NULL,
      selected_answer INTEGER NOT NULL,
      is_correct INTEGER NOT NULL,
      points_earned INTEGER NOT NULL DEFAULT 0,
      attempt_id TEXT NOT NULL,
      created_at INTEGER NOT NULL,
      synced INTEGER NOT NULL DEFAULT 0
    )
  ''';

  static const String _createPendingAnswersIndex =
      'CREATE INDEX idx_pending_unsynced '
      'ON $tablePendingAnswers (user_id, synced, level_id, attempt_id)';
}
