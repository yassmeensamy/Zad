import '../../../../core/constants/storage_keys.dart';
import '../../../../core/models/user_model.dart';
import '../../../../core/services/cache_service.dart';
import '../../../../core/utils/logger.dart';
import '../remote/user_remote_data_source.dart';

abstract class UserRepository {
  Future<UserModel> fetchUserProfile();
  Future<UserModel> updateProfile({
    required String fullName,
    DateTime? birthDate,
    String? avatarId,
    String? username,
    Gender? gender,
    int? countryId,
  });
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmNewPassword,
  });
  Future<UserModel?> loadProfileFromCache();
  Future<void> saveProfileToCache(UserModel user);
  Future<void> clearProfileCache();
}

class UserRepositoryImpl implements UserRepository {
  UserRepositoryImpl({
    required UserRemoteDataSource remoteDataSource,
    required CacheService cacheService,
  }) : _remoteDataSource = remoteDataSource,
       _cacheService = cacheService;

  final UserRemoteDataSource _remoteDataSource;
  final CacheService _cacheService;

  @override
  Future<UserModel> fetchUserProfile() async {
    final user = await _remoteDataSource.getUserProfile();
    final resolved = await _withSocialName(user);
    await saveProfileToCache(resolved);
    return resolved;
  }

  /// Prefers the name the provider handed us at sign-in over the server's.
  /// Apple releases the real name only on the first authorization, and the
  /// backend may not persist it — it answers /me with a placeholder ("Apple
  /// User") instead — so while that one-shot value is still around it wins.
  /// With no provider name (any later Apple sign-in) the server's name stands.
  /// The stored copy is dropped once the user saves a profile of their own.
  Future<UserModel> _withSocialName(UserModel user) async {
    final pending = await _cacheService.get<String>(
      StorageKeys.kPendingSocialNameKey,
    );
    final providerName = pending?.trim();
    if (providerName == null || providerName.isEmpty) return user;
    if (providerName == user.fullName.trim()) return user;
    logger.debug(
      '[apple-name] 5b/6 provider name wins → "$providerName" '
      'over /me "${user.fullName}"',
    );
    return user.copyWith(fullName: providerName);
  }

  @override
  Future<UserModel> updateProfile({
    required String fullName,
    DateTime? birthDate,
    String? avatarId,
    String? username,
    Gender? gender,
    int? countryId,
  }) async {
    final user = await _remoteDataSource.updateProfile(
      fullName: fullName,
      birthDate: birthDate,
      avatarId: avatarId,
      username: username,
      gender: gender,
      countryId: countryId,
    );
    // The name now lives on the server, so the sign-in fallback is spent.
    await _cacheService.remove(StorageKeys.kPendingSocialNameKey);
    await saveProfileToCache(user);
    return user;
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmNewPassword,
  }) {
    return _remoteDataSource.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
      confirmNewPassword: confirmNewPassword,
    );
  }

  @override
  Future<UserModel?> loadProfileFromCache() async {
    final raw = await _cacheService.get<String>(StorageKeys.kUserKey);
    if (raw == null || raw.isEmpty) return null;
    return UserModel.fromJson(raw);
  }

  @override
  Future<void> saveProfileToCache(UserModel user) async {
    await _cacheService.set<String>(StorageKeys.kUserKey, user.toJson());
  }

  @override
  Future<void> clearProfileCache() async {
    await _cacheService.remove(StorageKeys.kUserKey);
  }
}
