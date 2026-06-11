import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/snackbar_helper.dart';
import '../../../../core/widgets/responsive_text.dart';
import '../../../../theme/theme.dart';
import '../../../splash/widgets/desert_background.dart';
import '../../../splash/widgets/zaad_brand.dart';
import '../cubit/forgot_password_cubit.dart';
import '../cubit/forgot_password_state.dart';
import '../widgets/auth_primary_button.dart';
import '../widgets/auth_prompt_link.dart';
import '../widgets/reset_password_dialog.dart';
import '../widgets/zaad_text_field.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();

  bool _emailFilled = false;
  bool _dialogOpen = false;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_recomputeFilled);
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _recomputeFilled() {
    final filled = _emailController.text.trim().isNotEmpty;
    if (filled != _emailFilled) {
      setState(() => _emailFilled = filled);
    }
  }

  void _onSendCode() {
    FocusScope.of(context).unfocus();
    context.read<ForgotPasswordCubit>().sendOtp(_emailController.text.trim());
  }

  void _onBackToLogin() {
    context.pop();
  }

  void _onForgotStateChanged(BuildContext context, ForgotPasswordState state) {
    if (state.isOtpSent && !_dialogOpen) {
      _dialogOpen = true;
      SnackBarHelper.showSuccess(
        context,
        message: 'auth.forgot_password_screen.otp_sent',
      );
      ResetPasswordDialog.show(
        context,
        cubit: context.read<ForgotPasswordCubit>(),
        email: state.email ?? _emailController.text.trim(),
      ).whenComplete(() => _dialogOpen = false);
      return;
    }

    if (state.isSuccess) {
      if (_dialogOpen) {
        Navigator.of(context, rootNavigator: true).pop();
        _dialogOpen = false;
      }
      SnackBarHelper.showSuccess(
        context,
        message: 'auth.reset_password_dialog.success',
      );
      context.pop();
      return;
    }

    if (state.isError && state.errorMessage != null) {
      SnackBarHelper.showError(context, message: state.errorMessage!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    // Status-bar overlay & dark-mode canvas are owned by DesertBackground.
    return BlocListener<ForgotPasswordCubit, ForgotPasswordState>(
      listener: _onForgotStateChanged,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: DesertBackground(
          child: SafeArea(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(32, 12, 32, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: IconButton(
                      onPressed: _onBackToLogin,
                      icon: Icon(
                        Directionality.of(context) == TextDirection.rtl
                            ? Icons.arrow_forward_rounded
                            : Icons.arrow_back_rounded,
                        color: colors.oliveDeep,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const ZaadBrand.compact(),
                  const SizedBox(height: 24),
                  const _Headline(),
                  const SizedBox(height: 24),
                  ZaadTextField(
                    hintText: 'auth.forgot_password_screen.email_hint',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.email],
                    textInputAction: TextInputAction.done,
                    prefixIcon: Icon(
                      Icons.mail_outline_rounded,
                      color: colors.oliveSoft,
                      size: 20,
                    ),
                  ),
                  const SizedBox(height: 16),
                  BlocBuilder<ForgotPasswordCubit, ForgotPasswordState>(
                    buildWhen: (previous, current) =>
                        previous.isSendingOtp != current.isSendingOtp,
                    builder: (context, state) => AuthPrimaryButton(
                      label: 'auth.forgot_password_screen.send_code',
                      loading: state.isSendingOtp,
                      enabled: _emailFilled,
                      onTap: _onSendCode,
                    ),
                  ),
                  const SizedBox(height: 24),
                  AuthPromptLink(
                    prompt: 'auth.forgot_password_screen.back_to_login_prompt',
                    action: 'auth.forgot_password_screen.back_to_login',
                    onTap: _onBackToLogin,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Headline extends StatelessWidget {
  const _Headline();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Column(
      children: [
        Text.rich(
          TextSpan(
            style: ZaadType.titleHero.copyWith(color: colors.oliveDeep),
            children: [
              TextSpan(
                text: 'auth.forgot_password_screen.headline_prefix'.tr(),
              ),
              TextSpan(
                text: 'auth.forgot_password_screen.headline_accent'.tr(),
                style: AppTextStyles.bodyLarge.copyWith(
                  fontStyle: FontStyle.italic,
                  color: colors.textArabic,
                ),
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 300),
          child: ResponsiveText(
            'auth.forgot_password_screen.subtitle',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: 13,
              color: colors.dateSoft,
            ),
          ),
        ),
      ],
    );
  }
}
