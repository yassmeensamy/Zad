import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/navigation/app_routes.dart';
import '../../../../core/navigation/deep_links.dart';
import '../../../../core/services/core_service_locator.dart';
import '../../../../core/services/share_service.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/rank_crown.dart';
import '../../../../core/widgets/responsive_text.dart';
import '../../../../theme/theme.dart';
import '../../../categories/presentation/cubit/categories_cubit.dart';
import '../../../categories/presentation/cubit/categories_state.dart';
import '../../../user/presentation/cubit/user_cubit.dart';
import '../../data/models/team_member_progress_model.dart';
import '../cubit/teams_cubit.dart';
import '../cubit/teams_state.dart';
import '../widgets/date_ember_roles.dart';
import '../widgets/team_leave_sheet.dart';
import '../widgets/team_owner_menu_sheet.dart';
import '../widgets/team_transfer_ownership_sheet.dart';
import '../widgets/teams_painters.dart';

typedef _Pal = DateEmberRoles;

class TeamHomeScreen extends StatelessWidget {
  const TeamHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CategoriesCubit>.value(
      value: sl<CategoriesCubit>()..ensureLoaded(),
      child: const AppScaffold(
        safeArea: true,
        body: Column(
          children: [
            _AppBar(),
            Expanded(child: _Stage()),
          ],
        ),
      ),
    );
  }
}

class _AppBar extends StatelessWidget {
  const _AppBar();

  @override
  Widget build(BuildContext context) {
    final p = _Pal(context);
    final state = context.watch<TeamsCubit>().state;
    final teamName = state.team?.name ?? state.progress?.teamName ?? '';
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 10),
      child: Row(
        children: [
          _IconButton(
            icon: Directionality.of(context) == TextDirection.rtl
                ? Icons.arrow_forward
                : Icons.arrow_back,
            size: 17,
            onTap: () => context.canPop()
                ? context.pop()
                : context.goNamed(AppRoutes.homeName),
          ),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ResponsiveText(
                  'MY TEAM',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 3.0,
                    color: p.amber,
                  ),
                ),
                const SizedBox(height: 3),
                ResponsiveText(
                  teamName,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w300,
                    fontSize: 19,
                    height: 1,
                    letterSpacing: -0.3,
                    color: p.ink,
                  ),
                ),
              ],
            ),
          ),
          _IconButton(
            icon: Icons.more_horiz,
            size: 18,
            onTap: () => _onMenuTap(context),
          ),
        ],
      ),
    );
  }

  /// Owners get an actions menu (transfer ownership / leave); everyone else
  /// goes straight to the leave flow.
  Future<void> _onMenuTap(BuildContext context) async {
    final isOwner = context.read<TeamsCubit>().state.team?.isOwner ?? false;
    if (!isOwner) {
      await _leaveFlow(context);
      return;
    }

    final action = await showTeamOwnerMenu(context);
    if (!context.mounted) return;
    switch (action) {
      case TeamOwnerAction.transfer:
        final newOwner = await showTransferOwnershipSheet(context);
        if (newOwner != null && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'teams.transfer.success'.tr(namedArgs: {'name': newOwner}),
              ),
            ),
          );
        }
      case TeamOwnerAction.leave:
        await _leaveFlow(context);
      case null:
        break;
    }
  }

  Future<void> _leaveFlow(BuildContext context) async {
    final left = await showTeamLeaveSheet(context);
    if (left && context.mounted) {
      // Pop (rather than go) so the home section's awaited pushNamed resolves
      // and refreshTeam() re-syncs to noTeam.
      context.canPop()
          ? context.pop()
          : context.goNamed(AppRoutes.homeName);
    }
  }
}

class _IconButton extends StatelessWidget {
  const _IconButton({required this.icon, required this.size, this.onTap});

  final IconData icon;
  final double size;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final p = _Pal(context);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: p.cardFill,
          border: Border.all(color: p.glassBorder),
        ),
        child: Icon(icon, size: size, color: p.ink),
      ),
    );
  }
}

class _Stage extends StatelessWidget {
  const _Stage();

