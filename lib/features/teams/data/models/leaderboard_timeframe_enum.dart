enum LeaderboardTimeframe {
  week,
  month,
  allTime;

  static LeaderboardTimeframe fromApi(String? value) =>
      switch (value?.toLowerCase()) {
        'week' => LeaderboardTimeframe.week,
        'month' => LeaderboardTimeframe.month,
        'alltime' || 'all_time' || 'all-time' => LeaderboardTimeframe.allTime,
        _ => LeaderboardTimeframe.week,
      };

  String toApi() => switch (this) {
        LeaderboardTimeframe.week => 'week',
        LeaderboardTimeframe.month => 'month',
        LeaderboardTimeframe.allTime => 'all_time',
      };

  String get label => switch (this) {
        LeaderboardTimeframe.week => 'Week',
        LeaderboardTimeframe.month => 'Month',
        LeaderboardTimeframe.allTime => 'All time',
      };
}
