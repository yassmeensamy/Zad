import '../../../../core/constants/storage_keys.dart';
import '../../../../core/models/user_model.dart';
import '../../../../core/services/cache_service.dart';
import '../remote/user_remote_data_source.dart';

abstract class UserRepository {
  Future<UserModel> fetchUserProfile();
  Future<UserModel> updateProfile({
    required String fullName,
    DateTime? birthDate,
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
    await saveProfileToCache(user);
    return user;
  }

  @override
  Future<UserModel> updateProfile({
    required String fullName,
    DateTime? birthDate,
  }) async {
    final user = await _remoteDataSource.updateProfile(
      fullName: fullName,
      birthDate: birthDate,
    );
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
