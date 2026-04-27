import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/navigation/app_routes.dart';
import '../../../../core/validation/form_validation.dart';
import '../../../../core/widgets/responsive_text.dart';
import '../../../../theme/theme.dart';
import '../../../splash/widgets/desert_background.dart';
import '../../../splash/widgets/zad_brand.dart';
import '../../../splash/widgets/zad_logo_mark.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import '../widgets/auth_google_button.dart';
import '../widgets/auth_or_divider.dart';
import '../widgets/auth_primary_button.dart';
import '../widgets/auth_prompt_link.dart';
import '../widgets/zad_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _allFilled = false;

  static const _dateSoft = Color(0xFFA8825C);

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
    final filled = _emailController.text.trim().isNotEmpty &&
        _passwordController.text.isNotEmpty;
    if (filled != _allFilled) {
      setState(() => _allFilled = filled);
    }
  }

  void _onSignIn() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
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
        resizeToAvoidBottomInset: true,
        body: DesertBackground(
          child: SafeArea(
            child: SingleChildScrollView(
              physics: ClampingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(32, 24, 32, 32),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    const ZadLogoMark(size: 84),
                    const SizedBox(height: 22),
                    const ZadBrand.compact(dateSoft: _dateSoft),
                    const SizedBox(height: 24),
                    _Headline(dateSoft: _dateSoft),
                    const SizedBox(height: 22),
                    ZadTextField(
                      hintText: 'auth.email_hint',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                      textInputAction: TextInputAction.next,
                      validator: FormValidators.requiredEmail(),
                      prefixIcon: Icon(
                        Icons.mail_outline_rounded,
                        color: colors.oliveSoft,
                        size: 20,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ZadTextField(
                      hintText: '••••••••',
                      controller: _passwordController,
                      obscureText: true,
                      passwordToggle: true,
                      autofillHints: const [AutofillHints.password],
                      textInputAction: TextInputAction.done,
                      validator: FormValidators.requiredPassword(),
                      prefixIcon: Icon(
                        Icons.lock_outline_rounded,
                        color: colors.oliveSoft,
                        size: 20,
                      ),
                    ),
                    const SizedBox(height: 6),
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
                            style: GoogleFonts.inter(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w500,
                              color: colors.olive,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
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
                      prompt: 'auth.login_screen.new_prompt',
                      action: 'auth.login_screen.create_account',
                      dateSoft: _dateSoft,
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
  const _Headline({required this.dateSoft});
  final Color dateSoft;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Column(
      children: [
        Text.rich(
          TextSpan(
            style: GoogleFonts.fraunces(
              fontSize: 30,
              fontWeight: FontWeight.w300,
              height: 1.15,
              letterSpacing: -0.4,
              color: colors.oliveDeep,
            ),
            children: [
              TextSpan(text: 'auth.login_screen.welcome_prefix'.tr()),
              TextSpan(
                text: 'auth.login_screen.welcome_accent'.tr(),
                style: GoogleFonts.fraunces(
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w400,
                  color: colors.textArabic,
                ),
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 280),
          child: ResponsiveText(
            'auth.login_screen.subtitle',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 13,
              height: 1.6,
              color: dateSoft,
            ),
          ),
        ),
      ],
    );
  }
}
