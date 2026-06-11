import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/widgets/responsive_text.dart';
import '../../../../theme/theme.dart';
import '../widgets/date_ember_roles.dart';
import '../widgets/team_week_stats.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Zad — Team Home · Community
//
// A community-first team dashboard — identity, your standing, the live pulse of
// the team, and who you're chasing. No goals, just growth.
//
// This is a "temp" showcase screen: it carries its own mock data and renders
// the full design in a single file so the visual can be reviewed at scale
// before being wired to [TeamsCubit].
//
// Theming: the screen is fully brightness-aware. In **dark** mode it reproduces
// the original Date & Ember design 1:1 (via [AppColors]); in **light** mode it
// maps every surface, ink and accent onto the app's semantic [AppColorsTheme]
// tokens. All of that mapping lives in [_Pal] so the widgets below read colours
// by role, never by literal. Type uses the app's default family (ElMessiri) —
// no font is bundled here; only weights/styles vary.
// ─────────────────────────────────────────────────────────────────────────────

/// This screen's role-based palette lives in [DateEmberRoles] — shared with
/// [TeamWeekStats] and the app home screen. Aliased locally so the widgets below
/// keep reading `_Pal(context)`. Dark mode reproduces the Date & Ember design
/// 1:1; light mode maps each role onto the app's semantic [AppColorsTheme].
typedef _Pal = DateEmberRoles;

class TempTeamHomeScreen extends StatelessWidget {
  const TempTeamHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = _Pal(context);
    return Scaffold(
      backgroundColor: p.bgBottom,
      body: DecoratedBox(
        // .screen — radial vignette from raised top to base.
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0, -1.16), // 50% -8%
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
            // Tab bar floats over the stage at the bottom.
            Positioned(
              left: 14,
              right: 14,
              bottom: 18,
              child: _TabBar(),
            ),
          ],
        ),
      ),
    );
  }
}

// ───────────────────────── App bar ─────────────────────────

class _AppBar extends StatelessWidget {
  const _AppBar();

  @override
  Widget build(BuildContext context) {
    final p = _Pal(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 10),
      child: Row(
        children: [
          const _IconButton(icon: Icons.arrow_back, size: 17),
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
          const _IconButton(icon: Icons.more_horiz, size: 18),
        ],
      ),
    );
  }
}

/// Round frosted glass icon button — the design's `.ibtn`.
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

// ───────────────────────── Stage (scroll body) ─────────────────────────

class _Stage extends StatelessWidget {
  const _Stage();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 100),
      physics: const BouncingScrollPhysics(),
      children: const [
        // This week's team stats lead the screen — the four-square snapshot of
        // how the team is doing comes first. Extracted into [TeamWeekStats] so
        // the app home screen can reuse it.
        _SectionLabel('This week · team stats'),
        TeamWeekStats(),
        SizedBox(height: 4),
        _IdentityCard(),
        SizedBox(height: 11),
        _TeamCodeCard(),
        // Live activity — supporting context, quiet eyebrow.
        _SectionLabel('Live activity', more: 'See all →'),
        _ActivityFeed(),
        // Leaderboard — the competitive heart of the screen: promoted to a
        // primary heading so it reads as the most important block.
        _SectionLabel(
          'Team leaderboard',
          more: 'Top 10 →',
          emphasis: _LabelEmphasis.primary,
        ),
        _Leaderboard(),
        _RivalHint(),
      ],
    );
  }
}

/// How loud a [_SectionLabel] should read. [primary] is reserved for the screen's
/// most important block (the leaderboard); [secondary] is the quiet eyebrow used
/// for supporting sections.
enum _LabelEmphasis { secondary, primary }

/// Section label whose visual weight scales with the section's importance.
///
/// - [secondary]: a quiet amber eyebrow — a short 1px tick + 9px uppercase amber.
/// - [primary]: a real heading — a thicker glowing amber rule + a larger ivory
///   title that out-ranks the eyebrows around it, with extra breathing room
///   above so the eye registers a new, weightier block.
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
      // Primary sections get more space above to set them apart as a new block.
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
                      fontWeight:
                          _isPrimary ? FontWeight.w700 : FontWeight.w600,
                      letterSpacing: _isPrimary ? 2.2 : 3.0,
                      // Primary reads in ivory ink so it out-ranks the amber
                      // eyebrows; secondary stays a quiet amber kicker.
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

// ───────────────────────── 1 · Identity ─────────────────────────

class _IdentityCard extends StatelessWidget {
  const _IdentityCard();

