import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import '../../../../core/widgets/responsive_text.dart';
import '../../../../theme/theme.dart';
import 'eight_point_star.dart';
import 'dart:math' as math;

import '../../../streak/presentation/cubit/streak_cubit.dart';
import '../../../streak/presentation/cubit/streak_state.dart';

/// Home streak block: the [StreakHero] banner, masked by [Skeletonizer] while
/// the streak data loads.
class HomeStreakSection extends StatelessWidget {
  const HomeStreakSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StreakCubit, StreakState>(
      buildWhen: (a, b) =>
          a.status != b.status ||
          a.streakDays != b.streakDays ||
          a.todayIndex != b.todayIndex ||
          !listEquals(a.weekProgress, b.weekProgress),
      builder: (context, state) {
        final showSkeleton =
            state.isInitial || state.isLoading || !state.hasStreak;
        return Skeletonizer(
          enabled: showSkeleton,
          child: StreakHero(
            streakDays: state.streakDays,
            weekProgress: state.weekProgress,
            todayIndex: state.todayIndex,
          ),
        );
      },
    );
  }
}

class StreakHero extends StatefulWidget {
  const StreakHero({
    super.key,
    required this.streakDays,
    required this.weekProgress,
    required this.todayIndex,
  });

  final int streakDays;
  final List<bool> weekProgress;
  final int todayIndex;

  @override
  State<StreakHero> createState() => _StreakHeroState();
}

class _StreakHeroState extends State<StreakHero>
    with SingleTickerProviderStateMixin {
  late final AnimationController _countUp = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  );

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 250), () {
      if (mounted) _countUp.forward();
    });
  }

  @override
  void dispose() {
    _countUp.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Stack(
        children: [
          _buildBackground(context),
          const Positioned.fill(child: _PatternOverlay()),

          Positioned(
            top: -26,
            right: -26,
            child: EightPointStar(
              size: 140,
              color: colors.heroGlow,
              opacity: 0.10,
            ),
          ),

          const Positioned(top: -90, right: -80, child: _AmberGlow()),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _StreakHeader(),
                const SizedBox(height: 8),
                _StreakNumberRow(
                  countUp: _countUp,
                  totalDays: widget.streakDays,
                ),
                const SizedBox(height: 8),
                ResponsiveText(
                  'home.streak.motto_en',
                  style: AppTextStyles.bodySmall.copyWith(
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w300,
                    height: 1.35,
                    color: colors.heroInk.withValues(alpha: 0.82),
                  ),
                ),
                const SizedBox(height: 10),
                _DividerLine(),
                const SizedBox(height: 10),
                _WeekDots(
                  progress: widget.weekProgress,
                  todayIndex: widget.todayIndex,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground(BuildContext context) {
    final colors = context.appColors;
    return Positioned.fill(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [0.0, 0.6, 1.0],
            colors: [
              colors.heroSurfaceTop,
              colors.heroSurfaceMid,
              colors.heroSurfaceBottom,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: colors.heroShadow.withValues(alpha: 0.45),
              blurRadius: 50,
              offset: const Offset(0, 26),
            ),
            BoxShadow(
              color: colors.heroShadow.withValues(alpha: 0.30),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(
            color: colors.heroGlow.withValues(alpha: 0.18),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: const RadialGradientHighlight(),
      ),
    );
  }
}

class RadialGradientHighlight extends StatelessWidget {
  const RadialGradientHighlight({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.topCenter,
          radius: 0.9,
          colors: [
            colors.heroGlow.withValues(alpha: 0.30),
            colors.heroGlow.withValues(alpha: 0),
          ],
          stops: const [0.0, 0.6],
        ),
      ),
    );
  }
}

class _PatternOverlay extends StatelessWidget {
  const _PatternOverlay();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Opacity(
        opacity: 0.07,
        child: Image.asset(
          'assets/images/islamic-pattern.png',
          repeat: ImageRepeat.repeat,
          color: AppColors.white.withValues(alpha: 0.5),
          colorBlendMode: BlendMode.screen,
          errorBuilder: (_, _, _) => const SizedBox.shrink(),
        ),
      ),
    );
  }
}

class _AmberGlow extends StatelessWidget {
  const _AmberGlow();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return IgnorePointer(
      child: Container(
        width: 280,
        height: 280,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              colors.heroGlow.withValues(alpha: 0.32),
              colors.heroGlow.withValues(alpha: 0),
            ],
            stops: const [0.0, 0.7],
          ),
        ),
      ),
    );
  }
}

