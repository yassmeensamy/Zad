import '../../data/models/daily_activity_model.dart';
import '../../data/models/streak_model.dart';

enum StreakStatus { initial, loading, loaded, error }

class StreakState {
  const StreakState({
    this.status = StreakStatus.initial,
    this.streak,
    this.weekly = const [],
    this.errorMessage,
  });

  final StreakStatus status;
  final StreakModel? streak;
  final List<DailyActivityModel> weekly;
  final String? errorMessage;

  StreakState copyWith({
    StreakStatus? status,
    StreakModel? streak,
    List<DailyActivityModel>? weekly,
    String? Function()? errorMessage,
  }) => StreakState(
    status: status ?? this.status,
    streak: streak ?? this.streak,
    weekly: weekly ?? this.weekly,
    errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
  );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! StreakState) return false;
    if (other.weekly.length != weekly.length) return false;
    for (var i = 0; i < weekly.length; i++) {
      if (other.weekly[i] != weekly[i]) return false;
    }
    return other.status == status &&
        other.streak == streak &&
        other.errorMessage == errorMessage;
  }

  @override
  int get hashCode =>
      Object.hash(status, streak, Object.hashAll(weekly), errorMessage);
}

extension StreakStateX on StreakState {
  bool get isInitial => status == StreakStatus.initial;
  bool get isLoading => status == StreakStatus.loading;
  bool get isLoaded => status == StreakStatus.loaded;
  bool get isError => status == StreakStatus.error;

  bool get hasStreak => streak != null;

  int get streakDays => streak?.currentStreak ?? 0;

  List<bool> get weekProgress {
    final week = List<bool>.filled(7, false);
    for (final day in weekly) {
      final date = day.date;
      if (date == null) continue;
      week[date.weekday - 1] = day.active;
    }
    return week;
  }

  int get todayIndex {
    DateTime? latest;
    for (final day in weekly) {
      final date = day.date;
      if (date == null) continue;
      if (latest == null || date.isAfter(latest)) latest = date;
    }
    return latest == null ? DateTime.now().weekday - 1 : latest.weekday - 1;
  }
}
