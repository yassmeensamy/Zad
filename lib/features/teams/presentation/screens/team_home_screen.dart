import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/navigation/app_routes.dart';
import '../../../../core/widgets/responsive_text.dart';
import '../../../../core/widgets/zaad_app_bar.dart';
import '../../../../core/widgets/zaad_circle_button.dart';
import '../../../../core/widgets/zaad_shimmer.dart';
import '../../../../theme/theme.dart';
import '../../data/models/team_member_model.dart';
import '../../data/models/team_members_model.dart';
import '../../data/models/team_model.dart';
import '../../data/models/team_progress_model.dart';
import '../../data/models/team_progress_summary_model.dart';
import '../../data/models/team_role_enum.dart';
import '../cubit/teams_cubit.dart';
import '../cubit/teams_state.dart';
import '../widgets/olive_hero_card.dart';
import '../widgets/team_disc.dart';
import '../widgets/team_scaffold.dart';
import '../widgets/team_leave_sheet.dart';
import '../widgets/zaad_pill.dart';

/// Presentation-only mock state shown under [Skeletonizer] while the real team
/// home loads — realistic shapes only, never touches the data layer.
const TeamsState _kSkeletonHomeState = TeamsState(
  status: TeamsStatus.hasTeam,
  team: TeamModel(
    id: '0',
    name: 'Team name',
    joinCode: 'XXXX-XXXX',
    memberCount: 8,
    yourRole: TeamRoleEnum.member,
  ),
  members: TeamMembersModel(
    teamId: '0',
    members: [
      TeamMemberModel(userId: '0', username: 'Companion', role: TeamRoleEnum.owner),
      TeamMemberModel(userId: '1', username: 'Companion', role: TeamRoleEnum.member),
      TeamMemberModel(userId: '2', username: 'Companion', role: TeamRoleEnum.member),
      TeamMemberModel(userId: '3', username: 'Companion', role: TeamRoleEnum.member),
      TeamMemberModel(userId: '4', username: 'Companion', role: TeamRoleEnum.member),
    ],
  ),
  progress: TeamProgressModel(
    teamId: '0',
    teamName: 'Team name',
    teamRank: 3,
    totalTeams: 50,
  ),
  summary: TeamProgressSummaryModel(teamRank: 3, totalTeams: 50),
);

class TeamHomeScreen extends StatefulWidget {
  const TeamHomeScreen({super.key});

  @override
  State<TeamHomeScreen> createState() => _TeamHomeScreenState();
}