  @override
  Widget build(BuildContext context) {
    final p = _Pal(context);
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
              // Crest — gold metallic disc with Arabic glyph (decorative).
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
                  style: TextStyle(
                    fontSize: 29,
                    color: AppColors.discGoldInk,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ResponsiveText(
                      'Companions of Sabr',
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
                          '12 members',
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
                // #14 global rank.
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
                      '14',
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
                const SizedBox(width: 4),
                const _TrendChip(value: '3', up: true),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    ResponsiveText(
                      'of 312',
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

/// Pulsing olive "Active" badge.
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

// ───────────────────────── 2 · Team code ─────────────────────────

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
          // Copy button (with toast).
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topCenter,
            children: [
              if (_copied)
                const Positioned(top: -34, child: _CopiedToast()),
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
          // Share button — gold gradient.
          Container(
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
        ],
      ),
    );
  }
}

/// Dashed amber-bordered pill wrapping the invite code.
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
              offset: const Offset(0, 6)),
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

// ───────────────────────── 4 · Activity feed ─────────────────────────

/// The live feed reads as a connected **timeline** — node icons threaded on a
/// vertical rail — deliberately distinct from the leaderboard's ranked cards.
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

/// Plain data for one feed entry.
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

/// A single timeline row: the node sits on the rail; a connector line runs from
/// the node down to the next entry. The milestone (`gold`) entry's text sits in
/// a faint amber capsule so it still stands out within the thread.
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
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.3,
                    color: p.ink,
                  ),
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
          style: TextStyle(
            fontSize: 9,
            letterSpacing: 0.4,
            color: p.inkFaint,
          ),
        ),
      ],
    );

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Rail: node + connecting line.
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
          // Content.
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
      child: ResponsiveText(
        letter,
        style: TextStyle(fontSize: 14, color: ink),
      ),
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

// ───────────────────────── 5 · Leaderboard ─────────────────────────

class _Leaderboard extends StatelessWidget {
  const _Leaderboard();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        _LbRow(
          pos: '1',
          medal: true,
          avatar: _LbAvatar(
            letter: 'Y',
            hi: AppColors.discGoldHi,
            lo: AppColors.discGoldLo,
            ink: AppColors.discGoldInk,
          ),
          name: 'Yūsuf A.',
          meta: '94% accuracy · 38d streak',
          points: '3,420',
          trend: '0',
          up: true,
        ),
        SizedBox(height: 7),
        _LbRow(
          pos: '2',
          medal: true,
          avatar: _LbAvatar(
            letter: 'A',
            hi: DateEmberRoles.oliveLight,
            lo: AppColors.discOliveLo,
            ink: AppColors.discOliveInk,
          ),
          name: 'Aisha M.',
          meta: '91% accuracy · 24d streak',
          points: '2,980',
          trend: '1',
          up: true,
        ),
        SizedBox(height: 7),
        _LbRow(
          pos: '4',
          rival: true,
          avatar: _LbAvatar(
            letter: 'M',
            hi: AppColors.discGoldHi,
            lo: AppColors.discGoldLo,
            ink: AppColors.discGoldInk,
          ),
          name: 'Maryam K.',
          tag: _LbTag.rival,
          meta: '2,210 pts · just ahead of you',
          points: '2,210',
          trend: '1',
          up: false,
        ),
        SizedBox(height: 7),
        _LbRow(
          pos: '5',
          me: true,
          avatar: _LbAvatar(
            letter: 'ز',
            hi: AppColors.discGoldHi,
            lo: AppColors.discGoldLo,
            ink: AppColors.discGoldInk,
          ),
          name: 'Zayd N.',
          tag: _LbTag.you,
          meta: '2,070 pts · 140 to overtake',
          points: '2,070',
          trend: '2',
          up: true,
        ),
      ],
    );
  }
}

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
      child: ResponsiveText(
        letter,
        style: TextStyle(fontSize: 14, color: ink),
      ),
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
        color: (isYou ? p.washAmber : p.ember)
            .withValues(alpha: isYou ? 0.2 : 0.18),
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


// ───────────────────────── Tab bar ─────────────────────────

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

// ───────────────────────── Shared atoms ─────────────────────────

/// Up/down trend chip with a small chevron.
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

/// Four-point sparkle star — the design's `<path d="M12 2 L14 9 …">` glyph.
class _Sparkle extends StatelessWidget {
  const _Sparkle({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size.square(size), painter: _SparklePainter(color));
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

/// Flame glyph — the design's `<path d="M12 2c-1 5-5 5-5 10…">`.
class _Flame extends StatelessWidget {
  const _Flame({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Icon(Icons.local_fire_department, size: size, color: color);
  }
}

/// Accuracy ring — a 270°-style arc filled to [ratio].
/// Dashed rounded-rect border for the invite-code pill.
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
