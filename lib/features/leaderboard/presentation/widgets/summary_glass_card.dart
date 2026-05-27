import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../theme/theme.dart';
import '../../../teams/presentation/cubit/teams_state.dart';
import 'olive_leaderboard_widgets.dart';

/// Spacing rhythm inside the summary card. Tweaking here keeps all the
/// sections (header row, divider, stat row) visually balanced.
const _kSectionGap = 18.0;
const _kInnerGap = 14.0;

/// Summary glass card for the Olive Light leaderboard: rank arc gauge,
/// a tagline derived from the team's rank, and a three-stat row
/// (Levels done · Total · Members). All numbers come straight from
/// [TeamsState]; no estimated or fabricated values.
class SummaryGlassCard extends StatelessWidget {
  const SummaryGlassCard({super.key, required this.state});

  final TeamsState state;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final summary = state.summary;
    final progress = state.progress;
    final rank = summary?.teamRank;
    final total = summary?.totalTeams;
    final solved = progress?.totalCompleted;
    final totalLevels = progress?.totalLevels;
    final members = state.team?.memberCount ?? state.members?.members.length;

    return OliveGlassCard(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 72,
                height: 72,
                child: _RankArc(rank: rank, total: total),
              ),
              const SizedBox(width: _kInnerGap),
              Expanded(
                child: Text(
                  _tagline(rank, total),
                  style: AppTextStyles.displaySmall.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w300,
                    fontStyle: FontStyle.italic,
                    color: colors.oliveDeep,
                    height: 1.2,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: _kSectionGap),
          _Hairline(color: colors.oliveSoft.withValues(alpha: 0.28)),
          const SizedBox(height: _kSectionGap),
          Row(
            children: [
              Expanded(
                child: _StatCell(
                  value: solved == null ? '—' : _formatThousands(solved),
                  label: 'Levels done',
                  gold: true,
                ),
              ),
              _VerticalHair(color: colors.oliveSoft.withValues(alpha: 0.25)),
              Expanded(
                child: _StatCell(
                  value: totalLevels == null
                      ? '—'
                      : _formatThousands(totalLevels),
                  label: 'Total',
                ),
              ),
              _VerticalHair(color: colors.oliveSoft.withValues(alpha: 0.25)),
              Expanded(
                child: _StatCell(
                  value: members?.toString() ?? '—',
                  label: 'Members',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _tagline(int? rank, int? total) {
    if (rank == null || total == null || total <= 0) {
      return 'Your team rank is loading…';
    }
    if (rank <= 3) return 'Your team is in the top three.';
    if (rank <= 10) return 'Your team is in the top ten.';
    final gap = rank - 10;
    return 'Your team is climbing — $gap more until top ten.';
  }
}

class _StatCell extends StatelessWidget {
  const _StatCell({
    required this.value,
    required this.label,
    this.gold = false,
  });

  final String value;
  final String label;
  final bool gold;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final numStyle = TextStyle(
      fontFamily: 'serif',
      fontSize: 21,
      fontWeight: FontWeight.w300,
      fontStyle: FontStyle.italic,
      color: colors.oliveDeep,
      height: 0.9,
      letterSpacing: -1,
    );

    final number = gold
        ? ShaderMask(
            shaderCallback: (rect) => const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColors.amber, AppColors.date],
            ).createShader(rect),
            child: Text(value, style: numStyle.copyWith(color: Colors.white)),
          )
        : Text(value, style: numStyle);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        number,
        const SizedBox(height: 3),
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 8,
            fontWeight: FontWeight.w600,
            letterSpacing: 2.24,
            color: colors.oliveSoft,
          ),
        ),
      ],
    );
  }
}

class _Hairline extends StatelessWidget {
  const _Hairline({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    height: 1,
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [Colors.transparent, color, Colors.transparent],
      ),
    ),
  );
}

class _VerticalHair extends StatelessWidget {
  const _VerticalHair({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    width: 1,
    height: 32,
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.transparent, color, Colors.transparent],
      ),
    ),
  );
}

