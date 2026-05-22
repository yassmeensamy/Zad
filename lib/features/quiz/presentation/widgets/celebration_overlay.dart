import 'dart:math';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:my_app/core/widgets/responsive_text.dart';
import '../../../../theme/theme.dart';

double _interval(double t, double start, double end) =>
    ((t - start) / (end - start)).clamp(0.0, 1.0);

enum CelebrationStyle { bloom, stardust, crescent, shootingStar, random }

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
  late List<_Twinkle> _twinkles;
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
        milliseconds: switch (style) {
          CelebrationStyle.stardust => 2800,
          CelebrationStyle.crescent => 2600,
          CelebrationStyle.shootingStar => 2900,
          _ => 2200,
        },
      );

  void _seed() {
    final rng = Random(widget.trigger ^ (widget.isCorrect ? 0x9E3779B9 : 0));
    final titles = widget.isCorrect ? _correctTitleKeys : _wrongTitleKeys;
    _titleKey = titles[rng.nextInt(titles.length)];

    _effectiveStyle = widget.style == CelebrationStyle.random
        ? const [
            CelebrationStyle.bloom,
            CelebrationStyle.stardust,
            CelebrationStyle.crescent,
            CelebrationStyle.shootingStar,
          ][rng.nextInt(4)]
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

    // Crescent twinkling-star backdrop — only when correct.
    final needsTwinkles = widget.isCorrect &&
        (_effectiveStyle == CelebrationStyle.crescent ||
            _effectiveStyle == CelebrationStyle.shootingStar);
    if (needsTwinkles) {
      _twinkles = List<_Twinkle>.generate(9, (i) {
        final angle = (i / 9) * 2 * pi + (rng.nextDouble() - 0.5) * 0.5;
        return _Twinkle(
          angle: angle,
          distance: 72 + rng.nextDouble() * 56,
          size: 4 + rng.nextDouble() * 5,
          delay: 0.18 + rng.nextDouble() * 0.28,
          phase: rng.nextDouble() * 2 * pi,
          warm: rng.nextDouble() < 0.6,
        );
      });
    } else {
      _twinkles = const [];
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
          child: switch (_effectiveStyle) {
            CelebrationStyle.stardust =>
              _buildStardust(colors, accent, accentSoft),
            CelebrationStyle.crescent =>
              _buildCrescent(colors, accent, accentSoft),
            CelebrationStyle.shootingStar =>
              _buildShootingStar(colors, accent, accentSoft),
            _ => _buildBloom(colors, accent, accentSoft),
          },
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

  // ----- Crescent (moon + star, no checkmark) -----------------------------

  Widget _buildCrescent(
    AppColorsTheme colors,
    Color accent,
    Color accentSoft,
  ) {
    final warmAccent = colors.accent; // amber
    final warmDeep = colors.accentDeep;
    final warmSoft = colors.accentSoft;

    // For correct, lead with warm amber (the "moon" is gold). Olive
    // becomes the supporting accent. For wrong, fall back to the
    // error-tinted accent passed in.
    final primary = widget.isCorrect ? warmAccent : accent;
    final secondary = widget.isCorrect ? warmDeep : accentSoft;

    return Stack(
      alignment: Alignment.center,
      children: [
        _AuroraHalo(
          animation: _ctrl,
          inner: primary,
          outer: widget.isCorrect ? accent : accentSoft,
        ),
        if (widget.isCorrect) ...[
          _DottedOrbit(
            animation: _ctrl,
            color: accent,
            radius: 78,
            dotCount: 18,
            dotSize: 2.4,
            appearStart: 0.06,
            appearEnd: 0.36,
          ),
          _DottedOrbit(
            animation: _ctrl,
            color: warmSoft,
            radius: 110,
            dotCount: 26,
            dotSize: 1.8,
            appearStart: 0.14,
            appearEnd: 0.44,
            reverse: true,
          ),
        ],
        for (var i = 0; i < 2; i++)
          _PulseRing(
            animation: _ctrl,
            startDelay: 0.05 + i * 0.11,
            accent: i.isOdd ? primary : accent,
          ),
        for (final tw in _twinkles)
          _TwinkleView(
            animation: _ctrl,
            twinkle: tw,
            warm: warmAccent,
            cool: accent,
          ),
        _MoonBadge(
          animation: _ctrl,
          isCorrect: widget.isCorrect,
          primary: primary,
          secondary: secondary,
          canvas: colors.canvas,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 142),
          child: _StardustMessage(
            animation: _ctrl,
            title: _titleKey.tr(),
            subtitle: widget.messageKey?.tr(),
            accent: accent,
            warm: primary,
            titleColor: colors.textPrimary,
            subtitleColor: colors.textSecondary,
            canvas: colors.canvas,
            isCorrect: widget.isCorrect,
          ),
        ),
      ],
    );
  }

  // ----- Shooting Star (diagonal streak + landing flash) ------------------

  Widget _buildShootingStar(
    AppColorsTheme colors,
    Color accent,
    Color accentSoft,
  ) {
    final warmAccent = colors.accent;
    final warmDeep = colors.accentDeep;

    final primary = widget.isCorrect ? warmAccent : accent;
    final secondary = widget.isCorrect ? warmDeep : accentSoft;

    // Deterministic streak direction — pulled from the trigger seed so the
    // same question always comes in from the same diagonal.
    final fromAngle = -pi * 3 / 4 + _ornamentSpin * 0.6; // upper-left-ish

    return Stack(
      alignment: Alignment.center,
      children: [
        _AuroraHalo(
          animation: _ctrl,
          inner: primary,
          outer: widget.isCorrect ? warmAccent : accentSoft,
        ),
        // Faint background twinkles set the night-sky stage.
        for (final tw in _twinkles)
          _TwinkleView(
            animation: _ctrl,
            twinkle: tw,
            warm: warmAccent,
            cool: accent,
          ),
        // Flash burst on impact.
        if (widget.isCorrect)
          _FlashBurst(animation: _ctrl, color: warmAccent),
        // Two pulse rings rippling outward from the landing point.
        _PulseRing(
          animation: _ctrl,
          startDelay: 0.32,
          accent: primary,
        ),
        _PulseRing(
          animation: _ctrl,
          startDelay: 0.44,
          accent: warmAccent,
        ),
        // Sharp radiating sparks at the moment of impact.
        if (widget.isCorrect)
          _ImpactSparks(animation: _ctrl, color: warmAccent),
        _ShootingStarBadge(
          animation: _ctrl,
          isCorrect: widget.isCorrect,
          primary: primary,
          secondary: secondary,
          canvas: colors.canvas,
          fromAngle: fromAngle,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 142),
          child: _StardustMessage(
            animation: _ctrl,
            title: _titleKey.tr(),
            subtitle: widget.messageKey?.tr(),
            accent: accent,
            warm: primary,
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

// ===========================================================================
// Crescent variant pieces
// ===========================================================================

class _Twinkle {
  const _Twinkle({
    required this.angle,
    required this.distance,
    required this.size,
    required this.delay,
    required this.phase,
    required this.warm,
  });

  final double angle;
  final double distance;
  final double size;
  final double delay;
  final double phase;
  final bool warm;
}

class _TwinkleView extends StatelessWidget {
  const _TwinkleView({
    required this.animation,
    required this.twinkle,
    required this.warm,
    required this.cool,
  });

  final Animation<double> animation;
  final _Twinkle twinkle;
  final Color warm;
  final Color cool;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final t = animation.value;
        final adjusted =
            ((t - twinkle.delay) / (1 - twinkle.delay)).clamp(0.0, 1.0);
        if (adjusted <= 0) return const SizedBox.shrink();

        // Two slow twinkle cycles over the visible window.
        final twinkleWave =
            0.5 + 0.5 * sin(twinkle.phase + adjusted * pi * 3.2);
        final fadeIn = (adjusted / 0.18).clamp(0.0, 1.0);
        final fadeOut = 1 - _interval(t, 0.82, 1.0);
        final opacity = twinkleWave * fadeIn * fadeOut;
        if (opacity < 0.02) return const SizedBox.shrink();

        final dx = cos(twinkle.angle) * twinkle.distance;
        final dy = sin(twinkle.angle) * twinkle.distance;
        final scale = 0.6 + 0.4 * twinkleWave;
        final color = twinkle.warm ? warm : cool;

        return Transform.translate(
          offset: Offset(dx, dy),
          child: Transform.scale(
            scale: scale,
            child: Icon(
              Icons.star_rounded,
              size: twinkle.size,
              color: color.withValues(alpha: opacity.clamp(0.0, 1.0)),
            ),
          ),
        );
      },
    );
  }
}

class _DottedOrbit extends StatelessWidget {
  const _DottedOrbit({
    required this.animation,
    required this.color,
    required this.radius,
    required this.dotCount,
    required this.dotSize,
    required this.appearStart,
    required this.appearEnd,
    this.reverse = false,
  });

  final Animation<double> animation;
  final Color color;
  final double radius;
  final int dotCount;
  final double dotSize;
  final double appearStart;
  final double appearEnd;
  final bool reverse;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final t = animation.value;
        final appear = Curves.easeOutCubic.transform(
          _interval(t, appearStart, appearEnd),
        );
        final fadeOut = 1 - _interval(t, 0.76, 1.0);
        final opacity = appear * fadeOut;
        if (opacity <= 0.001) return const SizedBox.shrink();
        final rotation = (reverse ? -1 : 1) * t * 2 * pi * 0.22;

        return Transform.rotate(
          angle: rotation,
          child: CustomPaint(
            size: Size((radius + dotSize) * 2, (radius + dotSize) * 2),
            painter: _OrbitDotsPainter(
              color: color,
              opacity: opacity,
              radius: radius,
              dotCount: dotCount,
              dotSize: dotSize,
              appear: appear,
            ),
          ),
        );
      },
    );
  }
}

