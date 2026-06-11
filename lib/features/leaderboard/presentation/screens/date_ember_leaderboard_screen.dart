import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../theme/date_ember_palette.dart';

/// Zad — Date & Ember leaderboard screen.
///
/// A single-file, self-contained recreation of the `Zad Date and Ember
/// Screen.html` design handed off from Claude Design. Roasted-brown depths,
/// ember accents, gold foil and rising sparks. Every colour in the design is
/// captured in [DateEmber] (lib/theme/date_ember_palette.dart) — the shared palette this screen and the app dark theme both use.
///
/// This screen is intentionally independent of the app theme — it is a faithful
/// port of the mock, not yet  wired to live leaderboard data.
class DateEmberLeaderboardScreen extends StatelessWidget {
  const DateEmberLeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: DateEmber.canvas,
      body: _DateEmberBody(),
    );
  }
}

// Type families. The design uses Fraunces (serif italic), Inter (sans) and
// JetBrains Mono. We map these to the platform generic families so the screen
// stays a single file with no font bundling.
const String _serif = 'serif';
const String _mono = 'monospace';

class _DateEmberBody extends StatelessWidget {
  const _DateEmberBody();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      // radial-gradient(130% 75% at 50% -8%, #271A10, #1A120B 42%, #0E0905)
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(0, -1.05),
          radius: 1.35,
          colors: [DateEmber.raised, DateEmber.surface, DateEmber.base],
          stops: [0.0, 0.42, 1.0],
        ),
      ),
      child: Stack(
        children: [
          // Islamic pattern wallpaper.
          const Positioned.fill(
            child: IgnorePointer(
              child: Opacity(
                opacity: 0.05,
                child: Image(
                  image: AssetImage('assets/images/islamic-pattern.png'),
                  repeat: ImageRepeat.repeat,
                  alignment: Alignment.topLeft,
                  color: DateEmber.ivory,
                  colorBlendMode: BlendMode.screen,
                ),
              ),
            ),
          ),
          // Warm amber wash at the top.
          const Positioned(
            left: -120,
            right: -120,
            top: -120,
            height: 420,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    radius: 0.65,
                    colors: [Color(0x38E1A560), Color(0x00E1A560)],
                    stops: [0.0, 1.0],
                  ),
                ),
              ),
            ),
          ),
          // Rising ember sparks.
          const Positioned.fill(child: IgnorePointer(child: _EmberField())),

          // Foreground content.
          SafeArea(
            child: Column(
              children: const [
                _TopBar(),
                Expanded(child: _Stage()),
                _StreakCta(),
                SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Top bar.
// ─────────────────────────────────────────────────────────────────────────────
class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 12, 22, 4),
      child: Row(
        children: [
          _GlassIconButton(
            icon: Directionality.of(context) == TextDirection.rtl
                ? Icons.arrow_forward
                : Icons.arrow_back,
            onTap: () => Navigator.of(context).maybePop(),
          ),
          Expanded(
            child: Column(
              children: const [
                Text(
                  'LEAGUE · WEEK 12',
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 3.2,
                    color: DateEmber.amber,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Companions of Sabr',
                  style: TextStyle(
                    fontFamily: _serif,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w300,
                    fontSize: 21,
                    height: 1,
                    letterSpacing: -0.3,
                    color: DateEmber.ivory,
                  ),
                ),
              ],
            ),
          ),
          const _GlassIconButton(icon: Icons.search),
        ],
      ),
    );
  }
}

class _GlassIconButton extends StatelessWidget {
  const _GlassIconButton({required this.icon, this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0x0DF4ECD8), // ivory @ 0.05
      shape: const CircleBorder(side: BorderSide(color: DateEmber.glassBorder)),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: const SizedBox(width: 38, height: 38).withChild(icon),
      ),
    );
  }
}

