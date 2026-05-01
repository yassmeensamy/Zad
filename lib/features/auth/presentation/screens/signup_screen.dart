import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/navigation/app_routes.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../../../../theme/theme.dart';
import '../../../splash/widgets/desert_background.dart';
import '../../../splash/widgets/zaad_brand.dart';
import '../../../splash/widgets/zaad_logo_mark.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import '../widgets/auth_google_button.dart';
import '../widgets/auth_or_divider.dart';
import '../widgets/auth_primary_button.dart';
import '../widgets/auth_prompt_link.dart';
import '../widgets/signup_success_dialog.dart';
import '../widgets/zaad_text_field.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _awaitingSignupResult = false;
  bool _successShown = false;
  bool _allFilled = false;

  @override
  void initState() {
    super.initState();
    _usernameController.addListener(_recomputeFilled);
    _emailController.addListener(_recomputeFilled);
    _passwordController.addListener(_recomputeFilled);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _recomputeFilled() {
    final filled = _usernameController.text.trim().isNotEmpty &&
        _emailController.text.trim().isNotEmpty &&
        _passwordController.text.isNotEmpty;
    if (filled != _allFilled) {
      setState(() => _allFilled = filled);
    }
  }

  void _onCreateAccount() {
    _awaitingSignupResult = true;
    context.read<AuthCubit>().signup(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      fullName: _usernameController.text.trim(),
    );
  }

  void _onGoogle() {
    context.read<AuthCubit>().loginWithGoogle();
  }

  void _onGoToLogin() {
    context.go(AppRoutes.login);
  }

  void _onAuthStateChanged(BuildContext context, AuthState state) {
    if (state.isLoggedIn) {
      if (_awaitingSignupResult && !_successShown) {
        _awaitingSignupResult = false;
        _successShown = true;
        SignupSuccessDialog.show(
          context,
          onContinue: () {
            Navigator.of(context, rootNavigator: true).pop();
            context.go(AppRoutes.roleSelect);
          },
        );
        return;
      }
      context.go(AppRoutes.roleSelect);
      return;
    }
    if (state.isError) {
      _awaitingSignupResult = false;
      if (state.errorMessage != null) {
        SnackBarHelper.showError(context, message: state.errorMessage!);
      }
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
              physics: const ClampingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(32, 24, 32, 32),
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  const ZaadLogoMark(size: 84),
                  const SizedBox(height: 22),
                  const ZaadBrand.compact(),
                  const SizedBox(height: 24),
                  const _Headline(),
                  const SizedBox(height: 22),
                  ZaadTextField(
                    hintText: 'auth.signup_screen.username_hint',
                    controller: _usernameController,
                    keyboardType: TextInputType.text,
                    autofillHints: const [AutofillHints.newUsername],
                    textInputAction: TextInputAction.next,
                    prefixIcon: Icon(
                      Icons.person_outline_rounded,
                      color: colors.oliveSoft,
                      size: 20,
                    ),
                  ),
                  const SizedBox(height: 12),
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
                    autofillHints: const [AutofillHints.newPassword],
                    textInputAction: TextInputAction.done,
                    prefixIcon: Icon(
                      Icons.lock_outline_rounded,
                      color: colors.oliveSoft,
                      size: 20,
                    ),
                  ),
                  const SizedBox(height: 16),
                  BlocBuilder<AuthCubit, AuthState>(
                    buildWhen: (previous, current) =>
                        previous.isLoading != current.isLoading,
                    builder: (context, state) => AuthPrimaryButton(
                      label: 'auth.signup_screen.create_account',
                      loading: state.isLoading,
                      enabled: _allFilled,
                      onTap: _onCreateAccount,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const AuthOrDivider(label: 'auth.or_continue'),
                  const SizedBox(height: 12),
                  BlocBuilder<AuthCubit, AuthState>(
                    buildWhen: (previous, current) =>
                        previous.isSocialLoading != current.isSocialLoading,
                    builder: (context, state) => AuthGoogleButton(
                      label: 'auth.continue_google',
                      loading: state.isSocialLoading,
                      onTap: _onGoogle,
                    ),
                  ),
                  const SizedBox(height: 22),
                  AuthPromptLink(
                    prompt: 'auth.signup_screen.have_account_prompt',
                    action: 'auth.signup_screen.sign_in',
                    onTap: _onGoToLogin,
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
    return Text.rich(
      TextSpan(
        style: ZaadType.titleHero.copyWith(
          fontSize: 28,
          color: colors.oliveDeep,
        ),
        children: [
          TextSpan(text: 'auth.signup_screen.headline_prefix'.tr()),
          TextSpan(
            text: 'auth.signup_screen.headline_accent'.tr(),
            style: TextStyle(
              fontSize: 28,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w400,
              color: colors.textArabic,
            ),
          ),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}