class _OrbitDotsPainter extends CustomPainter {
  _OrbitDotsPainter({
    required this.color,
    required this.opacity,
    required this.radius,
    required this.dotCount,
    required this.dotSize,
    required this.appear,
  });

  final Color color;
  final double opacity;
  final double radius;
  final int dotCount;
  final double dotSize;
  final double appear;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final paint = Paint()
      ..color = color.withValues(alpha: opacity.clamp(0.0, 1.0))
      ..style = PaintingStyle.fill;

    for (var i = 0; i < dotCount; i++) {
      final a = (i / dotCount) * 2 * pi;
      final x = cx + cos(a) * radius;
      final y = cy + sin(a) * radius;
      // Every 4th dot is larger — gives rotation a visible cadence.
      final s = (i % 4 == 0 ? dotSize * 1.7 : dotSize * 0.75) * appear;
      canvas.drawCircle(Offset(x, y), s, paint);
    }
  }

  @override
  bool shouldRepaint(_OrbitDotsPainter old) =>
      old.color != color ||
      old.opacity != opacity ||
      old.appear != appear ||
      old.radius != radius;
}

class _MoonBadge extends StatelessWidget {
  const _MoonBadge({
    required this.animation,
    required this.isCorrect,
    required this.primary,
    required this.secondary,
    required this.canvas,
  });

