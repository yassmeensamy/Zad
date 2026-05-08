import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';

import '../../../../theme/theme.dart';
import 'eight_point_star.dart';
import 'streak_flame.dart';

class StreakHero extends StatefulWidget {
  const StreakHero({
    super.key,
    required this.streakDays,
    required this.weekProgress,
    required this.todayIndex,
    this.onShareTap,
  });

  /// Total streak count (animates from 0 → [streakDays] on mount).
  final int streakDays;

  /// 7 booleans, Mon → Sun, indicating completed days this week.
  final List<bool> weekProgress;

  /// Index in [weekProgress] for today (highlights with a ring).
  final int todayIndex;

  final VoidCallback? onShareTap;

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
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Stack(
        children: [
          _buildBackground(),
          const Positioned.fill(child: _PatternOverlay()),

          const Positioned(
            top: -26,
            right: -26,
            child: EightPointStar(
              size: 140,
              color: AppColors.amberGlow,
              opacity: 0.10,
            ),
          ),

          const Positioned(top: -90, right: -80, child: _AmberGlow()),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _StreakHeader(onShareTap: widget.onShareTap),
                const SizedBox(height: 8),
                _StreakNumberRow(
                  countUp: _countUp,
                  totalDays: widget.streakDays,
                ),
                const SizedBox(height: 8),
                Text(
                  'home.streak.motto_en'.tr(),
                  style: AppTextStyles.bodySmall.copyWith(
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w300,
                    height: 1.35,
                    color: AppColors.ivory.withValues(alpha: 0.82),
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

  Widget _buildBackground() {
    return Positioned.fill(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.0, 0.6, 1.0],
            colors: [
              AppColors.olive,
              AppColors.oliveDeep,
              AppColors.oliveAbyss,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowDeep.withValues(alpha: 0.45),
              blurRadius: 50,
              offset: const Offset(0, 26),
            ),
            BoxShadow(
              color: AppColors.shadowDeep.withValues(alpha: 0.30),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(
            color: AppColors.amberGlow.withValues(alpha: 0.18),
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
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.topCenter,
          radius: 0.9,
          colors: [
            AppColors.amberGlow.withValues(alpha: 0.30),
            AppColors.amberGlow.withValues(alpha: 0),
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
    return IgnorePointer(
      child: Container(
        width: 280,
        height: 280,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              AppColors.amberGlow.withValues(alpha: 0.32),
              AppColors.amberGlow.withValues(alpha: 0),
            ],
            stops: const [0.0, 0.7],
          ),
        ),
      ),
    );
  }
}

class _StreakHeader extends StatelessWidget {
  const _StreakHeader({this.onShareTap});

  final VoidCallback? onShareTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        RichText(
          text: TextSpan(
            style: AppTextStyles.labelSmall.copyWith(
              fontSize: 8.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 8.5 * 0.4,
              color: AppColors.ivory.withValues(alpha: 0.55),
            ),
            children: [
              TextSpan(text: 'home.streak.eyebrow_prefix'.tr().toUpperCase()),
              TextSpan(
                text: 'home.streak.eyebrow_accent'.tr().toUpperCase(),
                style: const TextStyle(color: AppColors.flameGold),
              ),
            ],
          ),
        ),
        _ShareButton(onTap: onShareTap),
      ],
    );
  }
}

class _ShareButton extends StatelessWidget {
  const _ShareButton({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.ivory.withValues(alpha: 0.06),
            border: Border.all(
              color: AppColors.ivory.withValues(alpha: 0.16),
            ),
          ),
          child: const Icon(
            Icons.ios_share_rounded,
            size: 14,
            color: AppColors.ivory,
          ),
        ),
      ),
    );
  }
}

class _StreakNumberRow extends StatelessWidget {
  const _StreakNumberRow({required this.countUp, required this.totalDays});

  final AnimationController countUp;
  final int totalDays;

  @override
  Widget build(BuildContext context) {
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
                    Text(
                      'home.streak.days_word'.tr(),
                      style: AppTextStyles.displaySmall.copyWith(
                        fontSize: 18,
                        height: 1,
                        letterSpacing: -0.3,
                        color: AppColors.flameGold,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'home.streak.in_a_row'.tr(),
                      style: AppTextStyles.labelSmall.copyWith(
                        fontSize: 8,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 8 * 0.34,
                        color: AppColors.ivory.withValues(alpha: 0.5),
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

class _AnimatedNumber extends StatelessWidget {
  const _AnimatedNumber({required this.controller, required this.target});

  final AnimationController controller;
  final int target;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final eased = Curves.easeOutCubic.transform(controller.value);
        final value = (target * eased).round();
        return ShaderMask(
          shaderCallback: (rect) => const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.0, 0.5, 1.0],
            colors: [
              AppColors.flameLight,
              AppColors.flameGold,
              AppColors.amber,
            ],
          ).createShader(rect),
          child: Text(
            '$value',
            style: AppTextStyles.numericLarge.copyWith(
              fontStyle: FontStyle.italic,
              fontSize: 56,
              height: 0.85,
              letterSpacing: -1.8,
              color: AppColors.white,
              shadows: [
                Shadow(
                  color: AppColors.amber.withValues(alpha: 0.18),
                  blurRadius: 14,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DividerLine extends StatelessWidget {
  const _DividerLine();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      color: AppColors.ivory.withValues(alpha: 0.14),
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
    final Decoration decoration;
    Widget child = const SizedBox.shrink();

    if (done) {
      decoration = BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.amberGlow, AppColors.amberDeep],
        ),
        border: Border.all(
          color: AppColors.amberGlow.withValues(alpha: 0.7),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.amber.withValues(alpha: 0.40),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      );
      child = const Icon(Icons.check_rounded, size: 11, color: AppColors.ivory);
    } else if (isToday) {
      decoration = BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.ivory.withValues(alpha: 0.10),
        border: Border.all(color: AppColors.flameGold, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.amberGlow.withValues(alpha: 0.14),
            blurRadius: 0,
            spreadRadius: 4,
          ),
        ],
      );
    } else {
      decoration = BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.ivory.withValues(alpha: 0.06),
        border: Border.all(
          color: AppColors.ivory.withValues(alpha: 0.14),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 18,
          height: 18,
          decoration: decoration,
          alignment: Alignment.center,
          child: child,
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            fontSize: 8,
            fontWeight: FontWeight.w700,
            letterSpacing: 8 * 0.22,
            color: isToday
                ? AppColors.flameGold
                : AppColors.ivory.withValues(alpha: 0.45),
          ),
        ),
      ],
    );
  }
}