  @override
  Widget build(BuildContext context) {
    // This shell never depends on cubit state, so it builds once. Only the
    // category-aware region below subscribes to the filter selection — the
    // identity card, team code and activity feed are untouched on filter taps.
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 28),
      physics: const BouncingScrollPhysics(),
      children: const [
        _IdentityCard(),
        SizedBox(height: 11),
        _TeamCodeCard(),

        _SectionLabel(
          'Team leaderboard',
          more: 'Top 10 →',
          emphasis: _LabelEmphasis.primary,
        ),

        _LeaderboardSection(),

        _SectionLabel('Live activity', more: 'See all →'),
        _ActivityFeed(),
      ],
    );
  }
}

/// Category filter + leaderboard + rival hint. Isolated so that switching the
/// category filter only rebuilds this region, not the whole [_Stage] list.
class _LeaderboardSection extends StatelessWidget {
  const _LeaderboardSection();

  @override
  Widget build(BuildContext context) {
    return BlocSelector<TeamsCubit, TeamsState, int?>(
      selector: (state) => state.progressCategoryId,
      builder: (context, selectedId) {
        return Column(
          children: [
            _CategoryFilter(
              selectedId: selectedId,
              onSelect: (id) {
                final cubit = context.read<TeamsCubit>();
                // Re-tapping the active filter normally no-ops, but allow it to
                // retry when the board still has no data (first load failed).
                if (id == selectedId && cubit.state.progress != null) return;
                cubit.loadTeamProgress(categoryId: id);
              },
            ),
            const SizedBox(height: 12),
            const _Leaderboard(),
          ],
        );
      },
    );
  }
}

class _CategoryFilter extends StatelessWidget {
  const _CategoryFilter({required this.selectedId, required this.onSelect});

  final int? selectedId;
  final ValueChanged<int?> onSelect;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CategoriesCubit, CategoriesState>(
      buildWhen: (a, b) => a.categories != b.categories || a.status != b.status,
      builder: (context, state) {
        final categories = state.categories;

        return SizedBox(
          height: 32,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Row(
              children: [
                _CategoryChip(
                  label: 'All',
                  active: selectedId == null,
                  onTap: () => onSelect(null),
                ),
                for (final category in categories)
                  _CategoryChip(
                    label: category.name,
                    active: category.id == selectedId,
                    onTap: () => onSelect(category.id),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = _Pal(context);
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          onTap();
          // Auto-scroll the tapped chip to the centre so the active filter is
          // always fully in view.
          Scrollable.ensureVisible(
            context,
            alignment: 0.5,
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutCubic,
          );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(99),
            color: active ? p.washAmber.withValues(alpha: 0.18) : p.cardFill,
            border: Border.all(
              color: active ? p.washAmber.withValues(alpha: 0.5) : p.hairline,
            ),
          ),
          child: ResponsiveText(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: active ? FontWeight.w700 : FontWeight.w600,
              letterSpacing: 1.2,
              color: active ? p.gold : p.inkMute,
            ),
          ),
        ),
      ),
    );
  }
}

