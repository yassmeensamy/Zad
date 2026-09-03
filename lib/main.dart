import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:my_app/firebase_options.dart';
import 'package:path_provider/path_provider.dart';
import 'package:requests_inspector/requests_inspector.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'app.dart';
import 'core/l10n/app_languages.dart';
import 'core/navigation/app_router.dart';
import 'core/navigation/deep_link_service.dart';
import 'core/navigation/deep_links.dart';
import 'core/services/core_service_locator.dart';
import 'core/services/remote_config_service.dart';
import 'core/services/service_locator.dart';
import 'features/auth/data/strategies/oauth_strategy_factory.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: kIsWeb
        ? HydratedStorageDirectory.web
        : HydratedStorageDirectory(
            (await getApplicationDocumentsDirectory()).path,
          ),
  );
  await Future.wait([
    dotenv.load(fileName: '.env'),
    EasyLocalization.ensureInitialized(),
    for (final code in AppLanguages.codes) initializeDateFormatting(code),
    Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform),
  ]);
  timeago.setLocaleMessages('ar', timeago.ArMessages());
  timeago.setLocaleMessages('ur', timeago.UrMessages());
  timeago.setLocaleMessages('id', timeago.IdMessages());

  final serviceLocator = ServiceLocator();
  await serviceLocator.init(
    baseUrl: dotenv.env['BASE_URL'] ?? '',
    oauthConfig: OAuthConfig(
      googleAndroidClientId: dotenv.env['GOOGLE_ANDROID_CLIENT_ID'] ?? '',
      googleIosClientId: dotenv.env['GOOGLE_IOS_CLIENT_ID'] ?? '',
      googleServerClientId: dotenv.env['GOOGLE_SERVER_CLIENT_ID'] ?? '',
      // Optional — only needed for Apple sign-in on Android/web. iOS works
      // without these.
      appleServiceId: dotenv.env['APPLE_SERVICE_ID'] ?? '',
      appleRedirectUri: dotenv.env['APPLE_REDIRECT_URI'],
    ),
  );
  await serviceLocator.startOffline();

  unawaited(sl<RemoteConfigService>().init());

  final deepLinks = DeepLinkService(resolver: DeepLinks.toLocation);
  final initialLink = await deepLinks.initialLocation();

  runApp(
    RequestsInspector(
      enabled: false,

      //showInspectorOn: ShowInspectorOn.Both,
      navigatorKey: AppRouter.rootNavigatorKey,
      child: EasyLocalization(
        supportedLocales: AppLanguages.locales,
        path: 'assets/translations',
        fallbackLocale: AppLanguages.fallback.locale,
        child: MyApp(deepLinks: deepLinks, initialLocation: initialLink),
      ),
    ),
  );
}
