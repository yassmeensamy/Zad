import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/models/user_model.dart';
import '../../../../core/navigation/app_routes.dart';
import '../../../../core/services/core_service_locator.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../core/widgets/light_mode_backdrop.dart';
import '../../../../core/widgets/responsive_text.dart';
import '../../../../theme/theme.dart';
import '../../../teams/data/models/team_progress_model.dart';
import '../../../teams/presentation/widgets/team_number_one_dialog.dart';
import '../../../teams/presentation/widgets/team_week_stats.dart';
import '../../../quiz_stats/presentation/cubit/quiz_stats_cubit.dart';
import '../../../streak/presentation/cubit/streak_cubit.dart';
import '../../../streak/presentation/cubit/streak_state.dart';
import '../../../teams/presentation/cubit/teams_cubit.dart';
import '../../../notification/presentation/cubit/notification_badge_cubit.dart';
import '../../../user/presentation/cubit/user_cubit.dart';
import '../../../user/presentation/cubit/user_state.dart';
import '../../data/models/quran_sign_model.dart';
import '../cubit/quran_sign_cubit.dart';
import '../cubit/quran_sign_state.dart';
import '../widgets/home_backdrop_pattern.dart';
import '../widgets/home_header.dart';
import '../widgets/home_streak_section.dart';
import '../widgets/home_team_section.dart';
import '../widgets/quran_sign_card.dart';
import '../widgets/home_why_login_section.dart';
import '../widgets/play_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<QuranSignCubit>(
          create: (_) => sl<QuranSignCubit>()..load(),
        ),
        BlocProvider<StreakCubit>(
          create: (_) => sl<StreakCubit>()..load(),
        ),
        BlocProvider<TeamsCubit>(
          create: (_) => sl<TeamsCubit>()
            ..loadTeamStatus()
            ..loadTeamProgress(),
        ),
        BlocProvider<QuizStatsCubit>(
          create: (_) => sl<QuizStatsCubit>()..load(),
        ),
        BlocProvider<NotificationBadgeCubit>(
          create: (_) => sl<NotificationBadgeCubit>()..refresh(),
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
      child: BlocBuilder<QuranSignCubit, QuranSignState>(
        buildWhen: (a, b) => a.status != b.status || a.sign != b.sign,
        builder: (context, state) {
          if (state.isError && !state.hasSign) {
            return ErrorState(
              message: state.errorMessage ?? 'home.load_failed'.tr(),
              onRetry: () => context.read<QuranSignCubit>().load(),
            );
          }
          final showSkeleton =
              state.isInitial || state.isLoading || !state.hasSign;
          final sign = state.sign ?? _placeholderSign;
          return RefreshIndicator(
            color: colors.olive,
            onRefresh: () async {
              await Future.wait([
                context.read<QuranSignCubit>().load(refresh: true),
                context.read<StreakCubit>().load(refresh: true),
                context.read<QuizStatsCubit>().refresh(),
                context.read<TeamsCubit>().loadTeamProgress(),
              ]);
            },
            child: Skeletonizer(
              enabled: showSkeleton,
              child: HomeLoadedContent(sign: sign),
            ),
          );
        },
      ),
    );

    return LightModeBackdrop(
      backdrop: const HomeBackdropPattern(),
      child: content,
    );
  }
}

const double _kGutter = 24;

class HomeLoadedContent extends StatelessWidget {
  const HomeLoadedContent({required this.sign, super.key});

  final QuranSignModel sign;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<UserCubit, UserState, bool>(
      selector: (state) => state.user?.isAnonymous ?? false,
      builder: (context, isGuest) {
        final rows = <Widget>[
          BlocBuilder<UserCubit, UserState>(
            buildWhen: (a, b) => a.user != b.user,
            builder: (context, userState) {
              final user = userState.user;
              return BlocBuilder<NotificationBadgeCubit, int>(
                builder: (context, unreadCount) {
                  final progress = context.watch<TeamsCubit>().state.progress;
                  final streakDays =
                      context.watch<StreakCubit>().state.streakDays;
                  return HomeHeader(
                    firstName: _firstName(
                      user?.fullName,
                      fallback: 'home.fallback_name'.tr(),
                    ),
                    unreadCount: unreadCount,
                    onBellTap: () async {
                      await context.pushNamed(AppRoutes.notificationsName);
                      if (!context.mounted) return;
                      context.read<NotificationBadgeCubit>().refresh();
                    },
                    onCelebrateTap: _celebrationTrigger(
                      context,
                      user: user,
                      progress: progress,
                      streakDays: streakDays,
                    ),
                  );
                },
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
              'home.team.week_stats_title'.tr(),
              style: context.textTheme.titleMedium?.copyWith(
                color: context.appColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            const TeamWeekStats(),
          ],
          const SizedBox(height: 26),
          QuranSignCard(sign: sign),
          const SizedBox(height: 14),
          const SizedBox(height: 8),
        ];

        return CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            SliverPadding(
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

  
  static String _firstName(String? fullName, {required String fallback}) {
    final trimmed = fullName?.trim() ?? '';
    if (trimmed.isEmpty) return fallback;
    return trimmed.split(RegExp(r'\s+')).first;
  }

  static VoidCallback? _celebrationTrigger(
    BuildContext context, {
    required UserModel? user,
    required TeamProgressModel? progress,
    required int streakDays,
  }) {
    if (user == null || progress == null || !progress.isUserFirst(user.id)) {
      return null;
    }
    final companions = progress.members.length > 1
        ? progress.members.length - 1
        : 0;
    return () => TeamNumberOneCelebrationDialog.show(
      context: context,
      teamName: progress.teamName,
      companions: companions,
      leaderName: user.fullName,
      points: user.totalPoints,
      streak: streakDays,
    );
  }
}

const _placeholderSign = QuranSignModel(
  id: 0,
  text: '──────────────────────────────────────────────────────────────',
  referenceNumber: 0,
  surahName: '────',
  madaniNumber: 0,
);