enum _LabelEmphasis { secondary, primary }

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(
    this.label, {
    this.more,
    this.emphasis = _LabelEmphasis.secondary,
  });

  final String label;
  final String? more;
  final _LabelEmphasis emphasis;

  bool get _isPrimary => emphasis == _LabelEmphasis.primary;

  @override
  Widget build(BuildContext context) {
    final p = _Pal(context);
    final ruleWidth = _isPrimary ? 22.0 : 16.0;
    final ruleHeight = _isPrimary ? 2.0 : 1.0;

    return Padding(
      padding: EdgeInsets.fromLTRB(2, _isPrimary ? 30 : 20, 2, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(
            child: Row(
              children: [
                Container(
                  width: ruleWidth,
                  height: ruleHeight,
                  decoration: BoxDecoration(
                    color: p.amber,
                    borderRadius: BorderRadius.circular(ruleHeight),
                    boxShadow: _isPrimary
                        ? [
                            BoxShadow(
                              color: p.washAmber.withValues(alpha: 0.6),
                              blurRadius: 8,
                            ),
                          ]
                        : null,
                  ),
                ),
                SizedBox(width: _isPrimary ? 10 : 8),
                Flexible(
                  child: ResponsiveText(
                    label.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: _isPrimary ? 12.5 : 9,
                      fontWeight: _isPrimary
                          ? FontWeight.w700
                          : FontWeight.w600,
                      letterSpacing: _isPrimary ? 2.2 : 3.0,

                      color: _isPrimary ? p.ink : p.amber,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (more != null)
            ResponsiveText(
              more!.toUpperCase(),
              style: TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.4,
                color: p.amber,
              ),
            ),
        ],
      ),
    );
  }
}

class _IdentityCard extends StatelessWidget {
  const _IdentityCard();

  @override
  Widget build(BuildContext context) {
    final p = _Pal(context);
    final state = context.watch<TeamsCubit>().state;
    final team = state.team;
    final progress = state.progress;
    final name = team?.name ?? progress?.teamName ?? '';
    final memberCount = team?.memberCount ?? 0;
    final rank = progress?.teamRank;
    final totalTeams = progress?.totalTeams;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: p.glassBorder),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [p.cardFillStrong, p.cardFillFaint],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: p.dark ? 0.42 : 0.06),
            blurRadius: 36,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 62,
                height: 62,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(19),
                  gradient: const RadialGradient(
                    center: Alignment(-0.36, -0.44),
                    colors: [
                      AppColors.discGoldHi,
                      AppColors.discGoldMid,
                      AppColors.discGoldLo,
                    ],
                    stops: [0.0, 0.55, 1.0],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: p.ember.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const ResponsiveText(
                  'ص',
                  style: TextStyle(fontSize: 29, color: AppColors.discGoldInk),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ResponsiveText(
                      name,
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w300,
                        fontSize: 23,
                        height: 1.05,
                        letterSpacing: -0.4,
                        color: p.ink,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        ResponsiveText(
                          '$memberCount ${memberCount == 1 ? 'member' : 'members'}',
                          style: TextStyle(fontSize: 11, color: p.inkMute),
                        ),
                        const SizedBox(width: 8),
                        ResponsiveText(
                          '·',
                          style: TextStyle(
                            fontSize: 11,
                            color: p.inkMute.withValues(alpha: 0.4),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const _ActiveBadge(),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.only(top: 14),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: p.hairline)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    ResponsiveText(
                      '#',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: p.amber,
                      ),
                    ),
                    const SizedBox(width: 6),
                    ResponsiveText(
                      rank != null ? '$rank' : '—',
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w300,
                        fontSize: 30,
                        height: 0.9,
                        color: p.emberLight,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 10),
                ResponsiveText(
                  'GLOBAL\nRANK',
                  style: TextStyle(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.6,
                    height: 1.4,
                    color: p.inkMute,
                  ),
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    ResponsiveText(
                      totalTeams != null ? 'of $totalTeams' : 'of —',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: p.gold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    ResponsiveText(
                      'TEAMS',
                      style: TextStyle(
                        fontSize: 8.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.6,
                        color: p.inkMute,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActiveBadge extends StatefulWidget {
  const _ActiveBadge();

  @override
  State<_ActiveBadge> createState() => _ActiveBadgeState();
}

class _ActiveBadgeState extends State<_ActiveBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = _Pal(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(99),
        color: p.greenSurface.withValues(alpha: 0.18),
        border: Border.all(color: p.greenSurface.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FadeTransition(
            opacity: Tween(begin: 1.0, end: 0.4).animate(_c),
            child: Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: p.green,
                boxShadow: [BoxShadow(color: p.green, blurRadius: 7)],
              ),
            ),
          ),
          const SizedBox(width: 5),
          ResponsiveText(
            'Active',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.7,
              color: p.green,
            ),
          ),
        ],
      ),
    );
  }
}

class _TeamCodeCard extends StatefulWidget {
  const _TeamCodeCard();

  @override
  State<_TeamCodeCard> createState() => _TeamCodeCardState();
}

class _TeamCodeCardState extends State<_TeamCodeCard> {
  bool _copied = false;

  Future<void> _copy(String code) async {
    await Clipboard.setData(ClipboardData(text: code));
    if (!mounted) return;
    setState(() => _copied = true);
    await Future.delayed(const Duration(milliseconds: 1700));
    if (!mounted) return;
    setState(() => _copied = false);
  }

  Future<void> _share(BuildContext context, String code) async {
    await sl<ShareService>().shareFrom(
      context: context,
      text: 'teams.create.share_message'.tr(
        namedArgs: {'code': code, 'link': DeepLinks.teamInvite(code)},
      ),
      subject: 'teams.create.share_subject'.tr(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = _Pal(context);
    final code = context.watch<TeamsCubit>().state.team?.joinCode ?? '';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: p.hairline),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [p.cardFill, p.cardFillFaint],
        ),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ResponsiveText(
                'INVITE CODE',
                style: TextStyle(
                  fontSize: 8.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2.0,
                  color: p.inkMute,
                ),
              ),
              const SizedBox(height: 6),
              _DashedPill(
                child: ResponsiveText(
                  code,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 3.2,
                    color: p.gold,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),

          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topCenter,
            children: [
              if (_copied) const Positioned(top: -34, child: _CopiedToast()),
              GestureDetector(
                onTap: () => _copy(code),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(13),
                    color: _copied
                        ? p.greenSurface.withValues(alpha: 0.2)
                        : p.cardFill,
                    border: Border.all(
                      color: _copied
                          ? p.greenSurface.withValues(alpha: 0.5)
                          : p.glassBorder,
                    ),
                  ),
                  child: Icon(
                    _copied ? Icons.check : Icons.copy_outlined,
                    size: 17,
                    color: _copied ? p.up : p.ink,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),

          GestureDetector(
            onTap: () => _share(context, code),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(13),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [p.gold, p.amber, p.amberDeep],
                  stops: const [0.0, 0.55, 1.0],
                ),
                boxShadow: [
                  BoxShadow(
                    color: p.washAmber.withValues(alpha: 0.26),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.ios_share,
                size: 17,
                color: AppColors.discGoldInk,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashedPill extends StatelessWidget {
  const _DashedPill({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final p = _Pal(context);
    return CustomPaint(
      painter: _DashedBorderPainter(color: p.amber, radius: 11),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(11),
          color: p.washAmber.withValues(alpha: 0.10),
        ),
        child: child,
      ),
    );
  }
}

class _CopiedToast extends StatelessWidget {
  const _CopiedToast();

  @override
  Widget build(BuildContext context) {
    final p = _Pal(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: p.greenSurface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.40),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ResponsiveText(
        'Copied ✓',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: p.dark ? AppColors.nightOliveCard : Colors.white,
        ),
      ),
    );
  }
}

class _ActivityFeed extends StatelessWidget {
  const _ActivityFeed();

  @override
  Widget build(BuildContext context) {
    final p = _Pal(context);
    final entries = <_ActivityEntry>[
      _ActivityEntry(
        node: _ActivityIcon(
          kind: _IconKind.streak,
          child: _Flame(size: 18, color: p.emberInk),
        ),
        name: 'Faisal',
        rest: ' reached a 50-day streak 🔥',
        meta: 'Milestone · 18m ago',
        trailing: _Sparkle(size: 14, color: p.gold),
        gold: true,
      ),
      _ActivityEntry(
        node: const _AvatarIcon(
          letter: 'A',
          hi: DateEmberRoles.oliveLight,
          lo: AppColors.discOliveLo,
          ink: AppColors.discOliveInk,
        ),
        name: 'Aisha',
        rest: ' completed Level 7',
        meta: 'Level · 1h ago',
        trailing: const _MiniCheck(),
      ),
      _ActivityEntry(
        node: _ActivityIcon(
          kind: _IconKind.quiz,
          child: Icon(Icons.help_outline, size: 17, color: p.gold),
        ),
        name: 'Maryam',
        rest: ' answered 20 questions today',
        meta: 'Quiz · 2h ago',
      ),
      _ActivityEntry(
        node: _ActivityIcon(
          kind: _IconKind.join,
          child: Icon(Icons.person_add_alt, size: 16, color: p.ink),
        ),
        name: 'Hamza',
        rest: ' joined the team',
        meta: 'New member · 5h ago',
      ),
    ];

    return Column(
      children: [
        for (var i = 0; i < entries.length; i++)
          _TimelineRow(entry: entries[i], isLast: i == entries.length - 1),
      ],
    );
  }
}

class _ActivityEntry {
  const _ActivityEntry({
    required this.node,
    required this.name,
    required this.rest,
    required this.meta,
    this.trailing,
    this.gold = false,
  });

  final Widget node;
  final String name;
  final String rest;
  final String meta;
  final Widget? trailing;
  final bool gold;
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({required this.entry, required this.isLast});

  final _ActivityEntry entry;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final p = _Pal(context);
    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: TextStyle(fontSize: 12, height: 1.3, color: p.ink),
                  children: [
                    TextSpan(
                      text: entry.name,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    TextSpan(text: entry.rest),
                  ],
                ),
              ),
            ),
            if (entry.trailing != null) ...[
              const SizedBox(width: 8),
              entry.trailing!,
            ],
          ],
        ),
        const SizedBox(height: 3),
        ResponsiveText(
          entry.meta,
          style: TextStyle(fontSize: 9, letterSpacing: 0.4, color: p.inkFaint),
        ),
      ],
    );

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 36,
            child: Column(
              children: [
                entry.node,
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: p.washAmber.withValues(alpha: 0.16),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 13),

          Expanded(
            child: Padding(
              padding: EdgeInsets.only(top: 2, bottom: isLast ? 0 : 18),
              child: entry.gold
                  ? Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 9,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: p.glassBorder),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            p.washAmber.withValues(alpha: 0.12),
                            p.washAmber.withValues(alpha: 0.03),
                          ],
                        ),
                      ),
                      child: body,
                    )
                  : body,
            ),
          ),
        ],
      ),
    );
  }
}

