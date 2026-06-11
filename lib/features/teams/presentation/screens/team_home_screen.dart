import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/navigation/deep_links.dart';
import '../../../../core/services/core_service_locator.dart';
import '../../../../core/services/share_service.dart';
import '../../../../core/widgets/responsive_text.dart';
import '../../../../theme/theme.dart';
import '../../../leaderboard/presentation/widgets/my_rank_card.dart';
import '../../../leaderboard/presentation/widgets/rank_seed.dart';
import '../../../leaderboard/presentation/widgets/ranking_row.dart';
import '../../../user/presentation/cubit/user_cubit.dart';
import '../../data/models/team_member_progress_model.dart';
import '../cubit/teams_cubit.dart';
import '../cubit/teams_state.dart';
import '../widgets/date_ember_roles.dart';

typedef _Pal = DateEmberRoles;

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
      if (!mounted) return;
      final cubit = context.read<TeamsCubit>();
      final s = cubit.state;
      if (!s.hasTeam && !s.isLoading) cubit.loadTeamStatus();
      if (s.members == null) cubit.loadTeamMembers();
      if (s.progress == null) cubit.loadTeamProgress();
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = _Pal(context);
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
        child: Stack(
          children: const [
            SafeArea(
              bottom: false,
              child: Column(
                children: [
                  _AppBar(),
                  Expanded(child: _Stage()),
                ],
              ),
            ),
            Positioned(left: 14, right: 14, bottom: 18, child: _TabBar()),
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
    final name = context.select<TeamsCubit, String>(
      (c) => c.state.team?.name ?? c.state.progress?.teamName ?? '',
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 10),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.maybePop(context),
            child: const _IconButton(icon: Icons.arrow_back, size: 17),
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
                  name.isEmpty ? 'Companions of Sabr' : name,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
          const _IconButton(icon: Icons.more_horiz, size: 18),
        ],
      ),
    );
  }
}

class _IconButton extends StatelessWidget {
  const _IconButton({required this.icon, required this.size});

  final IconData icon;
  final double size;

  @override
  Widget build(BuildContext context) {
    final p = _Pal(context);
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: p.cardFill,
        border: Border.all(color: p.glassBorder),
      ),
      child: Icon(icon, size: size, color: p.ink),
    );
  }
}

class _Stage extends StatelessWidget {
  const _Stage();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 100),
      physics: const BouncingScrollPhysics(),
      children: const [
        _IdentityCard(),
        SizedBox(height: 11),
        _TeamCodeCard(),
        _SectionLabel('Live activity', more: 'See all →'),
        _ActivityFeed(),
        _SectionLabel(
          'Team leaderboard',
          more: 'Top 10 →',
          emphasis: _LabelEmphasis.primary,
        ),
        _Leaderboard(),
        _MyTeamRankCard(),
      ],
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

    final name =
        state.team?.name ?? state.progress?.teamName ?? 'Companions of Sabr';
    final memberCount =
        state.team?.memberCount ?? state.members?.members.length ?? 12;
    final rank = state.summary?.teamRank ?? state.progress?.teamRank ?? 0;
    final totalTeams =
        state.summary?.totalTeams ?? state.progress?.totalTeams ?? 0;
    final rankLabel = rank > 0 ? '$rank' : '14';
    final totalLabel = totalTeams > 0 ? 'of $totalTeams' : 'of 312';

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
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
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
                          '$memberCount members',
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
                      rankLabel,
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
                      totalLabel,
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

  Future<void> _share(String code) async {
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
    final code = context.select<TeamsCubit, String>(
      (c) => c.state.team?.joinCode ?? '',
    );
    final display = code.isEmpty ? 'XXXX-XXXX' : code;
    final ready = code.isNotEmpty;

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
                  display,
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
                onTap: ready ? () => _copy(code) : null,
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
            onTap: ready ? () => _share(code) : null,
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
    final state = context.watch<TeamsCubit>().state;
    final source = (state.progress?.members.isNotEmpty ?? false)
        ? state.progress!.members
        : (state.summary?.members ?? const <TeamMemberProgressModel>[]);

    if (source.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 28),
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    final ranked = [...source]
      ..sort((a, b) => b.completedLevels.compareTo(a.completedLevels));
    final top = ranked.take(10).toList();
    final meId = context.watch<UserCubit>().state.user?.id;

    return Column(
      children: [
        for (var i = 0; i < top.length; i++) ...[
          if (i > 0) const SizedBox(height: 6),
          RankingRow(
            seed: RankSeed(
              rank: i + 1,
              name: top[i].username,
              completed: top[i].completedLevels,
              total: top[i].totalLevels,
              isMe: meId != null && top[i].userId == meId,
            ),
          ),
        ],
      ],
    );
  }
}

class _MyTeamRankCard extends StatelessWidget {
  const _MyTeamRankCard();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<TeamsCubit>().state;
    final source = (state.progress?.members.isNotEmpty ?? false)
        ? state.progress!.members
        : (state.summary?.members ?? const <TeamMemberProgressModel>[]);
    final meId = context.watch<UserCubit>().state.user?.id;
    if (source.isEmpty || meId == null) return const SizedBox.shrink();

    final ranked = [...source]
      ..sort((a, b) => b.completedLevels.compareTo(a.completedLevels));
    final i = ranked.indexWhere((m) => m.userId == meId);
    if (i < 0) return const SizedBox.shrink();
    final me = ranked[i];

    return MyRankCard(
      label: 'leaderboard.your_rank'.tr(),
      rank: i + 1,
      title: 'leaderboard.you'.tr(),
      completed: me.completedLevels,
      total: me.totalLevels,
    );
  }
}

class _TabBar extends StatelessWidget {
  const _TabBar();

  @override
  Widget build(BuildContext context) {
    final p = _Pal(context);
    return Container(
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: p.dark
              ? [
                  AppColors.nightRaised.withValues(alpha: 0.94),
                  AppColors.nightSurface.withValues(alpha: 0.94),
                ]
              : [p.bgTop, p.bgMid],
        ),
        border: Border.all(color: p.glassBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: p.dark ? 0.55 : 0.10),
            blurRadius: 30,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _Tab(icon: Icons.home_outlined, label: 'HOME', active: true),
          _Tab(icon: Icons.group_outlined, label: 'MEMBERS'),
          _Tab(icon: Icons.bar_chart, label: 'PROGRESS'),
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({required this.icon, required this.label, this.active = false});

  final IconData icon;
  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final p = _Pal(context);
    final color = active ? p.gold : p.inkFaint;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (active)
          Container(
            width: 26,
            height: 3,
            margin: const EdgeInsets.only(bottom: 7),
            decoration: BoxDecoration(
              color: p.amber,
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(3),
              ),
              boxShadow: [
                BoxShadow(
                  color: p.washAmber.withValues(alpha: 0.7),
                  blurRadius: 10,
                ),
              ],
            ),
          )
        else
          const SizedBox(height: 10),
        Icon(icon, size: 20, color: color),
        const SizedBox(height: 3),
        ResponsiveText(
          label,
          style: TextStyle(
            fontSize: 8.5,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.3,
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
