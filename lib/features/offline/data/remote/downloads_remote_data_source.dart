import '../../../../core/api/endpoints/app_endpoints.dart';
import '../../../../core/api/network_service.dart';
import '../../../../core/constants/storage_keys.dart';
import '../../../../core/expections/server_exception.dart';
import '../../../../core/services/cache_service.dart';
import '../../../../core/utils/logger.dart';
import '../models/category_download_bundle.dart';

abstract class DownloadsRemoteDataSource {
  Future<CategoryDownloadBundle> getCategoryDownload(int categoryId);
}

class DownloadsRemoteDataSourceImpl implements DownloadsRemoteDataSource {
  DownloadsRemoteDataSourceImpl({
    required NetworkService networkService,
    required AppEndpoint endpoints,
    required CacheService cacheService,
  }) : _networkService = networkService,
       _endpoints = endpoints,
       _cacheService = cacheService;

  final NetworkService _networkService;
  final AppEndpoint _endpoints;
  final CacheService _cacheService;

  void _validateResponse(
    dynamic response, [
    List<int> validCodes = const [200, 201],
  ]) {
    if (!validCodes.contains(response.statusCode)) {
      logger.debug('validateResponse: ${response.data}');
      throw ServerException.fromResponse(response);
    }
  }

  @override
  Future<CategoryDownloadBundle> getCategoryDownload(int categoryId) async {
    final response = await _networkService.get(
      _endpoints.categoryDownload(categoryId),
    );
    _validateResponse(response);
    final languageCode =
        await _cacheService.get<String>(StorageKeys.kLocaleKey) ?? 'ar';
    return CategoryDownloadBundle.fromMap(
      response.data as Map<String, dynamic>,
      languageCode: languageCode,
    );
  }
}
