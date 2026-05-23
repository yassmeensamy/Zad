import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/responsive_text.dart';
import '../../../../core/widgets/zaad_app_bar.dart';
import '../../../../core/widgets/zaad_circle_button.dart';
import '../../../../theme/theme.dart';
import '../../data/models/team_member_model.dart';
import '../../data/models/team_member_progress_model.dart';
import '../../data/models/team_role_enum.dart';
import '../cubit/teams_cubit.dart';
import '../cubit/teams_state.dart';
import '../widgets/team_disc.dart';
import '../widgets/team_scaffold.dart';
import '../widgets/team_tab_bar.dart';
import '../widgets/zaad_pill.dart';

enum _MemberFilter { all, leaders, active, quiet }

class TeamMembersScreen extends StatefulWidget {
  const TeamMembersScreen({super.key});

  @override
  State<TeamMembersScreen> createState() => _TeamMembersScreenState();
}

class _TeamMembersScreenState extends State<TeamMembersScreen> {
  _MemberFilter _filter = _MemberFilter.all;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cubit = context.read<TeamsCubit>();
      cubit.loadTeamMembers();
      cubit.loadTeamProgress();
    });
  }

  List<TeamMemberModel> _filtered(List<TeamMemberModel> members) {
    return switch (_filter) {
      _MemberFilter.all => members,
      _MemberFilter.leaders =>
        members.where((m) => m.role == TeamRoleEnum.owner).toList(),
      _MemberFilter.active => members.take((members.length / 2).ceil()).toList(),
      _MemberFilter.quiet => members.skip((members.length / 2).ceil()).toList(),
    };
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TeamsCubit, TeamsState>(
      buildWhen: (a, b) => a.members != b.members || a.progress != b.progress,
      builder: (context, state) {
        final team = state.team;
        final members = state.members?.members ?? const [];
        final filtered = _filtered(members);

        return TeamScaffold(
          extendBody: true,
          bottomNav: const TeamTabBar(active: TeamTab.members),
          child: Column(
            children: [
              ZaadAppBar(
                title: 'teams.members.title'.tr(
                  namedArgs: {'count': '${members.length}'},
                ),
                subtitle: team?.name ?? '',
                onBack: context.canPop() ? () => context.pop() : null,
                action: ZaadCircleIconButton(
                  icon: Icons.add_rounded,
                  onTap: () {},
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 110),
                  children: [
                    _FilterChips(
                      counts: members.length,
                      filter: _filter,
                      onChange: (f) => setState(() => _filter = f),
                    ),
                    const SizedBox(height: 14),
                    if (state.members == null)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(36),
                          child: CircularProgressIndicator.adaptive(),
                        ),
                      )
                    else if (filtered.isEmpty)
                      _EmptyMembers()
                    else
                      for (final m in filtered)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _MemberRow(
                            member: m,
                            progress: _progressFor(m, state),
                          ),
                        ),
                  ],
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
}

class _FilterChips extends StatelessWidget {
  const _FilterChips({
    required this.counts,
    required this.filter,
    required this.onChange,
  });

  final int counts;
  final _MemberFilter filter;
  final ValueChanged<_MemberFilter> onChange;

  @override
  Widget build(BuildContext context) {
    final items = <(_MemberFilter, String)>[
      (_MemberFilter.all, '${'teams.members.filter.all'.tr()} · $counts'),
      (_MemberFilter.leaders, 'teams.members.filter.leaders'.tr()),
      (_MemberFilter.active, 'teams.members.filter.active'.tr()),
      (_MemberFilter.quiet, 'teams.members.filter.quiet'.tr()),
    ];

    return SizedBox(
      height: 32,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(width: 7),
        itemBuilder: (context, i) {
          final (f, label) = items[i];
          final active = f == filter;
          return InkWell(
            onTap: () => onChange(f),
            borderRadius: ZaadRadii.pillAll,
            child: ZaadPill(
              label: label,
              tone: active ? ZaadPillTone.oliveOnDark : ZaadPillTone.olive,
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _MemberRow extends StatelessWidget {
  const _MemberRow({required this.member, this.progress});

  final TeamMemberModel member;
  final TeamMemberProgressModel? progress;

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
