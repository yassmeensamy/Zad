import 'dart:async';

import '../../../../core/cubits/base_cubit.dart';
import '../../../../core/expections/server_exception.dart';
import '../../../../core/models/user_model.dart';
import '../../../../core/utils/logger.dart';
import '../../../auth/core/auth_event_service.dart';
import '../../../auth/core/auth_state_listener_mixin.dart';
import '../../../onboarding_flow/data/avatar_model.dart';
import '../../../quiz/core/quiz_event_service.dart';
import '../../data/repositories/user_repository.dart';
import 'user_state.dart';

class UserCubit extends BaseCubit<UserState> with AuthStateListenerMixin {
  UserCubit({
    required UserRepository userRepository,
    required AuthEventService authEventService,
    required QuizEventService quizEventService,
  }) : _userRepository = userRepository,
       _authEventService = authEventService,
       super(const UserState()) {
    initAuthListener();
    // A finished level moves `totalPoints` server-side, so re-read /me to keep
    // the displayed total honest. Silent: the profile already on screen stays.
    _submitSub = quizEventService.onSubmitted.listen(
      (_) => fetchUserProfile(isRefresh: true),
    );
  }

  final UserRepository _userRepository;
  final AuthEventService _authEventService;
  StreamSubscription<int>? _submitSub;

  @override
  AuthEventService get authEventService => _authEventService;

  @override
  void onAuthenticated() => fetchUserProfile();

  @override
  void onUnauthenticated() => clearUser();

  /// Reads `GET /api/users/me` into state.
  ///
  /// [isRefresh] marks a background re-read of an already-loaded profile (after
  /// a quiz submit): it skips the `loading` emit so nothing on screen flashes,
  /// and swallows failures instead of falling back to cache — a momentarily
  /// stale total beats knocking a live session into an error/cache state.
  Future<void> fetchUserProfile({bool isRefresh = false}) async {
    if (!isRefresh) {
      emit(state.copyWith(status: UserStatus.loading));
    }
    try {
      final user = await _userRepository.fetchUserProfile();
      if (!isRefresh) {
        logger.debug(
          '[apple-name] 5/6 /me profile → fullName="${user.fullName}", '
          'email=${user.email}, profileComplete=${user.isProfileComplete}',
        );
      }
      emit(state.copyWith(status: UserStatus.success, user: user));
    } on ServerException catch (e) {
      if (isRefresh) {
        logger.error('UserCubit.fetchUserProfile refresh failed: ${e.message}');
        return;
      }
      await _fallbackToCache(message: e.message);
    } catch (e) {
      logger.error('UserCubit.fetchUserProfile failed: $e');
      if (isRefresh) return;
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
    AvatarModel? avatar,
    String? username,
    Gender? gender,
    int? countryId,
  }) async {
    final current = state.user;
    // Only send avatarId when it actually changed, so unrelated saves
    // (name/birthday) don't reassign the avatar field on the server.
    final avatarChanged = avatar != null && avatar != current?.avatar;
    final avatarId = avatarChanged ? avatar.id : null;
    emit(state.copyWith(updateStatus: UpdateProfileStatus.loading));
    try {
      final updated = await _userRepository.updateProfile(
        fullName: fullName,
        birthDate: birthDate,
        avatarId: avatarId,
        username: username,
        gender: gender,
        countryId: countryId,
      );

      final merged = (current ?? state.user)?.copyWith(
        fullName: updated.fullName,
        birthDate: updated.birthDate,
        username: updated.username,
        gender: updated.gender,
        countryId: updated.countryId,
        avatar: avatarChanged ? avatar : null,
      );
      emit(
        state.copyWith(
          updateStatus: UpdateProfileStatus.success,
          user: merged ?? updated,
        ),
      );
      if (merged != null) {
        await _userRepository.saveProfileToCache(merged);
      }
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
  Future<void> close() async {
    await _submitSub?.cancel();
    disposeAuthListener();
    return super.close();
  }
}
