import '../../../../core/api/endpoints/app_endpoints.dart';
import '../../../../core/api/network_service.dart';
import '../../../../core/expections/server_exception.dart';
import '../../../../core/utils/logger.dart';
import '../models/quiz_questions_response.dart';
import '../models/quiz_submission_request.dart';
import '../models/quiz_submission_response.dart';

abstract class QuizRemoteDataSource {
  Future<QuizQuestionsResponse> getQuestions(int levelId);
  Future<QuizSubmissionResponse> submitQuiz(
    int levelId,
    QuizSubmissionRequest request,
  );
}

class QuizRemoteDataSourceImpl implements QuizRemoteDataSource {
  QuizRemoteDataSourceImpl({
    required NetworkService networkService,
    required AppEndpoint endpoints,
  })  : _networkService = networkService,
        _endpoints = endpoints;

  final NetworkService _networkService;
  final AppEndpoint _endpoints;

  void _validateResponse(
    dynamic response, [
    List<int> validCodes = const [200, 201],
  ]) {
    if (!validCodes.contains(response.statusCode)) {
      logger.debug('validateResponse: ${response.data}');
      throw ServerException.fromMap(response.data);
    }
  }

  @override
  Future<QuizQuestionsResponse> getQuestions(int levelId) async {
    final response = await _networkService.get(
      _endpoints.questionsByLevelId(levelId),
    );
    _validateResponse(response);
    return QuizQuestionsResponse.fromMap(
      response.data as Map<String, dynamic>,
    );
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
    _validateResponse(response);
    return QuizSubmissionResponse.fromMap(
      response.data as Map<String, dynamic>,
    );
  }
}
