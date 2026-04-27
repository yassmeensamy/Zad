import '../../../../core/constants/storage_keys.dart';
import '../../../../core/services/cache_service.dart';
import '../models/onboarding_model.dart';

abstract class OnboardingRepository {
  List<OnboardingModel>? get cachedOnboarding;
  Future<List<OnboardingModel>> getOnboardingData();
  Future<bool> getFirstOpen();
  Future<void> setFirstOpen();
}

/// Mock-data implementation. Once the backend exists, swap this for a remote
/// data source — the cubit/screen consume the abstract interface.
class OnboardingRepositoryImpl implements OnboardingRepository {
  OnboardingRepositoryImpl({required CacheService cacheService})
    : _cacheService = cacheService;

  final CacheService _cacheService;
  List<OnboardingModel>? _cached;

  static const _mockPages = <OnboardingModel>[
    OnboardingModel(
      pk: 1,
      text: 'Learn the Quran daily',
      subText: 'Build a consistent reading habit with bite-sized lessons.',
      image: 'https://picsum.photos/seed/zad-1/800/1200',
    ),
    OnboardingModel(
      pk: 2,
      text: 'Track your progress',
      subText: 'See your streak, points, and weekly goals at a glance.',
      image: 'https://picsum.photos/seed/zad-2/800/1200',
    ),
    OnboardingModel(
      pk: 3,
      text: 'Compete with friends',
      subText: 'Climb the leaderboard and stay motivated together.',
      image: 'https://picsum.photos/seed/zad-3/800/1200',
    ),
  ];

  @override
  List<OnboardingModel>? get cachedOnboarding => _cached;

  @override
  Future<List<OnboardingModel>> getOnboardingData() async {
    if (_cached != null) return _cached!;
    await Future<void>.delayed(const Duration(milliseconds: 250));
    _cached = _mockPages;
    return _cached!;
  }

  @override
  Future<bool> getFirstOpen() async =>
      await _cacheService.get<bool>(StorageKeys.kFirstOpenKey) ?? true;

  @override
  Future<void> setFirstOpen() async =>
      await _cacheService.set<bool>(StorageKeys.kFirstOpenKey, false);
}
