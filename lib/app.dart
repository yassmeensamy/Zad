import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'core/bootstrap/app_startup_cubit.dart';
import 'core/navigation/app_router.dart';
import 'core/navigation/app_routes.dart';
import 'core/navigation/auth_gate.dart';
import 'core/navigation/deep_link_service.dart';
import 'core/services/connectivity_service.dart';
import 'core/services/core_service_locator.dart';
import 'features/auth/core/auth_event_service.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/offline/presentation/cubit/connectivity_cubit.dart';
import 'features/theme/presentation/cubit/theme_cubit.dart';
import 'features/user/presentation/cubit/user_cubit.dart';
import 'theme/theme.dart';

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
  );

  late final GoRouter _router = AppRouter.build(
    initialLocation: widget.initialLocation ?? AppRoutes.splash,
    gate: _gate,
    isOnline: () => sl<ConnectivityService>().isOnline,
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
      ),
    );
  }
}
