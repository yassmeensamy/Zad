import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/navigation/app_routes.dart';
import '../../../../core/widgets/responsive_text.dart';
import '../../../../theme/theme.dart';
import '../../../splash/widgets/desert_background.dart';
import '../../../splash/widgets/zad_brand.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import '../widgets/auth_google_button.dart';
import '../widgets/auth_or_divider.dart';
import '../widgets/auth_primary_button.dart';
import '../widgets/auth_prompt_link.dart';
import '../widgets/zad_text_field.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  static const _dateSoft = Color(0xFFA8825C);
  static const _fieldGap = 10.0;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onCreateAccount() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
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
      context.go(AppRoutes.home);
      return;
    }
    if (state.isError && state.errorMessage != null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: ResponsiveText(state.errorMessage!)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return BlocListener<AuthCubit, AuthState>(
      listener: _onAuthStateChanged,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: DesertBackground(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(32, 16, 32, 16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const ZadBrand(),
                    const SizedBox(height: 18),
                    const _Headline(),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ZadTextField(
                            hintText: 'auth.signup_screen.username_hint',
                            controller: _usernameController,
                            keyboardType: TextInputType.text,
                            autofillHints: const [AutofillHints.newUsername],
                            textInputAction: TextInputAction.next,
                            prefixIcon: Icon(
                              Icons.person_outline_rounded,
                              color: colors.textArabic.withValues(alpha: 0.55),
                              size: 20,
                            ),
                          ),
                          const SizedBox(height: _fieldGap),
                          ZadTextField(
                            hintText: 'auth.email_hint',
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            autofillHints: const [AutofillHints.email],
                            textInputAction: TextInputAction.next,
                            prefixIcon: Icon(
                              Icons.mail_outline_rounded,
                              color: colors.textArabic.withValues(alpha: 0.55),
                              size: 20,
                            ),
                          ),
                          const SizedBox(height: _fieldGap),
                          ZadTextField(
                            hintText: '••••••••',
                            controller: _passwordController,
                            obscureText: true,
                            passwordToggle: true,
                            autofillHints: const [AutofillHints.newPassword],
                            textInputAction: TextInputAction.done,
                            prefixIcon: Icon(
                              Icons.lock_outline_rounded,
                              color: colors.textArabic.withValues(alpha: 0.55),
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                    BlocBuilder<AuthCubit, AuthState>(
                      buildWhen: (previous, current) =>
                          previous.isLoading != current.isLoading,
                      builder: (context, state) => AuthPrimaryButton(
                        label: 'auth.signup_screen.create_account',
                        loading: state.isLoading,
                        onTap: _onCreateAccount,
                      ),
                    ),
                    const SizedBox(height: 14),
                    const AuthOrDivider(label: 'auth.or_continue'),
                    const SizedBox(height: 10),
                    BlocBuilder<AuthCubit, AuthState>(
                      buildWhen: (previous, current) =>
                          previous.isSocialLoading != current.isSocialLoading,
                      builder: (context, state) => AuthGoogleButton(
                        label: 'auth.continue_google',
                        loading: state.isSocialLoading,
                        onTap: _onGoogle,
                      ),
                    ),
                    const SizedBox(height: 8),
                    AuthPromptLink(
                      prompt: 'auth.signup_screen.have_account_prompt',
                      action: 'auth.signup_screen.sign_in',
                      dateSoft: _dateSoft,
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
        style: GoogleFonts.fraunces(
          fontSize: 26,
          fontWeight: FontWeight.w300,
          height: 1.15,
          letterSpacing: -0.14,
          color: colors.textArabic,
        ),
        children: [
          TextSpan(text: 'auth.signup_screen.headline_prefix'.tr()),
          TextSpan(
            text: 'auth.signup_screen.headline_accent'.tr(),
            style: GoogleFonts.fraunces(
              fontSize: 26,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w400,
              color: colors.accent,
            ),
          ),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}
