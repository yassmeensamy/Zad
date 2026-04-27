import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/navigation/app_routes.dart';
import '../../../../core/widgets/responsive_text.dart';
import '../../../../theme/theme.dart';
import '../../../splash/widgets/desert_background.dart';
import '../../../splash/widgets/zad_brand.dart';
import '../../../splash/widgets/zad_logo_mark.dart';
import '../widgets/zad_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController(text: '••••••••');

  static const _dateSoft = Color(0xFFA8825C);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onSignIn() {
    _formKey.currentState?.validate();
    context.go(AppRoutes.home);
  }

  void _onGoogle() {
    context.go(AppRoutes.home);
  }

  void _onGoToSignUp() {
    context.go(AppRoutes.signup);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: DesertBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(32, 24, 32, 32),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  const ZadLogoMark(size: 84),
                  const SizedBox(height: 22),
                  const ZadBrand(
                    wordSize: 52,
                    arabicSize: 24,
                    tagSize: 10,
                    ruleWidth: 28,
                    gap: 10,
                    ruleGap: 18,
                    tagGap: 14,
                    dateSoft: _dateSoft,
                  ),
                  const SizedBox(height: 24),
                  _Headline(dateSoft: _dateSoft),
                  const SizedBox(height: 22),
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
                  const SizedBox(height: 12),
                  ZadTextField(
                    hintText: '••••••••',
                    controller: _passwordController,
                    obscureText: true,
                    passwordToggle: true,
                    autofillHints: const [AutofillHints.password],
                    textInputAction: TextInputAction.done,
                    prefixIcon: Icon(
                      Icons.lock_outline_rounded,
                      color: colors.textArabic.withValues(alpha: 0.55),
                      size: 20,
                    ),
                  ),
                  const SizedBox(height: 18),
                  _SignInButton(onTap: _onSignIn),
                  const SizedBox(height: 20),
                  const _OrDivider(),
                  const SizedBox(height: 12),
                  _GoogleButton(onTap: _onGoogle),
                  const SizedBox(height: 22),
                  _SignUpPrompt(
                    dateSoft: _dateSoft,
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
              fontSize: 28,
              fontWeight: FontWeight.w300,
              height: 1.15,
              letterSpacing: -0.14,
              color: colors.textArabic,
            ),
            children: [
              const TextSpan(text: 'Welcome '),
              TextSpan(
                text: 'home',
                style: GoogleFonts.fraunces(
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w400,
                  color: colors.accent,
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
            'Sign in to continue your daily practice.',
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

class _SignInButton extends StatelessWidget {
  const _SignInButton({required this.onTap});
  final VoidCallback onTap;

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
            onTap: onTap,
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ResponsiveText(
                    'SIGN IN',
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
  const _GoogleButton({required this.onTap});
  final VoidCallback onTap;

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
            onTap: onTap,
            child: Center(
              child: Row(
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

class _SignUpPrompt extends StatelessWidget {
  const _SignUpPrompt({required this.dateSoft, required this.onTap});
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
              const TextSpan(text: "New to Zad?  "),
              TextSpan(
                text: 'Create an account',
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
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _GooglePainter()),
    );
  }
}

class _GooglePainter extends CustomPainter {
  // Brand colours from the design SVG.
  static const _blue = Color(0xFF4285F4);
  static const _green = Color(0xFF34A853);
  static const _yellow = Color(0xFFFBBC05);
  static const _red = Color(0xFFEA4335);

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 24;
    canvas.scale(scale);

    void drawPath(String _, Color color, Path path) {
      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;
      canvas.drawPath(path, paint);
    }

    final blue = Path()
      ..moveTo(21.6, 12.2)
      ..cubicTo(21.6, 11.52, 21.54, 10.86, 21.43, 10.23)
      ..lineTo(12, 10.23)
      ..lineTo(12, 13.96)
      ..lineTo(17.4, 13.96)
      ..cubicTo(17.16, 15.21, 16.45, 16.27, 15.4, 16.99)
      ..lineTo(15.4, 19.51)
      ..lineTo(18.63, 19.51)
      ..cubicTo(20.53, 17.76, 21.6, 15.19, 21.6, 12.2)
      ..close();
    drawPath('blue', _blue, blue);

    final green = Path()
      ..moveTo(12, 22)
      ..cubicTo(14.7, 22, 16.96, 21.1, 18.62, 19.57)
      ..lineTo(15.39, 17.05)
      ..cubicTo(14.49, 17.65, 13.35, 18, 12, 18)
      ..cubicTo(9.4, 18, 7.19, 16.24, 6.4, 13.87)
      ..lineTo(3.07, 16.47)
      ..cubicTo(4.72, 19.78, 8.09, 22, 12, 22)
      ..close();
    drawPath('green', _green, green);

    final yellow = Path()
      ..moveTo(6.4, 13.87)
      ..cubicTo(6.2, 13.27, 6.09, 12.64, 6.09, 12)
      ..cubicTo(6.09, 11.36, 6.2, 10.73, 6.4, 10.13)
      ..lineTo(6.4, 7.53)
      ..lineTo(3.07, 7.53)
      ..cubicTo(2.39, 8.88, 2, 10.4, 2, 12)
      ..cubicTo(2, 13.6, 2.39, 15.12, 3.07, 16.47)
      ..lineTo(6.4, 13.87)
      ..close();
    drawPath('yellow', _yellow, yellow);

    final red = Path()
      ..moveTo(12, 5.94)
      ..cubicTo(13.47, 5.92, 14.88, 6.47, 15.95, 7.48)
      ..lineTo(18.81, 4.62)
      ..cubicTo(16.96, 2.92, 14.55, 2, 12, 2)
      ..cubicTo(8.09, 2, 4.72, 4.22, 3.07, 7.53)
      ..lineTo(6.4, 10.13)
      ..cubicTo(7.18, 7.76, 9.4, 6, 12, 5.94)
      ..close();
    drawPath('red', _red, red);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
