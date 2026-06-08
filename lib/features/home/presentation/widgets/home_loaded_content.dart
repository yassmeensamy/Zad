import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/navigation/app_routes.dart';
import '../../../user/presentation/cubit/user_cubit.dart';
import '../../../user/presentation/cubit/user_state.dart';
import '../../data/models/home_overview_model.dart';
import 'hadith_card.dart';
import 'home_header.dart';
import 'home_streak_section.dart';
import 'home_team_section.dart';
import 'home_verse_card.dart';
import 'play_card.dart';

/// Horizontal page gutter shared by every section of the home screen.
const double _kGutter = 24;

/// The scrollable body of the home screen once the overview has loaded:
/// header → streak → play → team → hadith, each inset by [_kGutter].
class HomeLoadedContent extends StatelessWidget {
  const HomeLoadedContent({required this.overview, super.key});

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
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: _kGutter),
              child: HomeHeader(
                firstName: _firstName(
                  fullName,
                  fallback: 'home.fallback_name'.tr(),
                ),
                onBellTap: () => context.pushNamed(AppRoutes.notificationsName),
              ),
            );
          },
        ),
        const SizedBox(height: 26),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: _kGutter),
          child: HomeStreakSection(),
        ),
        const SizedBox(height: 14),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: _kGutter),
          child: PlayCard(
            onTap: () => context.goNamed(AppRoutes.categoriesName),
          ),
        ),
        const SizedBox(height: 14),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: _kGutter),
          child: HomeTeamSection(),
        ),
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
  }

  static String _firstName(String? fullName, {required String fallback}) {
    final trimmed = fullName?.trim() ?? '';
    if (trimmed.isEmpty) return fallback;
    return trimmed.split(RegExp(r'\s+')).first;
  }
}
