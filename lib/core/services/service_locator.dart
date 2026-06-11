import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:event_bus/event_bus.dart';

import '../../features/offline/data/remote/downloads_remote_data_source.dart';
import '../api/endpoints/app_endpoints.dart';
import '../api/network_service.dart';
import '../database/app_database.dart';
import '../../features/auth/core/auth_event_service.dart';
import '../../features/offline/core/offline_sync_service.dart';
import '../../features/offline/data/local/offline_content_dao.dart';
import '../../features/offline/data/local/pending_answers_dao.dart';
import '../../features/offline/data/repositories/downloads_repository.dart';
import '../../features/offline/presentation/cubit/connectivity_cubit.dart';
import '../../features/offline/presentation/cubit/downloads_cubit.dart';
import '../../features/onboarding_flow/data/avatars_remote_data_source.dart';
import '../../features/onboarding_flow/data/avatars_repository.dart';
import '../../features/onboarding_flow/presentation/cubit/avatars_cubit.dart';
import '../../features/auth/core/auth_status.dart';
import '../../features/auth/data/data_source/auth_remote_data_source.dart';
import '../../features/auth/data/data_source/auth_remote_data_source_impl.dart';
import '../../features/auth/data/repositories/auth_repository.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/data/services/auth_local_service.dart';
import '../../features/auth/data/strategies/oauth_strategy_factory.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/auth/presentation/cubit/forgot_password_cubit.dart';
import '../../features/child/data/remote/child_remote_data_source.dart';
import '../../features/child/data/repositories/child_repository.dart';
import '../../features/child/presentation/cubit/child_cubit.dart';
import '../../features/child/presentation/cubit/child_draft_cubit.dart';
import '../../features/drafts/data/remote/drafts_remote_data_source.dart';
import '../../features/drafts/data/repositories/drafts_repository.dart';
import '../../features/drafts/presentation/cubit/drafts_cubit.dart';
import '../../features/help_center/data/repositories/help_center_repository.dart';
import '../../features/help_center/presentation/cubit/help_center_cubit.dart';
import '../../features/home/data/remote/home_remote_data_source.dart';
import '../../features/home/data/repositories/home_repository.dart';
import '../../features/home/presentation/cubit/home_cubit.dart';
import '../../features/leaderboard/data/remote/rankings_remote_data_source.dart';
import '../../features/leaderboard/data/repositories/rankings_repository.dart';
import '../../features/leaderboard/presentation/cubit/rankings_cubit.dart';
import '../../features/language/data/remote/language_remote_data_source.dart';
import '../../features/language/data/repositories/language_repository.dart';
import '../../features/language/presentation/cubit/language_cubit.dart';
import '../../features/categories/data/remote/categories_remote_data_source.dart';
import '../../features/categories/data/repositories/categories_repository.dart';
import '../../features/categories/presentation/cubit/categories_cubit.dart';
import '../../features/levels/data/remote/levels_remote_data_source.dart';
import '../../features/levels/data/repositories/levels_repository.dart';
import '../../features/levels/presentation/cubit/levels_cubit.dart';
import '../../features/quiz/core/quiz_event_service.dart';
import '../../features/quiz/data/remote/quiz_remote_data_source.dart';
import '../../features/quiz/data/repositories/quiz_repository.dart';
import '../../features/quiz/presentation/cubit/quiz_cubit.dart';
import '../../features/profile/presentation/cubit/progress_reset_cubit.dart';
import '../../features/notification/data/remote/notification_remote_data_source.dart';
import '../../features/notification/data/repositories/notification_repository.dart';
import '../../features/notification/presentation/cubit/notification_cubit.dart';
import '../../features/onboarding/data/repositories/onboarding_repository.dart';
import '../../features/onboarding/presentation/cubit/onboarding_cubit.dart';
import '../bootstrap/app_startup_cubit.dart';
import '../../features/streak/data/remote/streak_remote_data_source.dart';
import '../../features/streak/data/repositories/streak_repository.dart';
import '../../features/streak/presentation/cubit/streak_cubit.dart';
import '../../features/support_tickets/data/remote/support_tickets_remote_data_source.dart';
import '../../features/support_tickets/data/repositories/support_tickets_repository.dart';
import '../../features/support_tickets/presentation/cubit/support_tickets_cubit.dart';
import '../../features/teams/data/remote/teams_remote_data_source.dart';
import '../../features/teams/data/repositories/teams_repository.dart';
import '../../features/teams/presentation/cubit/teams_cubit.dart';
import '../../features/upgrade/presentation/cubit/upgrade_cubit.dart';
import '../../features/user/data/remote/user_remote_data_source.dart';
import '../../features/user/data/repositories/user_repository.dart';
import '../../features/user/presentation/cubit/user_cubit.dart';