  final Animation<double> animation;
  final bool isCorrect;
  final Color primary;
  final Color secondary;
  final Color canvas;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final t = animation.value;
        // Moonrise: enter from below, then settle.
        final rise = Curves.easeOutCubic.transform(_interval(t, 0.0, 0.40));
        final pop = Curves.easeOutBack.transform(_interval(t, 0.10, 0.50));
        final fadeIn = _interval(t, 0.0, 0.30);
        final settle = isCorrect
            ? sin(_interval(t, 0.42, 0.92) * pi) * 0.05
            : 0.0;
        final bob = isCorrect
            ? sin(_interval(t, 0.40, 0.95) * pi * 2) * 2
            : 0.0;
        final shakeT = isCorrect ? 0.0 : _interval(t, 0.30, 0.62);
        final shake = sin(shakeT * pi * 4) * (1 - shakeT) * 6;

        final dyRise = (1 - rise) * 36;
        final scale = 0.65 + 0.35 * pop + settle;

        final child = isCorrect
            ? _CrescentVisual(primary: primary, secondary: secondary)
            : _WrongVisual(primary: primary, canvas: canvas);

        return Opacity(
          opacity: fadeIn.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(shake, dyRise - bob),
            child: Transform.scale(scale: scale, child: child),
          ),
        );
      },
    );
  }
}

class _CrescentVisual extends StatelessWidget {
  const _CrescentVisual({required this.primary, required this.secondary});

  final Color primary;
  final Color secondary;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: primary.withValues(alpha: 0.50),
            blurRadius: 30,
            spreadRadius: 4,
          ),
          BoxShadow(
            color: primary.withValues(alpha: 0.22),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: CustomPaint(
        painter: _CrescentPainter(primary: primary, secondary: secondary),
      ),
    );
  }
}

class _WrongVisual extends StatelessWidget {
  const _WrongVisual({required this.primary, required this.canvas});

  final Color primary;
  final Color canvas;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: primary,
        boxShadow: [
          BoxShadow(
            color: primary.withValues(alpha: 0.42),
            blurRadius: 22,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Icon(Icons.close_rounded, color: canvas, size: 34),
    );
  }
}

