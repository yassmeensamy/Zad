import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/custom_dialog.dart';
import '../../../../core/widgets/responsive_text.dart';
import '../../../../theme/theme.dart';
import '../cubit/forgot_password_cubit.dart';
import '../cubit/forgot_password_state.dart';
import 'auth_primary_button.dart';
import 'zaad_text_field.dart';

class ResetPasswordDialog extends StatefulWidget {
  const ResetPasswordDialog({super.key, required this.email});

  final String email;

  static Future<void> show(
    BuildContext context, {
    required ForgotPasswordCubit cubit,
    required String email,
  }) {
    return CustomDialog.show(
      context: context,
      barrierDismissible: false,
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
      constraints: const BoxConstraints(maxWidth: 400),
      child: BlocProvider<ForgotPasswordCubit>.value(
        value: cubit,
        child: ResetPasswordDialog(email: email),
      ),
    );
  }

  @override
  State<ResetPasswordDialog> createState() => _ResetPasswordDialogState();
}

class _ResetPasswordDialogState extends State<ResetPasswordDialog> {
  final _otpController = TextEditingController();
  final _passwordController = TextEditingController();

  static const int _otpLength = 6;
  static const int _minPasswordLength = 6;

  bool _canSubmit = false;

  @override
  void initState() {
    super.initState();
    _otpController.addListener(_recomputeCanSubmit);
    _passwordController.addListener(_recomputeCanSubmit);
  }

  @override
  void dispose() {
    _otpController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _recomputeCanSubmit() {
    final canSubmit =
        _otpController.text.trim().length == _otpLength &&
        _passwordController.text.length >= _minPasswordLength;
    if (canSubmit != _canSubmit) {
      setState(() => _canSubmit = canSubmit);
    }
  }

  void _onSubmit() {
    FocusScope.of(context).unfocus();
    context.read<ForgotPasswordCubit>().resetPassword(
      otp: _otpController.text.trim(),
      newPassword: _passwordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ResponsiveText(
          'auth.reset_password_dialog.title',
          textAlign: TextAlign.center,
          style: ZaadType.titleHero.copyWith(
            fontSize: 24,
            color: colors.oliveDeep,
          ),
        ),
        const SizedBox(height: 10),
        ResponsiveText(
          'auth.reset_password_dialog.subtitle',
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyMedium.copyWith(
            fontSize: 13,
            height: 1.5,
            color: colors.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          widget.email,
          textAlign: TextAlign.center,
          style: AppTextStyles.labelLarge.copyWith(
            fontSize: 13,
            letterSpacing: 0,
            color: colors.oliveDeep,
          ),
        ),
        const SizedBox(height: 22),
        ZaadTextField(
          hintText: 'auth.reset_password_dialog.otp_hint',
          controller: _otpController,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.next,
          prefixIcon: Icon(
            Icons.pin_outlined,
            color: colors.oliveSoft,
            size: 20,
          ),
        ),
        const SizedBox(height: 12),
        ZaadTextField(
          hintText: 'auth.reset_password_dialog.new_password_hint',
          controller: _passwordController,
          obscureText: true,
          passwordToggle: true,
          autofillHints: const [AutofillHints.newPassword],
          textInputAction: TextInputAction.done,
          prefixIcon: Icon(
            Icons.lock_outline_rounded,
            color: colors.oliveSoft,
            size: 20,
          ),
        ),
        const SizedBox(height: 22),
        BlocBuilder<ForgotPasswordCubit, ForgotPasswordState>(
          buildWhen: (previous, current) =>
              previous.isResetting != current.isResetting,
          builder: (context, state) => AuthPrimaryButton(
            label: 'auth.reset_password_dialog.submit',
            loading: state.isResetting,
            enabled: _canSubmit,
            onTap: _onSubmit,
          ),
        ),
        const SizedBox(height: 6),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: ResponsiveText(
            'auth.reset_password_dialog.cancel',
            style: AppTextStyles.labelLarge.copyWith(
              fontSize: 13,
              letterSpacing: 0,
              color: colors.olive,
            ),
          ),
        ),
      ],
    );
  }
}
