import 'package:sqflite/sqflite.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/services/current_user_provider.dart';
import '../../../categories/data/models/category_model.dart';
import '../../../levels/data/models/level_model.dart';
import '../../../quiz/data/models/question_model.dart';
import '../../../quiz/data/models/quiz_questions_response.dart';

/// Reads and writes the downloaded quiz content (categories, levels, questions)
/// that backs offline usage. All rows are namespaced by the current user id.
abstract class OfflineContentDao {
  /// Persists a whole category bundle atomically, replacing any prior copy of
  /// the same category (re-download safe).
  Future<void> saveCategoryBundle({
    required CategoryModel category,
    required List<LevelModel> levels,
    required Map<int, QuizQuestionsResponse> questionsByLevel,
  });

  Future<List<CategoryModel>> getDownloadedCategories();
  Future<List<LevelModel>> getDownloadedLevels(int categoryId);
  Future<QuizQuestionsResponse?> getDownloadedQuestions(int levelId);
  Future<Set<int>> getDownloadedCategoryIds();
  Future<bool> isCategoryDownloaded(int categoryId);

  /// Removes a downloaded category and its levels/questions/headers.
  Future<void> deleteCategory(int categoryId);

  /// Wipes all downloaded content for the current user (logout hygiene).
  Future<void> clearAllForUser();
}

class OfflineContentDaoImpl implements OfflineContentDao {
  OfflineContentDaoImpl({
    required AppDatabase database,
    required CurrentUserProvider userProvider,
  }) : _database = database,
       _userProvider = userProvider;

  final AppDatabase _database;
  final CurrentUserProvider _userProvider;

  @override
  Future<void> saveCategoryBundle({
    required CategoryModel category,
    required List<LevelModel> levels,
    required Map<int, QuizQuestionsResponse> questionsByLevel,
  }) async {
    final db = await _database.database;
    final userId = await _userProvider.userId();

    await db.transaction((txn) async {
      // Clear any prior copy so a re-download never leaves orphans.
      await _deleteCategoryWithin(txn, userId, category.id);

      await txn.insert(AppDatabase.tableCategories, {
        'user_id': userId,
        'category_id': category.id,
        'order_index': category.orderIndex,
        'downloaded_at': DateTime.now().millisecondsSinceEpoch,
        'payload': category.toJson(),
      }, conflictAlgorithm: ConflictAlgorithm.replace);

      for (final level in levels) {
        await txn.insert(AppDatabase.tableLevels, {
          'user_id': userId,
          'level_id': level.id,
          'category_id': category.id,
          'order_index': level.order,
          'payload': level.toJson(),
        }, conflictAlgorithm: ConflictAlgorithm.replace);

        final response = questionsByLevel[level.id];
        if (response == null) continue;

        for (var i = 0; i < response.questions.length; i++) {
          final question = response.questions[i];
          await txn.insert(AppDatabase.tableQuestions, {
            'user_id': userId,
            'question_id': question.id,
            'level_id': level.id,
            'order_index': i,
            'payload': question.toJson(),
          }, conflictAlgorithm: ConflictAlgorithm.replace);
        }
      }
    });
  }

  @override
  Future<List<CategoryModel>> getDownloadedCategories() async {
    final db = await _database.database;
    final userId = await _userProvider.userId();
    final rows = await db.query(
      AppDatabase.tableCategories,
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'order_index ASC',
    );
    return rows
        .map((r) => CategoryModel.fromJson(r['payload'] as String))
        .toList();
  }

  @override
  Future<List<LevelModel>> getDownloadedLevels(int categoryId) async {
    final db = await _database.database;
    final userId = await _userProvider.userId();
    final rows = await db.query(
      AppDatabase.tableLevels,
      where: 'user_id = ? AND category_id = ?',
      whereArgs: [userId, categoryId],
      orderBy: 'order_index ASC',
    );
    return rows.map((r) => LevelModel.fromJson(r['payload'] as String)).toList();
  }

  @override
  Future<QuizQuestionsResponse?> getDownloadedQuestions(int levelId) async {
    final db = await _database.database;
    final userId = await _userProvider.userId();

    final questionRows = await db.query(
      AppDatabase.tableQuestions,
      where: 'user_id = ? AND level_id = ?',
      whereArgs: [userId, levelId],
      orderBy: 'order_index ASC',
    );
    if (questionRows.isEmpty) return null;

    // Title and passing grade live in the level's own payload — no separate
    // header table needed.
    final levelRows = await db.query(
      AppDatabase.tableLevels,
      columns: ['payload'],
      where: 'user_id = ? AND level_id = ?',
      whereArgs: [userId, levelId],
      limit: 1,
    );
    final level = levelRows.isNotEmpty
        ? LevelModel.fromJson(levelRows.first['payload'] as String)
        : null;

    return QuizQuestionsResponse(
      levelId: levelId,
      title: level?.title ?? '',
      passingGrade: level?.passingGrade ?? 0,
      questions: questionRows
          .map((r) => QuestionModel.fromJson(r['payload'] as String))
          .toList(),
    );
  }

  @override
  Future<Set<int>> getDownloadedCategoryIds() async {
    final db = await _database.database;
    final userId = await _userProvider.userId();
    final rows = await db.query(
      AppDatabase.tableCategories,
      columns: ['category_id'],
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    return rows.map((r) => (r['category_id'] as num).toInt()).toSet();
  }

  @override
  Future<bool> isCategoryDownloaded(int categoryId) async {
    final db = await _database.database;
    final userId = await _userProvider.userId();
    final rows = await db.query(
      AppDatabase.tableCategories,
      columns: ['category_id'],
      where: 'user_id = ? AND category_id = ?',
      whereArgs: [userId, categoryId],
      limit: 1,
    );
    return rows.isNotEmpty;
  }

  @override
  Future<void> deleteCategory(int categoryId) async {
    final db = await _database.database;
    final userId = await _userProvider.userId();
    await db.transaction(
      (txn) => _deleteCategoryWithin(txn, userId, categoryId),
    );
  }

  @override
  Future<void> clearAllForUser() async {
    final db = await _database.database;
    final userId = await _userProvider.userId();
    final batch = db.batch();
    for (final table in const [
      AppDatabase.tableCategories,
      AppDatabase.tableLevels,
      AppDatabase.tableQuestions,
    ]) {
      batch.delete(table, where: 'user_id = ?', whereArgs: [userId]);
    }
    await batch.commit(noResult: true);
  }

  Future<void> _deleteCategoryWithin(
    Transaction txn,
    String userId,
    int categoryId,
  ) async {
    final levelRows = await txn.query(
      AppDatabase.tableLevels,
      columns: ['level_id'],
      where: 'user_id = ? AND category_id = ?',
      whereArgs: [userId, categoryId],
    );
    final levelIds = levelRows.map((r) => (r['level_id'] as num).toInt());

    for (final levelId in levelIds) {
      await txn.delete(
        AppDatabase.tableQuestions,
        where: 'user_id = ? AND level_id = ?',
        whereArgs: [userId, levelId],
      );
    }
    await txn.delete(
      AppDatabase.tableLevels,
      where: 'user_id = ? AND category_id = ?',
      whereArgs: [userId, categoryId],
    );
    await txn.delete(
      AppDatabase.tableCategories,
      where: 'user_id = ? AND category_id = ?',
      whereArgs: [userId, categoryId],
    );
  }
}
