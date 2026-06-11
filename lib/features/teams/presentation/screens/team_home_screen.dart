import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/navigation/app_routes.dart';
import '../../../../core/widgets/responsive_text.dart';
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
import '../widgets/team_disc.dart';
import '../widgets/team_scaffold.dart';
import '../widgets/teams_app_bar.dart';
import '../widgets/zaad_pill.dart';

// Type families matching the Date & Ember screens: Fraunces (serif italic) and
// JetBrains Mono, mapped to the platform generic families.
const String _serif = 'serif';
const String _mono = 'monospace';

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
      TeamMemberModel(
        userId: '0',
        username: 'Companion',
        role: TeamRoleEnum.owner,
      ),
      TeamMemberModel(
        userId: '1',
        username: 'Companion',
        role: TeamRoleEnum.member,
      ),
      TeamMemberModel(
        userId: '2',
        username: 'Companion',
        role: TeamRoleEnum.member,
      ),
      TeamMemberModel(
        userId: '3',
        username: 'Companion',
        role: TeamRoleEnum.member,
      ),
      TeamMemberModel(
        userId: '4',
        username: 'Companion',
        role: TeamRoleEnum.member,
      ),
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
      buildWhen: (a, b) => a.team != b.team || a.status != b.status,
      builder: (context, state) => TeamScaffold(
        child: Column(
          children: [
            TeamsAppBar(state: state),
            const Expanded(child: TeamHomeView()),
          ],
        ),
      ),
    );
  }
}

