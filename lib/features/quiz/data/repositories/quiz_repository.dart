import '../../../../core/api/network_failure.dart';
import '../../../../core/services/current_user_provider.dart';
import '../../../offline/data/local/offline_content_dao.dart';
import '../../../offline/data/local/pending_answers_dao.dart';
import '../../../offline/data/models/pending_answer_input.dart';
import '../models/quiz_questions_response.dart';
import '../models/quiz_submission_request.dart';
import '../models/quiz_submission_response.dart';
import '../remote/quiz_remote_data_source.dart';

abstract class QuizRepository {
  Future<QuizQuestionsResponse> getQuestions(int levelId);

  /// Submits a finished level attempt. [selectedAnswers] carries the user's
  /// chosen choice per question so an offline attempt can be persisted with the
  /// full `{questionId, selectedAnswer}` record (the batch [request] only knows
  /// correctness). Online behaviour is unchanged.
  Future<QuizSubmissionResponse> submitQuiz(
    int levelId,
    QuizSubmissionRequest request, {
    List<PendingAnswerInput>? selectedAnswers,
  });

  /// Resets all of the current user's quiz progress.
  Future<void> resetAll();
}

class QuizRepositoryImpl implements QuizRepository {
  QuizRepositoryImpl({
    required QuizRemoteDataSource remoteDataSource,
    required OfflineContentDao contentDao,
    required PendingAnswersDao pendingDao,
    required CurrentUserProvider userProvider,
  }) : _remoteDataSource = remoteDataSource,
       _contentDao = contentDao,
       _pendingDao = pendingDao,
       _userProvider = userProvider;

  final QuizRemoteDataSource _remoteDataSource;
  final OfflineContentDao _contentDao;
  final PendingAnswersDao _pendingDao;
  final CurrentUserProvider _userProvider;

  @override
  Future<QuizQuestionsResponse> getQuestions(int levelId) async {
    try {
      return await _remoteDataSource.getQuestions(levelId);
    } catch (e) {
      if (isConnectivityError(e)) {
        final local = await _contentDao.getDownloadedQuestions(levelId);
        if (local != null) return local;
      }
      // Not downloaded (or a real server error): surface the original failure
      // so the quiz screen shows its normal load-error with retry.
      rethrow;
    }
  }

  @override
  Future<QuizSubmissionResponse> submitQuiz(
    int levelId,
    QuizSubmissionRequest request, {
    List<PendingAnswerInput>? selectedAnswers,
  }) async {
    try {
      return await _remoteDataSource.submitQuiz(levelId, request);
    } catch (e) {
      if (isConnectivityError(e)) {
        await _persistOffline(levelId, request, selectedAnswers);
        return _syntheticResponse(levelId, request);
      }
      rethrow;
    }
  }

  Future<void> _persistOffline(
    int levelId,
    QuizSubmissionRequest request,
    List<PendingAnswerInput>? selectedAnswers,
  ) {
    final byId = {for (final a in selectedAnswers ?? const []) a.questionId: a};
    final answers = [
      for (final a in request.answers)
        PendingAnswerInput(
          questionId: a.questionId,
          selectedAnswer: byId[a.questionId]?.selectedAnswer ?? -1,
          isCorrect: a.isCorrect,
        ),
    ];
    return _pendingDao.insertAttempt(
      levelId: levelId,
      pointsEarned: request.pointsEarned,
      answers: answers,
    );
  }

  /// Builds the result the finish screen needs from data already computed
  /// client-side, so an offline attempt flows through the UI identically.
  /// `passed` uses the downloaded level's passing grade; `nextLevelUnlocked`
  /// and `totalPoints` are honest "unknown offline" defaults that the real
  /// values replace once the attempt syncs.
  Future<QuizSubmissionResponse> _syntheticResponse(
    int levelId,
    QuizSubmissionRequest request,
  ) async {
    final correct = request.answers.where((a) => a.isCorrect).length;
    final total = request.answers.length;
    final local = await _contentDao.getDownloadedQuestions(levelId);
    final passingGrade = local?.passingGrade ?? 0;
    final userId = await _userProvider.userId();
    return QuizSubmissionResponse(
      levelId: levelId,
      userId: userId,
      totalQuestions: total,
      correctAnswers: correct,
      passed: correct >= passingGrade,
      nextLevelUnlocked: false,
      pointsEarned: request.pointsEarned,
      totalPoints: 0,
    );
  }

  @override
  Future<void> resetAll() => _remoteDataSource.resetAll();
}