enum _IconKind { streak, quiz, join }

class _ActivityIcon extends StatelessWidget {
  const _ActivityIcon({required this.kind, required this.child});

  final _IconKind kind;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final p = _Pal(context);
    BoxDecoration deco;
    switch (kind) {
      case _IconKind.streak:
        deco = BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [p.emberLight, p.ember],
          ),
        );
      case _IconKind.quiz:
        deco = BoxDecoration(
          color: p.washAmber.withValues(alpha: 0.16),
          border: Border.all(color: p.washAmber.withValues(alpha: 0.4)),
        );
      case _IconKind.join:
        deco = BoxDecoration(
          color: p.cardFill,
          border: Border.all(color: p.glassBorder),
        );
    }
    return Container(
      width: 36,
      height: 36,
      alignment: Alignment.center,
      decoration: deco.copyWith(borderRadius: BorderRadius.circular(11)),
      child: child,
    );
  }
}

class _AvatarIcon extends StatelessWidget {
  const _AvatarIcon({
    required this.letter,
    required this.hi,
    required this.lo,
    required this.ink,
  });

  final String letter;
  final Color hi;
  final Color lo;
  final Color ink;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(11),
        gradient: RadialGradient(
          center: const Alignment(-0.36, -0.44),
          colors: [hi, lo],
        ),
      ),
      child: ResponsiveText(letter, style: TextStyle(fontSize: 14, color: ink)),
    );
  }
}

