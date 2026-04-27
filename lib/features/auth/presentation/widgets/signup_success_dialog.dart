import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_dialog.dart';
import '../../../../theme/theme.dart';

class SignupSuccessDialog extends StatefulWidget {
  const SignupSuccessDialog({super.key, required this.onContinue});

  final VoidCallback onContinue;

  static Future<void> show(
    BuildContext context, {
    required VoidCallback onContinue,
  }) {
    return CustomDialog.show(
      context: context,
      barrierDismissible: false,
      padding: const EdgeInsets.fromLTRB(28, 32, 28, 26),
      constraints: const BoxConstraints(maxWidth: 380),
      child: SignupSuccessDialog(onContinue: onContinue),
    );
  }

  @override
  State<SignupSuccessDialog> createState() => _SignupSuccessDialogState();
}

class _SignupSuccessDialogState extends State<SignupSuccessDialog>
    with TickerProviderStateMixin {
  // Fires once for the entrance choreography.
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1700),
  );

  // Loops forever for continuous rings + sparkle twinkles.
  late final AnimationController _rings = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  );
  late final AnimationController _sparkles = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3200),
  );

  late final Animation<double> _badgeScale = CurvedAnimation(
    parent: _ctrl,
    curve: const Interval(0.00, 0.32, curve: Curves.easeOutBack),
  );
  late final Animation<double> _check = CurvedAnimation(
    parent: _ctrl,
    curve: const Interval(0.26, 0.55, curve: Curves.easeOutCubic),
  );
  late final Animation<double> _title = CurvedAnimation(
    parent: _ctrl,
    curve: const Interval(0.42, 0.66, curve: Curves.easeOutCubic),
  );
  late final Animation<double> _subtitle = CurvedAnimation(
    parent: _ctrl,
    curve: const Interval(0.52, 0.74, curve: Curves.easeOutCubic),
  );
  late final Animation<double> _ornament = CurvedAnimation(
    parent: _ctrl,
    curve: const Interval(0.60, 0.80, curve: Curves.easeOutCubic),
  );
  late final Animation<double> _cta = CurvedAnimation(
    parent: _ctrl,
    curve: const Interval(0.66, 0.92, curve: Curves.easeOutCubic),
  );

  // Fades the ambient layer in once the badge is on-screen.
  late final Animation<double> _ambientFade = CurvedAnimation(
    parent: _ctrl,
    curve: const Interval(0.30, 0.65, curve: Curves.easeOut),
  );

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 120), () {
      if (!mounted) return;
      _ctrl.forward();
      _rings.repeat();
      _sparkles.repeat();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _rings.dispose();
    _sparkles.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final buttonTheme = Theme.of(context).extension<CustomButtonTheme>()!;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _AnimatedBadge(
          badgeScale: _badgeScale,
          check: _check,
          rings: _rings,
          sparkles: _sparkles,
          ambientFade: _ambientFade,
        ),
        const SizedBox(height: 26),
        _FadeUp(
          animation: _title,
          child: Text.rich(
            TextSpan(
              style: GoogleFonts.fraunces(
                fontSize: 26,
                fontWeight: FontWeight.w300,
                height: 1.15,
                letterSpacing: -0.4,
                color: colors.oliveDeep,
              ),
              children: [
                TextSpan(text: 'auth.signup_success.title_prefix'.tr()),
                TextSpan(
                  text: 'auth.signup_success.title_accent'.tr(),
                  style: GoogleFonts.fraunces(
                    fontSize: 26,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w400,
                    color: colors.textArabic,
                  ),
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 12),
        _FadeUp(
          animation: _subtitle,
          child: Text(
            'auth.signup_success.subtitle'.tr(),
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 14,
              height: 1.5,
              color: colors.textSecondary,
            ),
          ),
        ),
        const SizedBox(height: 22),
        _FadeUp(animation: _ornament, child: const _Ornament()),
        const SizedBox(height: 22),
        _FadeUp(
          animation: _cta,
          child: CustomButton.full(
            text: 'auth.signup_success.cta'.tr(),
            theme: buttonTheme.copyWith(
              useGradient: true,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [colors.olive, colors.oliveDeep],
              ),
              textColor: colors.textInverse,
              textStyle: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.6,
              ),
              height: 54,
              borderRadius: 18,
            ),
            onTap: widget.onContinue,
          ),
        ),
      ],
    );
  }
}

