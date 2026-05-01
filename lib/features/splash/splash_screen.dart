import 'dart:async';

import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/navigation/app_routes.dart';
import '../../core/services/core_service_locator.dart';
import '../../core/widgets/responsive_text.dart';
import '../../theme/theme.dart';
import '../auth/presentation/cubit/auth_cubit.dart';
import '../auth/presentation/cubit/auth_state.dart';
import '../user/presentation/cubit/user_cubit.dart';
import '../user/presentation/cubit/user_state.dart';
import 'presentation/cubit/splash_cubit.dart';
import 'presentation/cubit/splash_state.dart';
import 'widgets/desert_background.dart';
import 'widgets/zaad_brand.dart';
import 'widgets/zaad_logo_mark.dart';

class ZaadSplashScreen extends StatelessWidget {
  const ZaadSplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<SplashCubit>()..init(context.locale.languageCode),
      child: const _SplashView(),
    );
  }
}

class _SplashView extends StatefulWidget {
  const _SplashView();

  @override
  State<_SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<_SplashView>
    with TickerProviderStateMixin {
  late final AnimationController _intro = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  )..forward();

  late final AnimationController _hintPulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  );

  bool _navigating = false;

  @override
  void initState() {
    super.initState();
    Timer(const Duration(milliseconds: 3000), () {
      if (mounted) _hintPulse.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _intro.dispose();
    _hintPulse.dispose();
    super.dispose();
  }

  void _go(String route) {
    if (_navigating || !mounted) return;
    _navigating = true;
    context.go(route);
  }

  void _navigateWhenReady() {
    if (_navigating) return;
    final splash = context.read<SplashCubit>().state;
    final destination = splash.destination;
    if (destination == null) return;

    if (destination == SplashDestination.onboarding) {
      _go(AppRoutes.onboarding);
      return;
    }

    // authCheck path: wait for AuthCubit to resolve.
    final auth = context.read<AuthCubit>().state;
    if (auth.isInitial || auth.isLoading) return;
    if (auth.isError || auth.isNotLoggedIn) {
      _go(AppRoutes.login);
      return;
    }
    if (auth.isLoggedIn) {
      // Profile is auto-fetched via AuthEventService → UserCubit. Wait for
      // it to resolve before routing home so the home screen has data.
      final user = context.read<UserCubit>().state;
      if (user.isInitial || user.isLoading) return;
      if (user.isError) {
        _go(AppRoutes.login);
        return;
      }
      if (user.isSuccess) _go(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Scaffold(
      body: MultiBlocListener(
        listeners: [
          BlocListener<SplashCubit, SplashStates>(
            listenWhen: (a, b) => a.status != b.status,
            listener: (_, _) => _navigateWhenReady(),
          ),
          BlocListener<AuthCubit, AuthState>(
            listenWhen: (a, b) => a.status != b.status,
            listener: (_, _) => _navigateWhenReady(),
          ),
          BlocListener<UserCubit, UserState>(
            listenWhen: (a, b) => a.status != b.status,
            listener: (_, _) => _navigateWhenReady(),
          ),
        ],
        child: DesertBackground(
          child: SafeArea(
            child: Stack(
              children: [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ZaadLogoMark(animation: _intro),
                        const SizedBox(height: 32),
                        _StaggeredFade(
                          controller: _intro,
                          start: 0.42,
                          end: 0.6,
                          child: const ZaadBrand(),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 80,
                  child: _StaggeredFade(
                    controller: _intro,
                    start: 0.78,
                    end: 1,
                    targetOpacity: 0.65,
                    child: ResponsiveText(
                      'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                      textAlign: TextAlign.center,
                      textDirection: TextDirection.rtl,
                      style: TextStyle(
                        fontSize: 18,
                        color: colors.textArabic,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 36,
                  child: AnimatedBuilder(
                    animation: Listenable.merge([_intro, _hintPulse]),
                    builder: (context, _) {
                      final introT =
                          ((_intro.value - 0.9) / 0.1).clamp(0.0, 1.0);
                      final pulse = 0.4 + 0.4 * _hintPulse.value;
                      final opacity = introT * (introT < 1 ? 0.55 : pulse);
                      return Opacity(
                        opacity: opacity,
                        child: ResponsiveText(
                          'LOADING...',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 3,
                            color: colors.textArabic,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Drives a child between opacity 0 (with a small upward translation) and
/// [targetOpacity] across [start]..[end] of the supplied controller's value.
class _StaggeredFade extends StatelessWidget {
  const _StaggeredFade({
    required this.controller,
    required this.start,
    required this.end,
    required this.child,
    this.targetOpacity = 1,
  });

  final AnimationController controller;
  final double start;
  final double end;
  final Widget child;
  final double targetOpacity;
  static const double _translateY = 8;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final raw = ((controller.value - start) / (end - start)).clamp(0.0, 1.0);
        final eased = Curves.easeOutCubic.transform(raw);
        return Opacity(
          opacity: eased * targetOpacity,
          child: Transform.translate(
            offset: Offset(0, _translateY * (1 - eased)),
            child: child,
          ),
        );
      },
    );
  }
}
