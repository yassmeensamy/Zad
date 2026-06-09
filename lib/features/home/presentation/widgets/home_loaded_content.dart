import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/navigation/app_routes.dart';
import '../../../levels/presentation/screens/celebration.dart';
import '../../../teams/presentation/screens/temp_team_home.dart';
import '../../../user/presentation/cubit/user_cubit.dart';
import '../../../user/presentation/cubit/user_state.dart';
import '../../data/models/home_overview_model.dart';
import 'hadith_card.dart';
import 'home_header.dart';
import 'home_streak_section.dart';
import 'home_team_section.dart';
import 'home_verse_card.dart';
import 'home_why_login_section.dart';
import 'play_card.dart';

const double _kGutter = 24;

class HomeLoadedContent extends StatelessWidget {
  const HomeLoadedContent({required this.overview, super.key});

  final HomeOverviewModel overview;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<UserCubit, UserState, bool>(
      selector: (state) => state.user?.isAnonymous ?? false,
      builder: (context, isGuest) {
        return ListView(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 120),
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          children: [
            BlocSelector<UserCubit, UserState, String?>(
              selector: (state) => state.user?.fullName,
              builder: (context, fullName) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: _kGutter),
                  child: HomeHeader(
                    firstName: _firstName(
                      fullName,
                      fallback: 'home.fallback_name'.tr(),
                    ),
                    onBellTap: () =>
                        context.pushNamed(AppRoutes.notificationsName),
                  ),
                );
              },
            ),
            const SizedBox(height: 26),
            if (!isGuest) ...[
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: _kGutter),
                child: HomeStreakSection(),
              ),
              const SizedBox(height: 14),
            ],
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: _kGutter),
              child: PlayCard(
                onTap: () => context.goNamed(AppRoutes.categoriesName),
              ),
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: _kGutter),
              child: OutlinedButton.icon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => LevelCompleteCelebration(
                      eyebrow: 'LEVEL 6 · COMPLETE',
                      title: 'Level Complete',
                      arabic: 'أَحْسَنْتَ!',
                      subtitle: const Text(
                        'You answered 10 / 10 — a flawless round, mā shāʾ Allāh.',
                        textAlign: TextAlign.center,
                      ),
                      stats: const [
                        CelebrationStat(
                          value: '10',
                          suffix: '/10',
                          label: 'Correct',
                        ),
                        CelebrationStat(value: '2:14', label: 'Time'),
                        CelebrationStat(
                          value: '100',
                          suffix: '%',
                          label: 'Accuracy',
                          fire: true,
                        ),
                      ],
                      xp: 250,
                    ),
                  ),
                ),
                icon: const Icon(Icons.emoji_events_rounded),
                label: const Text('Level Complete Celebration'),
              ),
            ),
            const SizedBox(height: 14),
            if (isGuest)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: _kGutter),
                child: HomeWhyLoginSection(),
              )
            else ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: _kGutter),
                child: OutlinedButton.icon(
                  onPressed: () =>
                      context.pushNamed(AppRoutes.dateEmberLeaderboardName),
                  icon: const Icon(Icons.local_fire_department_rounded),
                  label: Text('home.date_ember_cta'.tr()),
                ),
              ),
              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: _kGutter),
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const TempTeamHomeScreen(),
                    ),
                  ),
                  icon: const Icon(Icons.groups_rounded),
                  label: const Text('Team Home · Community'),
                ),
              ),
              const SizedBox(height: 14),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: _kGutter),
                child: HomeTeamSection(),
              ),
            ],
            const SizedBox(height: 26),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: _kGutter),
              child: HadithSectionHeader(),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: _kGutter),
              child: HomeVerseCard(),
            ),
            const SizedBox(height: 8),
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
}