class _MiniCheck extends StatelessWidget {
  const _MiniCheck();

  @override
  Widget build(BuildContext context) {
    final p = _Pal(context);
    return Container(
      width: 28,
      height: 28,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(9),
        color: p.greenSurface.withValues(alpha: 0.16),
        border: Border.all(color: p.greenSurface.withValues(alpha: 0.34)),
      ),
      child: Icon(Icons.check, size: 14, color: p.green),
    );
  }
}

class _Leaderboard extends StatelessWidget {
  const _Leaderboard();

  @override
  Widget build(BuildContext context) {
    final p = _Pal(context);
    final state = context.watch<TeamsCubit>().state;
    final progress = state.progress;
    final loading = progress == null || state.progressLoading;
    final myId = context.watch<UserCubit>().state.user?.id;

    final List<_LbEntry> entries;
    if (progress == null) {
      // First load — no data yet, so fall back to a fixed placeholder board.
      entries = _skeletonBoard;
    } else {
      // While a category is loading, the previous board stays mounted and is
      // shimmered in place (same member count, so the leaderboard keeps its
      // height and the content below it doesn't move); once loaded it swaps to
      // the real values. `progress.category` is the scoped breakdown, falling
      // back to the all-categories totals.
      final source = progress.category?.members ?? progress.members;
      final members = [...source]
        ..sort((a, b) => b.completedLevels.compareTo(a.completedLevels));
      entries = [
        for (var i = 0; i < members.length; i++)
          _LbEntry.fromMember(
            members[i],
            rank: i + 1,
            isMe: members[i].userId == myId,
          ),
      ];
    }

    final podium = entries.take(3).toList();
    final rest = entries.skip(3).toList();
    return Skeletonizer(
      enabled: loading,
      effect: ShimmerEffect(
        baseColor: p.washAmber.withValues(alpha: 0.10),
        highlightColor: p.washAmber.withValues(alpha: 0.22),
      ),
      child: Column(
        children: [
          if (podium.isNotEmpty) _TopThree(entries: podium),
          if (podium.isNotEmpty && rest.isNotEmpty) const SizedBox(height: 14),
          for (var i = 0; i < rest.length; i++) ...[
            if (i > 0) const SizedBox(height: 7),
            _LbRow.fromEntry(rest[i]),
          ],
        ],
      ),
    );
  }
}

