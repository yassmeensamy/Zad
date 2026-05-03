import 'dart:math';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:my_app/core/widgets/responsive_text.dart';
import '../../../../theme/theme.dart';

double _interval(double t, double start, double end) =>
    ((t - start) / (end - start)).clamp(0.0, 1.0);

class CelebrationOverlay extends StatefulWidget {
  const CelebrationOverlay({
    super.key,
    required this.trigger,
    required this.isCorrect,
    this.messageKey,
  });

  /// Increment to replay the animation.
  final int trigger;

  /// Drives color & icon choice, particle behavior, etc.
  final bool isCorrect;

  /// Translation key for the subtitle line under the title.
  final String? messageKey;

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

  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1700),
  );

  late List<_Particle> _particles;
  late String _titleKey;

  @override
  void initState() {
    super.initState();
    _seed();
    _ctrl.forward();
  }

  @override
  void didUpdateWidget(CelebrationOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.trigger != widget.trigger ||
        oldWidget.isCorrect != widget.isCorrect) {
      _seed();
      _ctrl
        ..reset()
        ..forward();
    }
  }

  void _seed() {
    final rng = Random(widget.trigger ^ (widget.isCorrect ? 0x9E3779B9 : 0));
    final titles = widget.isCorrect ? _correctTitleKeys : _wrongTitleKeys;
    _titleKey = titles[rng.nextInt(titles.length)];

    if (!widget.isCorrect) {
      _particles = const [];
      return;
    }
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
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, _) {
          final t = _ctrl.value;

          final overlayFade = 1 - _interval(t, 0.86, 1.0);

          return Opacity(
            opacity: overlayFade,
            child: Stack(
              alignment: Alignment.center,
              children: [
                _Backdrop(t: t, accent: accent),
                for (var i = 0; i < 3; i++)
                  _Ring(
                    progress: ((t - i * 0.09) / 0.55).clamp(0.0, 1.0),
                    accent: i.isOdd ? accentSoft : accent,
                  ),
                for (final p in _particles)
                  _ParticleView(
                    particle: p,
                    progress: t,
                    color: p.isCrescent ? colors.accent : colors.olive,
                  ),
                _IconBadge(
                  t: t,
                  isCorrect: widget.isCorrect,
                  accent: accent,
                  canvas: colors.canvas,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 130),
                  child: _MessageBlock(
                    t: t,
                    title: _titleKey.tr(),
                    subtitle: widget.messageKey?.tr(),
                    accent: accent,
                    titleColor: colors.textPrimary,
                    subtitleColor: colors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

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

class _ParticleView extends StatelessWidget {
  const _ParticleView({
    required this.particle,
    required this.progress,
    required this.color,
  });

  final _Particle particle;
  final double progress;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final adjusted = ((progress - particle.delay) / (1 - particle.delay)).clamp(
      0.0,
      1.0,
    );
    final eased = Curves.easeOutCubic.transform(adjusted);
    final dx = cos(particle.angle) * particle.distance * eased;
    final dy = sin(particle.angle) * particle.distance * eased - 24 * eased;
    final opacity = adjusted < 0.65 ? 1.0 : ((1 - adjusted) / 0.35);
    final scale = 0.5 + 0.6 * eased;

    return Transform.translate(
      offset: Offset(dx, dy),
      child: Opacity(
        opacity: opacity.clamp(0.0, 1.0),
        child: Transform.rotate(
          angle: particle.rotation * eased,
          child: Transform.scale(
            scale: scale,
            child: Icon(
              particle.isCrescent
                  ? Icons.nightlight_round
                  : Icons.auto_awesome_rounded,
              size: particle.size,
              color: color,
            ),
          ),
        ),
      ),
    );
  }
}

class _Backdrop extends StatelessWidget {
  const _Backdrop({required this.t, required this.accent});

  final double t;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final fadeIn = _interval(t, 0.0, 0.18);
    final fadeOut = 1 - _interval(t, 0.65, 1.0);
    final opacity = fadeIn * fadeOut;
    if (opacity <= 0.001) return const SizedBox.shrink();
    return Opacity(
      opacity: opacity,
      child: Container(
        width: 240,
        height: 240,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              accent.withValues(alpha: 0.18),
              accent.withValues(alpha: 0.0),
            ],
            stops: const [0.0, 1.0],
          ),
        ),
      ),
    );
  }
}

