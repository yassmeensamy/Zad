import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_images.dart';
import '../../../../core/navigation/app_routes.dart';
import '../../../../core/widgets/responsive_text.dart';
import '../../../../theme/theme.dart';
import '../../../splash/widgets/desert_background.dart';
import '../../../splash/widgets/zad_brand.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
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
                            hintText: 'username',
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
                            hintText: 'you@example.com',
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
                      builder: (context, state) => _PrimaryButton(
                        label: 'CREATE ACCOUNT',
                        loading: state.isLoading,
                        onTap: _onCreateAccount,
                      ),
                    ),
                    const SizedBox(height: 14),
                    const _OrDivider(),
                    const SizedBox(height: 10),
                    BlocBuilder<AuthCubit, AuthState>(
                      buildWhen: (previous, current) =>
                          previous.isSocialLoading != current.isSocialLoading,
                      builder: (context, state) => _GoogleButton(
                        loading: state.isSocialLoading,
                        onTap: _onGoogle,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _LoginPrompt(
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
          const TextSpan(text: 'Begin your '),
          TextSpan(
            text: 'journey',
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

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.label,
    required this.onTap,
    this.loading = false,
  });
  final String label;
  final VoidCallback onTap;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [0.0, 0.55, 1.0],
            colors: [
              colors.accentSoft,
              const Color(0xFFD2963F),
              colors.accent,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: colors.accent.withValues(alpha: 0.18),
              blurRadius: 22,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: loading ? null : onTap,
            child: Center(
              child: loading
                  ? SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(colors.canvas),
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ResponsiveText(
                          label,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 14 * 0.14,
                            color: colors.canvas,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 18,
                          color: colors.canvas,
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

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final lineColor = colors.textArabic.withValues(alpha: 0.14);
    return Row(
      children: [
        Expanded(child: Container(height: 1, color: lineColor)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Opacity(
            opacity: 0.65,
            child: ResponsiveText(
              'OR CONTINUE WITH',
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                letterSpacing: 10 * 0.3,
                color: colors.textArabic,
              ),
            ),
          ),
        ),
        Expanded(child: Container(height: 1, color: lineColor)),
      ],
    );
  }
}

class _GoogleButton extends StatelessWidget {
  const _GoogleButton({required this.onTap, this.loading = false});
  final VoidCallback onTap;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.canvas.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: colors.textArabic.withValues(alpha: 0.14)),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: loading ? null : onTap,
            child: Center(
              child: loading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(colors.textArabic),
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const _GoogleGlyph(size: 20),
                        const SizedBox(width: 10),
                        ResponsiveText(
                          'Continue with Google',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: colors.textArabic,
                          ),
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

class _LoginPrompt extends StatelessWidget {
  const _LoginPrompt({required this.dateSoft, required this.onTap});
  final Color dateSoft;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Text.rich(
          TextSpan(
            style: GoogleFonts.inter(
              fontSize: 13,
              height: 1.4,
              color: dateSoft,
            ),
            children: [
              const TextSpan(text: 'Already have an account?  '),
              TextSpan(
                text: 'Sign in',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: colors.accent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GoogleGlyph extends StatelessWidget {
  const _GoogleGlyph({required this.size});
  final double size;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      AppImages.googleLogo,
      width: size,
      height: size,
      fit: BoxFit.contain,
    );
  }
}