// Small helper to keep the icon button terse.
extension on SizedBox {
  Widget withChild(IconData icon) => SizedBox(
    width: width,
    height: height,
    child: Icon(icon, size: 16, color: DateEmber.ivory),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Stage — scrollable body.
// ─────────────────────────────────────────────────────────────────────────────
class _Stage extends StatelessWidget {
  const _Stage();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 8),
      children: const [
        _SummaryCard(),
        SizedBox(height: 13),
        _Segmented(),
        SizedBox(height: 13),
        _EyebrowRule(label: 'PODIUM'),
        SizedBox(height: 11),
        _Podium(),
        SizedBox(height: 13),
        _DottedDivider(),
        SizedBox(height: 10),
        _RankRow(
          rank: '04',
          initial: 'M',
          disc: _DiscStyle.olive,
          name: 'Maryam K.',
          role: 'On fire · 2 m ago',
          dot: _DotState.active,
          points: '2,210',
          trend: '2',
        ),
        SizedBox(height: 6),
        _RankRow(
          rank: '05',
          initial: 'Z',
          disc: _DiscStyle.gold,
          name: 'Zayd',
          youSuffix: ' (You)',
          role: 'On fire · solving now',
          dot: _DotState.active,
          points: '1,860',
          trend: '3',
          isMe: true,
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Glass summary card.
// ─────────────────────────────────────────────────────────────────────────────
class _SummaryCard extends StatelessWidget {
  const _SummaryCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: DateEmber.glassBorder),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0x0FF4ECD8), Color(0x05F4ECD8)],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x80000000),
            blurRadius: 40,
            offset: Offset(0, 20),
          ),
        ],
      ),
      child: CustomPaint(
        foregroundPainter: _CornerBracketPainter(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                _Eyebrow('TEAM TOTAL · THIS WEEK'),
                _DeltaBadge('+18%'),
              ],
            ),
            const SizedBox(height: 6),
            // Big gold-foil total.
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                ShaderMask(
                  shaderCallback: (r) => const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      DateEmber.amberLight,
                      DateEmber.amber,
                      DateEmber.amberDeep,
                    ],
                    stops: [0.0, 0.55, 1.0],
                  ).createShader(r),
                  child: const Text(
                    '12,480',
                    style: TextStyle(
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
                const Text(
                  'XP',
                  style: TextStyle(
                    fontFamily: _mono,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2.2,
                    color: DateEmber.txtFaint,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const SizedBox(height: 26, child: _Sparkline()),
            const SizedBox(height: 9),
            const _DashedRule(),
            const SizedBox(height: 9),
            Row(
              children: const [
                Expanded(
                  child: _StatCell(value: '428', label: 'SOLVED'),
                ),
                _StatPipe(),
                Expanded(
                  child: _StatCell(value: '#14', sub: '/312', label: 'RANK'),
                ),
                _StatPipe(),
                Expanded(
                  child: _StatCell(value: '38', sub: 'd', label: 'STREAK'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Eyebrow extends StatelessWidget {
  const _Eyebrow(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: _mono,
        fontSize: 9,
        fontWeight: FontWeight.w600,
        letterSpacing: 3.2,
        color: DateEmber.amber,
      ),
    );
  }
}

class _DeltaBadge extends StatelessWidget {
  const _DeltaBadge(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.keyboard_arrow_up, size: 12, color: DateEmber.olive),
        const SizedBox(width: 2),
        Text(
          text,
          style: const TextStyle(
            fontFamily: _mono,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: DateEmber.olive,
          ),
        ),
      ],
    );
  }
}

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
              color: DateEmber.ivory,
            ),
            children: [
              if (sub != null)
                TextSpan(
                  text: sub,
                  style: const TextStyle(
                    fontSize: 12,
                    color: DateEmber.txtFaint,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: const TextStyle(
            fontSize: 8.5,
            fontWeight: FontWeight.w600,
            letterSpacing: 2.0,
            color: DateEmber.txtMute,
          ),
        ),
      ],
    );
  }
}

class _StatPipe extends StatelessWidget {
  const _StatPipe();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 34,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0x00E1A560), Color(0x40E1A560), Color(0x00E1A560)],
        ),
      ),
    );
  }
}

// Gold corner brackets drawn on the four corners of the summary card.
class _CornerBracketPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = DateEmber.amber
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
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Amber-gradient sparkline matching the design's path.
class _Sparkline extends StatelessWidget {
  const _Sparkline();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size.infinite, painter: _SparklinePainter());
  }
}

