import 'dart:math';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:my_app/core/widgets/responsive_text.dart';
import '../../../../theme/theme.dart';

double _interval(double t, double start, double end) =>
    ((t - start) / (end - start)).clamp(0.0, 1.0);

enum CelebrationStyle { bloom, stardust, random }

class CelebrationOverlay extends StatefulWidget {
  const CelebrationOverlay({
    super.key,
    required this.trigger,
    required this.isCorrect,
    this.messageKey,
    this.style = CelebrationStyle.random,
  });

  final int trigger;
  final bool isCorrect;
  final String? messageKey;

  /// When [CelebrationStyle.random], one of bloom/stardust is picked
  /// deterministically from [trigger] so the same question always shows
  /// the same variant.
  final CelebrationStyle style;

  @override
  State<CelebrationOverlay> createState() => _CelebrationOverlayState();
}

class _CelebrationOverlayState extends State<CelebrationOverlay>
    with SingleTickerProviderStateMixin {
  static const List<String> _correctTitleKeys = [
    'quiz.feedback.correct_title_1',
    'quiz.feedback.correct_title_2',
    'quiz.feedback.correct_title_3',
    'quiz.feedback.correct_title_4',
  ];

  static const List<String> _wrongTitleKeys = [
    'quiz.feedback.wrong_title_1',
    'quiz.feedback.wrong_title_2',
    'quiz.feedback.wrong_title_3',
    'quiz.feedback.wrong_title_4',
  ];

  late AnimationController _ctrl;
  late CelebrationStyle _effectiveStyle;

  late List<_Particle> _particles;
  late List<_Sparkle> _sparkles;
  late List<_Confetti> _confetti;
  late double _ornamentSpin;
  late String _titleKey;

  @override
  void initState() {
    super.initState();
    _seed();
    _ctrl = AnimationController(
      vsync: this,
      duration: _durationFor(_effectiveStyle),
    );
    _ctrl.forward();
  }

  @override
  void didUpdateWidget(CelebrationOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.trigger != widget.trigger ||
        oldWidget.isCorrect != widget.isCorrect ||
        oldWidget.style != widget.style) {
      _seed();
      _ctrl.duration = _durationFor(_effectiveStyle);
      _ctrl
        ..reset()
        ..forward();
    }
  }

  Duration _durationFor(CelebrationStyle style) => Duration(
        milliseconds: style == CelebrationStyle.stardust ? 2800 : 2200,
      );

  void _seed() {
    final rng = Random(widget.trigger ^ (widget.isCorrect ? 0x9E3779B9 : 0));
    final titles = widget.isCorrect ? _correctTitleKeys : _wrongTitleKeys;
    _titleKey = titles[rng.nextInt(titles.length)];

    _effectiveStyle = widget.style == CelebrationStyle.random
        ? (rng.nextBool() ? CelebrationStyle.stardust : CelebrationStyle.bloom)
        : widget.style;

    _ornamentSpin = (rng.nextDouble() - 0.5) * 0.6;

    // Bloom-only particles.
    if (_effectiveStyle == CelebrationStyle.bloom && widget.isCorrect) {
      _particles = List<_Particle>.generate(8, (i) {
        final angleStep = (2 * pi) / 8;
        return _Particle(
          angle: angleStep * i + (rng.nextDouble() - 0.5) * 0.4,
          distance: 60 + rng.nextDouble() * 42,
          size: 7 + rng.nextDouble() * 6,
          delay: 0.10 + rng.nextDouble() * 0.18,
          rotation: (rng.nextDouble() - 0.5) * 1.6,
          isCrescent: rng.nextDouble() < 0.30,
        );
      });
    } else {
      _particles = const [];
    }

    // Stardust sparkles + confetti — only when correct.
    if (_effectiveStyle == CelebrationStyle.stardust && widget.isCorrect) {
      _sparkles = List<_Sparkle>.generate(14, (i) {
        final ringIndex = i % 2;
        final base = ringIndex == 0 ? 70.0 : 105.0;
        final angle = (i / 14) * 2 * pi + (rng.nextDouble() - 0.5) * 0.35;
        return _Sparkle(
          angle: angle,
          distance: base + rng.nextDouble() * 28,
          size: 6 + rng.nextDouble() * 7,
          delay: 0.08 + rng.nextDouble() * 0.22,
          rotation: (rng.nextDouble() - 0.5) * 2.2,
          kind: _SparkleKind.values[rng.nextInt(_SparkleKind.values.length)],
          warm: rng.nextDouble() < 0.55,
        );
      });
      _confetti = List<_Confetti>.generate(10, (i) {
        return _Confetti(
          startAngle: rng.nextDouble() * 2 * pi,
          startRadius: 30 + rng.nextDouble() * 50,
          fall: 110 + rng.nextDouble() * 60,
          sway: 10 + rng.nextDouble() * 14,
          rotation: (rng.nextDouble() - 0.5) * 6,
          size: 4 + rng.nextDouble() * 3.5,
          delay: 0.18 + rng.nextDouble() * 0.22,
          tone: rng.nextInt(3),
        );
      });
    } else {
      _sparkles = const [];
      _confetti = const [];
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final errorColor = Theme.of(context).colorScheme.error;
    final accent = widget.isCorrect ? colors.olive : errorColor;
    final accentSoft = widget.isCorrect ? colors.oliveLeaf : errorColor;

    return IgnorePointer(
      child: RepaintBoundary(
        child: FadeTransition(
          opacity: CurvedAnimation(
            parent: _ctrl,
            curve: const Interval(0.88, 1.0, curve: Curves.linear),
          ).drive(Tween<double>(begin: 1.0, end: 0.0)),
          child: _effectiveStyle == CelebrationStyle.stardust
              ? _buildStardust(colors, accent, accentSoft)
              : _buildBloom(colors, accent, accentSoft),
        ),
      ),
    );
  }

  // ----- Bloom (original) -------------------------------------------------

  Widget _buildBloom(
    AppColorsTheme colors,
    Color accent,
    Color accentSoft,
  ) {
    return Stack(
      alignment: Alignment.center,
      children: [
        _Backdrop(animation: _ctrl, accent: accent),
        for (var i = 0; i < 3; i++)
          _Ring(
            animation: _ctrl,
            ringIndex: i,
            accent: i.isOdd ? accentSoft : accent,
          ),
        for (final p in _particles)
          _ParticleView(
            animation: _ctrl,
            particle: p,
            color: p.isCrescent ? colors.accent : colors.olive,
          ),
        _IconBadge(
          animation: _ctrl,
          isCorrect: widget.isCorrect,
          accent: accent,
          canvas: colors.canvas,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 138),
          child: _MessageBlock(
            animation: _ctrl,
            title: _titleKey.tr(),
            subtitle: widget.messageKey?.tr(),
            accent: accent,
            titleColor: colors.textPrimary,
            subtitleColor: colors.textSecondary,
            canvas: colors.canvas,
          ),
        ),
      ],
    );
  }

  // ----- Stardust (new creative) ------------------------------------------

  Widget _buildStardust(
    AppColorsTheme colors,
    Color accent,
    Color accentSoft,
  ) {
    final warmAccent = colors.accent; // amber
    final warmSoft = colors.accentSoft; // amber soft

    return Stack(
      alignment: Alignment.center,
      children: [
        _AuroraHalo(
          animation: _ctrl,
          inner: accent,
          outer: widget.isCorrect ? warmAccent : accentSoft,
        ),
        if (widget.isCorrect)
          _GeometricOrnament(
            animation: _ctrl,
            accent: accent,
            spinBias: _ornamentSpin,
          ),
        if (widget.isCorrect)
          _LightRays(animation: _ctrl, accent: warmAccent),
        for (var i = 0; i < 2; i++)
          _PulseRing(
            animation: _ctrl,
            startDelay: 0.04 + i * 0.10,
            accent: i.isOdd ? accentSoft : accent,
          ),
        for (final s in _sparkles)
          _SparkleView(
            animation: _ctrl,
            sparkle: s,
            warm: warmAccent,
            cool: accent,
            warmSoft: warmSoft,
          ),
        for (final c in _confetti)
          _ConfettiView(
            animation: _ctrl,
            confetti: c,
            tones: [accent, warmAccent, accentSoft],
          ),
        _HeroBadge(
          animation: _ctrl,
          isCorrect: widget.isCorrect,
          accent: accent,
          accentSoft: accentSoft,
          canvas: colors.canvas,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 140),
          child: _StardustMessage(
            animation: _ctrl,
            title: _titleKey.tr(),
            subtitle: widget.messageKey?.tr(),
            accent: accent,
            warm: warmAccent,
            titleColor: colors.textPrimary,
            subtitleColor: colors.textSecondary,
            canvas: colors.canvas,
            isCorrect: widget.isCorrect,
          ),
        ),
      ],
    );
  }
}

