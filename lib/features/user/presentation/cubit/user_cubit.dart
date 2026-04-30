import '../../../../core/cubits/base_cubit.dart';
import '../../../../core/expections/server_exception.dart';
import '../../../../core/utils/logger.dart';
import '../../../auth/core/auth_event_service.dart';
import '../../../auth/core/auth_state_listener_mixin.dart';
import '../../data/repositories/user_repository.dart';
import 'user_state.dart';

class UserCubit extends BaseCubit<UserState> with AuthStateListenerMixin {
  UserCubit({
    required UserRepository userRepository,
    required AuthEventService authEventService,
  }) : _userRepository = userRepository,
       _authEventService = authEventService,
       super(const UserState()) {
    initAuthListener();
  }

  final UserRepository _userRepository;
  final AuthEventService _authEventService;

  @override
  AuthEventService get authEventService => _authEventService;

  @override
  void onAuthenticated() => fetchUserProfile();

  @override
  void onUnauthenticated() => clearUser();

  Future<void> fetchUserProfile() async {
    emit(state.copyWith(status: UserStatus.loading));
    try {
      final user = await _userRepository.fetchUserProfile();
      emit(state.copyWith(status: UserStatus.success, user: user));
    } on ServerException catch (e) {
      await _fallbackToCache(message: e.message);
    } catch (e) {
      logger.error('UserCubit.fetchUserProfile failed: $e');
      await _fallbackToCache(message: 'Failed to load user profile');
    }
  }

  /// On network/5xx, serve stale cache so the app still works. If cache is
  /// empty, surface the error so the splash can route to login.
  Future<void> _fallbackToCache({required String message}) async {
    final cached = await _userRepository.loadProfileFromCache();
    if (cached == null) {
      emit(state.copyWith(status: UserStatus.error, errorMessage: message));
      return;
    }
    emit(state.copyWith(status: UserStatus.success, user: cached));
  }

  Future<void> updateProfile({
    required String fullName,
    DateTime? birthDate,
  }) async {
    emit(state.copyWith(updateStatus: UpdateProfileStatus.loading));
    try {
      final user = await _userRepository.updateProfile(
        fullName: fullName,
        birthDate: birthDate,
      );
      emit(
        state.copyWith(
          updateStatus: UpdateProfileStatus.success,
          user: user,
        ),
      );
    } on ServerException catch (e) {
      emit(
        state.copyWith(
          updateStatus: UpdateProfileStatus.error,
          updateErrorMessage: e.message,
        ),
      );
    } catch (e) {
      logger.error('UserCubit.updateProfile failed: $e');
      emit(
        state.copyWith(
          updateStatus: UpdateProfileStatus.error,
          updateErrorMessage: 'Failed to update profile',
        ),
      );
    }
  }

  void resetUpdateStatus() {
    emit(state.copyWith(updateStatus: UpdateProfileStatus.initial));
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmNewPassword,
  }) async {
    emit(state.copyWith(changePasswordStatus: ChangePasswordStatus.loading));
    try {
      await _userRepository.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
        confirmNewPassword: confirmNewPassword,
      );
      emit(
        state.copyWith(changePasswordStatus: ChangePasswordStatus.success),
      );
    } on ServerException catch (e) {
      emit(
        state.copyWith(
          changePasswordStatus: ChangePasswordStatus.error,
          changePasswordErrorMessage: e.message,
        ),
      );
    } catch (e) {
      logger.error('UserCubit.changePassword failed: $e');
      emit(
        state.copyWith(
          changePasswordStatus: ChangePasswordStatus.error,
          changePasswordErrorMessage: 'Failed to change password',
        ),
      );
    }
  }

  void resetChangePasswordStatus() {
    emit(
      state.copyWith(changePasswordStatus: ChangePasswordStatus.initial),
    );
  }

  Future<void> clearUser() async {
    await _userRepository.clearProfileCache();
    emit(const UserState());
  }

  @override
  Future<void> close() {
    disposeAuthListener();
    return super.close();
  }
}
