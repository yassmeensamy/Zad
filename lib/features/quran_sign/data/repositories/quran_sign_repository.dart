import '../models/quran_sign_model.dart';
import '../remote/quran_sign_remote_data_source.dart';

abstract class QuranSignRepository {
  Future<QuranSignModel> getRandomSign();
}

class QuranSignRepositoryImpl implements QuranSignRepository {
  QuranSignRepositoryImpl({required QuranSignRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  final QuranSignRemoteDataSource _remoteDataSource;

  @override
  Future<QuranSignModel> getRandomSign() => _remoteDataSource.getRandomSign();
}
