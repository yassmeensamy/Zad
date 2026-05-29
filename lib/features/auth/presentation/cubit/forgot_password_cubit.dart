import '../../../../core/cubits/base_cubit.dart';
import '../../../../core/expections/server_exception.dart';
import '../../../../core/utils/logger.dart';

import '../../data/repositories/auth_repository.dart';
import 'forgot_password_state.dart';

class ForgotPasswordCubit extends BaseCubit<ForgotPasswordState> {
  ForgotPasswordCubit({required AuthRepository repository})
    : _repository = repository,
      super(const ForgotPasswordState());

  final AuthRepository _repository;

  Future<void> sendOtp(String email) async {
    emit(state.copyWith(otpStatus: ForgotOtpStatus.sending, email: email));
    try {
      await _repository.forgotPassword(email: email);
      emit(state.copyWith(otpStatus: ForgotOtpStatus.sent));
    } on ServerException catch (e) {
      _emitOtpError(e.message);
    } catch (e) {
      logger.debug('Error in sendOtp: $e');
      _emitOtpError('errors.generic');
    }
  }

  Future<void> resetPassword({
    required String otp,
    required String newPassword,
  }) async {
    final email = state.email;
    if (email == null) return;

    emit(state.copyWith(resetStatus: ResetPasswordStatus.resetting));
    try {
      await _repository.resetPassword(
        email: email,
        otp: otp,
        newPassword: newPassword,
      );
      emit(state.copyWith(resetStatus: ResetPasswordStatus.success));
    } on ServerException catch (e) {
      _emitResetError(e.message);
    } catch (e) {
      logger.debug('Error in resetPassword: $e');
      _emitResetError('errors.generic');
    }
  }

  void _emitOtpError(String message) => emit(
    state.copyWith(otpStatus: ForgotOtpStatus.error, errorMessage: message),
  );

  void _emitResetError(String message) => emit(
    state.copyWith(resetStatus: ResetPasswordStatus.error, errorMessage: message),
  );
}