import 'app_info_service.dart';
import 'cache_service.dart';
import 'connectivity_service.dart';
import 'core_service_locator.dart';
import 'current_user_provider.dart';
import 'device_info_service.dart';
import 'notification_service.dart';
import 'permession_service.dart';
import 'remote_config_service.dart';
import 'share_service.dart';
import 'upgrade_service.dart';

class ServiceLocator {
  Future<void> init({
    required String baseUrl,
    required OAuthConfig oauthConfig,
    String? appType,
  }) async {
    sl.registerLazySingleton<CacheService>(() => CacheServiceImpl());
    sl.registerLazySingleton<DeviceInfoService>(() => DeviceInfoServiceImpl());
    sl.registerLazySingleton<AppInfoService>(() => AppInfoServiceImpl());
    sl.registerLazySingleton<PermissionService>(() => PermissionServiceImpl());
    sl.registerLazySingleton<ShareService>(() => ShareServiceImpl());
    sl.registerLazySingleton<NotificationService>(
      () => NotificationService(permissionService: sl()),
    );

    sl.registerLazySingleton<RemoteConfigService>(
      () => RemoteConfigServiceImpl(),
    );
    sl.registerLazySingleton<UpgradeService>(
      () => UpgradeServiceImpl(remoteConfig: sl()),
    );
    sl.registerFactory<UpgradeCubit>(
      () => UpgradeCubit(upgradeService: sl()),
    );

    sl.registerLazySingleton<AppEndpoint>(() => AppEndpoint(baseUrl: baseUrl));
    sl.registerLazySingleton<NetworkService>(
      () => NetworkServiceImpl(
        onLogout: () => sl<AuthEventService>().notify(AuthEvent.loggedOut),
        appType: appType,
      ),
    );

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
    sl.registerFactory<ForgotPasswordCubit>(
      () => ForgotPasswordCubit(repository: sl()),
    );

    sl.registerLazySingleton<UserRemoteDataSource>(
      () => UserRemoteDataSourceImpl(networkService: sl(), endpoints: sl()),
    );
    sl.registerLazySingleton<UserRepository>(
      () => UserRepositoryImpl(remoteDataSource: sl(), cacheService: sl()),
    );
    sl.registerFactory<UserCubit>(
      () => UserCubit(userRepository: sl(), authEventService: sl()),
    );

    sl.registerLazySingleton<ChildRemoteDataSource>(
      () => ChildRemoteDataSourceImpl(networkService: sl(), endpoints: sl()),
    );
    sl.registerLazySingleton<ChildRepository>(
      () => ChildRepositoryImpl(remoteDataSource: sl()),
    );
    sl.registerFactory<ChildCubit>(() => ChildCubit(childRepository: sl()));
    sl.registerFactory<ChildDraftCubit>(() => ChildDraftCubit());

    sl.registerLazySingleton<OnboardingRepository>(
      () => OnboardingRepositoryImpl(cacheService: sl()),
    );
    sl.registerFactory<OnboardingCubit>(
      () => OnboardingCubit(onboardingRepository: sl()),
    );

    sl.registerFactory<AppStartupCubit>(
      () => AppStartupCubit(
        onboardingRepository: sl(),
        notificationService: sl(),
        cacheService: sl(),
        upgradeService: sl(),
      ),
    );

    sl.registerLazySingleton<LanguageRemoteDataSource>(
      () => LanguageRemoteDataSourceImpl(networkService: sl(), endpoints: sl()),
    );
    sl.registerLazySingleton<LanguageRepository>(
      () => LanguageRepositoryImpl(remoteDataSource: sl()),
    );
    sl.registerFactory<LanguageCubit>(
      () => LanguageCubit(
        repository: sl(),
        cacheService: sl(),
        eventBus: sl(),
      ),
    );

    sl.registerLazySingleton<NotificationRemoteDataSource>(
      () => NotificationRemoteDataSourceImpl(),
    );
    sl.registerLazySingleton<NotificationRepository>(
      () => NotificationRepositoryImpl(remoteDataSource: sl()),
    );
    sl.registerFactory<NotificationCubit>(
      () => NotificationCubit(notificationRepository: sl()),
    );

    sl.registerLazySingleton<HomeRemoteDataSource>(
      () => HomeRemoteDataSourceImpl(),
    );
    sl.registerLazySingleton<HomeRepository>(
      () => HomeRepositoryImpl(remoteDataSource: sl()),
    );
    sl.registerFactory<HomeCubit>(
      () => HomeCubit(homeRepository: sl(), eventBus: sl()),
    );

    sl.registerLazySingleton<HelpCenterRepository>(
      () => HelpCenterRepositoryImpl(ticketsRepository: sl()),
    );
    sl.registerFactory<HelpCenterCubit>(
      () => HelpCenterCubit(helpCenterRepository: sl()),
    );

    sl.registerLazySingleton<AppDatabase>(() => AppDatabase());
    sl.registerLazySingleton<CurrentUserProvider>(
      () => CurrentUserProvider(sl()),
    );
    sl.registerLazySingleton<OfflineContentDao>(
      () => OfflineContentDaoImpl(database: sl(), userProvider: sl()),
    );
    sl.registerLazySingleton<PendingAnswersDao>(
      () => PendingAnswersDaoImpl(database: sl(), userProvider: sl()),
    );
    sl.registerLazySingleton<ConnectivityService>(
      () => ConnectivityService(Connectivity()),
    );
    sl.registerLazySingleton<DownloadsRemoteDataSource>(
      () => DownloadsRemoteDataSourceImpl(
        networkService: sl(),
        endpoints: sl(),
        cacheService: sl(),
      ),
    );
    sl.registerLazySingleton<DownloadsRepository>(
      () => DownloadsRepositoryImpl(remote: sl(), contentDao: sl()),
    );
    sl.registerLazySingleton<OfflineSyncService>(
      () => OfflineSyncService(
        pendingDao: sl(),
        quizRemote: sl(),
        quizEventService: sl(),
        connectivityService: sl(),
        authEventService: sl(),
      ),
    );
    sl.registerFactory<DownloadsCubit>(() => DownloadsCubit(repository: sl()));
    sl.registerFactory<ConnectivityCubit>(() => ConnectivityCubit(sl()));

    sl.registerLazySingleton<CategoriesRemoteDataSource>(
      () =>
          CategoriesRemoteDataSourceImpl(networkService: sl(), endpoints: sl()),
    );
    sl.registerLazySingleton<CategoriesRepository>(
      () => CategoriesRepositoryImpl(remoteDataSource: sl(), contentDao: sl()),
    );
    sl.registerLazySingleton<CategoriesCubit>(
      () => CategoriesCubit(
        categoriesRepository: sl(),
        quizEventService: sl(),
        eventBus: sl(),
      ),
    );

    sl.registerLazySingleton<LevelsRemoteDataSource>(
      () => LevelsRemoteDataSourceImpl(networkService: sl(), endpoints: sl()),
    );
    sl.registerLazySingleton<LevelsRepository>(
      () => LevelsRepositoryImpl(remoteDataSource: sl(), contentDao: sl()),
    );
    sl.registerFactory<LevelsCubit>(
      () => LevelsCubit(levelsRepository: sl(), quizEventService: sl()),
    );

    sl.registerLazySingleton<EventBus>(() => EventBus());
    sl.registerLazySingleton<QuizEventService>(() => QuizEventService());
    sl.registerLazySingleton<QuizRemoteDataSource>(
      () => QuizRemoteDataSourceImpl(networkService: sl(), endpoints: sl()),
    );
    sl.registerLazySingleton<QuizRepository>(
      () => QuizRepositoryImpl(
        remoteDataSource: sl(),
        contentDao: sl(),
        pendingDao: sl(),
        userProvider: sl(),
      ),
    );
    sl.registerFactory<QuizCubit>(
      () => QuizCubit(
        quizRepository: sl(),
        quizEventService: sl(),
        supportTicketsRepository: sl(),
      ),
    );
    sl.registerFactory<ProgressResetCubit>(
      () => ProgressResetCubit(quizRepository: sl(), quizEventService: sl()),
    );

    sl.registerLazySingleton<DraftsRemoteDataSource>(
      () => DraftsRemoteDataSourceImpl(networkService: sl(), endpoints: sl()),
    );
    sl.registerLazySingleton<DraftsRepository>(
      () => DraftsRepositoryImpl(remoteDataSource: sl()),
    );
    sl.registerFactory<DraftsCubit>(() => DraftsCubit(repository: sl()));

    sl.registerLazySingleton<SupportTicketsRemoteDataSource>(
      () => SupportTicketsRemoteDataSourceImpl(
        networkService: sl(),
        endpoints: sl(),
      ),
    );
    sl.registerLazySingleton<SupportTicketsRepository>(
      () => SupportTicketsRepositoryImpl(remoteDataSource: sl()),
    );
    sl.registerFactory<SupportTicketsCubit>(
      () => SupportTicketsCubit(repository: sl()),
    );

    sl.registerLazySingleton<AvatarsRemoteDataSource>(
      () => AvatarsRemoteDataSourceImpl(networkService: sl(), endpoints: sl()),
    );
    sl.registerLazySingleton<AvatarsRepository>(
      () => AvatarsRepositoryImpl(remoteDataSource: sl()),
    );
    sl.registerFactory<AvatarsCubit>(
      () => AvatarsCubit(avatarsRepository: sl()),
    );

    sl.registerLazySingleton<TeamsRemoteDataSource>(
      () => TeamsRemoteDataSourceImpl(networkService: sl(), endpoints: sl()),
    );
    sl.registerLazySingleton<TeamsRepository>(
      () => TeamsRepositoryImpl(remoteDataSource: sl()),
    );
    sl.registerFactory<TeamsCubit>(() => TeamsCubit(repository: sl()));

    sl.registerLazySingleton<RankingsRemoteDataSource>(
      () => RankingsRemoteDataSourceImpl(networkService: sl(), endpoints: sl()),
    );
    sl.registerLazySingleton<RankingsRepository>(
      () => RankingsRepositoryImpl(remoteDataSource: sl()),
    );
    sl.registerFactory<RankingsCubit>(() => RankingsCubit(repository: sl()));

    sl.registerLazySingleton<StreakRemoteDataSource>(
      () => StreakRemoteDataSourceImpl(networkService: sl(), endpoints: sl()),
    );
    sl.registerLazySingleton<StreakRepository>(
      () => StreakRepositoryImpl(remoteDataSource: sl()),
    );
    sl.registerFactory<StreakCubit>(
      () => StreakCubit(streakRepository: sl(), quizEventService: sl()),
    );

  }

  Future<void> startOffline() async {
    await sl<AppDatabase>().database;
    await sl<ConnectivityService>().init();
    unawaited(sl<OfflineSyncService>().start());
  }
}