class _StreakHeader extends StatelessWidget {
  const _StreakHeader();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        RichText(
          text: TextSpan(
            style: AppTextStyles.eyebrow(
              fontSize: 8.5,
              tracking: 0.4,
              color: colors.heroInk.withValues(alpha: 0.55),
            ),
            children: [
              TextSpan(text: 'home.streak.eyebrow_prefix'.tr().toUpperCase()),
              TextSpan(
                text: 'home.streak.eyebrow_accent'.tr().toUpperCase(),
                style: AppTextStyles.eyebrow(
                  fontSize: 8.5,
                  tracking: 0.4,
                  color: colors.heroGold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StreakNumberRow extends StatelessWidget {
  const _StreakNumberRow({required this.countUp, required this.totalDays});

  final AnimationController countUp;
  final int totalDays;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const StreakFlame(size: 42),
        const SizedBox(width: 12),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _AnimatedNumber(controller: countUp, target: totalDays),
              const SizedBox(width: 10),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ResponsiveText(
                      'home.streak.days_word',
                      style: AppTextStyles.displaySmall.copyWith(
                        fontSize: 18,
                        height: 1,
                        letterSpacing: -0.3,
                        color: colors.heroGold,
                      ),
                    ),
                    const SizedBox(height: 3),
                    ResponsiveText(
                      'home.streak.in_a_row',
                      style: AppTextStyles.eyebrow(
                        fontSize: 8,
                        tracking: 0.34,
                        color: colors.heroInk.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AnimatedNumber extends StatefulWidget {
  const _AnimatedNumber({required this.controller, required this.target});

  final AnimationController controller;
  final int target;

  @override
  State<_AnimatedNumber> createState() => _AnimatedNumberState();
}

class _AnimatedNumberState extends State<_AnimatedNumber> {
  LinearGradient? _gradient;
  Rect? _cachedRect;
  Shader? _cachedShader;

  Shader _shaderFor(Rect rect) {
    if (_cachedRect == rect && _cachedShader != null) return _cachedShader!;
    _cachedRect = rect;
    return _cachedShader = _gradient!.createShader(rect);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      stops: const [0.0, 0.5, 1.0],
      colors: [colors.heroGoldLight, colors.heroGold, colors.heroAmber],
    );
    if (gradient != _gradient) {
      _gradient = gradient;
      _cachedRect = null;
      _cachedShader = null;
    }

    final numberStyle = AppTextStyles.numericLarge.copyWith(
      fontStyle: FontStyle.italic,
      fontSize: 56,
      height: 0.85,
      letterSpacing: -1.8,
      color: AppColors.white,
      shadows: [
        Shadow(
          color: colors.heroAmber.withValues(alpha: 0.18),
          blurRadius: 14,
          offset: const Offset(0, 2),
        ),
      ],
    );

    return RepaintBoundary(
      child: ShaderMask(
        shaderCallback: _shaderFor,
        child: AnimatedBuilder(
          animation: widget.controller,
          builder: (context, _) {
            final eased = Curves.easeOutCubic.transform(
              widget.controller.value,
            );
            final value = (widget.target * eased).round();
            return ResponsiveText('$value', style: numberStyle);
          },
        ),
      ),
    );
  }
}

class _DividerLine extends StatelessWidget {
  const _DividerLine();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      color: context.appColors.heroInk.withValues(alpha: 0.14),
    );
  }
}

class _WeekDots extends StatelessWidget {
  const _WeekDots({required this.progress, required this.todayIndex});

  final List<bool> progress;
  final int todayIndex;

  static const _labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        for (var i = 0; i < _labels.length; i++)
          _DayDot(
            label: _labels[i],
            done: progress.length > i ? progress[i] : false,
            isToday: i == todayIndex,
          ),
      ],
    );
  }
}

class _DayDot extends StatelessWidget {
  const _DayDot({
    required this.label,
    required this.done,
    required this.isToday,
  });

  final String label;
  final bool done;
  final bool isToday;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final Decoration decoration;

    if (done) {
      decoration = BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colors.heroGlow, colors.heroAmberDeep],
        ),
        border: Border.all(color: colors.heroGlow.withValues(alpha: 0.7)),
        boxShadow: [
          BoxShadow(
            color: colors.heroAmber.withValues(alpha: 0.40),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      );
    } else if (isToday) {
      decoration = BoxDecoration(
        shape: BoxShape.circle,
        color: colors.heroInk.withValues(alpha: 0.10),
        border: Border.all(color: colors.heroGold, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: colors.heroGlow.withValues(alpha: 0.14),
            blurRadius: 0,
            spreadRadius: 4,
          ),
        ],
      );
    } else {
      decoration = BoxDecoration(
        shape: BoxShape.circle,
        color: colors.heroInk.withValues(alpha: 0.06),
        border: Border.all(color: colors.heroInk.withValues(alpha: 0.14)),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(3.5),
          decoration: decoration,
          alignment: Alignment.center,
          child: Icon(
            Icons.check_rounded,
            size: 11,
            color: done ? colors.heroInk : Colors.transparent,
          ),
        ),
        const SizedBox(height: 6),
        ResponsiveText(
          label,
          style: AppTextStyles.eyebrow(
            fontSize: 8,
            tracking: 0.22,
            color: isToday
                ? colors.heroGold
                : colors.heroInk.withValues(alpha: 0.45),
          ),
        ),
      ],
    );
  }
}

/// Hand-painted flame matching the streak hero in `Zad Home v2`.
///
/// Renders an outer flame silhouette with a luminous inner core, wrapped in
/// a softly pulsing amber halo.
class StreakFlame extends StatefulWidget {
  const StreakFlame({super.key, this.size = 64});

