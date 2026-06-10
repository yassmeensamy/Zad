import '../../../categories/data/models/category_model.dart';
import '../../../levels/data/models/level_model.dart';
import '../../../quiz/data/models/choice_model.dart';
import '../../../quiz/data/models/question_model.dart';
import '../../../quiz/data/models/quiz_questions_response.dart';

class CategoryDownloadBundle {
  const CategoryDownloadBundle({
    required this.category,
    required this.levels,
    required this.questionsByLevel,
  });

  final CategoryModel category;
  final List<LevelModel> levels;
  final Map<int, QuizQuestionsResponse> questionsByLevel;

  factory CategoryDownloadBundle.fromMap(
    Map<String, dynamic> map, {
    required String languageCode,
  }) {
    final categoryId = (map['id'] as num).toInt();
    final categoryTr = _pick(map['translations'], languageCode);

    final levelMaps =
        (map['levels'] as List<dynamic>? ?? const []).cast<Map<String, dynamic>>();

    final levels = <LevelModel>[];
    final questionsByLevel = <int, QuizQuestionsResponse>{};

    for (final levelMap in levelMaps) {
      final levelId = (levelMap['id'] as num).toInt();
      final levelTr = _pick(levelMap['translations'], languageCode);
      final passingGrade = (levelMap['passingGrade'] as num?)?.toInt() ?? 0;
      final title = (levelTr['title'] ?? '') as String;

      final questionMaps = (levelMap['questions'] as List<dynamic>? ?? const [])
          .cast<Map<String, dynamic>>();

      final questions = questionMaps
          .map((q) => _question(q, languageCode))
          .toList();

      levels.add(
        LevelModel(
          id: levelId,
          title: title,
          order: (levelMap['orderIndex'] as num?)?.toInt() ?? 0,
          questionCount: questions.length,
          completedQuestions: 0,
          passingGrade: passingGrade,
          status: (levelMap['isLocked'] as bool? ?? false)
              ? LevelStatus.locked
              : LevelStatus.unlocked,
        ),
      );

      questionsByLevel[levelId] = QuizQuestionsResponse(
        levelId: levelId,
        title: title,
        passingGrade: passingGrade,
        questions: questions,
      );
    }

    return CategoryDownloadBundle(
      category: CategoryModel(
        id: categoryId,
        name: (categoryTr['name'] ?? '') as String,
        description: (categoryTr['description'] ?? '') as String,
        iconUrl: (map['iconUrl'] ?? '') as String,
        levelCount: levels.length,
        completedLevels: 0,
        orderIndex: (map['orderIndex'] as num?)?.toInt() ?? 0,
      ),
      levels: levels,
      questionsByLevel: questionsByLevel,
    );
  }

  static QuestionModel _question(Map<String, dynamic> map, String languageCode) {
    final tr = _pick(map['translations'], languageCode);
    final choices = <ChoiceModel>[];
    for (var i = 0; i < 4; i++) {
      final text = tr['choice$i'] as String?;
      if (text == null) continue;
      choices.add(ChoiceModel(index: i, text: text));
    }
    return QuestionModel(
      id: (map['id'] as num).toInt(),
      text: (tr['questionText'] ?? '') as String,
      choices: choices,
      correctIndex: (map['correctIndex'] as num?)?.toInt() ?? 0,
      explanation: tr['explanation'] as String?,
      source: tr['source'] as String?,
    );
  }

  static Map<String, dynamic> _pick(dynamic translations, String languageCode) {
    if (translations is! Map) return const {};
    final byLang = translations.cast<String, dynamic>();
    final chosen = byLang[languageCode] ??
        byLang['ar'] ??
        byLang['en'] ??
        (byLang.isNotEmpty ? byLang.values.first : null);
    return chosen is Map ? chosen.cast<String, dynamic>() : const {};
  }
}
