import '../remote/language_remote_data_source.dart';

abstract class LanguageRepository {
  Future<void> updateLanguage(String language);
}

class LanguageRepositoryImpl implements LanguageRepository {
  LanguageRepositoryImpl({required LanguageRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  final LanguageRemoteDataSource _remoteDataSource;

  @override
  Future<void> updateLanguage(String language) =>
      _remoteDataSource.updateLanguage(language);
}