/// Placeholder rows rendered (skeletonized) while team progress loads, so the
/// leaderboard shows a shimmer in the real layout instead of an empty state.
const _skeletonBoard = <_LbEntry>[
  _LbEntry(
    pos: '1',
    letter: 'A',
    name: 'Member name',
    meta: 'Active',
    points: '18/20',
    percent: 90,
    medal: true,
  ),
  _LbEntry(
    pos: '2',
    letter: 'B',
    name: 'Member name',
    meta: 'Consistent',
    points: '16/20',
    percent: 80,
    medal: true,
    palette: _AvatarPalette.olive,
  ),
  _LbEntry(
    pos: '3',
    letter: 'C',
    name: 'Member name',
    meta: 'Active',
    points: '14/20',
    percent: 70,
    medal: true,
  ),
  _LbEntry(
    pos: '4',
    letter: 'D',
    name: 'Member name',
    meta: 'Idle',
    points: '11/20',
    percent: 55,
  ),
  _LbEntry(
    pos: '5',
    letter: 'E',
    name: 'Member name',
    meta: 'Consistent',
    points: '9/20',
    percent: 45,
    palette: _AvatarPalette.olive,
  ),
  _LbEntry(
    pos: '6',
    letter: 'F',
    name: 'Member name',
    meta: 'Idle',
    points: '7/20',
    percent: 35,
  ),
];

class _TopThree extends StatelessWidget {
  const _TopThree({required this.entries});

  final List<_LbEntry> entries;

  @override
  Widget build(BuildContext context) {
    _LbEntry? at(int i) => i < entries.length ? entries[i] : null;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(flex: 100, child: _PodiumPillar(place: 2, entry: at(1))),
          const SizedBox(width: 9),
          Expanded(flex: 115, child: _PodiumPillar(place: 1, entry: at(0))),
          const SizedBox(width: 9),
          Expanded(flex: 100, child: _PodiumPillar(place: 3, entry: at(2))),
        ],
      ),
    );
  }
}

class _PodiumPillar extends StatelessWidget {
  const _PodiumPillar({required this.place, required this.entry});

  final int place;
  final _LbEntry? entry;

