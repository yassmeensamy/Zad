import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../streak/presentation/cubit/streak_cubit.dart';
import '../../../streak/presentation/cubit/streak_state.dart';
import 'streak_hero.dart';

/// Home streak block: the [StreakHero] banner, masked by [Skeletonizer] while
/// the streak data loads.
class HomeStreakSection extends StatelessWidget {
  const HomeStreakSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StreakCubit, StreakState>(
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
