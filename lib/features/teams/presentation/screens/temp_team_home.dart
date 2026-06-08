import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../theme/date_ember_palette.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Zad — Team Home · Community
//
// A faithful, self-contained port of the `Zad Team Home Community.html` design
// handoff (Claude Design bundle). A community-first dashboard — identity, your
// standing, the live pulse of the team, and who you're chasing. No goals, just
// growth.
//
// This is a "temp" showcase screen: it carries its own mock data and renders
// the full design in a single file so the visual can be reviewed at scale
// before being wired to [TeamsCubit]. Colours come from [DateEmber] (the shared
// Date & Ember palette), which matches the design's CSS variables 1:1.
//
// Type families follow the rest of the Date & Ember set: Fraunces (serif
// italic) and JetBrains Mono map to the platform generic families.
// ─────────────────────────────────────────────────────────────────────────────

const String _serif = 'serif';
const String _mono = 'monospace';

// Tokens that aren't in [DateEmber] but appear in the design's `:root`.
const Color _oliveLight = Color(0xFFA6B584); // --olive-light
const Color _up = Color(0xFF9CCB8E); // --up (positive trend)
const Color _down = Color(0xFFD98A6F); // --down (negative trend)
const Color _emberLight = DateEmber.emberLight;

class TempTeamHomeScreen extends StatelessWidget {
  const TempTeamHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DateEmber.base,
      body: Container(
        // .screen — radial vignette from raised brown at top to near-black.
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -1.16), // 50% -8%
            radius: 1.3,
            colors: [DateEmber.raised, DateEmber.surface, DateEmber.base],
            stops: [0.0, 0.42, 1.0],
          ),
        ),
        child: Stack(
          children: [
            SafeArea(
              bottom: false,
              child: Column(
                children: const [
                  _AppBar(),
                  Expanded(child: _Stage()),
                ],
              ),
            ),
            // Tab bar floats over the stage at the bottom.
            const Positioned(
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 10),
      child: Row(
        children: [
          const _IconButton(icon: Icons.arrow_back, size: 17),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text(
                  'MY TEAM',
                  style: TextStyle(
                    fontFamily: _mono,
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 3.0,
                    color: DateEmber.amber,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Companions of Sabr',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: _serif,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w300,
                    fontSize: 19,
                    height: 1,
                    letterSpacing: -0.3,
                    color: DateEmber.ivory,
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
    return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: DateEmber.surface.withValues(alpha: 0.6),
          border: Border.all(color: DateEmber.glassBorder),
        ),
        child: Icon(icon, size: size, color: DateEmber.ivory),
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
        _IdentityCard(),
        SizedBox(height: 11),
        _TeamCodeCard(),
        _SectionLabel('Live activity', more: 'See all →'),
        _ActivityFeed(),
        _SectionLabel('Team leaderboard', more: 'Top 10 →'),
        _Leaderboard(),
        _RivalHint(),
        _SectionLabel('This week · team stats'),
        _TeamStats(),
      ],
    );
  }
}

/// Eyebrow section label with a short amber tick rule and optional "more" link.
class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label, {this.more});

  final String label;
  final String? more;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 20, 2, 11),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(width: 16, height: 1, color: DateEmber.amber),
              const SizedBox(width: 8),
              Text(
                label.toUpperCase(),
                style: const TextStyle(
                  fontFamily: _mono,
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 3.0,
                  color: DateEmber.amber,
                ),
              ),
            ],
          ),
          if (more != null)
            Text(
              more!.toUpperCase(),
              style: const TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.4,
                color: DateEmber.amber,
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
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: DateEmber.glassBorder),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0x12F4ECD8), Color(0x05F4ECD8)],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x6B000000),
            blurRadius: 36,
            offset: Offset(0, 18),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Crest — gold metallic disc with Arabic glyph.
              Container(
                width: 62,
                height: 62,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(19),
                  gradient: const RadialGradient(
                    center: Alignment(-0.36, -0.44),
                    colors: [
                      DateEmber.goldHi,
                      DateEmber.goldMid,
                      DateEmber.goldLo,
                    ],
                    stops: [0.0, 0.55, 1.0],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: DateEmber.ember.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Text(
                  'ص',
                  style: TextStyle(
                    fontFamily: _serif,
                    fontSize: 29,
                    color: DateEmber.goldInk,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Companions of Sabr',
                      style: TextStyle(
                        fontFamily: _serif,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w300,
                        fontSize: 23,
                        height: 1.05,
                        letterSpacing: -0.4,
                        color: DateEmber.ivory,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Text(
                          '12 members',
                          style: TextStyle(
                            fontSize: 11,
                            color: DateEmber.txtMute,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '·',
                          style: TextStyle(
                            fontSize: 11,
                            color: DateEmber.txtMute.withValues(alpha: 0.4),
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
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: Color(0x1FF4ECD8)),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // #14 global rank.
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: const [
                    Text(
                      '#',
                      style: TextStyle(
                        fontFamily: _mono,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: DateEmber.amber,
                      ),
                    ),
                    SizedBox(width: 6),
                    Text(
                      '14',
                      style: TextStyle(
                        fontFamily: _serif,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w300,
                        fontSize: 30,
                        height: 0.9,
                        color: _emberLight,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 10),
                const Text(
                  'GLOBAL\nRANK',
                  style: TextStyle(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.6,
                    height: 1.4,
                    color: DateEmber.txtMute,
                  ),
                ),
                const SizedBox(width: 4),
                const _TrendChip(value: '3', up: true),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: const [
                    Text(
                      'of 312',
                      style: TextStyle(
                        fontFamily: _mono,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: DateEmber.amberLight,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'TEAMS',
                      style: TextStyle(
                        fontSize: 8.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.6,
                        color: DateEmber.txtMute,
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(99),
        color: DateEmber.olive.withValues(alpha: 0.18),
        border: Border.all(color: DateEmber.olive.withValues(alpha: 0.4)),
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
                color: _oliveLight,
                boxShadow: [
                  BoxShadow(color: _oliveLight, blurRadius: 7),
                ],
              ),
            ),
          ),
          const SizedBox(width: 5),
          const Text(
            'Active',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.7,
              color: _oliveLight,
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: DateEmber.hairline),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0x0DF4ECD8), Color(0x05F4ECD8)],
        ),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'INVITE CODE',
                style: TextStyle(
                  fontSize: 8.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2.0,
                  color: DateEmber.txtMute,
                ),
              ),
              const SizedBox(height: 6),
              _DashedPill(
                child: const Text(
                  _code,
                  style: TextStyle(
                    fontFamily: _mono,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 3.2,
                    color: DateEmber.amberLight,
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
                        ? DateEmber.olive.withValues(alpha: 0.2)
                        : const Color(0x0DF4ECD8),
                    border: Border.all(
                      color: _copied
                          ? DateEmber.olive.withValues(alpha: 0.5)
                          : DateEmber.glassBorder,
                    ),
                  ),
                  child: Icon(
                    _copied ? Icons.check : Icons.copy_outlined,
                    size: 17,
                    color: _copied ? _up : DateEmber.ivory,
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
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  DateEmber.amberLight,
                  DateEmber.amber,
                  DateEmber.amberDeep,
                ],
                stops: [0.0, 0.55, 1.0],
              ),
              boxShadow: [
                BoxShadow(
                  color: DateEmber.washAmber.withValues(alpha: 0.26),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(
              Icons.ios_share,
              size: 17,
              color: DateEmber.goldInk,
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
    return CustomPaint(
      painter: _DashedBorderPainter(
        color: DateEmber.amber,
        radius: 11,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(11),
          color: DateEmber.washAmber.withValues(alpha: 0.10),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: DateEmber.olive,
        boxShadow: const [
          BoxShadow(color: Color(0x66000000), blurRadius: 14, offset: Offset(0, 6)),
        ],
      ),
      child: const Text(
        'Copied ✓',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: Color(0xFF10160B),
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
    const entries = <_ActivityEntry>[
      _ActivityEntry(
        node: _ActivityIcon(
          kind: _IconKind.streak,
          child: _Flame(size: 18, color: DateEmber.emberInk),
        ),
        name: 'Faisal',
        rest: ' reached a 50-day streak 🔥',
        meta: 'Milestone · 18m ago',
        trailing: _Sparkle(size: 14, color: DateEmber.amberLight),
        gold: true,
      ),
      _ActivityEntry(
        node: _AvatarIcon(
          letter: 'A',
          hi: _oliveLight,
          lo: DateEmber.oliveLo,
          ink: DateEmber.oliveInk,
        ),
        name: 'Aisha',
        rest: ' completed Level 7',
        meta: 'Level · 1h ago',
        trailing: _MiniCheck(),
      ),
      _ActivityEntry(
        node: _ActivityIcon(
          kind: _IconKind.quiz,
          child: Icon(Icons.help_outline, size: 17, color: DateEmber.amberLight),
        ),
        name: 'Maryam',
        rest: ' answered 20 questions today',
        meta: 'Quiz · 2h ago',
      ),
      _ActivityEntry(
        node: _ActivityIcon(
          kind: _IconKind.join,
          child: Icon(Icons.person_add_alt, size: 16, color: DateEmber.ivory),
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
    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 12,
                    height: 1.3,
                    color: DateEmber.ivory,
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
        Text(
          entry.meta,
          style: const TextStyle(
            fontFamily: _mono,
            fontSize: 9,
            letterSpacing: 0.4,
            color: DateEmber.txtFaint,
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
                      color: DateEmber.washAmber.withValues(alpha: 0.16),
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
                        border: Border.all(color: DateEmber.glassBorder),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            DateEmber.washAmber.withValues(alpha: 0.12),
                            DateEmber.washAmber.withValues(alpha: 0.03),
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
    BoxDecoration deco;
    switch (kind) {
      case _IconKind.streak:
        deco = const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [DateEmber.emberLight, DateEmber.ember],
          ),
        );
      case _IconKind.quiz:
        deco = BoxDecoration(
          color: DateEmber.washAmber.withValues(alpha: 0.16),
          border: Border.all(color: DateEmber.washAmber.withValues(alpha: 0.4)),
        );
      case _IconKind.join:
        deco = BoxDecoration(
          color: const Color(0x0FF4ECD8),
          border: Border.all(color: DateEmber.glassBorder),
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
      child: Text(
        letter,
        style: TextStyle(fontFamily: _serif, fontSize: 14, color: ink),
      ),
    );
  }
}

class _MiniCheck extends StatelessWidget {
  const _MiniCheck();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(9),
        color: DateEmber.olive.withValues(alpha: 0.16),
        border: Border.all(color: DateEmber.olive.withValues(alpha: 0.34)),
      ),
      child: const Icon(Icons.check, size: 14, color: _oliveLight),
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
            hi: DateEmber.goldHi,
            lo: DateEmber.goldLo,
            ink: DateEmber.goldInk,
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
            hi: _oliveLight,
            lo: DateEmber.oliveLo,
            ink: DateEmber.oliveInk,
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
            hi: DateEmber.goldHi,
            lo: DateEmber.goldLo,
            ink: DateEmber.goldInk,
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
            hi: DateEmber.goldHi,
            lo: DateEmber.goldLo,
            ink: DateEmber.goldInk,
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
    BoxDecoration deco;
    if (me) {
      deco = BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            DateEmber.washAmber.withValues(alpha: 0.12),
            DateEmber.washAmber.withValues(alpha: 0.03),
          ],
        ),
        border: Border.all(color: DateEmber.glassBorder),
      );
    } else if (rival) {
      deco = BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            DateEmber.ember.withValues(alpha: 0.12),
            DateEmber.ember.withValues(alpha: 0.03),
          ],
        ),
        border: Border.all(color: DateEmber.emberLight.withValues(alpha: 0.34)),
      );
    } else {
      deco = BoxDecoration(
        color: const Color(0x08F4ECD8),
        border: Border.all(color: DateEmber.hairline),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: deco.copyWith(borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: [
          SizedBox(
            width: 22,
            child: Text(
              pos,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: _mono,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: medal ? DateEmber.amberLight : DateEmber.txtFaint,
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
                      child: Text(
                        name,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          height: 1.1,
                          color: DateEmber.ivory,
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
                Text(
                  meta,
                  style: const TextStyle(
                    fontSize: 10,
                    color: DateEmber.txtMute,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                points,
                style: const TextStyle(
                  fontFamily: _mono,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: DateEmber.amberLight,
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
      child: Text(
        letter,
        style: TextStyle(fontFamily: _serif, fontSize: 14, color: ink),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag(this.tag);
  final _LbTag tag;

  @override
  Widget build(BuildContext context) {
    final isYou = tag == _LbTag.you;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(99),
        color: (isYou ? DateEmber.washAmber : DateEmber.ember)
            .withValues(alpha: isYou ? 0.2 : 0.18),
        border: Border.all(
          color: (isYou ? DateEmber.washAmber : DateEmber.emberLight)
              .withValues(alpha: 0.4),
        ),
      ),
      child: Text(
        isYou ? 'YOU' : 'RIVAL',
        style: TextStyle(
          fontSize: 7.5,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.0,
          color: isYou ? DateEmber.amberLight : _emberLight,
        ),
      ),
    );
  }
}

class _RivalHint extends StatelessWidget {
  const _RivalHint();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 9, 4, 0),
      child: Row(
        children: const [
          Icon(Icons.schedule, size: 13, color: _emberLight),
          SizedBox(width: 7),
          Expanded(
            child: Text(
              'Just 140 points behind Maryam — your closest competitor.',
              style: TextStyle(
                fontFamily: _serif,
                fontStyle: FontStyle.italic,
                fontSize: 10.5,
                color: _emberLight,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ───────────────────────── 6 · Team stats ─────────────────────────

class _TeamStats extends StatelessWidget {
  const _TeamStats();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: const [
              Expanded(
                child: _StatCard(
                  label: 'Questions answered',
                  value: '1,284',
                  trend: '18%',
                  trendNote: 'vs last week',
                  spark: true,
                ),
              ),
              SizedBox(width: 9),
              Expanded(
                child: _StatCard(
                  label: 'Avg accuracy',
                  value: '88%',
                  trend: '4%',
                  trendNote: 'vs last week',
                  ring: 0.83,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 9),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: const [
              Expanded(
                child: _StatCard(
                  label: 'Active members',
                  value: '9',
                  valueSub: ' / 12',
                  trend: '2',
                  trendNote: 'this week',
                ),
              ),
              SizedBox(width: 9),
              Expanded(
                child: _StatCard(
                  label: 'Peak activity day',
                  value: 'Wed',
                  valueSize: 22,
                  note: '312 questions · 8pm',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 9),
        // Insight banner.
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                DateEmber.olive.withValues(alpha: 0.16),
                DateEmber.olive.withValues(alpha: 0.05),
              ],
            ),
            border: Border.all(color: DateEmber.olive.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: DateEmber.olive.withValues(alpha: 0.2),
                ),
                child: const Icon(Icons.bar_chart, size: 18, color: _oliveLight),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: RichText(
                  text: const TextSpan(
                    style: TextStyle(
                      fontFamily: _serif,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w300,
                      fontSize: 14,
                      height: 1.35,
                      color: DateEmber.ivory,
                    ),
                    children: [
                      TextSpan(text: 'Your team is '),
                      TextSpan(
                        text: 'improving in accuracy',
                        style: TextStyle(
                          fontStyle: FontStyle.normal,
                          fontWeight: FontWeight.w600,
                          color: _oliveLight,
                        ),
                      ),
                      TextSpan(
                        text: ' — up 4% and climbing for three weeks straight.',
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

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    this.valueSub,
    this.valueSize = 28,
    this.trend,
    this.trendNote,
    this.note,
    this.spark = false,
    this.ring,
  });

  final String label;
  final String value;
  final String? valueSub;
  final double valueSize;
  final String? trend;
  final String? trendNote;
  final String? note;
  final bool spark;
  final double? ring;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: DateEmber.hairline),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0x0DF4ECD8), Color(0x05F4ECD8)],
        ),
      ),
      child: Stack(
        children: [
          if (ring != null)
            Positioned(
              right: 0,
              top: 0,
              child: CustomPaint(
                size: const Size(38, 38),
                painter: _RingPainter(ring!),
              ),
            ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                style: const TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.4,
                  color: DateEmber.txtMute,
                ),
              ),
              const SizedBox(height: 7),
              RichText(
                text: TextSpan(
                  text: value,
                  style: TextStyle(
                    fontFamily: _serif,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w300,
                    fontSize: valueSize,
                    height: 0.95,
                    color: DateEmber.ivory,
                  ),
                  children: [
                    if (valueSub != null)
                      TextSpan(
                        text: valueSub,
                        style: const TextStyle(
                          fontSize: 14,
                          color: DateEmber.txtFaint,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 7),
              if (trend != null)
                Row(
                  children: [
                    _TrendChip(value: trend!, up: true),
                    const SizedBox(width: 5),
                    Text(
                      trendNote ?? '',
                      style: const TextStyle(
                        fontSize: 9,
                        color: DateEmber.txtFaint,
                      ),
                    ),
                  ],
                ),
              if (note != null)
                Text(
                  note!,
                  style: const TextStyle(
                    fontSize: 9,
                    color: DateEmber.txtMute,
                  ),
                ),
              if (spark) ...[
                const SizedBox(height: 9),
                const _Spark(),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

/// Seven-bar sparkline; the fifth bar is the "hot" ember peak.
class _Spark extends StatelessWidget {
  const _Spark();

  @override
  Widget build(BuildContext context) {
    const heights = [0.40, 0.60, 0.48, 0.75, 0.95, 0.30, 0.22];
    return SizedBox(
      height: 22,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var i = 0; i < heights.length; i++) ...[
            Expanded(
              child: Container(
                height: 22 * heights[i],
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(2),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: i == 4
                        ? const [DateEmber.emberLight, DateEmber.ember]
                        : const [DateEmber.amberLight, DateEmber.amberDeep],
                  ),
                ),
              ),
            ),
            if (i < heights.length - 1) const SizedBox(width: 3),
          ],
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
    return Container(
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            DateEmber.raised.withValues(alpha: 0.94),
            DateEmber.surface.withValues(alpha: 0.94),
          ],
        ),
        border: Border.all(color: DateEmber.glassBorder),
        boxShadow: const [
          BoxShadow(
            color: Color(0x8C000000),
            blurRadius: 30,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: const [
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
    final color = active ? DateEmber.amberLight : DateEmber.txtFaint;
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
              color: DateEmber.amber,
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(3),
              ),
              boxShadow: [
                BoxShadow(
                  color: DateEmber.washAmber.withValues(alpha: 0.7),
                  blurRadius: 10,
                ),
              ],
            ),
          )
        else
          const SizedBox(height: 10),
        Icon(icon, size: 20, color: color),
        const SizedBox(height: 3),
        Text(
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

/// Mono up/down trend chip with a small chevron.
class _TrendChip extends StatelessWidget {
  const _TrendChip({required this.value, required this.up});

  final String value;
  final bool up;

  @override
  Widget build(BuildContext context) {
    final color = up ? _up : _down;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          up ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
          size: 12,
          color: color,
        ),
        Text(
          value,
          style: TextStyle(
            fontFamily: _mono,
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
class _RingPainter extends CustomPainter {
  _RingPainter(this.ratio);
  final double ratio;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2 - 2;
    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..color = DateEmber.ivory.withValues(alpha: 0.10);
    final arc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round
      ..color = DateEmber.amber;
    canvas.drawCircle(center, radius, track);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * ratio.clamp(0.0, 1.0),
      false,
      arc,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.ratio != ratio;
}

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