class _FadeUp extends StatelessWidget {
  const _FadeUp({required this.animation, required this.child});

  final Animation<double> animation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (_, child) {
        final t = animation.value;
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, (1 - t) * 14),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

class _AnimatedBadge extends StatelessWidget {
  const _AnimatedBadge({
    required this.badgeScale,
    required this.check,
    required this.rings,
    required this.sparkles,
    required this.ambientFade,
  });

  final Animation<double> badgeScale;
  final Animation<double> check;
  final Animation<double> rings;
  final Animation<double> sparkles;
  final Animation<double> ambientFade;

  static const double _badgeSize = 92;
  static const double _ringMaxExtent = 44;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return SizedBox(
      width: _badgeSize + _ringMaxExtent * 2,
      height: _badgeSize + _ringMaxExtent * 2,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Soft ambient halo behind everything.
          Container(
            width: _badgeSize + 48,
            height: _badgeSize + 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  colors.olive.withValues(alpha: 0.18),
                  colors.olive.withValues(alpha: 0.0),
                ],
                stops: const [0.0, 1.0],
              ),
            ),
          ),

          // Continuous pulse rings emanating outward (loops forever).
          AnimatedBuilder(
            animation: Listenable.merge([rings, ambientFade]),
            builder: (_, _) => Opacity(
              opacity: ambientFade.value,
              child: CustomPaint(
                size: Size.square(_badgeSize + _ringMaxExtent * 2),
                painter: _PulseRingPainter(
                  t: rings.value,
                  baseRadius: _badgeSize / 2,
                  maxRadius: _badgeSize / 2 + _ringMaxExtent,
                  color: colors.olive,
                ),
              ),
            ),
          ),

          // Twinkling sparkle stars around the badge.
          AnimatedBuilder(
            animation: Listenable.merge([sparkles, ambientFade]),
            builder: (_, _) => Opacity(
              opacity: ambientFade.value,
              child: CustomPaint(
                size: Size.square(_badgeSize + _ringMaxExtent * 2),
                painter: _SparklesPainter(
                  t: sparkles.value,
                  orbitRadius: _badgeSize / 2 + 16,
                  color: colors.accent,
                ),
              ),
            ),
          ),

          // Badge with check.
          AnimatedBuilder(
            animation: Listenable.merge([badgeScale, check]),
            builder: (_, _) {
              final s = badgeScale.value;
              return Transform.scale(
                scale: s,
                child: Container(
                  width: _badgeSize,
                  height: _badgeSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [colors.oliveSoft, colors.oliveDeep],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: colors.olive.withValues(alpha: 0.36),
                        blurRadius: 26,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Inner top sheen for depth.
                      Container(
                        margin: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            center: const Alignment(0, -0.55),
                            radius: 0.9,
                            colors: [
                              Colors.white.withValues(alpha: 0.22),
                              Colors.white.withValues(alpha: 0.0),
                            ],
                          ),
                        ),
                      ),
                      // Thin inner border ring for refinement.
                      Container(
                        margin: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: colors.textInverse.withValues(alpha: 0.14),
                            width: 1,
                          ),
                        ),
                      ),
                      // Check stroke.
                      CustomPaint(
                        size: const Size.square(_badgeSize),
                        painter: _CheckPainter(
                          progress: check.value,
                          color: colors.textInverse,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _PulseRingPainter extends CustomPainter {
  _PulseRingPainter({
    required this.t,
    required this.baseRadius,
    required this.maxRadius,
    required this.color,
  });

  final double t; // 0..1, looping
  final double baseRadius;
  final double maxRadius;
  final Color color;

  static const List<double> _phases = [0.0, 0.5];

  void _drawRing(Canvas canvas, Offset center, double localT) {
    final radius = lerpDouble(baseRadius, maxRadius, localT)!;
    // Eased fade: full at start, gone by end.
    final opacity = (1 - localT) * (1 - localT) * 0.55;
    if (opacity <= 0.001) return;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = lerpDouble(1.6, 0.4, localT)!
      ..color = color.withValues(alpha: opacity);
    canvas.drawCircle(center, radius, paint);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    for (final phase in _phases) {
      final localT = (t + phase) % 1.0;
      _drawRing(canvas, center, localT);
    }
  }

  @override
  bool shouldRepaint(_PulseRingPainter old) =>
      old.t != t || old.color != color;
}

class _SparklesPainter extends CustomPainter {
  _SparklesPainter({
    required this.t,
    required this.orbitRadius,
    required this.color,
  });

  final double t; // 0..1, looping
  final double orbitRadius;
  final Color color;

  static const int _count = 6;
  static const double _maxSize = 4.5;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);

    for (int i = 0; i < _count; i++) {
      final angle = (i / _count) * 2 * math.pi - math.pi / 2;
      final phase = i / _count;
      final localT = (t + phase) % 1.0;

      // sin curve gives a smooth fade-in/out twinkle: 0..1..0
      final twinkle = math.sin(localT * math.pi);
      if (twinkle <= 0.05) continue;

      // Tiny radial drift so they breathe outward as they twinkle.
      final drift = math.sin(localT * math.pi * 2) * 3.5;
      final r = orbitRadius + drift;
      final pos = center + Offset(math.cos(angle) * r, math.sin(angle) * r);

      final starSize = _maxSize * twinkle;
      final paint = Paint()
        ..color = color.withValues(alpha: twinkle * 0.85)
        ..style = PaintingStyle.fill;

      _drawFourPointStar(canvas, pos, starSize, paint);
    }
  }

  void _drawFourPointStar(Canvas canvas, Offset c, double r, Paint paint) {
    // Sharp 4-point star (sparkle), points along axes, valleys at 0.3*r.
    const inner = 0.28;
    final path = Path()
      ..moveTo(c.dx, c.dy - r)
      ..lineTo(c.dx + r * inner, c.dy - r * inner)
      ..lineTo(c.dx + r, c.dy)
      ..lineTo(c.dx + r * inner, c.dy + r * inner)
      ..lineTo(c.dx, c.dy + r)
      ..lineTo(c.dx - r * inner, c.dy + r * inner)
      ..lineTo(c.dx - r, c.dy)
      ..lineTo(c.dx - r * inner, c.dy - r * inner)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_SparklesPainter old) =>
      old.t != t || old.color != color || old.orbitRadius != orbitRadius;
}

