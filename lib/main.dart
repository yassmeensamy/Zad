import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:my_app/firebase_options.dart';
import 'package:requests_inspector/requests_inspector.dart';
import 'package:timeago/timeago.dart' as timeago;

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
  await dotenv.load(fileName: '.env');
  await EasyLocalization.ensureInitialized();
  await initializeDateFormatting('ar');
  timeago.setLocaleMessages('ar', timeago.ArMessages());
    Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await ServiceLocator().init(
    baseUrl: dotenv.env['BASE_URL'] ?? '',
    oauthConfig: OAuthConfig(
      googleAndroidClientId: dotenv.env['GOOGLE_ANDROID_CLIENT_ID'] ?? '',
      googleIosClientId: dotenv.env['GOOGLE_IOS_CLIENT_ID'] ?? '',
      googleServerClientId: dotenv.env['GOOGLE_SERVER_CLIENT_ID'] ?? '',
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
