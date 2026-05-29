import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/scroll_pagination_mixin.dart';
import '../../../../core/widgets/responsive_text.dart';
import '../../../../theme/theme.dart';
import '../../../categories/presentation/cubit/categories_cubit.dart';
import '../../../categories/presentation/cubit/categories_state.dart';
import '../../../teams/data/models/team_member_progress_model.dart';
import '../../../teams/presentation/widgets/team_scaffold.dart';
import '../cubit/rankings_cubit.dart';
import '../cubit/rankings_state.dart';
import '../widgets/all_members_header.dart';
import '../widgets/my_rank_card.dart';
import '../widgets/podium.dart';
import '../widgets/ranking_row.dart';
import '../widgets/rankings_category_filter.dart';
import '../widgets/rankings_scope_tabs.dart';
import '../widgets/top_three_eyebrow.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen>
    with ScrollPaginationMixin {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final categories = context.read<CategoriesCubit>();
      if (!categories.state.hasCategories) categories.getCategories();
      context.read<RankingsCubit>().loadInitial();
    });
  }

  @override
  void onLoadMore() => context.read<RankingsCubit>().loadMore();

  @override
  Widget build(BuildContext context) {
    return TeamScaffold(
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
          child: BlocBuilder<RankingsCubit, RankingsState>(
            builder: (context, state) {
              final cubit = context.read<RankingsCubit>();
              return Column(
                children: [
                  const _RankingsHeader(),
                  const SizedBox(height: 14),
                  RankingsScopeTabs(
                    value: state.scope,
                    onChanged: cubit.setScope,
                  ),
                  if (state.isIndividuals) ...[
                    const SizedBox(height: 12),
                    BlocBuilder<CategoriesCubit, CategoriesState>(
                      builder: (context, catState) => RankingsCategoryFilter(
                        categories: catState.categories,
                        selectedId: state.categoryId,
                        onSelected: cubit.setCategory,
                      ),
                    ),
                  ],
                  const SizedBox(height: 14),
                  Expanded(child: _Body(state: state, controller: scrollController)),
                  _Footer(state: state),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _RankingsHeader extends StatelessWidget {
  const _RankingsHeader();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Column(
      children: [
        ResponsiveText(
          'Global League'.toUpperCase(),
          style: AppTextStyles.labelSmall.copyWith(
            fontSize: 8.5,
            fontWeight: FontWeight.w600,
            letterSpacing: 2.4,
            color: colors.oliveDeep.withValues(alpha: 0.55),
          ),
        ),
        const SizedBox(height: 2),
        ResponsiveText(
          'Leaderboard',
          style: AppTextStyles.displaySmall.copyWith(
            fontSize: 20,
            color: colors.oliveDeep,
            height: 1,
            letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }
}

/// Maps a global ranking row into the lightweight model the [Podium] consumes.
/// The podium only reads name + completed/total, so the unused fields are
/// filled with safe defaults.
TeamMemberProgressModel _podiumSeed({
  required String id,
  required String name,
  required int completed,
  required int total,
}) => TeamMemberProgressModel(
  userId: id,
  username: name,
  completedLevels: completed,
  totalLevels: total,
);

class _Body extends StatelessWidget {
  const _Body({required this.state, required this.controller});

  final RankingsState state;
  final ScrollController controller;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    if (state.activeStatus == RankingsStatus.loading && state.activeIsEmpty) {
      return Center(
        child: CircularProgressIndicator(color: colors.oliveDeep, strokeWidth: 2),
      );
    }
    if (state.activeStatus == RankingsStatus.error && state.activeIsEmpty) {
      return _ErrorRetry(
        onRetry: () => context.read<RankingsCubit>().refresh(),
      );
    }
    if (state.activeIsEmpty) {
      return Center(
        child: Text(
          'No rankings yet.',
          style: TextStyle(
            fontSize: 12,
            color: colors.oliveSoft,
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    }

    final rows = state.isIndividuals
        ? _individualRows(state)
        : _teamRows(state);
    final podium = state.isIndividuals
        ? [
            for (final r in state.individuals.take(3))
              _podiumSeed(
                id: r.userId,
                name: r.username,
                completed: r.completedLevels,
                total: r.totalLevels,
              ),
          ]
        : [
            for (final t in state.teams.take(3))
              _podiumSeed(
                id: t.teamId,
                name: t.teamName,
                completed: t.totalCompletedLevels,
                total: t.totalLevels,
              ),
          ];

    return ListView(
      controller: controller,
      padding: const EdgeInsets.only(bottom: 8),
      children: [
        const TopThreeEyebrow(),
        const SizedBox(height: 8),
        Podium(members: podium),
        const SizedBox(height: 14),
        AllMembersHeader(count: state.activeCount),
        const SizedBox(height: 8),
        for (var i = 0; i < rows.length; i++) ...[
          if (i > 0) const SizedBox(height: 5),
          rows[i],
        ],
        if (state.loadingMore)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  color: colors.oliveDeep,
                  strokeWidth: 2,
                ),
              ),
            ),
          ),
      ],
    );
  }

  List<Widget> _individualRows(RankingsState state) {
    final myRank = state.myRank?.rank;
    return [
      for (final r in state.individuals)
        RankingRow(
          rank: r.rank,
          title: r.username,
          completed: r.completedLevels,
          total: r.totalLevels,
          isMe: myRank != null && r.rank == myRank,
        ),
    ];
  }

  List<Widget> _teamRows(RankingsState state) {
    final myRank = state.myTeamRank?.rank;
    return [
      for (final t in state.teams)
        RankingRow(
          rank: t.rank,
          title: t.teamName,
          completed: t.totalCompletedLevels,
          total: t.totalLevels,
          subtitle: '${t.memberCount} '
              '${t.memberCount == 1 ? 'member' : 'members'}',
          isMe: myRank != null && t.rank == myRank,
        ),
    ];
  }
}

/// Pinned "your standing" card for whichever scope is active.
class _Footer extends StatelessWidget {
  const _Footer({required this.state});

  final RankingsState state;

  @override
  Widget build(BuildContext context) {
    if (state.isIndividuals) {
      final me = state.myRank;
      if (me == null) return const SizedBox.shrink();
      return MyRankCard(
        label: 'Your rank',
        rank: me.rank,
        title: 'You',
        completed: me.completedLevels,
        total: me.totalLevels,
      );
    }
    final me = state.myTeamRank;
    if (me == null) return const SizedBox.shrink();
    return MyRankCard(
      label: 'Your team',
      rank: me.rank,
      title: me.teamName,
      completed: me.totalCompletedLevels,
      total: me.totalLevels,
    );
  }
}

class _ErrorRetry extends StatelessWidget {
  const _ErrorRetry({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Couldn't load the leaderboard.",
            style: TextStyle(
              fontSize: 12,
              color: colors.oliveSoft,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 8),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
