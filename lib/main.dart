import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:requests_inspector/requests_inspector.dart';

import 'core/navigation/app_router.dart';
import 'core/services/core_service_locator.dart';
import 'core/services/service_locator.dart';
import 'features/auth/core/auth_event_service.dart';
import 'features/auth/data/strategies/oauth_strategy_factory.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/user/presentation/cubit/user_cubit.dart';
import 'theme/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  await ServiceLocator().init(
    baseUrl: 'http://178.104.159.239:8000/',
    oauthConfig: const OAuthConfig(
      googleAndroidClientId: '',
      googleIosClientId: '',
      googleServerClientId: '',
    ),
  );

  runApp(
    RequestsInspector(
      enabled: true,
      showInspectorOn: ShowInspectorOn.Both,
      child: EasyLocalization(
        supportedLocales: const [Locale('en'), Locale('ar')],
        path: 'assets/translations',
        fallbackLocale: const Locale('en'),
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(
          create: (context) {
            final cubit = AuthCubit(
              repository: sl(),
              authEventService: sl<AuthEventService>(),
            )..init();

            return cubit;
          },
          lazy: false,
        ),
        BlocProvider<UserCubit>(
          create: (_) => sl<UserCubit>(),
          lazy: false,
        ),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'Zad',
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.system,
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        routerConfig: AppRouter.router,
      ),
    );
  }
}
