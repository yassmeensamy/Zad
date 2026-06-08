import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/navigation/app_routes.dart';
import '../../../../temp.dart';
import '../../../../theme/theme.dart';
import '../../../teams/presentation/cubit/teams_cubit.dart';
import '../../../teams/presentation/cubit/teams_state.dart';

/// Home team block: shows the [TempTeamCard] summary once the user belongs to a
/// circle, otherwise the [TempJoinTeamCard] prompt — the two states of the
/// "My Team" section from the Date & Ember home design.
class HomeTeamSection extends StatelessWidget {
  const HomeTeamSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TeamsCubit, TeamsState>(
      // When the team resolves, pull the auxiliary data the summary needs
      // (rank + member avatars) — but only once.
      listenWhen: (a, b) => a.status != b.status,
      listener: (context, state) {
        if (state.hasTeam) {
          final cubit = context.read<TeamsCubit>();
          if (state.members == null) cubit.loadTeamMembers();
          if (state.summary == null) cubit.loadTeamProgress();
        }
      },
      buildWhen: (a, b) =>
          a.status != b.status ||
          a.team != b.team ||
          a.members != b.members ||
          a.summary != b.summary,
      builder: (context, state) {
        void openTeam() => context.pushNamed(AppRoutes.teamsName);
        final team = state.team;
        // Render the Date & Ember design prototypes (temp.dart) for the team
        // block: the "Walk the path together" join card before joining, and
        // the team summary card once in a circle.
        if (!state.hasTeam || team == null) {
          return GestureDetector(
            onTap: openTeam,
            behavior: HitTestBehavior.opaque,
            child: const TempJoinTeamCard(),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _TeamSectionHeader(onOpen: openTeam),
            const SizedBox(height: 11),
            GestureDetector(
              onTap: openTeam,
              behavior: HitTestBehavior.opaque,
              child: const TempTeamCard(),
            ),
          ],
        );
      },
    );
  }
}

/// "My team · Open →" label row above the joined [TempTeamCard].
class _TeamSectionHeader extends StatelessWidget {
  const _TeamSectionHeader({required this.onOpen});

  final VoidCallback onOpen;

  // Eyebrow tracking — a tight cap-height label on the left, a looser
  // all-caps action on the right.
  static const double _eyebrowTracking = 3.06;
  static const double _actionTracking = 1.52;
  static const double _dividerWidth = 16;
  static const double _dividerHeight = 1;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Row(
      children: [
        Container(
          width: _dividerWidth,
          height: _dividerHeight,
          color: colors.accent,
        ),
        const SizedBox(width: 8),
        Text(
          'home.team.joined_eyebrow'.tr(),
          style: AppTextStyles.labelSmall.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: _eyebrowTracking,
            color: colors.accent,
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: onOpen,
          behavior: HitTestBehavior.opaque,
          child: Text(
            'home.team.open'.tr().toUpperCase(),
            style: AppTextStyles.labelSmall.copyWith(
              fontWeight: FontWeight.w600,
              letterSpacing: _actionTracking,
              color: colors.accent,
            ),
          ),
        ),
      ],
    );
  }
}
