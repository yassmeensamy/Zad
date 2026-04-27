// TODO: `google_sign_in` is imported by the OAuth strategy but not in pubspec
// yet — add it before this cubit can compile, or remove the typed
// `on GoogleSignInException` catch below and fall back to generic `catch`.
import 'package:google_sign_in/google_sign_in.dart';

import '../../../../core/cubits/base_cubit.dart';
import '../../../../core/expections/server_exception.dart';
import '../../../../core/utils/logger.dart';

import '../../core/auth_event_service.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/responses/auth_response.dart';
import 'auth_state.dart';

class AuthCubit extends BaseCubit<AuthState> {
  AuthCubit({
    required AuthRepository repository,
    required AuthEventService authEventService,
  }) : _repository = repository,
       _authEventService = authEventService,
       super(const AuthState());

  final AuthRepository _repository;
  final AuthEventService _authEventService;

  Future<void> init() async {
    try {
      final isLoggedIn = await _repository.isLoggedIn();
      if (!isLoggedIn) {
        emit(state.copyWith(status: AuthStatus.notLoggedIn));
        return;
      }
      _emitAndNotify(state.copyWith(status: AuthStatus.loggedIn));
    } catch (e) {
      logger.debug('Error during auth init: $e');
      emit(state.copyWith(status: AuthStatus.notLoggedIn));
    }
  }

  Future<void> signup({
    required String email,
    required String password,
    required String fullName,
  }) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      final response = await _repository.signup(
        email: email,
        password: password,
        fullName: fullName,
      );
      _emitLoggedIn(response, email: email);
    } on ServerException catch (e) {
      _emitError(_errorMessage(e));
    } catch (e) {
      logger.debug('Error in signup: $e');
      _emitError('general_error');
    }
  }

  Future<void> login({
    required String identifier,
    required String password,
  }) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      final response = await _repository.login(
        identifier: identifier,
        password: password,
      );
      _emitLoggedIn(response, email: identifier);
    } on ServerException catch (e) {
      _emitError(_errorMessage(e));
    } catch (e) {
      logger.debug('Error in login: $e');
      _emitError('general_error');
    }
  }

  Future<void> loginWithGoogle() async {
    emit(
      state.copyWith(
        status: AuthStatus.loading,
        socialAuthStatus: SocialAuthStatus.loading,
      ),
    );

    try {
      await _repository.loginWithGoogle();
      _emitAndNotify(
        state.copyWith(
          status: AuthStatus.loggedIn,
          socialAuthStatus: SocialAuthStatus.success,
          userType: UserType.user,
        ),
      );
    } on ServerException catch (e) {
      _emitSocialError(_errorMessage(e));
    } on GoogleSignInException catch (e) {
      _handleGoogleException(e);
    } catch (e) {
      logger.debug('Unexpected error in loginWithGoogle: $e');
      _emitSocialError('general_error');
    }
  }

  Future<void> logout() async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      await _authEventService.runPreLogoutCallbacks();
      await _repository.logout();
      _emitAndNotify(const AuthState(status: AuthStatus.notLoggedIn));
    } on ServerException catch (e) {
      logger.debug('Error during logout: ${e.message}');
      _emitError(_errorMessage(e));
    } catch (e) {
      logger.debug('Unexpected error in logout: $e');
      _emitError('general_error');
    }
  }

  Future<void> deleteAccount(String password) async {
    try {
      await _authEventService.runPreLogoutCallbacks();
      await _repository.deleteAccount(password);
      _emitAndNotify(const AuthState(status: AuthStatus.notLoggedIn));
    } on ServerException catch (e) {
      _emitError(_errorMessage(e));
    } catch (e) {
      logger.debug(e.toString());
    }
  }

  void _emitLoggedIn(AuthResponse response, {String? email}) {
    _emitAndNotify(
      state.copyWith(
        status: AuthStatus.loggedIn,
        email: email,
        userType: UserType.user,
      ),
    );
  }

  void _emitError(String message) {
    emit(state.copyWith(status: AuthStatus.error, errorMessage: message));
  }

  void _emitSocialError(String message) {
    emit(
      state.copyWith(
        status: AuthStatus.error,
        socialAuthStatus: SocialAuthStatus.error,
        errorMessage: message,
      ),
    );
  }

  void _handleGoogleException(GoogleSignInException e) {
    if (e.code == GoogleSignInExceptionCode.canceled) {
      emit(state.copyWith(socialAuthStatus: SocialAuthStatus.initial));
      return;
    }
    _emitSocialError(e.toString());
  }

  void _emitAndNotify(AuthState newState) {
    emit(newState);
    final event = switch (newState.status) {
      AuthStatus.loggedIn => AuthEvent.loggedIn,
      AuthStatus.notLoggedIn => AuthEvent.loggedOut,
      _ => null,
    };
    if (event != null) _authEventService.notify(event);
  }

  String _errorMessage(ServerException e) => e.message;
}
