import '../api/endpoints/app_endpoints.dart';
import '../api/network_service.dart';
import '../../features/auth/core/auth_event_service.dart';
import '../../features/auth/core/auth_status.dart';
import '../../features/auth/data/data_source/auth_remote_data_source.dart';
import '../../features/auth/data/data_source/auth_remote_data_source_impl.dart';
import '../../features/auth/data/repositories/auth_repository.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/data/services/auth_local_service.dart';
import '../../features/auth/data/strategies/oauth_strategy_factory.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/child/data/remote/child_remote_data_source.dart';
import '../../features/child/data/repositories/child_repository.dart';
import '../../features/child/presentation/cubit/child_cubit.dart';
import '../../features/child/presentation/cubit/child_draft_cubit.dart';
import '../../features/help_center/data/remote/help_center_remote_data_source.dart';
import '../../features/help_center/data/repositories/help_center_repository.dart';
import '../../features/help_center/presentation/cubit/help_center_cubit.dart';
import '../../features/language/data/remote/language_remote_data_source.dart';
import '../../features/language/data/repositories/language_repository.dart';
import '../../features/language/presentation/cubit/language_cubit.dart';
import '../../features/categories/data/remote/categories_remote_data_source.dart';
import '../../features/categories/data/repositories/categories_repository.dart';
import '../../features/categories/presentation/cubit/categories_cubit.dart';
import '../../features/levels/data/remote/levels_remote_data_source.dart';
import '../../features/levels/data/repositories/levels_repository.dart';
import '../../features/levels/presentation/cubit/levels_cubit.dart';
import '../../features/quiz/data/remote/quiz_remote_data_source.dart';
import '../../features/quiz/data/repositories/quiz_repository.dart';
import '../../features/quiz/presentation/cubit/quiz_cubit.dart';
import '../../features/notification/data/remote/notification_remote_data_source.dart';
import '../../features/notification/data/repositories/notification_repository.dart';
import '../../features/notification/presentation/cubit/notification_cubit.dart';
import '../../features/onboarding/data/repositories/onboarding_repository.dart';
import '../../features/onboarding/presentation/cubit/onboarding_cubit.dart';
import '../../features/splash/presentation/cubit/splash_cubit.dart';
import '../../features/user/data/remote/user_remote_data_source.dart';
import '../../features/user/data/repositories/user_repository.dart';
import '../../features/user/presentation/cubit/user_cubit.dart';

import 'app_info_service.dart';
import 'cache_service.dart';
import 'core_service_locator.dart';
import 'device_info_service.dart';
import 'notification_service.dart';
import 'permession_service.dart';