class _CheckPainter extends CustomPainter {
  _CheckPainter({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = size.width * 0.08;

    final start = Offset(size.width * 0.28, size.height * 0.52);
    final mid = Offset(size.width * 0.45, size.height * 0.66);
    final end = Offset(size.width * 0.72, size.height * 0.40);

    final lenA = (mid - start).distance;
    final lenB = (end - mid).distance;
    final total = lenA + lenB;
    final drawn = total * progress;

    final path = Path()..moveTo(start.dx, start.dy);
    if (drawn <= lenA) {
      final p = drawn / lenA;
      final point = Offset.lerp(start, mid, p)!;
      path.lineTo(point.dx, point.dy);
    } else {
      path.lineTo(mid.dx, mid.dy);
      final p = ((drawn - lenA) / lenB).clamp(0.0, 1.0);
      final point = Offset.lerp(mid, end, p)!;
      path.lineTo(point.dx, point.dy);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_CheckPainter old) =>
      old.progress != progress || old.color != color;
}

class _Ornament extends StatelessWidget {
  const _Ornament();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final lineColor = colors.accent.withValues(alpha: 0.55);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 36,
          height: 1,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.transparent, lineColor],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Transform.rotate(
          angle: math.pi / 4,
          child: Container(
            width: 5,
            height: 5,
            color: colors.accent,
          ),
        ),
        const SizedBox(width: 10),
        Container(
          width: 36,
          height: 1,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [lineColor, Colors.transparent],
            ),
          ),
        ),
      ],
    );
  }
}
