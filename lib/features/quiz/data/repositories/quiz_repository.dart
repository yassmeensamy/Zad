import '../models/quiz_questions_response.dart';
import '../models/quiz_submission_request.dart';
import '../models/quiz_submission_response.dart';
import '../remote/quiz_remote_data_source.dart';

abstract class QuizRepository {
  Future<QuizQuestionsResponse> getQuestions(int levelId);
  Future<QuizSubmissionResponse> submitQuiz(
    int levelId,
    QuizSubmissionRequest request,
  );
}

class QuizRepositoryImpl implements QuizRepository {
  QuizRepositoryImpl({required QuizRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  final QuizRemoteDataSource _remoteDataSource;

  @override
  Future<QuizQuestionsResponse> getQuestions(int levelId) =>
      _remoteDataSource.getQuestions(levelId);

  @override
  Future<QuizSubmissionResponse> submitQuiz(
    int levelId,
    QuizSubmissionRequest request,
  ) =>
      _remoteDataSource.submitQuiz(levelId, request);
}