class _TeamHomeScreenState extends State<TeamHomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cubit = context.read<TeamsCubit>();
      // If we got here without a team in state (deep link / cold start),
      // boot it; otherwise the loader just fetched it — skip the refetch
      // and only pull the auxiliary endpoints we don't yet have.
      if (cubit.state.team == null) {
        cubit.loadTeamStatus();
      } else {
        if (cubit.state.members == null) cubit.loadTeamMembers();
        if (cubit.state.progress == null) cubit.loadTeamProgress();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TeamsCubit, TeamsState>(
      buildWhen: (a, b) =>
          a.team != b.team ||
          a.members != b.members ||
          a.summary != b.summary ||
          a.status != b.status,
      builder: (context, state) {
        final team = state.team;
        if (team == null) {
          return TeamScaffold(
            child: Skeletonizer(
              enabled: true,
              effect: appShimmerEffect(context.appColors),
              child: CustomScrollView(
                physics: const NeverScrollableScrollPhysics(),
                slivers: [
                  const SliverToBoxAdapter(
                    child: ZaadAppBar(
                      title: 'Team name',
                      subtitle: 'teams.home.eyebrow',
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 110),
                    sliver: SliverList.list(
                      children: const [
                        _HeroCard(state: _kSkeletonHomeState),
                        SizedBox(height: 22),
                        _MembersStrip(state: _kSkeletonHomeState),
                        SizedBox(height: 18),
                        _WeekStrip(),
                        SizedBox(height: 22),
                        _RecentActivity(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        return TeamScaffold(
          child: RefreshIndicator.adaptive(
            onRefresh: () async {
              final cubit = context.read<TeamsCubit>();
              await cubit.refreshTeam();
              await cubit.loadTeamMembers();
              await cubit.loadTeamProgress();
            },
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: ZaadAppBar(
                    title: team.name,
                    subtitle: 'teams.home.eyebrow',
                    onBack: context.canPop() ? () => context.pop() : null,
                    action: ZaadCircleIconButton(
                      icon: Icons.more_horiz_rounded,
                      onTap: () async {
                        final left = await showTeamLeaveSheet(context);
                        if (left && context.mounted) {
                          context.goNamed(AppRoutes.homeName);
                        }
                      },
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 110),
                  sliver: SliverList.list(
                    children: [
                      _HeroCard(state: state),
                      const SizedBox(height: 22),
                      _MembersStrip(state: state),
                      const SizedBox(height: 18),
                      const _WeekStrip(),
                      const SizedBox(height: 22),
                      const _RecentActivity(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.state});
  final TeamsState state;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final team = state.team!;
    final rank = state.summary?.teamRank;
    final total = state.summary?.totalTeams;
    final rankLabel = rank != null && total != null && total > 0
        ? '#$rank / $total'
        : '—';

    return OliveHeroCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              TeamDisc(seed: team.name, size: 54),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ResponsiveText(
                      'teams.home.subtitle'.tr().toUpperCase(),
                      style: ZaadType.fieldLabel.copyWith(
                        color: colors.canvas.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: 3),
                    ResponsiveText(
                      team.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.displaySmall.copyWith(
                        fontSize: 20,
                        color: colors.canvas,
                      ),
                    ),
                  ],
                ),
              ),
              ZaadPill(label: rankLabel, tone: ZaadPillTone.amber),
            ],
          ),
          const SizedBox(height: 18),
          _LevelProgress(progress: state.progress),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.only(top: 14),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: colors.canvas.withValues(alpha: 0.14),
                ),
              ),
            ),
            child: Row(
              children: [
                _HeroStat(
                  value: '${team.memberCount}',
                  label: 'teams.home.companions',
                ),
                _HeroStat(
                  value: state.progress != null
                      ? '${state.progress!.overallProgressPercent}%'
                      : '—',
                  label: 'teams.home.progress',
                ),
                _HeroStat(
                  value: '${state.progress?.categories.length ?? 0}',
                  label: 'teams.home.categories',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LevelProgress extends StatelessWidget {
  const _LevelProgress({this.progress});
  final dynamic progress;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final ratio = (progress?.overallProgress as double?) ?? 0.0;
    final pct = (ratio * 100).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ResponsiveText(
              'teams.home.next_rank'.tr().toUpperCase(),
              style: ZaadType.fieldLabel.copyWith(
                color: colors.canvas.withValues(alpha: 0.55),
              ),
            ),
            ResponsiveText(
              '$pct%',
              style: ZaadType.fieldLabel.copyWith(
                color: colors.accentSoft,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: Stack(
            children: [
              Container(
                height: 6,
                color: colors.canvas.withValues(alpha: 0.10),
              ),
              FractionallySizedBox(
                widthFactor: ratio.clamp(0.0, 1.0),
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.amberGlow, AppColors.amberDeep],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: colors.accent.withValues(alpha: 0.5),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HeroStat extends StatelessWidget {
  const _HeroStat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ResponsiveText(
            value,
            style: AppTextStyles.displaySmall.copyWith(
              fontSize: 22,
              color: colors.accentSoft,
            ),
          ),
          const SizedBox(height: 3),
          ResponsiveText(
            label.tr().toUpperCase(),
            style: TextStyle(
              fontSize: 8.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.6,
              color: colors.canvas.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _MembersStrip extends StatelessWidget {
  const _MembersStrip({required this.state});
  final TeamsState state;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final members = state.members?.members ?? const [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ResponsiveText(
              'teams.home.companions'.tr().toUpperCase(),
              style: ZaadType.fieldLabel.copyWith(color: colors.oliveSoft),
            ),
            TextButton(
              onPressed: () =>
                  context.goNamed(AppRoutes.teamMembersName),
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: ResponsiveText(
                'teams.home.view_all'.tr().toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.6,
                  color: colors.oliveSoft,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 40,
          child: Stack(
            children: [
              for (var i = 0; i < members.take(5).length; i++)
                Positioned(
                  left: i * 28.0,
                  child: TeamDisc(
                    seed: members[i].username,
                    size: 40,
                    borderColor: colors.canvas,
                    borderWidth: 2,
                    useSerif: false,
                  ),
                ),
              if (members.length > 5)
                Positioned(
                  left: 5 * 28.0,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colors.canvas.withValues(alpha: 0.55),
                      border: Border.all(color: colors.canvas, width: 2),
                    ),
                    child: Center(
                      child: ResponsiveText(
                        '+${members.length - 5}',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: colors.oliveDeep,
                        ),
                      ),
                    ),
                  ),
                ),
              Positioned(
                right: 0,
                top: 2,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () =>
                        context.goNamed(AppRoutes.teamMembersName),
                    customBorder: const CircleBorder(),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: colors.canvas.withValues(alpha: 0.6),
                        border: Border.all(
                          color: colors.accentDeep,
                          width: 1.5,
                          style: BorderStyle.solid,
                        ),
                      ),
                      child: Icon(
                        Icons.add_rounded,
                        size: 16,
                        color: colors.accentDeep,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _WeekStrip extends StatelessWidget {
  const _WeekStrip();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    const heights = [0.46, 0.68, 0.54, 0.80, 0.34, 0.60, 0.30];
    const labels = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.canvas.withValues(alpha: 0.55),
        borderRadius: ZaadRadii.lgAll,
        border: Border.all(color: colors.olive.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ResponsiveText(
                'teams.home.week_title'.tr(),
                style: AppTextStyles.titleMedium.copyWith(
                  fontSize: 14,
                  color: colors.oliveDeep,
                ),
              ),
              ZaadPill(
                label: 'teams.home.week_chip'.tr(),
                tone: ZaadPillTone.olive,
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 100,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (var i = 0; i < heights.length; i++) ...[
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          height: 82 * heights[i],
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: i < 5
                                  ? const [
                                      AppColors.amberGlow,
                                      AppColors.amberDeep,
                                    ]
                                  : [
                                      colors.oliveDeep.withValues(alpha: 0.14),
                                      colors.oliveDeep.withValues(alpha: 0.14),
                                    ],
                            ),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(4),
                              topRight: Radius.circular(4),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        ResponsiveText(
                          labels[i],
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: colors.oliveSoft,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (i < heights.length - 1) const SizedBox(width: 6),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentActivity extends StatelessWidget {
  const _RecentActivity();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final rows = <_ActivityRow>[
      _ActivityRow(
        seed: 'A',
        title: 'teams.home.activity.completed'.tr(
          namedArgs: {'name': 'Aisha', 'chapter': '4'},
        ),
        meta: '+40 XP · 12 min ago',
        trailing: Icon(
          Icons.check_rounded,
          size: 14,
          color: colors.success,
        ),
      ),
      _ActivityRow(
        seed: 'F',
        title: 'teams.home.activity.streak'.tr(
          namedArgs: {'name': 'Faisal', 'days': '18'},
        ),
        meta: 'Streak · 2 hr ago',
        trailing: Icon(
          Icons.local_fire_department_rounded,
          size: 14,
          color: colors.accentDeep,
        ),
      ),
      _ActivityRow(
        seed: 'Y',
        title: 'teams.home.activity.goal'.tr(namedArgs: {'name': 'Yūsuf'}),
        meta: 'Leader · yesterday',
        trailing: null,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ResponsiveText(
          'teams.home.recent'.tr().toUpperCase(),
          style: ZaadType.fieldLabel.copyWith(color: colors.oliveSoft),
        ),
        const SizedBox(height: 8),
        for (var i = 0; i < rows.length; i++) ...[
          rows[i],
          if (i < rows.length - 1) const SizedBox(height: 6),
        ],
      ],
    );
  }
}

class _ActivityRow extends StatelessWidget {
  const _ActivityRow({
    required this.seed,
    required this.title,
    required this.meta,
    required this.trailing,
  });

  final String seed;
  final String title;
  final String meta;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: colors.canvas.withValues(alpha: 0.42),
        borderRadius: ZaadRadii.mdAll,
        border: Border.all(color: AppColors.sand),
      ),
      child: Row(
        children: [
          TeamDisc(seed: seed, size: 30, fontSize: 12),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ResponsiveText(
                  title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: colors.oliveDeep,
                  ),
                ),
                const SizedBox(height: 2),
                ResponsiveText(
                  meta,
                  style: TextStyle(
                    fontSize: 10,
                    color: colors.oliveSoft,
                  ),
                ),
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}
