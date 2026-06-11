import '../../../../core/services/notification_service.dart';
import '../../../../core/utils/logger.dart';
import '../data_source/auth_remote_data_source.dart';
import '../models/social_provider.dart';
import '../responses/auth_response.dart';
import '../services/auth_local_service.dart';
import '../strategies/oauth_strategy_factory.dart';
import 'auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required AuthLocalService localService,
    required OAuthStrategyFactory strategyFactory,
    required NotificationService notificationService,
  }) : _remoteDataSource = remoteDataSource,
       _localService = localService,
       _strategyFactory = strategyFactory,
       _notificationService = notificationService;

  final AuthRemoteDataSource _remoteDataSource;
  final AuthLocalService _localService;
  final OAuthStrategyFactory _strategyFactory;
  final NotificationService _notificationService;

  /// Resolves the device FCM token, returning null if it can't be obtained
  /// (e.g. unsupported platform or denied permission) so auth never fails
  /// because of notifications.
  Future<String?> _fcmToken() async {
    try {
      return await _notificationService.getDeviceToken();
    } on Object catch (e) {
      logger.debug('Failed to get FCM token: $e');
      return null;
    }
  }

  @override
  Future<AuthResponse> signup({
    required String email,
    required String password,
    required String fullName,
  }) async {
    final response = await _remoteDataSource.signup(
      email: email,
      password: password,
      fullName: fullName,
      fcmToken: await _fcmToken(),
    );
    if (!response.isPendingVerification) {
      await _localService.onLoginSuccess(response);
    }
    return response;
  }

  @override
  Future<AuthResponse> login({
    required String identifier,
    required String password,
  }) async {
    final response = await _remoteDataSource.login(
      identifier: identifier,
      password: password,
      fcmToken: await _fcmToken(),
    );
    await _localService.onLoginSuccess(response);
    return response;
  }

  @override
  Future<AuthResponse> guestLogin() async {
    final response = await _remoteDataSource.guestLogin();
    await _localService.onLoginSuccess(response);
    return response;
  }

  @override
  Future<AuthResponse> upgradeGuest({
    required String email,
    required String password,
    required String fullName,
  }) async {
    final response = await _remoteDataSource.upgradeGuest(
      email: email,
      password: password,
      fullName: fullName,
    );
    await _localService.onLoginSuccess(response);
    return response;
  }

  @override
  Future<AuthResponse> loginWithGoogle() async {
    final strategy = _strategyFactory.getStrategy(SocialProvider.google);
    final tokens = await strategy.getTokens();
    final idToken = tokens['idToken'];
    if (idToken == null) {
      throw StateError('Google sign-in did not return an idToken');
    }

    final response = await _remoteDataSource.googleAuth(
      idToken,
      fcmToken: await _fcmToken(),
    );
    await _localService.onLoginSuccess(response);
    await _localService.setLoginMethod(SocialProvider.google);
    return response;
  }

  @override
  Future<void> forgotPassword({required String email}) =>
      _remoteDataSource.forgotPassword(email: email);

  @override
  Future<void> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) => _remoteDataSource.resetPassword(
    email: email,
    otp: otp,
    newPassword: newPassword,
  );

  @override
  Future<AuthResponse> verifyEmail({
    required String email,
    required String otp,
  }) async {
    final response = await _remoteDataSource.verifyEmail(
      email: email,
      otp: otp,
    );
    await _localService.onLoginSuccess(response);
    return response;
  }

  @override
  Future<void> resendVerification({required String email}) =>
      _remoteDataSource.resendVerification(email: email);

  @override
  Future<AuthResponse> switchAccount(String childId) async {
    final response = await _remoteDataSource.switchAccount(childId);
    await _localService.onLoginSuccess(response);
    return response;
  }

  @override
  Future<void> logout() async {
    final refreshToken = await _localService.getRefreshToken();
    if (refreshToken != null && refreshToken.isNotEmpty) {
      await _remoteDataSource.logout(refreshToken, fcmToken: await _fcmToken());
    }
    await _localService.clearAllAuthData(
      (provider) => _strategyFactory.getStrategy(provider).signOut(),
    );
  }

  @override
  Future<void> deleteAccount(String password) async {
    await _remoteDataSource.deleteAccount(password);
    await _localService.clearAllAuthData(
      (provider) => _strategyFactory.getStrategy(provider).signOut(),
    );
  }

  @override
  Future<String?> getAccessToken() => _localService.getAccessToken();

  @override
  Future<bool> isLoggedIn() async =>
      (await _localService.getAccessToken()) != null;



}
