import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/navigation/app_routes.dart';
import '../../../../core/services/core_service_locator.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../core/widgets/zaad_primary_button.dart';
import '../../../../theme/theme.dart';
import '../../../leaderboard/presentation/screens/date_ember_leaderboard_screen.dart';
import '../../../profile/presentation/screens/date_ember_profile_screen.dart';
import '../../../streak/presentation/cubit/streak_cubit.dart';
import '../../../streak/presentation/cubit/streak_state.dart';
import '../../../user/presentation/cubit/user_cubit.dart';
import '../../../user/presentation/cubit/user_state.dart';
import '../../data/models/hadith_model.dart';
import '../../data/models/home_overview_model.dart';
import '../cubit/home_cubit.dart';
import '../cubit/home_state.dart';
import '../widgets/hadith_card.dart';
import '../widgets/home_header.dart';
import '../widgets/join_team_card.dart';
import '../widgets/play_card.dart';
import '../widgets/streak_hero.dart';

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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final content = SafeArea(
            bottom: false,
            child: BlocBuilder<HomeCubit, HomeState>(
              buildWhen: (a, b) =>
                  a.status != b.status || a.overview != b.overview,
              builder: (context, state) {
                if (state.isError && !state.hasOverview) {
                  return ErrorState(
                    message: state.errorMessage ?? 'home.load_failed',
                    onRetry: () =>
                        context.read<HomeCubit>().getOverview(),
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
                    child: _LoadedContent(overview: overview),
                  ),
                );
              },
            ),
          );

    // Dark mode relies on the global Date & Ember backdrop (injected in
    // main.dart); light keeps its own cream backdrop + pattern.
    if (isDark) return content;
    return ColoredBox(
      color: colors.canvas,
      child: Stack(
        children: [
          const Positioned.fill(child: _BackdropPattern()),
          content,
        ],
      ),
    );
  }
}

class _LoadedContent extends StatelessWidget {
  const _LoadedContent({required this.overview});

  final HomeOverviewModel overview;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 120),
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      children: [
        BlocSelector<UserCubit, UserState, String?>(
          selector: (state) => state.user?.fullName,
          builder: (context, fullName) {
            return HomeHeader(
              firstName: _firstName(
                fullName,
                fallback: 'home.fallback_name'.tr(),
              ),
              onBellTap: () => context.pushNamed(AppRoutes.notificationsName),
            );
          },
        ),
        const SizedBox(height: 26),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: _StreakSection(),
        ),
        const SizedBox(height: 14),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: PlayCard(
            onTap: () => context.goNamed(AppRoutes.categoriesName),
          ),
        ),
        const SizedBox(height: 14),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: JoinTeamCard(
            onTap: () => context.pushNamed(AppRoutes.teamsName),
          ),
        ),
        const SizedBox(height: 14),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: ZaadPrimaryButton(
            label: 'Date & Ember Leaderboard',
            leadingIcon: Icons.local_fire_department,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const DateEmberLeaderboardScreen(),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: ZaadPrimaryButton(
            label: 'Date & Ember Profile',
            leadingIcon: Icons.person_outline,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const DateEmberProfileScreen(),
              ),
            ),
          ),
        ),
        const SizedBox(height: 26),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: HadithSectionHeader(),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: HadithCard(hadith: overview.hadithOfDay),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  static String _firstName(String? fullName, {required String fallback}) {
    final trimmed = fullName?.trim() ?? '';
    if (trimmed.isEmpty) return fallback;
    return trimmed.split(RegExp(r'\s+')).first;
  }
}

class _StreakSection extends StatelessWidget {
  const _StreakSection();

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

class _BackdropPattern extends StatelessWidget {
  const _BackdropPattern();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return IgnorePointer(
      child: DecoratedBox(
        // Dark: roasted-brown radial vignette (raised → surface → base),
        // lifted from the Date & Ember design. Light keeps the cream linear
        // wash.
        decoration: BoxDecoration(
          gradient: isDark
              ? RadialGradient(
                  center: const Alignment(0, -1.05),
                  radius: 1.4,
                  colors: [
                    colors.backdropTop,
                    colors.backdropMid,
                    colors.backdropBottom,
                  ],
                  stops: const [0.0, 0.42, 1.0],
                )
              : LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [colors.backdropTop, colors.backdropBottom],
                ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Warm amber wash glowing from just above the top edge — the
            // signature Date & Ember light source.
            if (isDark)
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(0, -0.95),
                    radius: 0.9,
                    colors: [
                      colors.accent.withValues(alpha: 0.16),
                      colors.accent.withValues(alpha: 0),
                    ],
                    stops: const [0.0, 0.65],
                  ),
                ),
              ),
            Opacity(
              opacity: isDark ? 0.05 : 0.07,
              child: Image.asset(
                'assets/images/islamic-pattern.png',
                repeat: ImageRepeat.repeat,
                errorBuilder: (_, _, _) => const SizedBox.shrink(),
              ),
            ),
          ],
        ),
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
