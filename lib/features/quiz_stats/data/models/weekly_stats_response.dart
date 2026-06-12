import 'dart:convert';

/// Response body for `GET /api/quiz/stats/weekly`.
///
/// [dailyBreakdown] maps an arbitrary day key (e.g. a weekday name or ISO date,
/// the server decides) to the number of questions solved that day. It is kept
/// as a plain map so the UI can render whatever buckets the backend returns.
class WeeklyStatsResponse {
  const WeeklyStatsResponse({
    required this.solvedLastWeek,
    required this.peakDay,
    required this.peakDayCount,
    required this.dailyBreakdown,
  });

  /// Total questions solved across the last week.
  final int solvedLastWeek;

  /// Key of the most productive day, empty when there was no activity.
  final String peakDay;

  /// Questions solved on [peakDay].
  final int peakDayCount;

  /// Per-day solved counts, keyed by the day label the server provides.
  final Map<String, int> dailyBreakdown;

  factory WeeklyStatsResponse.fromMap(Map<String, dynamic> map) =>
      WeeklyStatsResponse(
        solvedLastWeek: (map['solvedLastWeek'] as num?)?.toInt() ?? 0,
        peakDay: map['peakDay'] as String? ?? '',
        peakDayCount: (map['peakDayCount'] as num?)?.toInt() ?? 0,
        dailyBreakdown:
            ((map['dailyBreakdown'] as Map<dynamic, dynamic>?) ?? const {})
                .map(
                  (key, value) =>
                      MapEntry('$key', (value as num?)?.toInt() ?? 0),
                ),
      );

  factory WeeklyStatsResponse.fromJson(String source) =>
      WeeklyStatsResponse.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'WeeklyStatsResponse(solvedLastWeek: $solvedLastWeek, '
      'peakDay: $peakDay, peakDayCount: $peakDayCount)';
}
