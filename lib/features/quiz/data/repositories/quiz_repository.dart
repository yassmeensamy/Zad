import '../models/quiz_questions_response.dart';
import '../remote/quiz_remote_data_source.dart';

abstract class QuizRepository {
  Future<QuizQuestionsResponse> getQuestions(int levelId);
}

class QuizRepositoryImpl implements QuizRepository {
  QuizRepositoryImpl({required QuizRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  final QuizRemoteDataSource _remoteDataSource;

  @override
  Future<QuizQuestionsResponse> getQuestions(int levelId) =>
      _remoteDataSource.getQuestions(levelId);
}
