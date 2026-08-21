import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'core/bootstrap/app_startup_cubit.dart';
import 'core/bootstrap/app_startup_state.dart';
import 'core/navigation/app_router.dart';
import 'core/navigation/app_routes.dart';
import 'core/navigation/auth_gate.dart';
import 'core/navigation/deep_link_service.dart';
import 'core/services/connectivity_service.dart';
import 'core/services/core_service_locator.dart';
import 'core/services/upgrade_service.dart';
import 'core/widgets/force_update_dialog.dart';
import 'features/auth/core/auth_event_service.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/offline/presentation/cubit/connectivity_cubit.dart';
import 'features/theme/presentation/cubit/theme_cubit.dart';
import 'features/user/presentation/cubit/user_cubit.dart';
import 'theme/theme.dart';

/// App-wide floor for text scaling.
///
/// **This is the single knob for "make the app's text bigger."** Raising it
/// lifts every screen at once — including the widgets that still hardcode a
/// `fontSize` rather than reading a [TextTheme] role, which a change to
/// `AppTextStyles` would miss.
///
/// It's a floor, not a multiplier: a user who has already raised their OS
/// text size keeps their larger setting rather than getting ours stacked on
/// top. Once the hardcoded sizes are migrated onto [TextTheme], move the
/// increase into the roles themselves and drop this back to 1.0.
///
/// Tuning reference — the app's two most common sizes are 13 (53 call sites)
/// and 11 (49 call sites), so judge any value against those:
///   1.05 → 13.7 / 11.6   invisible (under 1px)
///   1.15 → 14.9 / 12.7   barely perceptible
///   1.25 → 16.3 / 13.8   clearly larger, layouts still hold   ← current
///   1.35 → 17.6 / 14.9   strong; expect clipping on the dense screens
const double kMinTextScale = 1.07;

/// Ceiling for text scaling, so the dense grid and leaderboard screens stay
/// laid out at the top of the OS accessibility range.
const double kMaxTextScale = 1.6;

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.deepLinks, this.initialLocation});

  final DeepLinkService deepLinks;
  final String? initialLocation;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(
          create: (_) => AuthCubit(
            repository: sl(),
            authEventService: sl<AuthEventService>(),
          )..init(),
          lazy: false,
        ),
        BlocProvider<UserCubit>(create: (_) => sl<UserCubit>(), lazy: false),
        BlocProvider<ThemeCubit>(create: (_) => ThemeCubit(), lazy: false),
        BlocProvider<ConnectivityCubit>(
          create: (_) => sl<ConnectivityCubit>(),
          lazy: false,
        ),
        BlocProvider<AppStartupCubit>(
          create: (_) => sl<AppStartupCubit>(),
          lazy: false,
        ),
      ],
      child: _AppView(deepLinks: deepLinks, initialLocation: initialLocation),
    );
  }
}

class _AppView extends StatefulWidget {
  const _AppView({required this.deepLinks, this.initialLocation});

  final DeepLinkService deepLinks;
  final String? initialLocation;

  @override
  State<_AppView> createState() => _AppViewState();
}

class _AppViewState extends State<_AppView> {
  late final AuthGate _gate = AuthGate(
    auth: context.read<AuthCubit>(),
    user: context.read<UserCubit>(),
    startup: context.read<AppStartupCubit>(),
    connectivity: sl<ConnectivityService>(),
  );

  late final GoRouter _router = AppRouter.build(
    initialLocation: widget.initialLocation ?? AppRoutes.splash,
    gate: _gate,
  );

  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    context.read<AppStartupCubit>().init(context.locale.languageCode);
    widget.deepLinks.start();
    widget.deepLinks.locations.listen(_router.go);
  }

  @override
  void dispose() {
    _gate.dispose();
    widget.deepLinks.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, themeMode) => MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'Zaad | زاد',
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: themeMode,
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        routerConfig: _router,
        // Render the blocking force-update prompt as a persistent overlay above
        // the router's Navigator. A widget (not an imperative showDialog) so
        // go_router page changes — e.g. the auth guard redirecting away from the
        // splash — can't tear it down once it's shown.
        builder: (context, child) {
          final mediaQuery = MediaQuery.of(context);
          // The app's one and only source of text scaling. Everything below
          // inherits it — Text, ResponsiveText, and every framework widget —
          // so no widget needs to pass a `textScaler` of its own.
          return MediaQuery(
            data: mediaQuery.copyWith(
              textScaler: mediaQuery.textScaler.clamp(
                minScaleFactor: kMinTextScale,
                maxScaleFactor: kMaxTextScale,
              ),
            ),
            child: BlocBuilder<AppStartupCubit, AppStartupState>(
              buildWhen: (a, b) =>
                  a.forceUpdateRequired != b.forceUpdateRequired,
              builder: (context, state) {
                final content = child ?? const SizedBox.shrink();
                if (!state.forceUpdateRequired) return content;
                final upgrade = sl<UpgradeService>();
                final info = upgrade.info;
                return Stack(
                  children: [
                    content,
                    Positioned.fill(
                      child: AppUpdateDialog.overlay(
                        onUpdate: upgrade.openStore,
                        currentVersion: info.installedVersion,
                        newVersion: info.availableVersion,
                        releaseNotes: info.releaseNotes,
                      ),
                    ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }
}
