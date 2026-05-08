import '../models/hadith_model.dart';
import '../models/home_overview_model.dart';
import '../models/streak_model.dart';

abstract class HomeRemoteDataSource {
  Future<HomeOverviewModel> getOverview();
}

/// Mock implementation that fakes a network round-trip with [Future.delayed]
/// and serves a static streak + hadith pair. Swap for an API-backed source
/// when the backend is available — the repository contract stays the same.
class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  HomeRemoteDataSourceImpl();

  @override
  Future<HomeOverviewModel> getOverview() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return _seedOverview;
  }

  static const HomeOverviewModel _seedOverview = HomeOverviewModel(
    streak: StreakModel(
      streakDays: 12,
      weekProgress: [true, true, true, true, true, false, false],
      todayIndex: 5,
      personalBest: 28,
      nextMilestone: 14,
    ),
    hadithOfDay: HadithModel(
      id: 1,
      source: 'Saḥīḥ al-Bukhārī',
      arabic: 'إِنَّمَا الأَعْمَالُ بِالنِّيَّاتِ',
      english:
          '"Actions are judged by their intentions, and every person will be rewarded according to what they intended."',
      narrator: 'ʿUmar ibn al-Khaṭṭāb',
      hadithNumber: 1,
    ),
  );
}
