part of '../celebration_overlay.dart';

// ===========================================================================
// Stardust variant pieces
// ===========================================================================

class _AuroraHalo extends StatelessWidget {
  const _AuroraHalo({
    required this.animation,
    required this.inner,
    required this.outer,
  });

  final Animation<double> animation;
  final Color inner;
  final Color outer;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final t = animation.value;
        final fadeIn = Curves.easeOutCubic.transform(_interval(t, 0.0, 0.32));
        final fadeOut = 1 - _interval(t, 0.72, 1.0);
        final opacity = fadeIn * fadeOut;
        if (opacity <= 0.001) return const SizedBox.shrink();
        final breathe = sin(_interval(t, 0.0, 1.0) * pi) * 0.06;
        final size = 270 + breathe * 24;
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                inner.withValues(alpha: 0.24 * opacity),
                outer.withValues(alpha: 0.10 * opacity),
                inner.withValues(alpha: 0.0),
              ],
              stops: const [0.0, 0.55, 1.0],
            ),
          ),
        );
      },
    );
  }
}

class _GeometricOrnament extends StatelessWidget {
  const _GeometricOrnament({
    required this.animation,
    required this.accent,
    required this.spinBias,
  });

  final Animation<double> animation;
  final Color accent;
  final double spinBias;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final t = animation.value;
        final appear = Curves.easeOutCubic.transform(_interval(t, 0.04, 0.40));
        final fadeOut = 1 - _interval(t, 0.70, 1.0);
        final opacity = appear * fadeOut * 0.55;
        if (opacity <= 0.001) return const SizedBox.shrink();
        final scale = 0.6 + appear * 0.4;
        final angle = (t * 0.6 + spinBias) * 2 * pi * 0.18;

        return Transform.rotate(
          angle: angle,
          child: Transform.scale(
            scale: scale,
            child: CustomPaint(
              size: const Size(168, 168),
              painter: _OrnamentPainter(color: accent, opacity: opacity),
            ),
          ),
        );
      },
    );
  }
}

class _OrnamentPainter extends CustomPainter {
  _OrnamentPainter({required this.color, required this.opacity});

  final Color color;
  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1
      ..strokeJoin = StrokeJoin.round;

    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2 - 4;

    // 8-point star: two squares rotated 45° from each other.
    for (var sq = 0; sq < 2; sq++) {
      final baseAngle = sq * pi / 4 - pi / 4;
      final path = Path();
      for (var i = 0; i < 4; i++) {
        final a = baseAngle + i * pi / 2;
        final x = cx + cos(a) * r;
        final y = cy + sin(a) * r;
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      path.close();
      canvas.drawPath(path, paint);
    }

    // Inner circle.
    canvas.drawCircle(Offset(cx, cy), r * 0.46, paint);

    // Tiny corner dots between the star tips.
    final dotPaint = Paint()
      ..color = color.withValues(alpha: opacity * 1.4)
      ..style = PaintingStyle.fill;
    for (var i = 0; i < 8; i++) {
      final a = i * pi / 4;
      final x = cx + cos(a) * r * 0.72;
      final y = cy + sin(a) * r * 0.72;
      canvas.drawCircle(Offset(x, y), 1.4, dotPaint);
    }
  }

  @override
  bool shouldRepaint(_OrnamentPainter old) =>
      old.color != color || old.opacity != opacity;
}

class _LightRays extends StatelessWidget {
  const _LightRays({required this.animation, required this.accent});

  final Animation<double> animation;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final t = animation.value;
        final progress = _interval(t, 0.04, 0.58);
        if (progress <= 0 || progress >= 1) return const SizedBox.shrink();
        return CustomPaint(
          size: const Size(220, 220),
          painter: _RaysPainter(color: accent, progress: progress),
        );
      },
    );
  }
}

class _RaysPainter extends CustomPainter {
  _RaysPainter({required this.color, required this.progress});

  final Color color;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final maxR = size.width / 2;
    final innerR = 30.0;
    final eased = Curves.easeOutCubic.transform(progress);
    final outerR = innerR + (maxR - innerR) * eased;
    final fade = (1 - progress).clamp(0.0, 1.0);
    final opacity = fade * 0.55;

    final paint = Paint()
      ..color = color.withValues(alpha: opacity)
      ..style = PaintingStyle.fill;

    const rays = 12;
    const innerHalfArc = 0.045;
    const outerHalfArc = 0.012;
    for (var i = 0; i < rays; i++) {
      final a = i * (2 * pi / rays);
      final p1 = Offset(
        cx + cos(a - innerHalfArc) * innerR,
        cy + sin(a - innerHalfArc) * innerR,
      );
      final p2 = Offset(
        cx + cos(a + innerHalfArc) * innerR,
        cy + sin(a + innerHalfArc) * innerR,
      );
      final p3 = Offset(
        cx + cos(a + outerHalfArc) * outerR,
        cy + sin(a + outerHalfArc) * outerR,
      );
      final p4 = Offset(
        cx + cos(a - outerHalfArc) * outerR,
        cy + sin(a - outerHalfArc) * outerR,
      );
      final path = Path()
        ..moveTo(p1.dx, p1.dy)
        ..lineTo(p2.dx, p2.dy)
        ..lineTo(p3.dx, p3.dy)
        ..lineTo(p4.dx, p4.dy)
        ..close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_RaysPainter old) =>
      old.color != color || old.progress != progress;
}

