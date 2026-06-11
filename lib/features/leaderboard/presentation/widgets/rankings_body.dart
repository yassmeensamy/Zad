import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/navigation/app_routes.dart';
import '../cubit/rankings_cubit.dart';
import '../cubit/rankings_state.dart';
import 'leaderboard_loading.dart';
import 'leaderboard_no_team.dart';
import 'leaderboard_rules.dart';
import 'leaderboard_states.dart';
import 'my_rank_card.dart';
import 'podium.dart';
import 'rank_seed.dart';
import 'ranking_row.dart';

/// Scrollable leaderboard content: handles the loading / error / empty / no-team
/// states, then renders the podium followed by the paginated ranking list.
class RankingsBody extends StatelessWidget {
  const RankingsBody({
    super.key,
    required this.state,
    required this.controller,
  });

  final RankingsState state;
  final ScrollController controller;

  @override
  Widget build(BuildContext context) {
    if (state.activeStatus == RankingsStatus.loading && state.activeIsEmpty) {
      return const LeaderboardLoading();
    }
    if (state.activeStatus == RankingsStatus.error && state.activeIsEmpty) {
      return LeaderboardErrorRetry(
        onRetry: () => context.read<RankingsCubit>().refresh(),
      );
    }
    if (state.isTeams &&
        state.teamStatus == RankingsStatus.success &&
        state.myTeamRank == null) {
      return LeaderboardNoTeam(
        onChanged: () => context.read<RankingsCubit>().refresh(),
      );
    }
    if (state.activeIsEmpty) {
      return const LeaderboardEmptyHint(textKey: 'leaderboard.empty');
    }

    return CustomScrollView(
      controller: controller,
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.only(bottom: 8),
          sliver: SliverList.list(
            children: [
              const PodiumEyebrow(label: 'PODIUM'),
              const SizedBox(height: 11),
              Podium(seeds: _podium(state)),
              const SizedBox(height: 14),
              AllMembersRule(count: state.activeCount),
              const SizedBox(height: 10),
            ],
          ),
        ),
        SliverList.separated(
          itemCount: state.activeCount,
          separatorBuilder: (_, _) => const SizedBox(height: 6),
          itemBuilder: (context, i) => RankingRow(seed: _rowAt(state, i)),
        ),
        if (state.loadingMore)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(top: 6),
              child: LeaderboardMoreLoading(),
            ),
          ),
      ],
    );
  }

  List<RankSeed> _podium(RankingsState state) => state.isIndividuals
      ? [
          for (final r in state.individuals.take(3))
            RankSeed(
              rank: r.rank,
              name: r.username,
              completed: r.completedLevels,
              total: r.totalLevels,
            ),
        ]
      : [
          for (final t in state.teams.take(3))
            RankSeed(
              rank: t.rank,
              name: t.teamName,
              completed: t.totalCompletedLevels,
              total: t.totalLevels,
            ),
        ];

  RankSeed _rowAt(RankingsState state, int i) {
    if (state.isIndividuals) {
      final r = state.individuals[i];
      final myRank = state.myRank?.rank;
      return RankSeed(
        rank: r.rank,
        name: r.username,
        completed: r.completedLevels,
        total: r.totalLevels,
        isMe: myRank != null && r.rank == myRank,
      );
    }
    final t = state.teams[i];
    final myRank = state.myTeamRank?.rank;
    return RankSeed(
      rank: t.rank,
      name: t.teamName,
      completed: t.totalCompletedLevels,
      total: t.totalLevels,
      subtitle: 'leaderboard.member_count'.plural(
        t.memberCount,
        args: ['${t.memberCount}'],
      ),
      isMe: myRank != null && t.rank == myRank,
    );
  }
}

/// The bottom "your rank" / "your team" card. Hidden until the user's own
/// standing is known.
class RankingsFooter extends StatelessWidget {
  const RankingsFooter({super.key, required this.state});

  final RankingsState state;

  @override
  Widget build(BuildContext context) {
    if (state.isIndividuals) {
      final me = state.myRank;
      if (me == null) return const SizedBox.shrink();
      return MyRankCard(
        label: 'leaderboard.your_rank'.tr(),
        rank: me.rank,
        title: 'leaderboard.you'.tr(),
        completed: me.completedLevels,
        total: me.totalLevels,
      );
    }
    final me = state.myTeamRank;
    if (me == null) return const SizedBox.shrink();
    return MyRankCard(
      label: 'leaderboard.your_team'.tr(),
      rank: me.rank,
      title: me.teamName,
      completed: me.totalCompletedLevels,
      total: me.totalLevels,
      onTap: () => context.pushNamed(AppRoutes.teamMembersName),
    );
  }
}