  final double size;

  @override
  State<StreakFlame> createState() => _StreakFlameState();
}

class _StreakFlameState extends State<StreakFlame>
    with TickerProviderStateMixin {
  late final AnimationController _flicker = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3600),
  );

  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  );

  bool _animating = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // No point burning frames animating a flame that's masked by the
    // skeleton shimmer. Pause both loops until the real streak data lands.
    // (Off-screen scrolling is already handled — ListView disposes children
    // past its cache extent, which fires [dispose] below.)
    final shouldAnimate = !(Skeletonizer.maybeOf(context)?.enabled ?? false);
    if (shouldAnimate == _animating) return;
    _animating = shouldAnimate;
    if (shouldAnimate) {
      _flicker.repeat();
      _pulse.repeat(reverse: true);
    } else {
      _flicker.stop();
      _pulse.stop();
    }
  }

  @override
  void dispose() {
    _flicker.dispose();
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = widget.size;
    final h = widget.size * (78 / 64);

    return SizedBox(
      width: w,
      height: h,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          AnimatedBuilder(
            animation: _pulse,
            builder: (context, _) {
              final t = _pulse.value;
              final scale = 1.0 + 0.12 * t;
              final opacity = 0.55 + 0.45 * t;
              return Transform.scale(
                scale: scale,
                child: Container(
                  width: w + 44,
                  height: h + 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      radius: 0.5,
                      colors: [
                        AppColors.flameHalo.withValues(alpha: 0.55 * opacity),
                        AppColors.flameHalo.withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          RepaintBoundary(
            child: AnimatedBuilder(
              animation: _flicker,
              builder: (context, _) {
                return CustomPaint(
                  size: Size(w * (54 / 64), h * (68 / 78)),
                  painter: _FlamePainter(progress: _flicker.value),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FlamePainter extends CustomPainter {
  _FlamePainter({required this.progress});

  final double progress;

  static const _outerRect = Rect.fromLTWH(0, 6, 64, 72);
  static const _innerRect = Rect.fromLTWH(22, 22, 20, 52);

  static const _outerStops = [
    AppColors.flameLight,
    AppColors.flameGold,
    AppColors.amber,
    AppColors.date,
  ];

  static final _innerStops = [
    AppColors.flameCore,
    AppColors.flameGold,
    AppColors.amber.withValues(alpha: 0.6),
  ];

  // Shaders depend only on rect (which is constant) and gradient colors —
  // cache once, reuse across every paint.
  static final Shader _outerShader = const LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: _outerStops,
    stops: [0.0, 0.45, 0.78, 1.0],
  ).createShader(_outerRect);

  static final Shader _innerShader = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: _innerStops,
    stops: const [0.0, 0.6, 1.0],
  ).createShader(_innerRect);

  static final Path _outerPath = Path()
    ..moveTo(32, 4)
    ..cubicTo(38, 18, 50, 24, 52, 40)
    ..cubicTo(54, 56, 46, 70, 32, 74)
    ..cubicTo(18, 70, 10, 56, 12, 40)
    ..cubicTo(14, 28, 22, 22, 26, 12)
    ..cubicTo(28, 18, 30, 22, 32, 4)
    ..close();

  static final Path _innerPath = Path()
    ..moveTo(32, 22)
    ..cubicTo(36, 30, 42, 36, 42, 48)
    ..cubicTo(42, 60, 36, 68, 32, 70)
    ..cubicTo(28, 68, 22, 60, 22, 48)
    ..cubicTo(22, 38, 28, 32, 32, 22)
    ..close();

  static final Paint _outerStrokePaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 0.6
    ..color = AppColors.date.withValues(alpha: 0.5);

  static final Paint _outerFillPaint = Paint()..shader = _outerShader;
  static final Paint _innerFillPaint = Paint()..shader = _innerShader;
  static final Paint _corePaint = Paint()
    ..color = AppColors.flameCore.withValues(alpha: 0.85);

  static const _coreRect = Rect.fromLTWH(26, 47, 12, 18);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 64, size.height / 80);

    // Subtle flicker around the bottom of the flame.
    final phase = progress * 2 * math.pi;
    final sx = 1 + 0.04 * math.sin(phase);
    final sy = 1 - 0.02 * math.sin(phase + 1.2);
    canvas.translate(32, 80);
    canvas.scale(sx, sy);
    canvas.translate(-32, -80);

    // Outer flame body. (Glow comes from the parent _pulse halo — no
    // MaskFilter.blur here; that was the dominant per-frame cost.)
    canvas.drawPath(_outerPath, _outerFillPaint);
    canvas.drawPath(_outerPath, _outerStrokePaint);

    // Brighter inner flame + glowing core ellipse.
    canvas.drawPath(_innerPath, _innerFillPaint);
    canvas.drawOval(_coreRect, _corePaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _FlamePainter old) =>
      // Sub-frame progress changes are visually imperceptible; throttle to
      // ~0.5% deltas to roughly halve repaint frequency.
      (old.progress - progress).abs() > 0.005;
}
