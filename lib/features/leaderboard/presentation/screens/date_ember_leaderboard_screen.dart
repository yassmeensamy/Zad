import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:my_app/core/widgets/responsive_text.dart';
import 'package:my_app/theme/app_colors.dart';


/// Zad — Date & Ember leaderboard screen.
///
/// A single-file, self-contained recreation of the `Zad Date and Ember
/// Screen.html` design handed off from Claude Design. Roasted-brown depths,
/// ember accents, gold foil and rising sparks. Every colour in the design is
/// captured in [AppColors] (lib/theme/app_colors.dart) — the shared palette this screen and the app dark theme both use.
///
/// This screen is intentionally independent of the app theme — it is a faithful
/// port of the mock, not yet  wired to live leaderboard data.
class DateEmberLeaderboardScreen extends StatelessWidget {
  const DateEmberLeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.canvasNight,
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
          colors: [AppColors.nightRaised, AppColors.nightSurface, AppColors.nightLow],
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
                  color: AppColors.ivory,
                  colorBlendMode: BlendMode.screen,
                ),
              ),
            ),
          ),
          // Warm amber wash at the top.
          Positioned(
            left: -120,
            right: -120,
            top: -120,
            height: 420,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    radius: 0.65,
                    colors: [
                      AppColors.washAmber.withValues(alpha: 0.22),
                      AppColors.washAmber.withValues(alpha: 0),
                    ],
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
                ResponsiveText(
                  'LEAGUE · WEEK 12',
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 3.2,
                    color: AppColors.amberGlow,
                  ),
                ),
                SizedBox(height: 3),
                ResponsiveText(
                  'Companions of Sabr',
                  style: TextStyle(
                    fontFamily: _serif,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w300,
                    fontSize: 21,
                    height: 1,
                    letterSpacing: -0.3,
                    color: AppColors.ivory,
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
      color: AppColors.ivory.withValues(alpha: 0.05), // ivory @ 0.05
      shape: const CircleBorder(side: BorderSide(color: AppColors.nightOutline)),
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
    child: Icon(icon, size: 16, color: AppColors.ivory),
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
                      AppColors.amberLight,
                      AppColors.amberGlow,
                      AppColors.discGoldLo,
                    ],
                    stops: [0.0, 0.55, 1.0],
                  ).createShader(r),
                  child: const ResponsiveText(
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
                const ResponsiveText(
                  'XP',
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
    return ResponsiveText(
      text,
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

class _DeltaBadge extends StatelessWidget {
  const _DeltaBadge(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.keyboard_arrow_up, size: 12, color: AppColors.oliveLight),
        const SizedBox(width: 2),
        ResponsiveText(
          text,
          style: const TextStyle(
            fontFamily: _mono,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.oliveLight,
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

class _StatPipe extends StatelessWidget {
  const _StatPipe();

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
            AppColors.washAmber.withValues(alpha: 0),
            AppColors.washAmber.withValues(alpha: 0.25),
            AppColors.washAmber.withValues(alpha: 0),
          ],
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
      ..color = AppColors.amberGlow
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
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.amberGlow.withValues(alpha: 0.35),
            AppColors.amberGlow.withValues(alpha: 0),
          ],
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
          colors: [AppColors.discGoldLo, AppColors.amberLight],
        ).createShader(Offset.zero & size),
    );

    // End marker.
    final end = map(_pts.last);
    canvas.drawCircle(end, 3, Paint()..color = AppColors.amberLight);
    canvas.drawCircle(
      end,
      6,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = AppColors.amberGlow.withValues(alpha: 0.5),
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
      ..color = AppColors.washAmber.withValues(alpha: 0.22)
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
        color: AppColors.ivory.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.ivory08),
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
                        ? LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              AppColors.amberLight.withValues(alpha: 0.20),
                              AppColors.discGoldLo.withValues(alpha: 0.12),
                            ],
                          )
                        : null,
                  ),
                  alignment: Alignment.center,
                  child: ResponsiveText(
                    _items[i],
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.8,
                      color: i == _selected
                          ? AppColors.amberLight
                          : AppColors.ivory62,
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
        SizedBox(
          width: 26,
          height: 1,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.amberGlow.withValues(alpha: 0), AppColors.amberGlow],
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        ResponsiveText(
          label,
          style: const TextStyle(
            fontFamily: _mono,
            fontSize: 9,
            fontWeight: FontWeight.w600,
            letterSpacing: 3.2,
            color: AppColors.amberGlow,
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 26,
          height: 1,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.amberGlow, AppColors.amberGlow.withValues(alpha: 0)],
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
      1 => AppColors.amberGlow,
      2 => AppColors.discSilverMid,
      _ => AppColors.emberBright,
    };
    final pedHeight = switch (place) {
      1 => 46.0,
      2 => 34.0,
      _ => 25.0,
    };
    final pedTint = switch (place) {
      1 => AppColors.amberGlow,
      2 => AppColors.discSilverMid,
      _ => AppColors.ember,
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
        ResponsiveText(
          name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isFirst ? FontWeight.w700 : FontWeight.w600,
            color: isFirst ? AppColors.amberLight : AppColors.ivory,
          ),
        ),
        const SizedBox(height: 2),
        ResponsiveText(
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
          child: ResponsiveText(
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
        color: AppColors.nightLow,
        border: Border.all(color: color, width: 2),
      ),
      child: ResponsiveText(
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
          colors: [AppColors.amberLight, AppColors.discGoldLo],
        ).createShader(Offset.zero & size),
    );
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8
        ..strokeJoin = StrokeJoin.round
        ..color = AppColors.discBronzeLo,
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
        [AppColors.discGoldHi, AppColors.discGoldMid, AppColors.discGoldLo],
        AppColors.discGoldInk,
        AppColors.washAmber.withValues(alpha: 0.55),
      ),
      _DiscStyle.silver => (
        [AppColors.discSilverHi, AppColors.discSilverMid, AppColors.discSilverLo],
        AppColors.discGoldInk,
        AppColors.sandWarm.withValues(alpha: 0.50),
      ),
      _DiscStyle.bronze => (
        [AppColors.discBronzeHi, AppColors.discBronzeMid, AppColors.discBronzeLo],
        AppColors.discBronzeInk,
        AppColors.ember.withValues(alpha: 0.50),
      ),
      _DiscStyle.olive => (
        [AppColors.discOliveHi, AppColors.discOliveMid, AppColors.discOliveLo],
        AppColors.discOliveInk,
        AppColors.nightOutline,
      ),
      _DiscStyle.date => (
        [AppColors.discDateHi, AppColors.discDateMid, AppColors.discDateLo],
        AppColors.ivory,
        AppColors.nightOutline,
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
      child: ResponsiveText(
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
        Expanded(
          child: SizedBox(
            height: 1,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.washAmber.withValues(alpha: 0),
                    AppColors.washAmber.withValues(alpha: 0.30),
                    AppColors.washAmber.withValues(alpha: 0),
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
            color: AppColors.amberGlow,
          ),
        ),
        Expanded(
          child: SizedBox(
            height: 1,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.washAmber.withValues(alpha: 0),
                    AppColors.washAmber.withValues(alpha: 0.30),
                    AppColors.washAmber.withValues(alpha: 0),
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
            ? LinearGradient(
                colors: [
                  AppColors.washAmber.withValues(alpha: 0.12),
                  AppColors.washAmber.withValues(alpha: 0.02),
                ],
              )
            : null,
        color: isMe ? null : AppColors.ivory.withValues(alpha: 0.02),
        border: Border.all(
          color: isMe
              ? AppColors.washAmber.withValues(alpha: 0.40)
              : AppColors.ivory.withValues(alpha: 0.05),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 22,
            child: ResponsiveText(
              rank,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: _mono,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isMe ? AppColors.amberGlow : AppColors.ivory40,
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
                      color: isMe ? AppColors.amberLight : AppColors.ivory,
                    ),
                    children: [
                      if (youSuffix != null)
                        TextSpan(
                          text: youSuffix,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: AppColors.amberLight.withValues(alpha: 0.65),
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
                    ResponsiveText(
                      role,
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.ivory62,
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
              ResponsiveText(
                points,
                style: TextStyle(
                  fontFamily: _mono,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isMe ? AppColors.amberLight : AppColors.ivory,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.keyboard_arrow_up,
                    size: 10,
                    color: AppColors.oliveLight,
                  ),
                  ResponsiveText(
                    trend,
                    style: const TextStyle(
                      fontFamily: _mono,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.oliveLight,
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
      _DotState.active => AppColors.ember,
      _DotState.steady => AppColors.amberGlow,
      _DotState.idle => AppColors.ivory.withValues(alpha: 0.22),
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
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.ember.withValues(alpha: 0.18),
            AppColors.discBronzeLo.withValues(alpha: 0.08),
          ],
        ),
        border: Border.all(color: AppColors.emberBright.withValues(alpha: 0.40)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.45),
            blurRadius: 30,
            offset: const Offset(0, 16),
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
                colors: [AppColors.emberBright, AppColors.ember],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.ember.withValues(alpha: 0.55),
                  blurRadius: 18,
                ),
              ],
            ),
            child: const Icon(
              Icons.local_fire_department,
              size: 20,
              color: AppColors.emberInk,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                ResponsiveText(
                  'Keep your ember alight — 38 days.',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.1,
                    color: AppColors.amberLight,
                  ),
                ),
                SizedBox(height: 3),
                ResponsiveText(
                  'One more solve to climb to #4 tonight.',
                  style: TextStyle(fontSize: 10.5, color: AppColors.ivory62),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.arrow_forward, size: 16, color: AppColors.amberGlow),
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
            AppColors.amberLight.withValues(alpha: opacity),
            AppColors.emberBright.withValues(alpha: opacity * 0.6),
            AppColors.emberBright.withValues(alpha: 0),
          ],
          stops: const [0.0, 0.6, 1.0],
        ).createShader(Rect.fromCircle(center: Offset(dx, dy), radius: radius));
      canvas.drawCircle(Offset(dx, dy), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _EmberPainter oldDelegate) => oldDelegate.t != t;
}