class _CrescentPainter extends CustomPainter {
  _CrescentPainter({required this.primary, required this.secondary});

  final Color primary;
  final Color secondary;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width * 0.36;

    // Build the crescent by subtracting an offset inner disk from the outer.
    final outer = Path()
      ..addOval(Rect.fromCircle(center: Offset(cx, cy), radius: r));
    final inner = Path()
      ..addOval(
        Rect.fromCircle(
          center: Offset(cx + r * 0.42, cy - r * 0.12),
          radius: r * 0.90,
        ),
      );
    final crescent = Path.combine(PathOperation.difference, outer, inner);

    final shader = LinearGradient(
      colors: [primary, secondary],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    final paint = Paint()..shader = shader;
    canvas.drawPath(crescent, paint);

    // Small companion star next to the crescent opening.
    final starCenter = Offset(cx + r * 0.92, cy - r * 0.50);
    final starR = r * 0.22;
    _drawStar(canvas, starCenter, starR, paint);
  }

  void _drawStar(Canvas canvas, Offset center, double outerR, Paint paint) {
    final path = Path();
    const points = 5;
    final innerR = outerR * 0.46;
    for (var i = 0; i < points * 2; i++) {
      final angle = -pi / 2 + i * pi / points;
      final r = i.isEven ? outerR : innerR;
      final x = center.dx + cos(angle) * r;
      final y = center.dy + sin(angle) * r;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_CrescentPainter old) =>
      old.primary != primary || old.secondary != secondary;
}

// ===========================================================================
// Shooting Star variant pieces
// ===========================================================================

/// Bright circular flash that pops on the star's impact at center.
class _FlashBurst extends StatelessWidget {
  const _FlashBurst({required this.animation, required this.color});

  final Animation<double> animation;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final t = animation.value;
        // Flash centered on the moment the star lands (~0.34).
        final progress = _interval(t, 0.26, 0.64);
        if (progress <= 0 || progress >= 1) return const SizedBox.shrink();
        final eased = Curves.easeOutCubic.transform(progress);
        final size = 70 + eased * 210;
        // Bright at start, fades fast.
        final opacity = ((1 - progress) * (1 - progress) * 1.15).clamp(0.0, 1.0);
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                color.withValues(alpha: 0.95 * opacity),
                color.withValues(alpha: 0.45 * opacity),
                color.withValues(alpha: 0.0),
              ],
              stops: const [0.0, 0.45, 1.0],
            ),
          ),
        );
      },
    );
  }
}

class _ShootingStarBadge extends StatelessWidget {
  const _ShootingStarBadge({
    required this.animation,
    required this.isCorrect,
    required this.primary,
    required this.secondary,
    required this.canvas,
    required this.fromAngle,
  });

  final Animation<double> animation;
  final bool isCorrect;
  final Color primary;
  final Color secondary;
  final Color canvas;
  final double fromAngle;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final t = animation.value;
        // Flight from off-screen toward the center, decelerating.
        final flight = Curves.easeOutCubic.transform(_interval(t, 0.0, 0.36));
        // Pop on landing.
        final pop = Curves.easeOutBack.transform(_interval(t, 0.30, 0.58));
        final settle = isCorrect
            ? sin(_interval(t, 0.55, 0.95) * pi) * 0.06
            : 0.0;
        final shakeT = isCorrect ? 0.0 : _interval(t, 0.36, 0.70);
        final shake = sin(shakeT * pi * 4) * (1 - shakeT) * 6;

        // Position: starts ~180px away along fromAngle, lands at 0,0.
        const flightDistance = 180.0;
        final remaining = 1 - flight;
        final dx = cos(fromAngle) * flightDistance * remaining;
        final dy = sin(fromAngle) * flightDistance * remaining;

        final scale = 0.55 + 0.45 * pop + settle;
        final trailOpacity = (1 - flight).clamp(0.0, 1.0);
        final landed = (flight - 0.7) / 0.3;
        final glowOpacity = landed.clamp(0.0, 1.0);

        final child = isCorrect
            ? CustomPaint(
                size: const Size(200, 200),
                painter: _ShootingStarPainter(
                  primary: primary,
                  secondary: secondary,
                  highlight: canvas,
                  fromAngle: fromAngle,
                  trailLength: 140 * (1 - flight * 0.82),
                  trailOpacity: trailOpacity,
                  glowOpacity: glowOpacity,
                ),
              )
            : _WrongVisual(primary: primary, canvas: canvas);

