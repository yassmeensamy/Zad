import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pinput/pinput.dart';

import '../../../../core/utils/snackbar_helper.dart';
import '../../../../core/widgets/custom_dialog.dart';
import '../../../../core/widgets/otp_timer.dart';
import '../../../../core/widgets/responsive_text.dart';
import '../../../../theme/theme.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import 'auth_primary_button.dart';

/// Bottom-of-signup verification step. Shown after a `pending_verification`
/// signup so the user can enter the code sent to their email. Reads the
/// app-scoped [AuthCubit] directly; closing is driven by the host screen once
/// the user becomes logged in.
class VerifyEmailDialog extends StatefulWidget {
  const VerifyEmailDialog({super.key, required this.email});

  final String email;

  /// Resolves to `true` once the email is verified (the user is now logged in),
  /// or `null` if the dialog is dismissed without verifying.
  static Future<bool?> show(BuildContext context, {required String email}) {
    return CustomDialog.show<bool>(
      context: context,
      barrierDismissible: false,
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
      constraints: const BoxConstraints(maxWidth: 400),
      child: VerifyEmailDialog(email: email),
    );
  }

  @override
  State<VerifyEmailDialog> createState() => _VerifyEmailDialogState();
}

class _VerifyEmailDialogState extends State<VerifyEmailDialog> {
  static const int _codeLength = 6;

  late final TextEditingController _pinController;
  late final FocusNode _pinFocusNode;

  @override
  void initState() {
    super.initState();
    _pinController = TextEditingController();
    _pinFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _pinController.dispose();
    _pinFocusNode.dispose();
    super.dispose();
  }

  void _onVerify() {
    if (_pinController.text.length != _codeLength) return;
    _pinFocusNode.unfocus();
    context.read<AuthCubit>().verifyEmail(_pinController.text.trim());
  }

  void _onResend() {
    _pinFocusNode.unfocus();
    context.read<AuthCubit>().resendVerification();
  }

  void _onStateChanged(BuildContext context, AuthState state) {
   
    if (state.isLoggedIn) {
      Navigator.of(context).pop(true);
      return;
    }
    if (state.isVerificationError && state.errorMessage != null) {
      SnackBarHelper.showError(context, message: state.errorMessage!);
      _pinController.clear();
    }
  }

  PinTheme _defaultPinTheme(AppColorsTheme colors) => PinTheme(
    width: 48,
    height: 56,
    textStyle: AppTextStyles.titleLarge.copyWith(
      fontSize: 22,
      color: colors.oliveDeep,
    ),
    decoration: BoxDecoration(
      color: colors.inputSurface,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: colors.borderDefault),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final defaultPinTheme = _defaultPinTheme(colors);

    return BlocListener<AuthCubit, AuthState>(
      listenWhen: (previous, current) =>
          previous.verificationStatus != current.verificationStatus ||
          previous.status != current.status,
      listener: _onStateChanged,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ResponsiveText(
            'auth.verify_email_dialog.title',
            textAlign: TextAlign.center,
            style: ZaadType.titleHero.copyWith(
              fontSize: 24,
              color: colors.oliveDeep,
            ),
          ),
          const SizedBox(height: 10),
          ResponsiveText(
            'auth.verify_email_dialog.subtitle',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: 13,
              height: 1.5,
              color: colors.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          ResponsiveText(
            widget.email,
            textAlign: TextAlign.center,
            style: AppTextStyles.labelLarge.copyWith(
              fontSize: 13,
              letterSpacing: 0,
              color: colors.oliveDeep,
            ),
          ),
          const SizedBox(height: 24),
          Pinput(
            length: _codeLength,
            controller: _pinController,
            focusNode: _pinFocusNode,
            autofocus: true,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            defaultPinTheme: defaultPinTheme,
            focusedPinTheme: defaultPinTheme.copyWith(
              decoration: defaultPinTheme.decoration!.copyWith(
                border: Border.all(color: colors.olive, width: 1.6),
              ),
            ),
            submittedPinTheme: defaultPinTheme.copyWith(
              decoration: defaultPinTheme.decoration!.copyWith(
                color: colors.olive.withValues(alpha: 0.08),
                border: Border.all(color: colors.olive),
              ),
            ),
            onCompleted: (_) => _onVerify(),
          ),
          const SizedBox(height: 24),
          ListenableBuilder(
            listenable: _pinController,
            builder: (context, _) => BlocBuilder<AuthCubit, AuthState>(
              buildWhen: (previous, current) =>
                  previous.verificationStatus != current.verificationStatus,
              builder: (context, state) => AuthPrimaryButton(
                label: 'auth.verify_email_dialog.verify',
                loading: state.isVerifying,
                enabled: _pinController.text.length == _codeLength &&
                    !state.isVerifying,
                onTap: _onVerify,
              ),
            ),
          ),
          const SizedBox(height: 12),
          OtpTimer(
            duration: 120,
            onResend: _onResend,
            baseTextStyle: AppTextStyles.bodyMedium.copyWith(
              fontSize: 13,
              color: colors.textSecondary,
            ),
            linkTextStyle: AppTextStyles.labelLarge.copyWith(
              fontSize: 13,
              letterSpacing: 0,
              color: colors.olive,
            ),
          ),
        ],
      ),
    );
  }
}