class _Ring extends StatelessWidget {
  const _Ring({required this.progress, required this.accent});

  /// 0..1 mapped within this ring's lifetime.
  final double progress;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    if (progress <= 0 || progress >= 1) return const SizedBox.shrink();
    final eased = Curves.easeOutCubic.transform(progress);
    final size = 56 + eased * 140;
    final opacity = (1 - progress).clamp(0.0, 1.0) * 0.7;
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: accent.withValues(alpha: opacity),
            width: 1.4,
          ),
        ),
      ),
    );
  }
}

class _IconBadge extends StatelessWidget {
  const _IconBadge({
    required this.t,
    required this.isCorrect,
    required this.accent,
    required this.canvas,
  });

  final double t;
  final bool isCorrect;
  final Color accent;
  final Color canvas;

  @override
  Widget build(BuildContext context) {
    final scale = Curves.easeOutBack.transform(_interval(t, 0.0, 0.32));

    final pulse = isCorrect
        ? sin(_interval(t, 0.32, 0.60) * pi) * 0.06
        : 0.0;

    final shakeT = isCorrect ? 0.0 : _interval(t, 0.30, 0.62);
    final shake = sin(shakeT * pi * 4) * (1 - shakeT) * 6;

    final badgeSize = isCorrect ? 50.0 : 64.0;
    final iconSize = isCorrect ? 26.0 : 36.0;

    return Transform.translate(
      offset: Offset(shake, 0),
      child: Transform.scale(
        scale: scale + pulse,
        child: Container(
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
        ),
      ),
    );
  }
}

class _MessageBlock extends StatelessWidget {
  const _MessageBlock({
    required this.t,
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.titleColor,
    required this.subtitleColor,
  });

  final double t;
  final String title;
  final String? subtitle;
  final Color accent;
  final Color titleColor;
  final Color subtitleColor;

  @override
  Widget build(BuildContext context) {
    final titleEased = Curves.easeOutCubic.transform(_interval(t, 0.20, 0.50));
    final shimmerT = _interval(t, 0.30, 0.70);
    final subEased = Curves.easeOutCubic.transform(_interval(t, 0.40, 0.72));

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _FadeSlideUp(
          progress: titleEased,
          slide: 18,
          child: _ShimmerText(
            text: title,
            progress: shimmerT,
            baseColor: titleColor,
            shimmerColor: accent,
            style: AppTextStyles.titleLarge.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              height: 1.2,
              letterSpacing: 0.2,
              color: titleColor,
            ),
          ),
        ),
        if (subtitle != null && subtitle!.isNotEmpty) ...[
          const SizedBox(height: 8),
          _FadeSlideUp(
            progress: subEased,
            slide: 14,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: ResponsiveText(
                subtitle,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                  height: 1.5,
                  color: subtitleColor,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Renders [text] with a single highlight that sweeps from start to end
/// as [progress] goes 0→1. Past 1 the highlight is fully gone.
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

    // Highlight is a narrow band traveling across the text.
    // We reuse a horizontal LinearGradient with three stops:
    // [base, shimmerColor, base], sliding the middle stop along.
    final pos = progress; // 0..1
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
      child: ResponsiveText(text, style: style.copyWith(color: Colors.white)),
    );
  }
}

/// Fades in from `progress` 0→1 and slides up from `slide` pixels below.
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
    return Opacity(
      opacity: progress,
      child: Transform.translate(
        offset: Offset(0, (1 - progress) * slide),
        child: child,
      ),
    );
  }
}
