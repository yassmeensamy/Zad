import 'package:dio/dio.dart';
import '../services/cache_service.dart';

import '../constants/storage_keys.dart';

class LanguageInterceptor extends Interceptor {
  LanguageInterceptor({required CacheService cacheService})
    : _cacheService = cacheService;
  final CacheService _cacheService;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final languageCode = await _cacheService.get<String>(
      StorageKeys.kLocaleKey,
    );
    if (languageCode != null) {
      options.headers.addAll({'Accept-Language': languageCode});
    }
    super.onRequest(options, handler);
  }
}
