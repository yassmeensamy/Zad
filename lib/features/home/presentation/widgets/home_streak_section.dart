import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/widgets/responsive_text.dart';
import '../../../../theme/theme.dart';
import '../../../streak/presentation/cubit/streak_cubit.dart';
import '../../../streak/presentation/cubit/streak_state.dart';
import '../../../streak/presentation/widgets/streak_hero.dart';
import '../../../user/presentation/cubit/user_cubit.dart';

/// Home's adapter over the streak feature: binds [StreakCubit] to
/// [StreakHero] and owns the section's loading and failure presentation.
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
        if (state.isError && !state.hasStreak) {
          return _StreakError(
            onRetry: () => context.read<StreakCubit>().load(),
          );
        }
        final colors = context.appColors;
        return Skeletonizer(
          enabled: !state.hasStreak,
          effect: ShimmerEffect(
            baseColor: colors.heroSurfaceTop.withValues(alpha: 0.55),
            highlightColor: colors.heroSurfaceMid.withValues(alpha: 0.85),
          ),
          child: StreakHero(
            streakDays: state.streakDays,
            weekProgress: state.weekProgress,
            todayIndex: state.todayIndex,
            // Points ride along with the streak: both answer "what has my
            // effort added up to". Null until the profile lands, which keeps
            // the badge off rather than flashing a zero.
            points: context.select<UserCubit, int?>(
              (cubit) => cubit.state.user?.totalPoints,
            ),
          ),
        );
      },
    );
  }
}

class _StreakError extends StatelessWidget {
  const _StreakError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [colors.heroSurfaceTop, colors.heroSurfaceBottom],
        ),
        border: Border.all(color: colors.heroGlow.withValues(alpha: 0.18)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 12, 16),
        child: Row(
          children: [
            Icon(
              Icons.local_fire_department_outlined,
              size: 24,
              color: colors.heroGold,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ResponsiveText(
                'home.streak.load_failed',
                style: AppTextStyles.bodySmall.copyWith(
                  fontSize: 12.5,
                  height: 1.4,
                  color: colors.heroInk.withValues(alpha: 0.82),
                ),
              ),
            ),
            const SizedBox(width: 4),
            TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const ResponsiveText('common.retry'),
              style: TextButton.styleFrom(
                foregroundColor: colors.heroGold,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                textStyle: AppTextStyles.labelSmall.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
