import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/services/core_service_locator.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../theme/theme.dart';
import '../../../streak/presentation/cubit/streak_cubit.dart';
import '../../../teams/presentation/cubit/teams_cubit.dart';
import '../../data/models/hadith_model.dart';
import '../../data/models/home_overview_model.dart';
import '../cubit/home_cubit.dart';
import '../cubit/home_state.dart';
import '../widgets/home_backdrop_pattern.dart';
import '../widgets/home_loaded_content.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<HomeCubit>(
          create: (_) => sl<HomeCubit>()..getOverview(),
        ),
        BlocProvider<StreakCubit>(
          create: (_) => sl<StreakCubit>()..load(),
        ),
        BlocProvider<TeamsCubit>(
          create: (_) => sl<TeamsCubit>()..loadTeamStatus(),
        ),
      ],
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    final content = SafeArea(
      bottom: false,
      child: BlocBuilder<HomeCubit, HomeState>(
        buildWhen: (a, b) => a.status != b.status || a.overview != b.overview,
        builder: (context, state) {
          if (state.isError && !state.hasOverview) {
            return ErrorState(
              message: state.errorMessage ?? 'home.load_failed'.tr(),
              onRetry: () => context.read<HomeCubit>().getOverview(),
            );
          }
          final showSkeleton =
              state.isInitial || state.isLoading || !state.hasOverview;
          final overview = state.overview ?? _placeholderOverview;
          return RefreshIndicator(
            color: colors.olive,
            onRefresh: () async {
              await Future.wait([
                context.read<HomeCubit>().getOverview(refresh: true),
                context.read<StreakCubit>().load(refresh: true),
              ]);
            },
            child: Skeletonizer(
              enabled: showSkeleton,
              child: HomeLoadedContent(overview: overview),
            ),
          );
        },
      ),
    );

    // Dark mode relies on the global Date & Ember backdrop (injected in
    // main.dart); light keeps its own cream backdrop + pattern.
    if (context.isDark) return content;
    return ColoredBox(
      color: colors.canvas,
      child: Stack(
        children: [
          const Positioned.fill(child: HomeBackdropPattern()),
          content,
        ],
      ),
    );
  }
}

/// Lookalike payload used while the real overview loads, so [Skeletonizer]
/// has shapes of the right size to mask.
const _placeholderOverview = HomeOverviewModel(
  hadithOfDay: HadithModel(
    id: 0,
    source: '────────────────',
    arabic: '──────────────────────',
    english:
        '─────────────────────────────────────────────────────────────',
    narrator: '──────────────',
    hadithNumber: 0,
  ),
);