class _SparklinePainter extends CustomPainter {
  // Normalised points from the SVG (viewBox 280×40).
  static const List<Offset> _pts = [
    Offset(0, 30),
    Offset(23, 26),
    Offset(46, 28),
    Offset(70, 20),
    Offset(93, 22),
    Offset(116, 15),
    Offset(140, 18),
    Offset(163, 11),
    Offset(186, 14),
    Offset(210, 8),
    Offset(233, 11),
    Offset(256, 5),
    Offset(280, 9),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final sx = size.width / 280;
    final sy = size.height / 40;
    Offset map(Offset o) => Offset(o.dx * sx, o.dy * sy);

    final line = Path()..moveTo(map(_pts.first).dx, map(_pts.first).dy);
    for (final p in _pts.skip(1)) {
      final m = map(p);
      line.lineTo(m.dx, m.dy);
    }

    // Fill under the curve.
    final fill = Path.from(line)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(
      fill,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0x59E0A560), Color(0x00E0A560)],
        ).createShader(Offset.zero & size),
    );

    // Stroke.
    canvas.drawPath(
      line,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..shader = const LinearGradient(
          colors: [DateEmber.amberDeep, DateEmber.amberLight],
        ).createShader(Offset.zero & size),
    );

    // End marker.
    final end = map(_pts.last);
    canvas.drawCircle(end, 3, Paint()..color = DateEmber.amberLight);
    canvas.drawCircle(
      end,
      6,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = DateEmber.amber.withValues(alpha: 0.5),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _DashedRule extends StatelessWidget {
  const _DashedRule();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 1,
      child: CustomPaint(painter: _DashedLinePainter()),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = DateEmber.washAmber.withValues(alpha: 0.22)
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
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// Segmented control.
// ─────────────────────────────────────────────────────────────────────────────
class _Segmented extends StatefulWidget {
  const _Segmented();

  @override
  State<_Segmented> createState() => _SegmentedState();
}

class _SegmentedState extends State<_Segmented> {
  static const _items = ['WEEK', 'MONTH', 'ALL TIME'];
  int _selected = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0x0AF4ECD8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: DateEmber.hairline),
      ),
      child: Row(
        children: [
          for (var i = 0; i < _items.length; i++)
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selected = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(9),
                    gradient: i == _selected
                        ? const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Color(0x33F1C57A), Color(0x1FA6622A)],
                          )
                        : null,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _items[i],
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.8,
                      color: i == _selected
                          ? DateEmber.amberLight
                          : DateEmber.txtMute,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Eyebrow rule (── PODIUM ──).
// ─────────────────────────────────────────────────────────────────────────────
class _EyebrowRule extends StatelessWidget {
  const _EyebrowRule({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(
          width: 26,
          height: 1,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0x00E0A560), DateEmber.amber],
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: const TextStyle(
            fontFamily: _mono,
            fontSize: 9,
            fontWeight: FontWeight.w600,
            letterSpacing: 3.2,
            color: DateEmber.amber,
          ),
        ),
        const SizedBox(width: 10),
        const SizedBox(
          width: 26,
          height: 1,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [DateEmber.amber, Color(0x00E0A560)],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Podium.
// ─────────────────────────────────────────────────────────────────────────────
class _Podium extends StatelessWidget {
  const _Podium();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: const [
        Expanded(
          flex: 100,
          child: _PodiumPillar(
            place: 2,
            initial: 'A',
            disc: _DiscStyle.silver,
            name: 'Aisha M.',
            points: '2,980',
          ),
        ),
        SizedBox(width: 9),
        Expanded(
          flex: 115,
          child: _PodiumPillar(
            place: 1,
            initial: 'Y',
            disc: _DiscStyle.gold,
            name: 'Yūsuf A.',
            points: '3,420',
          ),
        ),
        SizedBox(width: 9),
        Expanded(
          flex: 100,
          child: _PodiumPillar(
            place: 3,
            initial: 'F',
            disc: _DiscStyle.bronze,
            name: 'Faisal R.',
            points: '2,540',
          ),
        ),
      ],
    );
  }
}

class _PodiumPillar extends StatelessWidget {
  const _PodiumPillar({
    required this.place,
    required this.initial,
    required this.disc,
    required this.name,
    required this.points,
  });

  final int place;
  final String initial;
  final _DiscStyle disc;
  final String name;
  final String points;

  @override
  Widget build(BuildContext context) {
    final isFirst = place == 1;
    final accent = switch (place) {
      1 => DateEmber.amber,
      2 => DateEmber.silverMid,
      _ => DateEmber.emberLight,
    };
    final pedHeight = switch (place) {
      1 => 46.0,
      2 => 34.0,
      _ => 25.0,
    };
    final pedTint = switch (place) {
      1 => DateEmber.amber,
      2 => DateEmber.silverMid,
      _ => DateEmber.ember,
    };
    final avatarSize = isFirst ? 62.0 : 52.0;

    return Column(
      children: [
        // Avatar with rank badge + optional crown + glow.
        SizedBox(
          width: avatarSize + 14,
          height: avatarSize + (isFirst ? 22 : 14),
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              // Soft glow halo.
              Container(
                width: avatarSize + 14,
                height: avatarSize + 14,
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
              _Disc(
                size: avatarSize,
                initial: initial,
                style: disc,
                fontSize: isFirst ? 24 : 20,
              ),
              if (isFirst) const Positioned(top: -8, child: _Crown()),
              Positioned(
                right: 2,
                bottom: 2,
                child: _RankBadge(place: place, color: accent),
              ),
            ],
          ),
        ),
        const SizedBox(height: 7),
        Text(
          name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isFirst ? FontWeight.w700 : FontWeight.w600,
            color: isFirst ? DateEmber.amberLight : DateEmber.ivory,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          points,
          style: TextStyle(
            fontFamily: _mono,
            fontSize: isFirst ? 12 : 11,
            fontWeight: FontWeight.w500,
            color: accent,
          ),
        ),
        const SizedBox(height: 7),
        // Pedestal.
        Container(
          height: pedHeight,
          width: double.infinity,
          padding: const EdgeInsets.only(top: 7),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(9)),
            border: Border(
              top: BorderSide(color: pedTint.withValues(alpha: 0.4)),
              left: BorderSide(color: pedTint.withValues(alpha: 0.4)),
              right: BorderSide(color: pedTint.withValues(alpha: 0.4)),
            ),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                pedTint.withValues(alpha: 0.28),
                pedTint.withValues(alpha: 0.05),
              ],
            ),
          ),
          child: Text(
            '0$place',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: _mono,
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

class _RankBadge extends StatelessWidget {
  const _RankBadge({required this.place, required this.color});
  final int place;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: DateEmber.base,
        border: Border.all(color: color, width: 2),
      ),
      child: Text(
        '$place',
        style: TextStyle(
          fontFamily: _mono,
          fontSize: 11,
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
    // Path scaled from viewBox 26×16.
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
          colors: [DateEmber.amberLight, DateEmber.amberDeep],
        ).createShader(Offset.zero & size),
    );
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8
        ..strokeJoin = StrokeJoin.round
        ..color = DateEmber.bronzeLo,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// Metallic disc avatars.
// ─────────────────────────────────────────────────────────────────────────────
enum _DiscStyle { gold, silver, bronze, olive, date }

class _Disc extends StatelessWidget {
  const _Disc({
    required this.size,
    required this.initial,
    required this.style,
    required this.fontSize,
  });

  final double size;
  final String initial;
  final _DiscStyle style;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final (colors, ink, ringColor) = switch (style) {
      _DiscStyle.gold => (
        [DateEmber.goldHi, DateEmber.goldMid, DateEmber.goldLo],
        DateEmber.goldInk,
        const Color(0x8CE1A560),
      ),
      _DiscStyle.silver => (
        [DateEmber.silverHi, DateEmber.silverMid, DateEmber.silverLo],
        DateEmber.goldInk,
        const Color(0x80DCCDB4),
      ),
      _DiscStyle.bronze => (
        [DateEmber.bronzeHi, DateEmber.bronzeMid, DateEmber.bronzeLo],
        DateEmber.bronzeInk,
        const Color(0x80C9512B),
      ),
      _DiscStyle.olive => (
        [DateEmber.oliveHi, DateEmber.oliveMid, DateEmber.oliveLo],
        DateEmber.oliveInk,
        const Color(0x33E1A560),
      ),
      _DiscStyle.date => (
        [DateEmber.dateHi, DateEmber.dateMid, DateEmber.dateLo],
        DateEmber.ivory,
        const Color(0x33E1A560),
      ),
    };

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          center: const Alignment(-0.36, -0.44), // ~32% 28%
          radius: 0.95,
          colors: colors,
          stops: const [0.0, 0.55, 1.0],
        ),
        border: Border.all(color: ringColor, width: 2),
      ),
      child: Text(
        initial,
        style: TextStyle(fontFamily: _serif, fontSize: fontSize, color: ink),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Divider with centre dot.
// ─────────────────────────────────────────────────────────────────────────────
class _DottedDivider extends StatelessWidget {
  const _DottedDivider();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: SizedBox(
            height: 1,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0x00E1A560),
                    Color(0x4DE1A560),
                    Color(0x00E1A560),
                  ],
                ),
              ),
            ),
          ),
        ),
        Container(
          width: 6,
          height: 6,
          margin: const EdgeInsets.symmetric(horizontal: 8),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: DateEmber.amber,
          ),
        ),
        const Expanded(
          child: SizedBox(
            height: 1,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0x00E1A560),
                    Color(0x4DE1A560),
                    Color(0x00E1A560),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Leaderboard rows.
// ─────────────────────────────────────────────────────────────────────────────
enum _DotState { active, steady, idle }

class _RankRow extends StatelessWidget {
  const _RankRow({
    required this.rank,
    required this.initial,
    required this.disc,
    required this.name,
    this.youSuffix,
    required this.role,
    required this.dot,
    required this.points,
    required this.trend,
    this.isMe = false,
  });

  final String rank;
  final String initial;
  final _DiscStyle disc;
  final String name;
  final String? youSuffix;
  final String role;
  final _DotState dot;
  final String points;
  final String trend;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: isMe
            ? const LinearGradient(
                colors: [Color(0x1FE1A560), Color(0x05E1A560)],
              )
            : null,
        color: isMe ? null : const Color(0x06F4ECD8),
        border: Border.all(
          color: isMe ? const Color(0x66E1A560) : const Color(0x0DF4ECD8),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 22,
            child: Text(
              rank,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: _mono,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isMe ? DateEmber.amber : DateEmber.txtFaint,
              ),
            ),
          ),
          const SizedBox(width: 12),
          _Disc(size: 38, initial: initial, style: disc, fontSize: 15),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  text: TextSpan(
                    text: name,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      height: 1.1,
                      color: isMe ? DateEmber.amberLight : DateEmber.ivory,
                    ),
                    children: [
                      if (youSuffix != null)
                        TextSpan(
                          text: youSuffix,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Color(0xA6F1C57A),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    _StatusDot(state: dot),
                    const SizedBox(width: 7),
                    Text(
                      role,
                      style: const TextStyle(
                        fontSize: 10,
                        color: DateEmber.txtMute,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                points,
                style: TextStyle(
                  fontFamily: _mono,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isMe ? DateEmber.amberLight : DateEmber.ivory,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.keyboard_arrow_up,
                    size: 10,
                    color: DateEmber.olive,
                  ),
                  Text(
                    trend,
                    style: const TextStyle(
                      fontFamily: _mono,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      color: DateEmber.olive,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusDot extends StatefulWidget {
  const _StatusDot({required this.state});
  final _DotState state;

  @override
  State<_StatusDot> createState() => _StatusDotState();
}

class _StatusDotState extends State<_StatusDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  );

  @override
  void initState() {
    super.initState();
    if (widget.state == _DotState.active) _c.repeat(reverse: true);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = switch (widget.state) {
      _DotState.active => DateEmber.ember,
      _DotState.steady => DateEmber.amber,
      _DotState.idle => const Color(0x38F4ECD8),
    };
    if (widget.state != _DotState.active) {
      return _dot(color, 0.18);
    }
    return AnimatedBuilder(
      animation: _c,
      builder: (_, _) => _dot(color, 0.5 + 0.45 * _c.value),
    );
  }

  Widget _dot(Color color, double glow) {
    return Container(
      width: 7,
      height: 7,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: glow),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Streak CTA.
// ─────────────────────────────────────────────────────────────────────────────
class _StreakCta extends StatelessWidget {
  const _StreakCta();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(18, 0, 18, 8),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0x2EC9512B), Color(0x147A2E15)],
        ),
        border: Border.all(color: const Color(0x66E07A48)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x73000000),
            blurRadius: 30,
            offset: Offset(0, 16),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [DateEmber.emberLight, DateEmber.ember],
              ),
              boxShadow: [
                BoxShadow(
                  color: DateEmber.ember.withValues(alpha: 0.55),
                  blurRadius: 18,
                ),
              ],
            ),
            child: const Icon(
              Icons.local_fire_department,
              size: 20,
              color: DateEmber.emberInk,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Keep your ember alight — 38 days.',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.1,
                    color: DateEmber.amberLight,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'One more solve to climb to #4 tonight.',
                  style: TextStyle(fontSize: 10.5, color: DateEmber.txtMute),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.arrow_forward, size: 16, color: DateEmber.amber),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Rising ember particle field.
// ─────────────────────────────────────────────────────────────────────────────
class _EmberField extends StatefulWidget {
  const _EmberField();

  @override
  State<_EmberField> createState() => _EmberFieldState();
}

class _EmberFieldState extends State<_EmberField>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 12),
  )..repeat();

  // Deterministic per-particle parameters (x, durationScale, sizeScale, phase).
  final List<_Spark> _sparks = List.generate(14, (i) {
    final rnd = math.Random(i * 7 + 3);
    return _Spark(
      x: rnd.nextDouble(),
      durScale: 0.5 + rnd.nextDouble(),
      sizeScale: 0.5 + rnd.nextDouble() * 0.9,
      phase: rnd.nextDouble(),
    );
  });

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, _) => CustomPaint(
        painter: _EmberPainter(sparks: _sparks, t: _c.value),
        size: Size.infinite,
      ),
    );
  }
}

