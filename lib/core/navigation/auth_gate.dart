import 'package:flutter/foundation.dart';
import 'package:my_app/core/utils/logger.dart';

import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/user/presentation/cubit/user_cubit.dart';
import '../../features/user/presentation/cubit/user_state.dart';
import '../bootstrap/app_startup_cubit.dart';
import '../bootstrap/app_startup_state.dart';
import 'auth_guard.dart';
import 'stream_listenable.dart';

class AuthGate {
  AuthGate({
    required AuthCubit auth,
    required UserCubit user,
    required AppStartupCubit startup,
  }) : _auth = auth,
       _user = user,
       _startup = startup;

  final AuthCubit _auth;
  final UserCubit _user;
  final AppStartupCubit _startup;

  late final List<StreamListenable> _sources = [
    StreamListenable(_auth.stream),
    StreamListenable(_user.stream),
    StreamListenable(_startup.stream),
  ];

  late final Listenable listenable = Listenable.merge(_sources);

  AuthPhase get phase {
    logger.debug('AuthGate.phase: startup=${_startup.state.status}, auth=${_auth.state.status}, user=${_user.state.status}');
    final startup = _startup.state;
    if (startup.isInitial || startup.isLoading) return AuthPhase.unknown;
    // Force update is blocking: keep the router pinned to the splash route so
    // the persistent update overlay sits over the splash and the guard never
    // redirects on to home/login behind it.
    if (startup.forceUpdateRequired) return AuthPhase.unknown;
    if (startup.isError) return AuthPhase.signedOut;
    if (startup.needsOnboarding) return AuthPhase.onboarding;

    final auth = _auth.state;
    if (auth.isInitial) return AuthPhase.unknown;
    if (auth.isLoading) return AuthPhase.transitioning;
    if (auth.isError || auth.isNotLoggedIn) return AuthPhase.signedOut;

    final user = _user.state;
    if (user.isInitial) return AuthPhase.unknown;
    if (user.isLoading) return AuthPhase.transitioning;
    if (user.isError) return AuthPhase.signedOut;

    return AuthPhase.signedIn;
  }

  /// Whether the signed-in user is an anonymous guest. Source of truth is
  /// [UserModel.isAnonymous] from /me, not auth state.
  bool get isGuest => _user.state.user?.isAnonymous ?? false;

  void dispose() {
    for (final source in _sources) {
      source.dispose();
    }
  }
}
