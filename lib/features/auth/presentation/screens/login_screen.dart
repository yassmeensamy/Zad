import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/navigation/app_routes.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../../../../core/widgets/responsive_text.dart';
import '../../../../theme/theme.dart';
import '../../../splash/widgets/desert_background.dart';
import '../../../splash/widgets/zaad_brand.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import '../widgets/auth_google_button.dart';
import '../widgets/auth_or_divider.dart';
import '../widgets/auth_primary_button.dart';
import '../widgets/auth_prompt_link.dart';
import '../widgets/zaad_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _allFilled = false;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_recomputeFilled);
    _passwordController.addListener(_recomputeFilled);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _recomputeFilled() {
    final filled =
        _emailController.text.trim().isNotEmpty &&
        _passwordController.text.isNotEmpty;
    if (filled != _allFilled) {
      setState(() => _allFilled = filled);
    }
  }

  void _onSignIn() {
    context.read<AuthCubit>().login(
      identifier: _emailController.text.trim(),
      password: _passwordController.text,
    );
  }

  void _onGoogle() {
    context.read<AuthCubit>().loginWithGoogle();
  }

  void _onGoToSignUp() {
    context.go(AppRoutes.signup);
  }

  void _onForgotPassword() {
    // TODO: route to forgot-password flow once it exists.
  }

  void _onAuthStateChanged(BuildContext context, AuthState state) {
    if (state.isLoggedIn) {
      context.go(AppRoutes.roleSelect);
      return;
    }
    if (state.isError && state.errorMessage != null) {
      SnackBarHelper.showError(context, message: state.errorMessage!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: BlocListener<AuthCubit, AuthState>(
        listener: _onAuthStateChanged,
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          body: DesertBackground(
          child: SafeArea(
            child: SingleChildScrollView(
              physics: ClampingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(32, 24, 32, 32),
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  const ZaadBrand.compact(),
                  const SizedBox(height: 24),
                  const _Headline(),
                  const SizedBox(height: 24),
                  ZaadTextField(
                    hintText: 'auth.email_hint',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.email],
                    textInputAction: TextInputAction.next,
                    prefixIcon: Icon(
                      Icons.mail_outline_rounded,
                      color: colors.oliveSoft,
                      size: 20,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ZaadTextField(
                    hintText: 'auth.password_hint',
                    controller: _passwordController,
                    obscureText: true,
                    passwordToggle: true,
                    autofillHints: const [AutofillHints.password],
                    textInputAction: TextInputAction.done,
                    prefixIcon: Icon(
                      Icons.lock_outline_rounded,
                      color: colors.oliveSoft,
                      size: 20,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: InkWell(
                      onTap: _onForgotPassword,
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 6,
                        ),
                        child: ResponsiveText(
                          'auth.forgot_password',
                          style: AppTextStyles.labelLarge.copyWith(
                            fontSize: 13,
                            letterSpacing: 0,
                            color: colors.olive,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  BlocBuilder<AuthCubit, AuthState>(
                    buildWhen: (previous, current) =>
                        previous.isLoading != current.isLoading,
                    builder: (context, state) => AuthPrimaryButton(
                      label: 'auth.login_screen.sign_in',
                      loading: state.isLoading,
                      enabled: _allFilled,
                      onTap: _onSignIn,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const AuthOrDivider(label: 'auth.or_continue'),
                  const SizedBox(height: 16),
                  BlocBuilder<AuthCubit, AuthState>(
                    buildWhen: (previous, current) =>
                        previous.isSocialLoading != current.isSocialLoading,
                    builder: (context, state) => AuthGoogleButton(
                      label: 'auth.continue_google',
                      loading: state.isSocialLoading,
                      onTap: _onGoogle,
                    ),
                  ),
                  const SizedBox(height: 24),
                  AuthPromptLink(
                    prompt: 'auth.login_screen.new_prompt',
                    action: 'auth.login_screen.create_account',
                    onTap: _onGoToSignUp,
                  ),
                ],
              ),
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
              TextSpan(text: 'auth.login_screen.welcome_prefix'.tr()),
              TextSpan(
                text: 'auth.login_screen.welcome_accent'.tr(),
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
          constraints: const BoxConstraints(maxWidth: 280),
          child: ResponsiveText(
            'auth.login_screen.subtitle',
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