/// Pure render of the team home body from [TeamsState] — no scaffold, no app
/// bar of its own. It sits below the fixed [TeamsAppBar], so the combined
/// [TeamLoaderScreen] can swap it in place once a team resolves and the bar
/// stays put.
class TeamHomeView extends StatelessWidget {
  const TeamHomeView({super.key});

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
          return Skeletonizer(
            enabled: true,
            effect: appShimmerEffect(context.appColors),
            child: CustomScrollView(
              physics: const NeverScrollableScrollPhysics(),
              slivers: [
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
          );
        }
        return RefreshIndicator.adaptive(
          onRefresh: () async {
            final cubit = context.read<TeamsCubit>();
            await cubit.refreshTeam();
            await cubit.loadTeamMembers();
            await cubit.loadTeamProgress();
          },
          child: CustomScrollView(
            slivers: [
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
    final team = state.team!;
    final progress = state.progress;
    final rank = state.summary?.teamRank ?? progress?.teamRank;
    final total = state.summary?.totalTeams ?? progress?.totalTeams;
    final hasRank = rank != null && total != null && total > 0;
    final pct = progress?.overallProgressPercent ?? 0;
    final ratio = (progress?.overallProgress ?? 0.0).clamp(0.0, 1.0).toDouble();
    final solved = progress?.totalCompleted ?? 0;
    final totalLevels = progress?.totalLevels ?? 0;

    // Faithful port of the Date & Ember leaderboard summary card — frosted
    // ivory-glass surface, gold corner brackets, gold-foil headline, dashed
    // rule and serif stat cells — populated with this team's data.
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.nightOutline),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.ivory06, AppColors.ivory02],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.50),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: CustomPaint(
        foregroundPainter: _HeroBracketPainter(color: AppColors.amberGlow),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Eyebrow + rank badge.
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: _Eyebrow('teams.home.eyebrow'.tr().toUpperCase()),
                ),
                if (hasRank) _RankBadge('#$rank / $total'),
              ],
            ),
            const SizedBox(height: 6),
            // Big gold-foil progress total.
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                ShaderMask(
                  shaderCallback: (r) => const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.amberLight,
                      AppColors.amberGlow,
                      AppColors.discGoldLo,
                    ],
                    stops: [0.0, 0.55, 1.0],
                  ).createShader(r),
                  child: ResponsiveText(
                    '$pct',
                    style: const TextStyle(
                      fontFamily: _serif,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w300,
                      fontSize: 44,
                      height: 0.9,
                      letterSpacing: -1.4,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 11),
                const ResponsiveText(
                  '%',
                  style: TextStyle(
                    fontFamily: _mono,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2.2,
                    color: AppColors.ivory40,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Real progress bar in place of the design's sparkline.
            _GlassProgressBar(ratio: ratio),
            const SizedBox(height: 9),
            _DashedRule(color: AppColors.washAmber.withValues(alpha: 0.22)),
            const SizedBox(height: 9),
            Row(
              children: [
                Expanded(
                  child: _StatCell(
                    value: '${team.memberCount}',
                    label: 'teams.home.companions'.tr().toUpperCase(),
                  ),
                ),
                _StatPipe(color: AppColors.washAmber),
                Expanded(
                  child: _StatCell(
                    value: '$solved',
                    sub: totalLevels > 0 ? ' / $totalLevels' : null,
                    label: 'teams.home.solved'.tr().toUpperCase(),
                  ),
                ),
                _StatPipe(color: AppColors.washAmber),
                Expanded(
                  child: _StatCell(
                    value: hasRank ? '#$rank' : '—',
                    sub: hasRank ? ' / $total' : null,
                    label: 'teams.home.rank'.tr().toUpperCase(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Small amber mono caps label — the summary card's `_Eyebrow`.
class _Eyebrow extends StatelessWidget {
  const _Eyebrow(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return ResponsiveText(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        fontFamily: _mono,
        fontSize: 9,
        fontWeight: FontWeight.w600,
        letterSpacing: 3.2,
        color: AppColors.amberGlow,
      ),
    );
  }
}

/// Amber glass pill carrying the team rank, sitting where the summary card's
/// delta badge does.
class _RankBadge extends StatelessWidget {
  const _RankBadge(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.nightOutline),
        color: AppColors.washAmber.withValues(alpha: 0.10),
      ),
      child: ResponsiveText(
        text,
        style: const TextStyle(
          fontFamily: _mono,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.amberGlow,
        ),
      ),
    );
  }
}

/// Thin amber-gradient progress bar — the real-data stand-in for the summary
/// card's sparkline.
class _GlassProgressBar extends StatelessWidget {
  const _GlassProgressBar({required this.ratio});
  final double ratio;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(3),
      child: Stack(
        children: [
          Container(height: 6, width: double.infinity, color: AppColors.ivory08),
          FractionallySizedBox(
            widthFactor: ratio.clamp(0.0, 1.0),
            child: Container(
              height: 6,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.discGoldLo, AppColors.amberLight],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.amberGlow.withValues(alpha: 0.40),
                    blurRadius: 8,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Serif-italic value over a mono caps label — the summary card's `_StatCell`.
class _StatCell extends StatelessWidget {
  const _StatCell({required this.value, this.sub, required this.label});

  final String value;
  final String? sub;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: value,
            style: const TextStyle(
              fontFamily: _serif,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w300,
              fontSize: 19,
              height: 1,
              color: AppColors.ivory,
            ),
            children: [
              if (sub != null)
                TextSpan(
                  text: sub,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.ivory40,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 3),
        ResponsiveText(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 8.5,
            fontWeight: FontWeight.w600,
            letterSpacing: 2.0,
            color: AppColors.ivory62,
          ),
        ),
      ],
    );
  }
}

/// Vertical gradient pipe separating hero stats — fades in from transparent at
/// the ends to a soft amber in the middle, mirroring the leaderboard summary
/// card's `_StatPipe`.
class _StatPipe extends StatelessWidget {
  const _StatPipe({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 34,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            color.withValues(alpha: 0),
            color.withValues(alpha: 0.25),
            color.withValues(alpha: 0),
          ],
        ),
      ),
    );
  }
}

/// A 1px dashed amber rule, matching the leaderboard summary card's divider.
class _DashedRule extends StatelessWidget {
  const _DashedRule({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 1,
      child: CustomPaint(painter: _DashedLinePainter(color)),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  _DashedLinePainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    const dash = 4.0;
    const gap = 4.0;
    double x = 0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, 0), Offset(x + dash, 0), paint);
      x += dash + gap;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedLinePainter oldDelegate) =>
      oldDelegate.color != color;
}

/// Gold right-angle brackets on the four corners of the hero card, echoing the
/// leaderboard summary card's `_CornerBracketPainter`.
class _HeroBracketPainter extends CustomPainter {
  _HeroBracketPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    const arm = 7.0;
    const inset = 1.0;
    final w = size.width;
    final h = size.height;
    // Top-left.
    canvas.drawPath(
      Path()
        ..moveTo(inset, arm)
        ..lineTo(inset, inset)
        ..lineTo(arm, inset),
      paint,
    );
    // Top-right.
    canvas.drawPath(
      Path()
        ..moveTo(w - inset, arm)
        ..lineTo(w - inset, inset)
        ..lineTo(w - arm, inset),
      paint,
    );
    // Bottom-left.
    canvas.drawPath(
      Path()
        ..moveTo(inset, h - arm)
        ..lineTo(inset, h - inset)
        ..lineTo(arm, h - inset),
      paint,
    );
    // Bottom-right.
    canvas.drawPath(
      Path()
        ..moveTo(w - inset, h - arm)
        ..lineTo(w - inset, h - inset)
        ..lineTo(w - arm, h - inset),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _HeroBracketPainter oldDelegate) =>
      oldDelegate.color != color;
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
              onPressed: () => context.goNamed(AppRoutes.teamMembersName),
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
                    onTap: () => context.goNamed(AppRoutes.teamMembersName),
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
        trailing: Icon(Icons.check_rounded, size: 14, color: colors.success),
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
                  style: TextStyle(fontSize: 10, color: colors.oliveSoft),
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
