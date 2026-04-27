import '../../../../core/constants/storage_keys.dart';
import '../../../../core/services/cache_service.dart';

import '../models/social_provider.dart';
import '../responses/auth_response.dart';

class AuthLocalService {
  AuthLocalService(this._cache);

  final CacheService _cache;

  Future<void> setAccessToken(String token) async => await _cache.set<String>(
    StorageKeys.kAccessTokenKey,
    token,
    isSecure: true,
  );

  Future<String?> getAccessToken() async =>
      await _cache.get<String>(StorageKeys.kAccessTokenKey, isSecure: true);

  Future<void> setRefreshToken(String token) async => await _cache.set<String>(
    StorageKeys.kRefreshTokenKey,
    token,
    isSecure: true,
  );

  Future<String?> getRefreshToken() async =>
      await _cache.get<String>(StorageKeys.kRefreshTokenKey, isSecure: true);

  Future<void> setLoginMethod(SocialProvider method) async =>
      await _cache.set<String>(StorageKeys.kLoginMethodKey, method.name);

  Future<String?> getSocialLoginMethod() async =>
      await _cache.get<String>(StorageKeys.kLoginMethodKey);

  Future<void> clearLoginMethod() async =>
      await _cache.remove(StorageKeys.kLoginMethodKey);


  Future<void> onLoginSuccess(AuthResponse response) async {
    await setAccessToken(response.accessToken);
    await setRefreshToken(response.refreshToken);
  }

  Future<void> clearTokens() async {
    await _cache.remove(StorageKeys.kAccessTokenKey, isSecure: true);
    await _cache.remove(StorageKeys.kRefreshTokenKey, isSecure: true);
  }

  Future<void> clearAllAuthData(
    Future<void> Function(SocialProvider) signOutProvider,
  ) async {
    final socialLoginMethod = await getSocialLoginMethod();
    if (socialLoginMethod != null) {
      final provider = SocialProvider.values.byName(socialLoginMethod);
      await signOutProvider(provider);
      await clearLoginMethod();
    }
    await clearTokens();
  }
}
