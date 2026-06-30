import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/widgets/responsive_text.dart';
import '../../../leaderboard/data/models/individual_ranking_model.dart';
import '../../../quiz_stats/data/models/weekly_stats_response.dart';
import '../../../quiz_stats/presentation/cubit/quiz_stats_cubit.dart';
import '../../../quiz_stats/presentation/cubit/quiz_stats_state.dart';
import 'date_ember_roles.dart';

/// "This week · stats" — a 2×2 snapshot plus a level-progress bar, wired to
/// [QuizStatsCubit].
///
///  - **Your rank** ← `myRank.rank` (+ a progress ring), top-3 tinted gold.
///  - **Questions last week** ← `solvedLastWeek`, with a day-labelled sparkline
///    built from `dailyBreakdown`.
///  - **Peak activity day** ← `peakDay` + `peakDayCount`.
///  - **Total solved** ← `totalSolvedQuestions`.
///  - **Level progress** (full-width) ← `myRank.completedLevels/totalLevels`.
///
/// "Avg accuracy", "Active members", and the "% vs last week" trend chips remain
/// omitted: no current endpoint exposes accuracy, team membership, or a
/// previous-week baseline. Re-add them once a team-stats endpoint provides them.
///
/// Fully brightness-aware via [DateEmberRoles]. Requires a [QuizStatsCubit]
/// above it in the tree.
class TeamWeekStats extends StatelessWidget {
  const TeamWeekStats({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<QuizStatsCubit, QuizStatsState>(
      buildWhen: (a, b) =>
          a.status != b.status ||
          a.weekly != b.weekly ||
          a.myRank != b.myRank ||
          a.totalSolved != b.totalSolved,
      builder: (context, state) {
        final weekly = state.weekly;
        final rank = state.myRank;
        final loading = state.isLoading || state.status == QuizStatsStatus.idle;
        return Skeletonizer(
          enabled: loading,
          child: Column(
            children: [
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(child: _rankCard(context, rank)),
                    const SizedBox(width: 9),
                    Expanded(child: _questionsCard(context, weekly)),
                  ],
                ),
              ),
              const SizedBox(height: 9),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(child: _peakCard(context, weekly)),
                    const SizedBox(width: 9),
                    Expanded(child: _totalCard(context, state)),
                  ],
                ),
              ),
              const SizedBox(height: 9),
              _LevelProgressBar(rank: rank),
            ],
          ),
        );
      },
    );
  }

  Widget _rankCard(BuildContext context, MyIndividualRank? rank) {
    final p = DateEmberRoles(context);
    final isPodium = rank != null && rank.rank >= 1 && rank.rank <= 3;
    return _StatCard(
      icon: Icons.emoji_events_rounded,
      accent: p.gold,
      label: 'teams.stats.rank_label'.tr(),
      value: rank != null ? '#${rank.rank}' : '—',
      valueColor: isPodium ? p.gold : null,
      note: rank != null
          ? 'teams.stats.rank_levels'.tr(
              namedArgs: {
                'completed': '${rank.completedLevels}',
                'total': '${rank.totalLevels}',
              },
            )
          : 'teams.stats.not_ranked'.tr(),
      ring: rank?.progress,
    );
  }

  Widget _questionsCard(BuildContext context, WeeklyStatsResponse? weekly) {
    final p = DateEmberRoles(context);
    return _StatCard(
      icon: Icons.insights_rounded,
      accent: p.amber,
      label: 'teams.stats.questions_label'.tr(),
      value: _grouped(weekly?.solvedLastWeek ?? 0),
      note: 'teams.stats.this_week'.tr(),
      spark: true,
      sparkBars: _sparkBars(weekly),
      sparkLabels: _sparkLabels(weekly),
      peakIndex: _peakIndex(weekly),
    );
  }

  Widget _peakCard(BuildContext context, WeeklyStatsResponse? weekly) {
    final p = DateEmberRoles(context);
    return _StatCard(
      icon: Icons.local_fire_department_rounded,
      accent: p.ember,
      label: 'teams.stats.peak_label'.tr(),
      value: (weekly?.peakDay.isNotEmpty ?? false) ? weekly!.peakDay : '—',
      valueSize: 22,
      note: 'teams.stats.peak_questions'.tr(
        namedArgs: {'count': _grouped(weekly?.peakDayCount ?? 0)},
      ),
    );
  }

  Widget _totalCard(BuildContext context, QuizStatsState state) {
    final p = DateEmberRoles(context);
    return _StatCard(
      icon: Icons.task_alt_rounded,
      accent: p.green,
      label: 'teams.stats.total_label'.tr(),
      value: _grouped(state.totalSolvedQuestions),
      note: 'teams.stats.all_time'.tr(),
    );
  }

  /// Normalised (0..1) bar heights from the daily breakdown, in the order the
  /// server returns them. Falls back to a shape-only set so [Skeletonizer] has
  /// something to mask while the real data loads.
  static List<double> _sparkBars(WeeklyStatsResponse? w) {
    final values = w?.dailyBreakdown.values.toList() ?? const <int>[];
    if (values.isEmpty) {
      return const [0.40, 0.60, 0.48, 0.75, 0.95, 0.30, 0.22];
    }
    final maxValue = values.reduce(math.max);
    if (maxValue <= 0) return List<double>.filled(values.length, 0.06);
    return [for (final v in values) (v / maxValue).clamp(0.06, 1.0)];
  }

  /// First letter of each day key, used as sparkline axis labels.
  static List<String> _sparkLabels(WeeklyStatsResponse? w) {
    final keys = w?.dailyBreakdown.keys.toList() ?? const <String>[];
    if (keys.isEmpty) return const ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    return [for (final k in keys) k.isEmpty ? '' : k[0].toUpperCase()];
  }

  /// Index of the busiest bar, highlighted in ember.
  static int _peakIndex(WeeklyStatsResponse? w) {
    final values = w?.dailyBreakdown.values.toList() ?? const <int>[];
    if (values.isEmpty) return 4;
    var best = 0;
    for (var i = 1; i < values.length; i++) {
      if (values[i] > values[best]) best = i;
    }
    return best;
  }

  /// Thousands-grouped formatting for a non-negative count (e.g. 1284 → 1,284).
  static String _grouped(int n) {
    final s = n.toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.accent,
    required this.label,
    required this.value,
    this.valueSize = 28,
    this.valueColor,
    this.note,
    this.spark = false,
    this.sparkBars,
    this.sparkLabels,
    this.peakIndex = 4,
    this.ring,
  });

  final IconData icon;
  final Color accent;
  final String label;
  final String value;
  final double valueSize;
  final Color? valueColor;
  final String? note;
  final bool spark;
  final List<double>? sparkBars;
  final List<String>? sparkLabels;
  final int peakIndex;

  /// 0..1 progress arc drawn in the top-right corner (used by the rank card).
  final double? ring;

  @override
  Widget build(BuildContext context) {
    final p = DateEmberRoles(context);
    final column = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 20,
              height: 20,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(7),
              ),
              child: Icon(icon, size: 12, color: accent),
            ),
            const SizedBox(width: 7),
            Expanded(
              child: ResponsiveText(
                label.toUpperCase(),
                style: TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: p.inkMute,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 9),
        ResponsiveText(
          value,
          style: TextStyle(
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.w300,
            fontSize: valueSize,
            height: 0.95,
            color: valueColor ?? p.ink,
          ),
        ),
        const SizedBox(height: 7),
        if (note != null)
          ResponsiveText(
            note!,
            style: TextStyle(fontSize: 9, color: p.inkMute),
          ),
        if (spark) ...[
          const SizedBox(height: 9),
          _Spark(
            heights: sparkBars ?? const [],
            labels: sparkLabels ?? const [],
            peakIndex: peakIndex,
          ),
        ],
      ],
    );

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
      child: ring == null
          ? column
          : Stack(
              children: [
                // Pinned to the trailing corner via PositionedDirectional so it
                // sits opposite the start-aligned trophy badge in both LTR and
                // RTL — in Arabic `end` resolves to the left, clearing the icon
                // instead of overlapping it.
                PositionedDirectional(
                  end: 0,
                  top: 0,
                  child: CustomPaint(
                    size: const Size(38, 38),
                    painter: _RingPainter(
                      ratio: ring!,
                      track: p.ink,
                      arc: accent,
                    ),
                  ),
                ),
                column,
              ],
            ),
    );
  }
}

