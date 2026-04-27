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
  }) : _remoteDataSource = remoteDataSource,
       _localService = localService,
       _strategyFactory = strategyFactory;

  final AuthRemoteDataSource _remoteDataSource;
  final AuthLocalService _localService;
  final OAuthStrategyFactory _strategyFactory;

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
    );
    await _localService.onLoginSuccess(response);
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

    final response = await _remoteDataSource.googleAuth(idToken);
    await _localService.onLoginSuccess(response);
    await _localService.setLoginMethod(SocialProvider.google);
    return response;
  }

  @override
  Future<void> logout() async {
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
