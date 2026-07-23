import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';

import '../../../../core/widgets/eight_point_star.dart';
import '../../../../core/widgets/responsive_text.dart';
import '../../../../theme/theme.dart';
import 'streak_count_up.dart';
import 'streak_flame.dart';
import 'week_dots.dart';

class StreakHero extends StatelessWidget {
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
                _StreakNumberRow(totalDays: streakDays),
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
                WeekDots(progress: weekProgress, todayIndex: todayIndex),
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
        child: const _RadialGradientHighlight(),
      ),
    );
  }
}

class _RadialGradientHighlight extends StatelessWidget {
  const _RadialGradientHighlight();

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
              fontSize: 14,
              tracking: 0.4,
              color: colors.heroInk.withValues(alpha: 0.55),
            ),
            children: [
              TextSpan(text: 'home.streak.eyebrow_prefix'.tr().toUpperCase()),
              TextSpan(
                text: 'home.streak.eyebrow_accent'.tr().toUpperCase(),
                style: AppTextStyles.eyebrow(
                  fontSize: 14,
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
  const _StreakNumberRow({required this.totalDays});

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
              StreakCountUp(target: totalDays),
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