// ===========================================================================
// Shared data
// ===========================================================================

class _Particle {
  const _Particle({
    required this.angle,
    required this.distance,
    required this.size,
    required this.delay,
    required this.rotation,
    required this.isCrescent,
  });

  final double angle;
  final double distance;
  final double size;
  final double delay;
  final double rotation;
  final bool isCrescent;
}

enum _SparkleKind { star, dot, crescent, twinkle }

class _Sparkle {
  const _Sparkle({
    required this.angle,
    required this.distance,
    required this.size,
    required this.delay,
    required this.rotation,
    required this.kind,
    required this.warm,
  });

  final double angle;
  final double distance;
  final double size;
  final double delay;
  final double rotation;
  final _SparkleKind kind;
  final bool warm;
}

class _Confetti {
  const _Confetti({
    required this.startAngle,
    required this.startRadius,
    required this.fall,
    required this.sway,
    required this.rotation,
    required this.size,
    required this.delay,
    required this.tone,
  });

  final double startAngle;
  final double startRadius;
  final double fall;
  final double sway;
  final double rotation;
  final double size;
  final double delay;
  final int tone;
}

// ===========================================================================
// Bloom variant pieces (kept intact)
// ===========================================================================

class _ParticleView extends StatelessWidget {
  const _ParticleView({
    required this.animation,
    required this.particle,
    required this.color,
  });