  @override
  Widget build(BuildContext context) {
    final p = _Pal(context);
    final isFirst = place == 1;

    final accent = switch (place) {
      1 => AppColors.discGoldMid,
      2 => AppColors.discSilverMid,
      _ => AppColors.discBronzeMid,
    };
    final discHi = switch (place) {
      1 => AppColors.discGoldHi,
      2 => AppColors.discSilverHi,
      _ => AppColors.discBronzeHi,
    };
    final discLo = switch (place) {
      1 => AppColors.discGoldLo,
      2 => AppColors.discSilverLo,
      _ => AppColors.discBronzeLo,
    };
    final avatarSize = isFirst ? 60.0 : 50.0;
    final pedHeight = switch (place) {
      1 => 42.0,
      2 => 30.0,
      _ => 24.0,
    };

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        SizedBox(
          width: avatarSize + 16,
          height: avatarSize + (isFirst ? 24 : 16),
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Container(
                width: avatarSize + 16,
                height: avatarSize + 16,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      accent.withValues(alpha: 0.5),
                      accent.withValues(alpha: 0),
                    ],
                    stops: const [0.5, 1.0],
                  ),
                ),
              ),
              Container(
                width: avatarSize,
                height: avatarSize,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    center: const Alignment(-0.36, -0.44),
                    colors: [discHi, discLo],
                  ),
                ),
                child: ResponsiveText(
                  entry?.letter ?? '—',
                  style: TextStyle(
                    fontSize: isFirst ? 24 : 20,
                    color: AppColors.discGoldInk,
                  ),
                ),
              ),
              if (isFirst && entry != null)
                const Positioned(top: -10, child: RankCrown()),
              Positioned(
                right: 0,
                bottom: 0,
                child: _PodiumBadge(place: place, color: accent),
              ),
            ],
          ),
        ),
        const SizedBox(height: 7),
        ResponsiveText(
          entry?.name ?? '—',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: isFirst ? FontWeight.w700 : FontWeight.w600,
            color: isFirst ? p.gold : p.ink,
          ),
        ),
        const SizedBox(height: 2),
        ResponsiveText(
          entry?.points ?? '—',
          style: TextStyle(
            fontSize: isFirst ? 12 : 11,
            fontWeight: FontWeight.w500,
            color: accent,
          ),
        ),
        const SizedBox(height: 8),

        Container(
          height: pedHeight,
          width: double.infinity,
          padding: const EdgeInsets.only(top: 7),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(9)),
            border: Border(
              top: BorderSide(color: accent.withValues(alpha: 0.4)),
              left: BorderSide(color: accent.withValues(alpha: 0.4)),
              right: BorderSide(color: accent.withValues(alpha: 0.4)),
            ),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                accent.withValues(alpha: 0.28),
                accent.withValues(alpha: 0.05),
              ],
            ),
          ),
          child: ResponsiveText(
            '0$place',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: accent,
            ),
          ),
        ),
      ],
    );
  }
}

class _PodiumBadge extends StatelessWidget {
  const _PodiumBadge({required this.place, required this.color});

