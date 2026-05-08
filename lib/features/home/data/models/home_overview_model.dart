import 'hadith_model.dart';
import 'streak_model.dart';

/// Composite payload for the home screen — bundles the streak summary and
/// the hadith of the day. Future home-only widgets (e.g. ayah of the day,
/// daily goal) can be added here without growing the cubit's surface.
class HomeOverviewModel {
  const HomeOverviewModel({required this.streak, required this.hadithOfDay});

  final StreakModel streak;
  final HadithModel hadithOfDay;

  HomeOverviewModel copyWith({
    StreakModel? streak,
    HadithModel? hadithOfDay,
  }) => HomeOverviewModel(
    streak: streak ?? this.streak,
    hadithOfDay: hadithOfDay ?? this.hadithOfDay,
  );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HomeOverviewModel &&
        other.streak == streak &&
        other.hadithOfDay == hadithOfDay;
  }

  @override
  int get hashCode => Object.hash(streak, hadithOfDay);
}