/// Percentile-based arc gauge: arc length is `1 - rank/total`, so the
/// closer the team is to #1, the fuller the ring. Color follows the rank
/// tier (gold = top 10%, olive = top 33%, date = below) so the gauge
/// reads even before you look at the numbers. When either value is
/// unknown the gauge renders an empty olive ring with `—` for both
/// numbers — no fabricated rank.
class _RankArc extends StatelessWidget {
  const _RankArc({required this.rank, required this.total});

  final int? rank;
  final int? total;

  ({double value, List<Color> gradient}) _resolve(AppColorsTheme colors) {
    final r = rank;
    final t = total;
    if (r == null || t == null || t <= 0 || r <= 0) {
      return (value: 0, gradient: [colors.oliveSoft, colors.oliveDeep]);
    }
    final percentileTop = (1 - r / t).clamp(0.0, 1.0);
    final gradient = switch (percentileTop) {
      >= 0.9 => const [AppColors.flameLight, AppColors.goldDeep],
      >= 0.67 => const [AppColors.amber, AppColors.date],
      _ => [colors.oliveSoft, colors.oliveDeep],
    };
    return (value: percentileTop, gradient: gradient);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final arc = _resolve(colors);
    final hasData = rank != null && total != null && total! > 0 && rank! > 0;
    final pctTop = hasData ? (arc.value * 100).round().clamp(0, 100) : null;

    return CustomPaint(
      painter: _ArcPainter(
        ratio: arc.value,
        track: colors.oliveSoft.withValues(alpha: 0.14),
        gradient: arc.gradient,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ShaderMask(
              shaderCallback: (rect) => LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: arc.gradient,
              ).createShader(rect),
              child: Text(
                hasData ? '#$rank' : '—',
                style: const TextStyle(
                  fontFamily: 'serif',
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                  fontStyle: FontStyle.italic,
                  color: Colors.white,
                  height: 1,
                ),
              ),
            ),
            const SizedBox(height: 3),
            Text(
              hasData ? 'of $total' : 'of —',
              style: TextStyle(
                fontSize: 7.5,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.4,
                color: colors.oliveSoft,
                height: 1,
              ),
            ),
            if (pctTop != null) ...[
              const SizedBox(height: 2),
              Text(
                'TOP $pctTop%',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 6.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: arc.gradient.last,
                  height: 1,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ArcPainter extends CustomPainter {
  _ArcPainter({
    required this.ratio,
    required this.track,
    required this.gradient,
  });

  final double ratio;
  final Color track;
  final List<Color> gradient;

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 5.0;
    final center = size.center(Offset.zero);
    final radius = size.width / 2 - stroke / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..color = track,
    );

    if (ratio <= 0) return;

    final arcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        startAngle: 0,
        endAngle: 2 * math.pi,
        transform: const GradientRotation(-math.pi / 2),
        colors: [gradient.first, gradient.last, gradient.first],
      ).createShader(rect);

    canvas.drawArc(
      rect,
      -math.pi / 2,
      ratio.clamp(0.0, 1.0) * 2 * math.pi,
      false,
      arcPaint,
    );

    // Small bead at the arc's leading edge for emphasis.
    final endAngle = -math.pi / 2 + ratio.clamp(0.0, 1.0) * 2 * math.pi;
    final beadCenter = Offset(
      center.dx + radius * math.cos(endAngle),
      center.dy + radius * math.sin(endAngle),
    );
    canvas.drawCircle(
      beadCenter,
      stroke * 0.55,
      Paint()..color = gradient.last,
    );
  }

  @override
  bool shouldRepaint(covariant _ArcPainter old) =>
      old.ratio != ratio || old.track != track || old.gradient != gradient;
}

String _formatThousands(int n) {
  final s = n.toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    final fromEnd = s.length - i;
    buf.write(s[i]);
    if (fromEnd > 1 && fromEnd % 3 == 1) buf.write(',');
  }
  return buf.toString();
}