class ServiceLocator {
  Future<void> init({
    required String baseUrl,
    required OAuthConfig oauthConfig,
    String? appType,
  }) async {
    // Core services
    sl.registerLazySingleton<CacheService>(() => CacheServiceImpl());
    sl.registerLazySingleton<DeviceInfoService>(() => DeviceInfoServiceImpl());
    sl.registerLazySingleton<AppInfoService>(() => AppInfoServiceImpl());
    sl.registerLazySingleton<PermissionService>(() => PermissionServiceImpl());
    sl.registerLazySingleton<NotificationService>(
      () => NotificationService(permissionService: sl()),
    );

    // API
    sl.registerLazySingleton<AppEndpoint>(() => AppEndpoint(baseUrl: baseUrl));
    sl.registerLazySingleton<NetworkService>(
      () => NetworkServiceImpl(
        onLogout: () => sl<AuthEventService>().notify(AuthEvent.loggedOut),
        appType: appType,
      ),
    );

    // Auth
    sl.registerLazySingleton<AuthEventService>(() => AuthEventService());
    sl.registerLazySingleton<AuthLocalService>(() => AuthLocalService(sl()));
    sl.registerLazySingleton<OAuthStrategyFactory>(
      () => OAuthStrategyFactory(config: oauthConfig),
    );
    sl.registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(networkService: sl(), endpoints: sl()),
    );
    sl.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(
        remoteDataSource: sl(),
        localService: sl(),
        strategyFactory: sl(),
      ),
    );
    sl.registerFactory<AuthCubit>(
      () => AuthCubit(repository: sl(), authEventService: sl()),
    );

    // User
    sl.registerLazySingleton<UserRemoteDataSource>(
      () => UserRemoteDataSourceImpl(networkService: sl(), endpoints: sl()),
    );
    sl.registerLazySingleton<UserRepository>(
      () => UserRepositoryImpl(remoteDataSource: sl(), cacheService: sl()),
    );
    sl.registerLazySingleton<UserCubit>(
      () => UserCubit(userRepository: sl(), authEventService: sl()),
    );

    // Child
    sl.registerLazySingleton<ChildRemoteDataSource>(
      () => ChildRemoteDataSourceImpl(networkService: sl(), endpoints: sl()),
    );
    sl.registerLazySingleton<ChildRepository>(
      () => ChildRepositoryImpl(remoteDataSource: sl()),
    );
    sl.registerFactory<ChildCubit>(() => ChildCubit(childRepository: sl()));
    sl.registerFactory<ChildDraftCubit>(() => ChildDraftCubit());

    // Onboarding
    sl.registerLazySingleton<OnboardingRepository>(
      () => OnboardingRepositoryImpl(cacheService: sl()),
    );
    sl.registerFactory<OnboardingCubit>(
      () => OnboardingCubit(onboardingRepository: sl()),
    );

    // Splash
    sl.registerFactory<SplashCubit>(
      () => SplashCubit(
        onboardingRepository: sl(),
        notificationService: sl(),
        cacheService: sl(),
      ),
    );

    // Language
    sl.registerLazySingleton<LanguageRemoteDataSource>(
      () => LanguageRemoteDataSourceImpl(
        networkService: sl(),
        endpoints: sl(),
      ),
    );
    sl.registerLazySingleton<LanguageRepository>(
      () => LanguageRepositoryImpl(remoteDataSource: sl()),
    );
    sl.registerFactory<LanguageCubit>(
      () => LanguageCubit(repository: sl()),
    );

    // Notifications (mock-backed)
    sl.registerLazySingleton<NotificationRemoteDataSource>(
      () => NotificationRemoteDataSourceImpl(),
    );
    sl.registerLazySingleton<NotificationRepository>(
      () => NotificationRepositoryImpl(remoteDataSource: sl()),
    );
    sl.registerFactory<NotificationCubit>(
      () => NotificationCubit(notificationRepository: sl()),
    );

    // Help center (mock-backed)
    sl.registerLazySingleton<HelpCenterRemoteDataSource>(
      () => HelpCenterRemoteDataSourceImpl(),
    );
    sl.registerLazySingleton<HelpCenterRepository>(
      () => HelpCenterRepositoryImpl(remoteDataSource: sl()),
    );
    sl.registerFactory<HelpCenterCubit>(
      () => HelpCenterCubit(helpCenterRepository: sl()),
    );

    // Categories
    sl.registerLazySingleton<CategoriesRemoteDataSource>(
      () => CategoriesRemoteDataSourceImpl(
        networkService: sl(),
        endpoints: sl(),
      ),
    );
    sl.registerLazySingleton<CategoriesRepository>(
      () => CategoriesRepositoryImpl(remoteDataSource: sl()),
    );
    sl.registerFactory<CategoriesCubit>(
      () => CategoriesCubit(categoriesRepository: sl()),
    );

    // Levels
    sl.registerLazySingleton<LevelsRemoteDataSource>(
      () => LevelsRemoteDataSourceImpl(
        networkService: sl(),
        endpoints: sl(),
      ),
    );
    sl.registerLazySingleton<LevelsRepository>(
      () => LevelsRepositoryImpl(remoteDataSource: sl()),
    );
    sl.registerFactory<LevelsCubit>(
      () => LevelsCubit(levelsRepository: sl()),
    );

    // Quiz
    sl.registerLazySingleton<QuizRemoteDataSource>(
      () => QuizRemoteDataSourceImpl(
        networkService: sl(),
        endpoints: sl(),
      ),
    );
    sl.registerLazySingleton<QuizRepository>(
      () => QuizRepositoryImpl(remoteDataSource: sl()),
    );
    sl.registerFactory<QuizCubit>(
      () => QuizCubit(quizRepository: sl()),
    );
  }
}
