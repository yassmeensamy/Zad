import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/navigation/app_routes.dart';
import '../../../../core/navigation/deep_links.dart';
import '../../../../core/services/core_service_locator.dart';
import '../../../../core/services/share_service.dart';
import '../../../../core/widgets/responsive_text.dart';
import '../../../../theme/theme.dart';
import '../../../categories/presentation/cubit/categories_cubit.dart';
import '../../../categories/presentation/cubit/categories_state.dart';
import '../cubit/teams_cubit.dart';
import '../widgets/date_ember_roles.dart';
import '../widgets/team_leave_sheet.dart';

typedef _Pal = DateEmberRoles;

class TempTeamHomeScreen extends StatelessWidget {
  const TempTeamHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = _Pal(context);

    return BlocProvider<CategoriesCubit>.value(
      value: sl<CategoriesCubit>()..ensureLoaded(),
      child: _build(context, p),
    );
  }

  Widget _build(BuildContext context, _Pal p) {
    return Scaffold(
      backgroundColor: p.bgBottom,
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0, -1.16),
            radius: 1.3,
            colors: [p.bgTop, p.bgMid, p.bgBottom],
            stops: const [0.0, 0.42, 1.0],
          ),
        ),
        child: const SafeArea(
          bottom: false,
          child: Column(
            children: [
              _AppBar(),
              Expanded(child: _Stage()),
            ],
          ),
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 10),
      child: Row(
        children: [
          _IconButton(
            icon: Icons.arrow_back,
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
                  'Companions of Sabr',
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
            onTap: () async {
              final left = await showTeamLeaveSheet(context);
              if (left && context.mounted) {
                context.goNamed(AppRoutes.homeName);
              }
            },
          ),
        ],
      ),
    );
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

class _Stage extends StatefulWidget {
  const _Stage();

  @override
  State<_Stage> createState() => _StageState();
}

class _StageState extends State<_Stage> {
  int? _categoryId;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 28),
      physics: const BouncingScrollPhysics(),
      children: [
        const _IdentityCard(),
        const SizedBox(height: 11),
        const _TeamCodeCard(),

        const _SectionLabel(
          'Team leaderboard',
          more: 'Top 10 →',
          emphasis: _LabelEmphasis.primary,
        ),

        _CategoryFilter(
          selectedId: _categoryId,
          onSelect: (id) => setState(() => _categoryId = id),
        ),
        const SizedBox(height: 12),
        _Leaderboard(categoryId: _categoryId),

        if (_categoryId == null) const _RivalHint(),

        const _SectionLabel('Live activity', more: 'See all →'),
        const _ActivityFeed(),
      ],
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
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 2),

            itemCount: categories.length + 1,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, i) {
              if (i == 0) {
                return _CategoryChip(
                  label: 'All',
                  active: selectedId == null,
                  onTap: () => onSelect(null),
                );
              }
              final category = categories[i - 1];
              return _CategoryChip(
                label: category.name,
                active: category.id == selectedId,
                onTap: () => onSelect(category.id),
              );
            },
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
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
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
  static const _code = 'SABR-9F2K';
  bool _copied = false;

  Future<void> _copy() async {
    await Clipboard.setData(const ClipboardData(text: _code));
    if (!mounted) return;
    setState(() => _copied = true);
    await Future.delayed(const Duration(milliseconds: 1700));
    if (!mounted) return;
    setState(() => _copied = false);
  }

  Future<void> _share(BuildContext context) async {
    await sl<ShareService>().shareFrom(
      context: context,
      text: 'teams.create.share_message'.tr(
        namedArgs: {'code': _code, 'link': DeepLinks.teamInvite(_code)},
      ),
      subject: 'teams.create.share_subject'.tr(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = _Pal(context);
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
                  _code,
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
                onTap: _copy,
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
            onTap: () => _share(context),
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
  const _Leaderboard({required this.categoryId});

  final int? categoryId;

  @override
  Widget build(BuildContext context) {
    final entries = categoryId == null
        ? _overallBoard
        : _categoryBoards[categoryId! % _categoryBoards.length];

    final podium = entries.take(3).toList();
    final rest = entries.skip(3).toList();
    return Column(
      children: [
        if (podium.isNotEmpty) _TopThree(entries: podium),
        if (podium.isNotEmpty && rest.isNotEmpty) const SizedBox(height: 14),
        for (var i = 0; i < rest.length; i++) ...[
          if (i > 0) const SizedBox(height: 7),
          _LbRow.fromEntry(rest[i]),
        ],
      ],
    );
  }
}

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
                const Positioned(top: -10, child: _Crown()),
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

class _Crown extends StatelessWidget {
  const _Crown();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 26,
      height: 16,
      child: CustomPaint(painter: _CrownPainter()),
    );
  }
}

