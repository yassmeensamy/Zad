import '../models/hadith_model.dart';
import '../models/home_overview_model.dart';

abstract class HomeRemoteDataSource {
  Future<HomeOverviewModel> getOverview();
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  HomeRemoteDataSourceImpl();

  @override
  Future<HomeOverviewModel> getOverview() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return _seedOverview;
  }

  static const HomeOverviewModel _seedOverview = HomeOverviewModel(
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
