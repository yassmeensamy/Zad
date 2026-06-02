import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/services/core_service_locator.dart';
import '../../../../core/services/share_service.dart';
import '../../../../core/widgets/responsive_text.dart';
import '../../../../core/widgets/zaad_app_bar.dart';
import '../../../../core/widgets/zaad_shimmer.dart';
import '../../../../theme/theme.dart';
import '../../data/models/team_member_model.dart';
import '../../data/models/team_member_progress_model.dart';
import '../../data/models/team_role_enum.dart';
import '../cubit/teams_cubit.dart';
import '../cubit/teams_state.dart';
import '../widgets/team_disc.dart';
import '../widgets/team_scaffold.dart';
import '../widgets/zaad_pill.dart';

/// Presentation-only stand-ins shown under [Skeletonizer] while the real team
/// members load. Realistic shapes only — this never touches the data layer.
const List<TeamMemberModel> _kPlaceholderMembers = [
  TeamMemberModel(userId: '0', username: 'Companion', role: TeamRoleEnum.owner),
  TeamMemberModel(userId: '1', username: 'Companion', role: TeamRoleEnum.member),
  TeamMemberModel(userId: '2', username: 'Companion', role: TeamRoleEnum.member),
  TeamMemberModel(userId: '3', username: 'Companion', role: TeamRoleEnum.member),
  TeamMemberModel(userId: '4', username: 'Companion', role: TeamRoleEnum.member),
  TeamMemberModel(userId: '5', username: 'Companion', role: TeamRoleEnum.member),
];

const TeamMemberProgressModel _kPlaceholderProgress = TeamMemberProgressModel(
  userId: '0',
  username: 'Companion',
  completedLevels: 6,
  totalLevels: 10,
);

class TeamMembersScreen extends StatefulWidget {
  const TeamMembersScreen({super.key});

  @override
  State<TeamMembersScreen> createState() => _TeamMembersScreenState();
}