/// Sparkline driven by the weekly daily breakdown; the busiest bar is the "hot"
/// ember peak. Optional [labels] render a day-initial axis beneath the bars.
class _Spark extends StatelessWidget {
  const _Spark({
    required this.heights,
    required this.labels,
    required this.peakIndex,
  });

  final List<double> heights;
  final List<String> labels;
  final int peakIndex;

  @override
  Widget build(BuildContext context) {
    final p = DateEmberRoles(context);
    if (heights.isEmpty) return const SizedBox(height: 22);
    return Column(
      children: [
        SizedBox(
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
                        colors: i == peakIndex
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
        ),
        if (labels.isNotEmpty) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              for (var i = 0; i < labels.length; i++) ...[
                Expanded(
                  child: ResponsiveText(
                    labels[i],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 7,
                      fontWeight: i == peakIndex
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: i == peakIndex ? p.ember : p.inkFaint,
                    ),
                  ),
                ),
                if (i < labels.length - 1) const SizedBox(width: 3),
              ],
            ],
          ),
        ],
      ],
    );
  }
}

/// Full-width "level progress" bar — completed vs total levels from [rank],
/// rendered as a gradient track with a percentage and count.
class _LevelProgressBar extends StatelessWidget {
  const _LevelProgressBar({required this.rank});

  final MyIndividualRank? rank;

  @override
  Widget build(BuildContext context) {
    final p = DateEmberRoles(context);
    final progress = rank?.progress ?? 0;
    final completed = rank?.completedLevels ?? 0;
    final total = rank?.totalLevels ?? 0;
    final percent = (progress * 100).round();

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: p.green.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Icon(Icons.flag_rounded, size: 12, color: p.green),
              ),
              const SizedBox(width: 7),
              Expanded(
                child: ResponsiveText(
                  'teams.stats.level_progress'.tr().toUpperCase(),
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    color: p.inkMute,
                  ),
                ),
              ),
              ResponsiveText(
                '$completed / $total',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: p.inkMute,
                ),
              ),
            ],
          ),
          const SizedBox(height: 11),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ResponsiveText(
                '$percent%',
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w300,
                  fontSize: 22,
                  height: 0.95,
                  color: p.ink,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: Stack(
                    children: [
                      Container(
                        height: 8,
                        color: p.ink.withValues(alpha: 0.08),
                      ),
                      FractionallySizedBox(
                        widthFactor: progress.clamp(0.0, 1.0),
                        child: Container(
                          height: 8,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(99),
                            gradient: LinearGradient(
                              colors: [p.gold, p.ember],
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
        ],
      ),
    );
  }
}

/// Progress ring — a circle track with an arc filled to [ratio].
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
