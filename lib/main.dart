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
    initializeDateFormatting('ar'),
    Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform),
  ]);
  timeago.setLocaleMessages('ar', timeago.ArMessages());

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

  // Warm Remote Config so the splash force-update check reads fresh min-version
  // values — but NEVER await it here. The Android native splash stays up until
  // Flutter renders its first frame, which only happens after `runApp`, so any
  // network call awaited above it holds the launch screen hostage. Awaiting
  // `fetchAndActivate` used to strand Play-signed builds on the native splash
  // indefinitely. The force-update gate awaits `RemoteConfigService.ready`
  // (bounded) after the first frame instead.
  unawaited(sl<RemoteConfigService>().init());

  final deepLinks = DeepLinkService(resolver: DeepLinks.toLocation);
  final initialLink = await deepLinks.initialLocation();

  runApp(
    RequestsInspector(
      enabled: false,
      //!kReleaseMode,
      showInspectorOn: ShowInspectorOn.Both,
      child: EasyLocalization(
        supportedLocales: const [Locale('en'), Locale('ar')],
        path: 'assets/translations',
        fallbackLocale: const Locale('en'),
        child: MyApp(deepLinks: deepLinks, initialLocation: initialLink),
      ),
    ),
  );
}