        return Transform.translate(
          offset: Offset(dx + shake, dy),
          child: Transform.scale(scale: scale, child: child),
        );
      },
    );
  }
}

class _ShootingStarPainter extends CustomPainter {
  _ShootingStarPainter({
    required this.primary,
    required this.secondary,
    required this.highlight,
    required this.fromAngle,
    required this.trailLength,
    required this.trailOpacity,
    required this.glowOpacity,
  });

  final Color primary;
  final Color secondary;
  final Color highlight;
  final double fromAngle;
  final double trailLength;
  final double trailOpacity;
  final double glowOpacity;

  void _drawStar(
    Canvas canvas,
    Offset center,
    double outerR,
    Paint paint,
  ) {
    final path = Path();
    const points = 5;
    final innerR = outerR * 0.42;
    for (var i = 0; i < points * 2; i++) {
      final angle = -pi / 2 + i * pi / points;
      final r = i.isEven ? outerR : innerR;
      final x = center.dx + cos(angle) * r;
      final y = center.dy + sin(angle) * r;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final center = Offset(cx, cy);

    // Trail: a tapered streak pointing back along fromAngle.
    if (trailOpacity > 0.02 && trailLength > 2) {
      final tailEnd = Offset(
        cx + cos(fromAngle) * trailLength,
        cy + sin(fromAngle) * trailLength,
      );
      final trailRect = Rect.fromPoints(tailEnd, center);

      // Outer wide glow stripe.
      final glowPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            secondary.withValues(alpha: 0.0),
            secondary.withValues(alpha: trailOpacity * 0.55),
            primary.withValues(alpha: trailOpacity * 0.85),
          ],
        ).createShader(trailRect)
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 20;
      canvas.drawLine(tailEnd, center, glowPaint);

      // Bright core stripe.
      final corePaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            primary.withValues(alpha: 0.0),
            primary.withValues(alpha: trailOpacity),
            highlight.withValues(alpha: trailOpacity),
          ],
        ).createShader(trailRect)
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 6.5;
      canvas.drawLine(tailEnd, center, corePaint);
    }

    // Soft halo behind the star (grows once landed).
    if (glowOpacity > 0.02) {
      final haloPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            primary.withValues(alpha: 0.70 * glowOpacity),
            primary.withValues(alpha: 0.0),
          ],
        ).createShader(Rect.fromCircle(center: center, radius: 60));
      canvas.drawCircle(center, 60, haloPaint);
    }

    // The star itself — gradient gold with a bright inner highlight.
    const outerR = 32.0;
    final starShader = RadialGradient(
      colors: [highlight, primary, secondary],
      stops: const [0.0, 0.55, 1.0],
    ).createShader(Rect.fromCircle(center: center, radius: outerR));
    _drawStar(canvas, center, outerR, Paint()..shader = starShader);

    // Small specular highlight near the upper-left of the star.
    final highlightPaint = Paint()
      ..color = highlight.withValues(alpha: 0.9);
    canvas.drawCircle(
      Offset(cx - outerR * 0.22, cy - outerR * 0.30),
      outerR * 0.20,
      highlightPaint,
    );
  }

  @override
  bool shouldRepaint(_ShootingStarPainter old) =>
      old.primary != primary ||
      old.secondary != secondary ||
      old.fromAngle != fromAngle ||
      old.trailLength != trailLength ||
      old.trailOpacity != trailOpacity ||
      old.glowOpacity != glowOpacity;
}

/// A single centered radial flare that pops at the moment the star lands.
/// Uses a positioned-absolute layout so it is rigidly anchored to the
/// exact center of the overlay, never offset by sibling layout flow.
class _ImpactSparks extends StatelessWidget {
  const _ImpactSparks({required this.animation, required this.color});

  final Animation<double> animation;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Align(
          alignment: Alignment.center,
          child: AnimatedBuilder(
            animation: animation,
            builder: (context, _) {
              final t = animation.value;
              final progress = _interval(t, 0.30, 0.66);
              if (progress <= 0 || progress >= 1) {
                return const SizedBox.shrink();
              }
              final eased = Curves.easeOutCubic.transform(progress);
              final fade = (1 - progress).clamp(0.0, 1.0);
              final size = 38 + eased * 32; // 38 → 70 px, tight
              return Opacity(
                opacity: fade,
                child: Icon(
                  Icons.flare_rounded,
                  size: size,
                  color: color,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