class _Spark {
  const _Spark({
    required this.x,
    required this.durScale,
    required this.sizeScale,
    required this.phase,
  });
  final double x;
  final double durScale;
  final double sizeScale;
  final double phase;
}

class _EmberPainter extends CustomPainter {
  _EmberPainter({required this.sparks, required this.t});
  final List<_Spark> sparks;
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    for (final s in sparks) {
      // Progress of this spark through its rise cycle.
      final p = (t / s.durScale + s.phase) % 1.0;
      // Opacity envelope: fade in, hold, fade out (mirrors the CSS keyframes).
      double opacity;
      if (p < 0.12) {
        opacity = (p / 0.12) * 0.7;
      } else if (p < 0.85) {
        opacity = 0.7 - (p - 0.12) / 0.73 * 0.3;
      } else {
        opacity = 0.4 * (1 - (p - 0.85) / 0.15);
      }
      if (opacity <= 0) continue;

      final scale = 0.5 + p * 0.7;
      final radius = 2 * s.sizeScale * scale;
      final dx = s.x * size.width;
      final dy = size.height - p * (size.height + 40);

      final paint = Paint()
        ..shader = RadialGradient(
          colors: [
            DateEmber.amberLight.withValues(alpha: opacity),
            DateEmber.emberLight.withValues(alpha: opacity * 0.6),
            DateEmber.emberLight.withValues(alpha: 0),
          ],
          stops: const [0.0, 0.6, 1.0],
        ).createShader(Rect.fromCircle(center: Offset(dx, dy), radius: radius));
      canvas.drawCircle(Offset(dx, dy), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _EmberPainter oldDelegate) => oldDelegate.t != t;
}
