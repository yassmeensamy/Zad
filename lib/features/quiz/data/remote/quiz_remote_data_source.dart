import '../../../../core/api/endpoints/app_endpoints.dart';
import '../../../../core/api/network_service.dart';
import '../models/quiz_questions_response.dart';
import '../models/quiz_submission_request.dart';
import '../models/quiz_submission_response.dart';
import '../models/quiz_sync_request.dart';
import '../models/quiz_sync_response.dart';

abstract class QuizRemoteDataSource {
  Future<QuizQuestionsResponse> getQuestions(int levelId);
  Future<QuizSubmissionResponse> submitQuiz(
    int levelId,
    QuizSubmissionRequest request,
  );

  /// Flushes the whole offline answer queue in one batch call.
  Future<QuizSyncResponse> syncQuiz(QuizSyncRequest request);

  /// Resets all of the current user's quiz progress.
  Future<void> resetAll();
}

class QuizRemoteDataSourceImpl implements QuizRemoteDataSource {
  QuizRemoteDataSourceImpl({
    required NetworkService networkService,
    required AppEndpoint endpoints,
  }) : _networkService = networkService,
       _endpoints = endpoints;

  final NetworkService _networkService;
  final AppEndpoint _endpoints;

  @override
  Future<QuizQuestionsResponse> getQuestions(int levelId) async {
    final response = await _networkService.get(
      _endpoints.questionsByLevelId(levelId),
    );
    response.validated();
    return QuizQuestionsResponse.fromMap(response.data as Map<String, dynamic>);
  }

  @override
  Future<QuizSubmissionResponse> submitQuiz(
    int levelId,
    QuizSubmissionRequest request,
  ) async {
    final response = await _networkService.post(
      _endpoints.submitQuiz(levelId),
      data: request.toMap(),
    );
    response.validated();
    return QuizSubmissionResponse.fromMap(
      response.data as Map<String, dynamic>,
    );
  }

  @override
  Future<QuizSyncResponse> syncQuiz(QuizSyncRequest request) async {
    final response = await _networkService.post(
      _endpoints.syncQuiz,
      data: request.toMap(),
    );
    response.validated();
    return QuizSyncResponse.fromMap(response.data as Map<String, dynamic>);
  }

  @override
  Future<void> resetAll() async {
    final response = await _networkService.post(_endpoints.resetQuiz);
    response.validated(const [200, 201, 204]);
  }
}
