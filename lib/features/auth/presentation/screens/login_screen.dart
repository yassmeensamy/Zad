import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/navigation/app_routes.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../../../../core/widgets/responsive_text.dart';
import '../../../../theme/theme.dart';
import '../../../splash/widgets/desert_background.dart';
import '../../../splash/widgets/zaad_brand.dart';
import '../../../user/presentation/cubit/user_cubit.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import '../widgets/auth_apple_button.dart';
import '../widgets/auth_google_button.dart';
import '../widgets/auth_guest_button.dart';
import '../widgets/auth_language_button.dart';
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

  void _onApple() {
    context.read<AuthCubit>().loginWithApple();
  }

  void _onContinueAsGuest() {
    final isAlreadyGuest =
        context.read<UserCubit>().state.user?.isAnonymous ?? false;
    if (isAlreadyGuest) {
      context.goNamed(AppRoutes.homeName);
      return;
    }
    context.read<AuthCubit>().continueAsGuest();
  }

  void _onGoToSignUp() {
    context.go(AppRoutes.signup);
  }

  void _onForgotPassword() {
    context.push(AppRoutes.forgotPassword);
  }

  bool _shouldHandle(AuthState prev, AuthState curr) =>
      (!prev.isGuestSuccess && curr.isGuestSuccess) ||
      (!prev.isLoggedIn && curr.isLoggedIn) ||
      (!prev.isError && curr.isError) ||
      (!prev.isGuestError && curr.isGuestError);

  void _onAuthStateChanged(BuildContext context, AuthState state) {
    if (state.isGuestSuccess) {
      context.goNamed(AppRoutes.homeName);
      return;
    }
    if (state.isLoggedIn) {
      // Routing is owned by the auth guard, which waits for /me to resolve:
      // incomplete profiles go to role-select, complete ones straight to home.
      return;
    }
    if ((state.isError || state.isGuestError) && state.errorMessage != null) {
      SnackBarHelper.showError(context, message: state.errorMessage!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    // Status-bar overlay & dark-mode canvas are owned by DesertBackground.
    return BlocListener<AuthCubit, AuthState>(
      listenWhen: _shouldHandle,
      listener: _onAuthStateChanged,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: DesertBackground(
          // `bottom: false` keeps the scroll viewport running to the screen
          // edge; the home-indicator inset is folded into the scroll padding so
          // content scrolls through it instead of stopping above a dead strip.
          child: SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                32,
                24,
                32,
                32 + MediaQuery.paddingOf(context).bottom,
              ),
              child: Column(
                children: [
                  const Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: AuthLanguageButton(),
                  ),
                  const SizedBox(height: 12),
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
                  if (Platform.isIOS) ...[
                    const SizedBox(height: 12),
                    BlocBuilder<AuthCubit, AuthState>(
                      buildWhen: (previous, current) =>
                          previous.isSocialLoading != current.isSocialLoading,
                      builder: (context, state) => AuthAppleButton(
                        label: 'auth.continue_apple',
                        loading: state.isSocialLoading,
                        onTap: _onApple,
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  BlocBuilder<AuthCubit, AuthState>(
                    buildWhen: (previous, current) =>
                        previous.isGuestLoading != current.isGuestLoading,
                    builder: (context, state) => AuthGuestButton(
                      loading: state.isGuestLoading,
                      onTap: _onContinueAsGuest,
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