class _CrownPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final sx = size.width / 26;
    final sy = size.height / 16;
    final path = Path()
      ..moveTo(1.5 * sx, 14 * sy)
      ..lineTo(4 * sx, 5 * sy)
      ..lineTo(9.5 * sx, 10.5 * sy)
      ..lineTo(13 * sx, 2.5 * sy)
      ..lineTo(16.5 * sx, 10.5 * sy)
      ..lineTo(22 * sx, 5 * sy)
      ..lineTo(24.5 * sx, 14 * sy)
      ..close();
    canvas.drawPath(
      path,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.discGoldHi, AppColors.discGoldLo],
        ).createShader(Offset.zero & size),
    );
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8
        ..strokeJoin = StrokeJoin.round
        ..color = AppColors.discGoldLo,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

enum _AvatarPalette { gold, olive }

class _LbEntry {
  const _LbEntry({
    required this.pos,
    required this.letter,
    required this.name,
    required this.meta,
    required this.points,
    required this.trend,
    this.medal = false,
    this.up = true,
    this.tag = _LbTag.none,
    this.palette = _AvatarPalette.gold,
  });

  final String pos;
  final String letter;
  final String name;
  final String meta;
  final String points;
  final String trend;
  final bool medal;
  final bool up;
  final _LbTag tag;
  final _AvatarPalette palette;
}

const _overallBoard = <_LbEntry>[
  _LbEntry(
    pos: '1',
    letter: 'Y',
    name: 'Yūsuf A.',
    meta: '94% accuracy · 38d streak',
    points: '3,420',
    trend: '0',
    medal: true,
  ),
  _LbEntry(
    pos: '2',
    letter: 'A',
    name: 'Aisha M.',
    meta: '91% accuracy · 24d streak',
    points: '2,980',
    trend: '1',
    medal: true,
    palette: _AvatarPalette.olive,
  ),
  _LbEntry(
    pos: '4',
    letter: 'M',
    name: 'Maryam K.',
    meta: '2,210 pts · just ahead of you',
    points: '2,210',
    trend: '1',
    up: false,
    tag: _LbTag.rival,
  ),
  _LbEntry(
    pos: '5',
    letter: 'ز',
    name: 'Zayd N.',
    meta: '2,070 pts · 140 to overtake',
    points: '2,070',
    trend: '2',
    tag: _LbTag.you,
  ),
];

const _categoryBoards = <List<_LbEntry>>[
  [
    _LbEntry(
      pos: '1',
      letter: 'A',
      name: 'Aisha M.',
      meta: '1,540 pts · category leader',
      points: '1,540',
      trend: '0',
      medal: true,
      palette: _AvatarPalette.olive,
    ),
    _LbEntry(
      pos: '2',
      letter: 'ز',
      name: 'Zayd N.',
      meta: '1,420 pts · 120 to the top',
      points: '1,420',
      trend: '2',
      tag: _LbTag.you,
    ),
    _LbEntry(
      pos: '3',
      letter: 'Y',
      name: 'Yūsuf A.',
      meta: '88% accuracy · steady',
      points: '1,180',
      trend: '1',
      up: false,
    ),
    _LbEntry(
      pos: '4',
      letter: 'M',
      name: 'Maryam K.',
      meta: '1,090 pts · just behind you',
      points: '1,090',
      trend: '1',
      up: false,
      tag: _LbTag.rival,
    ),
  ],
  [
    _LbEntry(
      pos: '1',
      letter: 'Y',
      name: 'Yūsuf A.',
      meta: '980 pts · category leader',
      points: '980',
      trend: '0',
      medal: true,
    ),
    _LbEntry(
      pos: '2',
      letter: 'M',
      name: 'Maryam K.',
      meta: '870 pts · just ahead of you',
      points: '870',
      trend: '1',
      tag: _LbTag.rival,
    ),
    _LbEntry(
      pos: '3',
      letter: 'ز',
      name: 'Zayd N.',
      meta: '760 pts · 110 to overtake',
      points: '760',
      trend: '1',
      up: false,
      tag: _LbTag.you,
    ),
    _LbEntry(
      pos: '4',
      letter: 'B',
      name: 'Bilal R.',
      meta: '85% accuracy · rising',
      points: '640',
      trend: '2',
      palette: _AvatarPalette.olive,
    ),
  ],
  [
    _LbEntry(
      pos: '1',
      letter: 'M',
      name: 'Maryam K.',
      meta: '1,310 pts · just ahead of you',
      points: '1,310',
      trend: '0',
      medal: true,
      tag: _LbTag.rival,
    ),
    _LbEntry(
      pos: '2',
      letter: 'ز',
      name: 'Zayd N.',
      meta: '1,240 pts · 70 to overtake',
      points: '1,240',
      trend: '1',
      tag: _LbTag.you,
    ),
    _LbEntry(
      pos: '3',
      letter: 'A',
      name: 'Aisha M.',
      meta: '90% accuracy · consistent',
      points: '1,100',
      trend: '1',
      up: false,
      palette: _AvatarPalette.olive,
    ),
    _LbEntry(
      pos: '4',
      letter: 'Y',
      name: 'Yūsuf A.',
      meta: '980 pts · holding',
      points: '980',
      trend: '0',
    ),
  ],
  [
    _LbEntry(
      pos: '1',
      letter: 'ز',
      name: 'Zayd N.',
      meta: '1,560 pts · you lead this category',
      points: '1,560',
      trend: '1',
      medal: true,
      tag: _LbTag.you,
    ),
    _LbEntry(
      pos: '2',
      letter: 'Y',
      name: 'Yūsuf A.',
      meta: '1,420 pts · chasing you',
      points: '1,420',
      trend: '1',
      up: false,
    ),
    _LbEntry(
      pos: '3',
      letter: 'A',
      name: 'Aisha M.',
      meta: '92% accuracy · steady',
      points: '1,260',
      trend: '0',
      palette: _AvatarPalette.olive,
    ),
    _LbEntry(
      pos: '4',
      letter: 'M',
      name: 'Maryam K.',
      meta: '1,150 pts · slipping',
      points: '1,150',
      trend: '2',
      up: false,
      tag: _LbTag.rival,
    ),
  ],
];

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