class _PulseRing extends StatelessWidget {
  const _PulseRing({
    required this.animation,
    required this.startDelay,
    required this.accent,
  });

  final Animation<double> animation;
  final double startDelay;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final t = animation.value;
        final progress = ((t - startDelay) / 0.55).clamp(0.0, 1.0);
        if (progress <= 0 || progress >= 1) return const SizedBox.shrink();
        final eased = Curves.easeOutCubic.transform(progress);
        final size = 70 + eased * 138;
        final opacity = (1 - progress) * 0.6;
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: accent.withValues(alpha: opacity),
              width: 1.2,
            ),
          ),
        );
      },
    );
  }
}

class _SparkleView extends StatelessWidget {
  const _SparkleView({
    required this.animation,
    required this.sparkle,
    required this.warm,
    required this.cool,
    required this.warmSoft,
  });

  final Animation<double> animation;
  final _Sparkle sparkle;
  final Color warm;
  final Color cool;
  final Color warmSoft;

  IconData _icon() {
    switch (sparkle.kind) {
      case _SparkleKind.star:
        return Icons.star_rounded;
      case _SparkleKind.dot:
        return Icons.circle;
      case _SparkleKind.crescent:
        return Icons.nightlight_round;
      case _SparkleKind.twinkle:
        return Icons.auto_awesome_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final progress = animation.value;
        final adjusted =
            ((progress - sparkle.delay) / (1 - sparkle.delay)).clamp(0.0, 1.0);
        if (adjusted <= 0) return const SizedBox.shrink();
        final eased = Curves.easeOutCubic.transform(adjusted);
        final dx = cos(sparkle.angle) * sparkle.distance * eased;
        final dy = sin(sparkle.angle) * sparkle.distance * eased - 18 * eased;
        final twinkle = 0.85 + sin(adjusted * pi * 3) * 0.15;
        final fade = adjusted < 0.6 ? 1.0 : ((1 - adjusted) / 0.4).clamp(0.0, 1.0);
        final scale = (0.4 + 0.7 * eased) * twinkle;

        final color = sparkle.warm
            ? (sparkle.kind == _SparkleKind.dot ? warmSoft : warm)
            : cool;

        return Transform.translate(
          offset: Offset(dx, dy),
          child: Transform.rotate(
            angle: sparkle.rotation * eased,
            child: Transform.scale(
              scale: scale,
              child: Icon(
                _icon(),
                size: sparkle.size,
                color: color.withValues(alpha: fade),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ConfettiView extends StatelessWidget {
  const _ConfettiView({
    required this.animation,
    required this.confetti,
    required this.tones,
  });

  final Animation<double> animation;
  final _Confetti confetti;
  final List<Color> tones;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final progress = animation.value;
        final adjusted =
            ((progress - confetti.delay) / (1 - confetti.delay)).clamp(0.0, 1.0);
        if (adjusted <= 0) return const SizedBox.shrink();

        // Burst out first, then drift down.
        final burstEased = Curves.easeOutCubic.transform(
          (adjusted / 0.35).clamp(0.0, 1.0),
        );
        final burstX = cos(confetti.startAngle) * confetti.startRadius * burstEased;
        final burstY = sin(confetti.startAngle) * confetti.startRadius * burstEased;

        final fallProgress = ((adjusted - 0.30) / 0.70).clamp(0.0, 1.0);
        final fallEased = Curves.easeInCubic.transform(fallProgress);
        final fallY = confetti.fall * fallEased;
        final swayX = sin(fallEased * pi * 2.2) * confetti.sway;

        final dx = burstX + swayX;
        final dy = burstY + fallY;

        final fadeIn = (adjusted / 0.18).clamp(0.0, 1.0);
        final fadeOut = adjusted < 0.78 ? 1.0 : ((1 - adjusted) / 0.22).clamp(0.0, 1.0);
        final opacity = fadeIn * fadeOut;

        return Transform.translate(
          offset: Offset(dx, dy),
          child: Transform.rotate(
            angle: confetti.rotation * adjusted,
            child: Container(
              width: confetti.size,
              height: confetti.size * 0.42,
              decoration: BoxDecoration(
                color: tones[confetti.tone % tones.length]
                    .withValues(alpha: opacity),
                borderRadius: BorderRadius.circular(confetti.size * 0.2),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _HeroBadge extends StatelessWidget {
  const _HeroBadge({
    required this.animation,
    required this.isCorrect,
    required this.accent,
    required this.accentSoft,
    required this.canvas,
  });

  final Animation<double> animation;
  final bool isCorrect;
  final Color accent;
  final Color accentSoft;
  final Color canvas;

  @override
  Widget build(BuildContext context) {
    final badgeSize = isCorrect ? 60.0 : 64.0;
    final iconSize = isCorrect ? 30.0 : 34.0;

    final badge = Container(
      width: badgeSize,
      height: badgeSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [accent, accent, accentSoft],
          stops: const [0.0, 0.55, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.45),
            blurRadius: 24,
            spreadRadius: 1.5,
          ),
          BoxShadow(
            color: accent.withValues(alpha: 0.20),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(
        isCorrect ? Icons.check_rounded : Icons.close_rounded,
        color: canvas,
        size: iconSize,
      ),
    );

    return AnimatedBuilder(
      animation: animation,
      child: badge,
      builder: (context, child) {
        final t = animation.value;
        final scaleIn = Curves.easeOutBack.transform(_interval(t, 0.0, 0.36));
        final settle = isCorrect
            ? sin(_interval(t, 0.36, 0.78) * pi) * 0.07
            : 0.0;
        final shakeT = isCorrect ? 0.0 : _interval(t, 0.28, 0.62);
        final shake = sin(shakeT * pi * 4) * (1 - shakeT) * 6;
        final bob = isCorrect
            ? sin(_interval(t, 0.40, 0.95) * pi * 2) * 2
            : 0.0;

        return Transform.translate(
          offset: Offset(shake, -bob),
          child: Transform.scale(
            scale: scaleIn + settle,
            child: child,
          ),
        );
      },
    );
  }
}

class _StardustMessage extends StatelessWidget {
  const _StardustMessage({
    required this.animation,
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.warm,
    required this.titleColor,
    required this.subtitleColor,
    required this.canvas,
    required this.isCorrect,
  });

  final Animation<double> animation;
  final String title;
  final String? subtitle;
  final Color accent;
  final Color warm;
  final Color titleColor;
  final Color subtitleColor;
  final Color canvas;
  final bool isCorrect;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final t = animation.value;
        final titleEased =
            Curves.easeOutCubic.transform(_interval(t, 0.16, 0.42));
        final titlePop =
            Curves.easeOutBack.transform(_interval(t, 0.16, 0.46));
        final shimmerT = _interval(t, 0.32, 0.78);
        final ornamentT =
            Curves.easeOutCubic.transform(_interval(t, 0.34, 0.62));
        final subEased =
            Curves.easeOutCubic.transform(_interval(t, 0.42, 0.66));

        // Text glow plate gently fades in to lift letters off the busy backdrop.
        final plateProgress =
            Curves.easeOutCubic.transform(_interval(t, 0.14, 0.40));

        return Stack(
          alignment: Alignment.topCenter,
          children: [
            // Soft luminous plate behind the text.
            _TextGlowPlate(progress: plateProgress, canvas: canvas),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _FadeSlideUp(
                  progress: titleEased,
                  slide: 14,
                  child: Transform.scale(
                    scale: 0.88 + 0.12 * titlePop,
                    child: _ShimmerText(
                      text: title,
                      progress: isCorrect ? shimmerT : 0.0,
                      baseColor: titleColor,
                      shimmerColor: warm,
                      style: AppTextStyles.titleLarge.copyWith(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        height: 1.15,
                        letterSpacing: 0.4,
                        color: titleColor,
                        shadows: [
                          Shadow(
                            color: canvas.withValues(alpha: 0.65),
                            blurRadius: 10,
                          ),
                          Shadow(
                            color: warm.withValues(alpha: 0.25),
                            blurRadius: 18,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _OrnamentDivider(progress: ornamentT, color: accent, warm: warm),
                if (subtitle != null && subtitle!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _FadeSlideUp(
                    progress: subEased,
                    slide: 10,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      child: ResponsiveText(
                        subtitle,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                          height: 1.45,
                          letterSpacing: 0.15,
                          color: subtitleColor,
                          shadows: [
                            Shadow(
                              color: canvas.withValues(alpha: 0.6),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        );
      },
    );
  }
}

class _OrnamentDivider extends StatelessWidget {
  const _OrnamentDivider({
    required this.progress,
    required this.color,
    required this.warm,
  });

  final double progress;
  final Color color;
  final Color warm;

  @override
  Widget build(BuildContext context) {
    if (progress <= 0.01) return const SizedBox(height: 6);
    final lineWidth = 56.0 * progress;
    final dotScale = progress;
    final opacity = progress.clamp(0.0, 1.0);

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Transform.scale(
          scale: dotScale,
          child: Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: warm.withValues(alpha: opacity * 0.85),
            ),
          ),
        ),
        const SizedBox(width: 6),
        Container(
          width: lineWidth,
          height: 1.5,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            gradient: LinearGradient(
              colors: [
                color.withValues(alpha: 0.0),
                color.withValues(alpha: 0.85 * opacity),
                warm.withValues(alpha: 0.85 * opacity),
                color.withValues(alpha: 0.0),
              ],
              stops: const [0.0, 0.4, 0.6, 1.0],
            ),
          ),
        ),
        const SizedBox(width: 6),
        Transform.scale(
          scale: dotScale,
          child: Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: warm.withValues(alpha: opacity * 0.85),
            ),
          ),
        ),
      ],
    );
  }
}
