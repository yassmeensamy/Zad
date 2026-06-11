import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/widgets/responsive_text.dart';
import 'date_ember_roles.dart';

/// "This week · team stats" — a four-square snapshot of the team's week (volume,
/// accuracy, participation, peak) plus an insight banner.
///
/// Fully brightness-aware via [DateEmberRoles], uses the app's default font and
/// [ResponsiveText]. Shared by the Team Home screen and the app home screen.
///
/// Values are illustrative for now — wire to live team data when available.
class TeamWeekStats extends StatelessWidget {
  const TeamWeekStats({super.key});

  @override
  Widget build(BuildContext context) {
    final p = DateEmberRoles(context);
    return Column(
      children: [
        const IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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
        const IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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
                p.greenSurface.withValues(alpha: 0.16),
                p.greenSurface.withValues(alpha: 0.05),
              ],
            ),
            border: Border.all(color: p.greenSurface.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: p.greenSurface.withValues(alpha: 0.2),
                ),
                child: Icon(Icons.bar_chart, size: 18, color: p.green),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w300,
                      fontSize: 14,
                      height: 1.35,
                      color: p.ink,
                    ),
                    children: [
                      const TextSpan(text: 'Your team is '),
                      TextSpan(
                        text: 'improving in accuracy',
                        style: TextStyle(
                          fontStyle: FontStyle.normal,
                          fontWeight: FontWeight.w600,
                          color: p.green,
                        ),
                      ),
                      const TextSpan(
                        text:
                            ' — up 4% and climbing for three weeks straight.',
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
    final p = DateEmberRoles(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: p.hairline),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [p.cardFill, p.cardFillFaint],
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
                painter: _RingPainter(ratio: ring!, track: p.ink, arc: p.amber),
              ),
            ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ResponsiveText(
                label.toUpperCase(),
                style: TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.4,
                  color: p.inkMute,
                ),
              ),
              const SizedBox(height: 7),
              RichText(
                text: TextSpan(
                  text: value,
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w300,
                    fontSize: valueSize,
                    height: 0.95,
                    color: p.ink,
                  ),
                  children: [
                    if (valueSub != null)
                      TextSpan(
                        text: valueSub,
                        style: TextStyle(
                          fontStyle: FontStyle.normal,
                          fontSize: 14,
                          color: p.inkFaint,
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
                    ResponsiveText(
                      trendNote ?? '',
                      style: TextStyle(fontSize: 9, color: p.inkFaint),
                    ),
                  ],
                ),
              if (note != null)
                ResponsiveText(
                  note!,
                  style: TextStyle(fontSize: 9, color: p.inkMute),
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
    final p = DateEmberRoles(context);
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
                        ? [p.emberLight, p.ember]
                        : [p.gold, p.amberDeep],
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

/// Up/down trend chip with a small chevron.
class _TrendChip extends StatelessWidget {
  const _TrendChip({required this.value, required this.up});

  final String value;
  final bool up;

  @override
  Widget build(BuildContext context) {
    final p = DateEmberRoles(context);
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

/// Accuracy ring — a 270°-style arc filled to [ratio].
class _RingPainter extends CustomPainter {
  _RingPainter({required this.ratio, required this.track, required this.arc});
  final double ratio;
  final Color track;
  final Color arc;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2 - 2;
    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..color = track.withValues(alpha: 0.10);
    final arcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round
      ..color = arc;
    canvas.drawCircle(center, radius, trackPaint);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * ratio.clamp(0.0, 1.0),
      false,
      arcPaint,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.ratio != ratio || old.track != track || old.arc != arc;
}