  final int place;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final p = _Pal(context);
    return Container(
      width: 22,
      height: 22,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: p.bgBottom,
        border: Border.all(color: color, width: 2),
      ),
      child: ResponsiveText(
        '$place',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

enum _AvatarPalette { gold, olive }

class _LbEntry {
  const _LbEntry({
    required this.pos,
    required this.letter,
    required this.name,
    required this.meta,
    required this.points,
    required this.percent,
    this.medal = false,
    this.isMe = false,
    this.palette = _AvatarPalette.gold,
  });

  factory _LbEntry.fromMember(
    TeamMemberProgressModel member, {
    required int rank,
    required bool isMe,
  }) {
    final name = member.username.trim();
    return _LbEntry(
      pos: '$rank',
      letter: name.isEmpty ? '—' : name.substring(0, 1).toUpperCase(),
      name: name.isEmpty ? 'Member' : name,
      meta: member.activityStatus.label,
      points: '${member.completedLevels}/${member.totalLevels}',
      percent: member.progressPercent,
      medal: rank <= 3,
      isMe: isMe,
      palette: rank.isEven ? _AvatarPalette.olive : _AvatarPalette.gold,
    );
  }

  final String pos;
  final String letter;
  final String name;
  final String meta;
  final String points;
  final int percent;
  final bool medal;
  final bool isMe;
  final _AvatarPalette palette;
}

_LbAvatar _avatarFor(_AvatarPalette palette, String letter) =>
    switch (palette) {
      _AvatarPalette.gold => _LbAvatar(
        letter: letter,
        hi: AppColors.discGoldHi,
        lo: AppColors.discGoldLo,
        ink: AppColors.discGoldInk,
      ),
      _AvatarPalette.olive => _LbAvatar(
        letter: letter,
        hi: DateEmberRoles.oliveLight,
        lo: AppColors.discOliveLo,
        ink: AppColors.discOliveInk,
      ),
    };

class _LbRow extends StatelessWidget {
  const _LbRow({
    required this.pos,
    required this.avatar,
    required this.name,
    required this.meta,
    required this.points,
    required this.percent,
    this.medal = false,
    this.me = false,
  });

  factory _LbRow.fromEntry(_LbEntry e) => _LbRow(
    pos: e.pos,
    avatar: _avatarFor(e.palette, e.letter),
    name: e.name,
    meta: e.meta,
    points: e.points,
    percent: e.percent,
    medal: e.medal,
    me: e.isMe,
  );

  final String pos;
  final Widget avatar;
  final String name;
  final String meta;
  final String points;
  final int percent;
  final bool medal;
  final bool me;

  @override
  Widget build(BuildContext context) {
    final p = _Pal(context);
    final deco = me
        ? BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                p.washAmber.withValues(alpha: 0.12),
                p.washAmber.withValues(alpha: 0.03),
              ],
            ),
            border: Border.all(color: p.glassBorder),
          )
        : BoxDecoration(
            color: p.cardFill,
            border: Border.all(color: p.hairline),
          );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: deco.copyWith(borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: [
          SizedBox(
            width: 22,
            child: ResponsiveText(
              pos,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: medal ? p.gold : p.inkFaint,
              ),
            ),
          ),
          const SizedBox(width: 11),
          avatar,
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: ResponsiveText(
                        name,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          height: 1.1,
                          color: p.ink,
                        ),
                      ),
                    ),
                    if (me) ...[
                      const SizedBox(width: 6),
                      const _Tag(),
                    ],
                  ],
                ),
                const SizedBox(height: 3),
                ResponsiveText(
                  meta,
                  style: TextStyle(fontSize: 10, color: p.inkMute),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              ResponsiveText(
                points,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: p.gold,
                ),
              ),
              const SizedBox(height: 2),
              ResponsiveText(
                '$percent%',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: p.up,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LbAvatar extends StatelessWidget {
  const _LbAvatar({
    required this.letter,
    required this.hi,
    required this.lo,
    required this.ink,
  });

  final String letter;
  final Color hi;
  final Color lo;
  final Color ink;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          center: const Alignment(-0.36, -0.44),
          colors: [hi, lo],
        ),
      ),
      child: ResponsiveText(letter, style: TextStyle(fontSize: 14, color: ink)),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag();

  @override
  Widget build(BuildContext context) {
    final p = _Pal(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(99),
        color: p.washAmber.withValues(alpha: 0.2),
        border: Border.all(color: p.washAmber.withValues(alpha: 0.4)),
      ),
      child: ResponsiveText(
        'YOU',
        style: TextStyle(
          fontSize: 7.5,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.0,
          color: p.gold,
        ),
      ),
    );
  }
}


class _Sparkle extends StatelessWidget {
  const _Sparkle({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: SparklePainter(color),
    );
  }
}

class _Flame extends StatelessWidget {
  const _Flame({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Icon(Icons.local_fire_department, size: size, color: color);
  }
}

class _DashedBorderPainter extends CustomPainter {
  _DashedBorderPainter({required this.color, required this.radius});

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = color;
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );
    final path = Path()..addRRect(rrect);
    const dash = 4.0;
    const gap = 3.0;
    for (final metric in path.computeMetrics()) {
      double d = 0;
      while (d < metric.length) {
        canvas.drawPath(
          metric.extractPath(d, math.min(d + dash, metric.length)),
          paint,
        );
        d += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter old) =>
      old.color != color || old.radius != radius;
}