  final Animation<double> animation;
  final _Particle particle;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final progress = animation.value;
        final adjusted =
            ((progress - particle.delay) / (1 - particle.delay)).clamp(0.0, 1.0);
        if (adjusted <= 0) return const SizedBox.shrink();
        final eased = Curves.easeOutCubic.transform(adjusted);
        final dx = cos(particle.angle) * particle.distance * eased;
        final dy = sin(particle.angle) * particle.distance * eased - 24 * eased;
        final opacity = adjusted < 0.65 ? 1.0 : ((1 - adjusted) / 0.35);
        final scale = 0.5 + 0.6 * eased;

        return Transform.translate(
          offset: Offset(dx, dy),
          child: Transform.rotate(
            angle: particle.rotation * eased,
            child: Transform.scale(
              scale: scale,
              child: Icon(
                particle.isCrescent
                    ? Icons.nightlight_round
                    : Icons.auto_awesome_rounded,
                size: particle.size,
                color: color.withValues(alpha: opacity.clamp(0.0, 1.0)),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Backdrop extends StatelessWidget {
  const _Backdrop({required this.animation, required this.accent});

  final Animation<double> animation;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final t = animation.value;
        final fadeIn = _interval(t, 0.0, 0.18);
        final fadeOut = 1 - _interval(t, 0.65, 1.0);
        final opacity = fadeIn * fadeOut;
        if (opacity <= 0.001) return const SizedBox.shrink();
        return Container(
          width: 240,
          height: 240,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                accent.withValues(alpha: 0.18 * opacity),
                accent.withValues(alpha: 0.0),
              ],
              stops: const [0.0, 1.0],
            ),
          ),
        );
      },
    );
  }
}

class _Ring extends StatelessWidget {
  const _Ring({
    required this.animation,
    required this.ringIndex,
    required this.accent,
  });

  final Animation<double> animation;
  final int ringIndex;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final t = animation.value;
        final progress = ((t - ringIndex * 0.09) / 0.55).clamp(0.0, 1.0);
        if (progress <= 0 || progress >= 1) return const SizedBox.shrink();
        final eased = Curves.easeOutCubic.transform(progress);
        final size = 56 + eased * 140;
        final opacity = (1 - progress).clamp(0.0, 1.0) * 0.7;
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: accent.withValues(alpha: opacity),
              width: 1.4,
            ),
          ),
        );
      },
    );
  }
}

class _IconBadge extends StatelessWidget {
  const _IconBadge({
    required this.animation,
    required this.isCorrect,
    required this.accent,
    required this.canvas,
  });

  final Animation<double> animation;
  final bool isCorrect;
  final Color accent;
  final Color canvas;