class _TeamMembersScreenState extends State<TeamMembersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cubit = context.read<TeamsCubit>();
      // When opened directly (e.g. from the leaderboard) the team itself — and
      // with it the join code we show below — hasn't been fetched yet.
      if (cubit.state.team == null) cubit.refreshTeam();
      cubit.loadTeamMembers();
      cubit.loadTeamProgress();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return BlocBuilder<TeamsCubit, TeamsState>(
      buildWhen: (a, b) =>
          a.team != b.team ||
          a.members != b.members ||
          a.progress != b.progress,
      builder: (context, state) {
        final team = state.team;
        // Members haven't arrived yet → render placeholder rows under a shimmer.
        final isLoading = state.members == null;
        final members = isLoading
            ? _kPlaceholderMembers
            : state.members!.members;
        final ranks = isLoading
            ? {
                for (var i = 0; i < members.length; i++)
                  members[i].userId: i + 1,
              }
            : _rankByProgress(members, state);
        final showCodeCard =
            isLoading || (team != null && team.joinCode.isNotEmpty);

        return TeamScaffold(
          child: Column(
            children: [
              ZaadAppBar(
                title: 'teams.members.title'.tr(
                  namedArgs: {'count': isLoading ? '—' : '${members.length}'},
                ),
                subtitle: team?.name ?? '',
                onBack: context.canPop() ? () => context.pop() : null,
              ),
              Expanded(
                child: Skeletonizer(
                  enabled: isLoading,
                  effect: appShimmerEffect(colors),
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 110),
                    children: [
                      if (showCodeCard) ...[
                        _TeamCodeCard(
                          code: isLoading ? 'XXXX-XXXX' : team!.joinCode,
                        ),
                        const SizedBox(height: 16),
                      ],
                      if (!isLoading && members.isEmpty)
                        _EmptyMembers()
                      else
                        for (final m in members)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: _MemberRow(
                              member: m,
                              progress: isLoading
                                  ? _kPlaceholderProgress
                                  : _progressFor(m, state),
                              rank: ranks[m.userId],
                            ),
                          ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  TeamMemberProgressModel? _progressFor(
    TeamMemberModel member,
    TeamsState state,
  ) {
    final summaryMembers = state.summary?.members ?? const [];
    for (final p in summaryMembers) {
      if (p.userId == member.userId) return p;
    }
    return null;
  }

  /// Ranks members 1..n by completed levels (descending). Returns a map of
  /// userId → rank. Falls back to no ranks until progress has loaded.
  Map<String, int> _rankByProgress(
    List<TeamMemberModel> members,
    TeamsState state,
  ) {
    if (state.summary == null) return const {};
    final sorted = [...members]..sort((a, b) {
      final pa = _progressFor(a, state)?.completedLevels ?? 0;
      final pb = _progressFor(b, state)?.completedLevels ?? 0;
      return pb.compareTo(pa);
    });
    return {
      for (var i = 0; i < sorted.length; i++) sorted[i].userId: i + 1,
    };
  }
}

class _MemberRow extends StatelessWidget {
  const _MemberRow({required this.member, this.progress, this.rank});

  final TeamMemberModel member;
  final TeamMemberProgressModel? progress;
  final int? rank;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isLeader = member.role == TeamRoleEnum.owner;
    final ratio = progress?.progress ?? 0.0;

    final bg = isLeader
        ? LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colors.accent.withValues(alpha: 0.14),
              colors.accent.withValues(alpha: 0.04),
            ],
          )
        : LinearGradient(
            colors: [
              colors.canvas.withValues(alpha: 0.42),
              colors.canvas.withValues(alpha: 0.42),
            ],
          );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        gradient: bg,
        borderRadius: ZaadRadii.lgAll,
        border: Border.all(
          color: isLeader
              ? colors.accentDeep.withValues(alpha: 0.3)
              : AppColors.sand,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (rank != null) ...[
            _RankBadge(rank: rank!),
            const SizedBox(width: 10),
          ],
          TeamDisc(
            seed: member.username,
            size: 42,
            fontSize: 16,
            useSerif: false,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: ResponsiveText(
                        member.username,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: colors.oliveDeep,
                        ),
                      ),
                    ),
                    if (isLeader) ...[
                      const SizedBox(width: 6),
                      ZaadPill(
                        label: 'teams.members.role_leader'.tr(),
                        tone: ZaadPillTone.amber,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        fontSize: 8,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                ResponsiveText(
                  progress != null
                      ? 'teams.members.meta'.tr(
                          namedArgs: {
                            'done': '${progress!.completedLevels}',
                            'total': '${progress!.totalLevels}',
                          },
                        )
                      : '—',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 10,
                    color: colors.oliveSoft,
                  ),
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: SizedBox(
                    height: 5,
                    child: Stack(
                      children: [
                        Container(
                          color: colors.oliveDeep.withValues(alpha: 0.10),
                        ),
                        FractionallySizedBox(
                          widthFactor: ratio.clamp(0.0, 1.0),
                          child: Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.amberGlow,
                                  AppColors.amberDeep,
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Small numbered medallion shown at the leading edge of each member row.
/// The top three ranks get the gold treatment; the rest a muted olive chip.
class _RankBadge extends StatelessWidget {
  const _RankBadge({required this.rank});

  final int rank;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isTop = rank <= 3;

    return Container(
      width: 24,
      height: 24,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: isTop
            ? const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppColors.amberGlow, AppColors.amberDeep],
              )
            : null,
        color: isTop ? null : colors.oliveDeep.withValues(alpha: 0.08),
        border: Border.all(
          color: isTop
              ? AppColors.amberDeep.withValues(alpha: 0.5)
              : colors.oliveDeep.withValues(alpha: 0.18),
        ),
      ),
      child: ResponsiveText(
        '$rank',
        style: AppTextStyles.labelSmall.copyWith(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: isTop ? Colors.white : colors.oliveSoft,
        ),
      ),
    );
  }
}

/// Team invite-code card with copy + share actions. Mirrors the invite chip on
/// the team-create success screen so the share message stays consistent.
class _TeamCodeCard extends StatelessWidget {
  const _TeamCodeCard({required this.code});

  final String code;

  Future<void> _share(BuildContext context) async {
    await sl<ShareService>().shareFrom(
      context: context,
      text: 'teams.create.share_message'.tr(namedArgs: {'code': code}),
      subject: 'teams.create.share_subject'.tr(),
    );
  }

  Future<void> _copy(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: code));
    if (!context.mounted) return;
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
      SnackBar(
        content: Text('teams.create.copied'.tr()),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final goldDeep = colors.goldDeep;

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withValues(alpha: 0.85),
            Colors.white.withValues(alpha: 0.55),
          ],
        ),
        borderRadius: ZaadRadii.lgAll,
        border: Border.all(color: goldDeep.withValues(alpha: 0.45)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ResponsiveText(
                  'teams.members.code_label'.tr().toUpperCase(),
                  style: AppTextStyles.labelSmall.copyWith(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2.8,
                    color: goldDeep,
                  ),
                ),
                const SizedBox(height: 4),
                ResponsiveText(
                  code,
                  style: AppTextStyles.titleMedium.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 4.5,
                    color: colors.inkBrownDeep,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _CodeAction(
            icon: Icons.copy_rounded,
            onTap: () => _copy(context),
          ),
          const SizedBox(width: 6),
          _CodeAction(
            icon: Icons.ios_share_rounded,
            onTap: () => _share(context),
          ),
        ],
      ),
    );
  }
}

class _CodeAction extends StatelessWidget {
  const _CodeAction({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final goldDeep = context.appColors.goldDeep;
    return Material(
      color: Colors.transparent,
      child: InkResponse(
        onTap: onTap,
        radius: 22,
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: goldDeep.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(9),
            border: Border.all(color: goldDeep.withValues(alpha: 0.45)),
          ),
          child: Icon(icon, size: 14, color: goldDeep),
        ),
      ),
    );
  }
}

class _EmptyMembers extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.group_off_outlined,
              size: 48,
              color: colors.oliveSoft,
            ),
            const SizedBox(height: 12),
            ResponsiveText(
              'teams.members.empty_filter'.tr(),
              style: AppTextStyles.bodyMedium.copyWith(
                color: colors.oliveSoft,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
