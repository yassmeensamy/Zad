import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/navigation/app_routes.dart';
import '../../../../core/services/core_service_locator.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../core/widgets/light_mode_backdrop.dart';
import '../../../../core/widgets/responsive_text.dart';
import '../../../../theme/theme.dart';
import '../../../teams/presentation/widgets/team_week_stats.dart';
import '../../../streak/presentation/cubit/streak_cubit.dart';
import '../../../teams/presentation/cubit/teams_cubit.dart';
import '../../../teams/presentation/screens/temp_team_home.dart';
import '../../../user/presentation/cubit/user_cubit.dart';
import '../../../user/presentation/cubit/user_state.dart';
import '../../data/models/hadith_model.dart';
import '../../data/models/home_overview_model.dart';
import '../cubit/home_cubit.dart';
import '../cubit/home_state.dart';
import '../widgets/home_backdrop_pattern.dart';
import '../widgets/home_header.dart';
import '../widgets/home_streak_section.dart';
import '../widgets/home_team_section.dart';
import '../widgets/hadith_card.dart';
import '../widgets/home_why_login_section.dart';
import '../widgets/play_card.dart';

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

    // Dark mode relies on the global Date & Ember backdrop (injected in the
    // shell's AppScaffold); light keeps its own cream backdrop + pattern.
    // The optional update prompt is owned by the home shell, not this screen.
    return LightModeBackdrop(
      backdrop: const HomeBackdropPattern(),
      child: content,
    );
  }
}

const double _kGutter = 24;

class HomeLoadedContent extends StatelessWidget {
  const HomeLoadedContent({required this.overview, super.key});

  final HomeOverviewModel overview;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<UserCubit, UserState, bool>(
      selector: (state) => state.user?.isAnonymous ?? false,
      builder: (context, isGuest) {
        // Flatten the rows once, then hand them to a builder delegate so only
        // on-screen children are built (a plain ListView(children:) builds the
        // whole list eagerly via SliverChildListDelegate).
        final rows = <Widget>[
          BlocSelector<UserCubit, UserState, String?>(
            selector: (state) => state.user?.fullName,
            builder: (context, fullName) {
              return HomeHeader(
                firstName: _firstName(
                  fullName,
                  fallback: 'home.fallback_name'.tr(),
                ),
                onBellTap: () =>
                    context.pushNamed(AppRoutes.notificationsName),
              );
            },
          ),
          const SizedBox(height: 26),
          if (!isGuest) ...[
            const HomeStreakSection(),
            const SizedBox(height: 14),
          ],
          PlayCard(
            onTap: () => context.goNamed(AppRoutes.categoriesName),
          ),
          const SizedBox(height: 14),
          if (isGuest)
            const HomeWhyLoginSection()
          else ...[
            const HomeTeamSection(),
            const SizedBox(height: 26),
            ResponsiveText(
              'This week · team stats',
              style: context.textTheme.titleMedium?.copyWith(
                color: context.appColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            const TeamWeekStats(),
          ],
          const SizedBox(height: 26),
          HadithCard(hadith: overview.hadithOfDay),
          const SizedBox(height: 14),
          ElevatedButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const TempTeamHomeScreen(),
              ),
            ),
            child: const ResponsiveText('Team Home (preview)'),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () => _debugGetDeviceToken(context),
            child: const ResponsiveText('Get device token (debug)'),
          ),
          const SizedBox(height: 8),
        ];

        return CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            SliverPadding(
              // Horizontal gutter lives here so every child shares it; only a
              // full-bleed child would need to opt out via a negative margin.
              padding: const EdgeInsets.fromLTRB(_kGutter, 0, _kGutter, 120),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => rows[index],
                  childCount: rows.length,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _debugGetDeviceToken(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final token = await sl<NotificationService>().getDeviceToken();
      messenger.showSnackBar(
        SnackBar(content: Text('Token: $token')),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Token failed: $e')),
      );
    }
  }

  static String _firstName(String? fullName, {required String fallback}) {
    final trimmed = fullName?.trim() ?? '';
    if (trimmed.isEmpty) return fallback;
    return trimmed.split(RegExp(r'\s+')).first;
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