  @override
  Widget build(BuildContext context) {
    final badgeSize = isCorrect ? 50.0 : 64.0;
    final iconSize = isCorrect ? 26.0 : 36.0;
    final badge = Container(
      width: badgeSize,
      height: badgeSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: accent,
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.38),
            blurRadius: 18,
            spreadRadius: 0.5,
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
        final scale = Curves.easeOutBack.transform(_interval(t, 0.0, 0.32));
        final pulse = isCorrect
            ? sin(_interval(t, 0.32, 0.60) * pi) * 0.06
            : 0.0;
        final shakeT = isCorrect ? 0.0 : _interval(t, 0.30, 0.62);
        final shake = sin(shakeT * pi * 4) * (1 - shakeT) * 6;

        return Transform.translate(
          offset: Offset(shake, 0),
          child: Transform.scale(
            scale: scale + pulse,
            child: child,
          ),
        );
      },
    );
  }
}

class _MessageBlock extends StatelessWidget {
  const _MessageBlock({
    required this.animation,
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.titleColor,
    required this.subtitleColor,
    required this.canvas,
  });

  final Animation<double> animation;
  final String title;
  final String? subtitle;
  final Color accent;
  final Color titleColor;
  final Color subtitleColor;
  final Color canvas;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final t = animation.value;
        final titleEased =
            Curves.easeOutCubic.transform(_interval(t, 0.18, 0.46));
        final titlePop =
            Curves.easeOutBack.transform(_interval(t, 0.18, 0.48));
        final shimmerT = _interval(t, 0.30, 0.74);
        final subEased =
            Curves.easeOutCubic.transform(_interval(t, 0.40, 0.66));
        final plateProgress =
            Curves.easeOutCubic.transform(_interval(t, 0.16, 0.44));

        return Stack(
          alignment: Alignment.topCenter,
          children: [
            if (plateProgress > 0.01)
              Positioned.fill(
                child: IgnorePointer(
                  child: Opacity(
                    opacity: plateProgress * 0.8,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(28),
                        gradient: RadialGradient(
                          colors: [
                            canvas.withValues(alpha: 0.5),
                            canvas.withValues(alpha: 0.0),
                          ],
                          radius: 0.9,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _FadeSlideUp(
                  progress: titleEased,
                  slide: 16,
                  child: Transform.scale(
                    scale: 0.9 + 0.1 * titlePop,
                    child: _ShimmerText(
                      text: title,
                      progress: shimmerT,
                      baseColor: titleColor,
                      shimmerColor: accent,
                      style: AppTextStyles.titleLarge.copyWith(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                        letterSpacing: 0.3,
                        color: titleColor,
                        shadows: [
                          Shadow(
                            color: canvas.withValues(alpha: 0.6),
                            blurRadius: 10,
                          ),
                          Shadow(
                            color: accent.withValues(alpha: 0.22),
                            blurRadius: 16,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (subtitle != null && subtitle!.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  _FadeSlideUp(
                    progress: subEased,
                    slide: 12,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      child: ResponsiveText(
                        subtitle,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          height: 1.45,
                          letterSpacing: 0.15,
                          color: subtitleColor,
                          shadows: [
                            Shadow(
                              color: canvas.withValues(alpha: 0.55),
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

class _ShimmerText extends StatelessWidget {
  const _ShimmerText({
    required this.text,
    required this.progress,
    required this.baseColor,
    required this.shimmerColor,
    required this.style,
  });

  final String text;
  final double progress;
  final Color baseColor;
  final Color shimmerColor;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    final base = ResponsiveText(text, style: style);
    if (progress <= 0 || progress >= 1) return base;

    final pos = progress;
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (rect) {
        final width = rect.width;
        final start = (pos - 0.18).clamp(-1.0, 2.0);
        final mid = pos.clamp(-1.0, 2.0);
        final end = (pos + 0.18).clamp(-1.0, 2.0);
        return LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [baseColor, shimmerColor, baseColor],
          stops: [start, mid, end],
        ).createShader(Rect.fromLTWH(0, 0, width, rect.height));
      },
      child: base,
    );
  }
}

class _FadeSlideUp extends StatelessWidget {
  const _FadeSlideUp({
    required this.progress,
    required this.slide,
    required this.child,
  });

  final double progress;
  final double slide;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (progress <= 0.001) return const SizedBox.shrink();
    final translated = Transform.translate(
      offset: Offset(0, (1 - progress) * slide),
      child: child,
    );
    if (progress >= 0.999) return translated;
    return Opacity(opacity: progress, child: translated);
  }
}

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
            if (plateProgress > 0.01)
              Positioned.fill(
                child: IgnorePointer(
                  child: Opacity(
                    opacity: plateProgress * 0.85,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(28),
                        gradient: RadialGradient(
                          colors: [
                            canvas.withValues(alpha: 0.55),
                            canvas.withValues(alpha: 0.0),
                          ],
                          radius: 0.9,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
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
