part of '../celebration_overlay.dart';

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
            _TextGlowPlate(
              progress: plateProgress,
              canvas: canvas,
              opacityMul: 0.8,
              canvasAlpha: 0.5,
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

/// Soft radial "glow plate" that fades in behind celebration text to lift it
/// off the busy backdrop. Shared by the bloom and stardust message blocks.
/// Returns an empty box until [progress] crosses the visibility threshold.
class _TextGlowPlate extends StatelessWidget {
  const _TextGlowPlate({
    required this.progress,
    required this.canvas,
    this.opacityMul = 0.85,
    this.canvasAlpha = 0.55,
  });

  final double progress;
  final Color canvas;
  final double opacityMul;
  final double canvasAlpha;

  @override
  Widget build(BuildContext context) {
    if (progress <= 0.01) return const SizedBox.shrink();
    return Positioned.fill(
      child: IgnorePointer(
        child: Opacity(
          opacity: progress * opacityMul,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: RadialGradient(
                colors: [
                  canvas.withValues(alpha: canvasAlpha),
                  canvas.withValues(alpha: 0.0),
                ],
                radius: 0.9,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