enum _LbTag { none, you, rival }

class _LbRow extends StatelessWidget {
  const _LbRow({
    required this.pos,
    required this.avatar,
    required this.name,
    required this.meta,
    required this.points,
    required this.trend,
    required this.up,
    this.medal = false,
    this.me = false,
    this.rival = false,
    this.tag = _LbTag.none,
  });

  factory _LbRow.fromEntry(_LbEntry e) => _LbRow(
    pos: e.pos,
    avatar: _avatarFor(e.palette, e.letter),
    name: e.name,
    meta: e.meta,
    points: e.points,
    trend: e.trend,
    up: e.up,
    medal: e.medal,
    me: e.tag == _LbTag.you,
    rival: e.tag == _LbTag.rival,
    tag: e.tag,
  );

  final String pos;
  final Widget avatar;
  final String name;
  final String meta;
  final String points;
  final String trend;
  final bool up;
  final bool medal;
  final bool me;
  final bool rival;
  final _LbTag tag;

  @override
  Widget build(BuildContext context) {
    final p = _Pal(context);
    BoxDecoration deco;
    if (me) {
      deco = BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            p.washAmber.withValues(alpha: 0.12),
            p.washAmber.withValues(alpha: 0.03),
          ],
        ),
        border: Border.all(color: p.glassBorder),
      );
    } else if (rival) {
      deco = BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            p.ember.withValues(alpha: 0.12),
            p.ember.withValues(alpha: 0.03),
          ],
        ),
        border: Border.all(color: p.emberLight.withValues(alpha: 0.34)),
      );
    } else {
      deco = BoxDecoration(
        color: p.cardFill,
        border: Border.all(color: p.hairline),
      );
    }

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
                    if (tag != _LbTag.none) ...[
                      const SizedBox(width: 6),
                      _Tag(tag),
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
              _TrendChip(value: trend, up: up),
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
  const _Tag(this.tag);
  final _LbTag tag;

  @override
  Widget build(BuildContext context) {
    final p = _Pal(context);
    final isYou = tag == _LbTag.you;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(99),
        color: (isYou ? p.washAmber : p.ember).withValues(
          alpha: isYou ? 0.2 : 0.18,
        ),
        border: Border.all(
          color: (isYou ? p.washAmber : p.emberLight).withValues(alpha: 0.4),
        ),
      ),
      child: ResponsiveText(
        isYou ? 'YOU' : 'RIVAL',
        style: TextStyle(
          fontSize: 7.5,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.0,
          color: isYou ? p.gold : p.emberLight,
        ),
      ),
    );
  }
}

class _RivalHint extends StatelessWidget {
  const _RivalHint();

  @override
  Widget build(BuildContext context) {
    final p = _Pal(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 9, 4, 0),
      child: Row(
        children: [
          Icon(Icons.schedule, size: 13, color: p.emberLight),
          const SizedBox(width: 7),
          Expanded(
            child: ResponsiveText(
              'Just 140 points behind Maryam — your closest competitor.',
              style: TextStyle(
                fontStyle: FontStyle.italic,
                fontSize: 10.5,
                color: p.emberLight,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TrendChip extends StatelessWidget {
  const _TrendChip({required this.value, required this.up});

  final String value;
  final bool up;

  @override
  Widget build(BuildContext context) {
    final p = _Pal(context);
    final color = up ? p.up : p.down;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          up ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
          size: 12,
          color: color,
        ),
        ResponsiveText(
          value,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
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
      painter: _SparklePainter(color),
    );
  }
}

class _SparklePainter extends CustomPainter {
  _SparklePainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 24.0;
    final paint = Paint()..color = color;
    final path = Path()
      ..moveTo(12 * s, 2 * s)
      ..lineTo(14 * s, 9 * s)
      ..lineTo(21 * s, 12 * s)
      ..lineTo(14 * s, 15 * s)
      ..lineTo(12 * s, 22 * s)
      ..lineTo(10 * s, 15 * s)
      ..lineTo(3 * s, 12 * s)
      ..lineTo(10 * s, 9 * s)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_SparklePainter old) => old.color != color;
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
