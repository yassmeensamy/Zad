import 'package:my_app/core/utils/logger.dart';

import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/user/presentation/cubit/user_cubit.dart';
import '../../features/user/presentation/cubit/user_state.dart';
import '../bootstrap/app_startup_cubit.dart';
import '../bootstrap/app_startup_state.dart';
import '../services/connectivity_service.dart';
import 'router_refresh.dart';
import 'routing_state.dart';

/// Projects the app's auth/startup/connectivity state into the single
/// [RoutingState] the router is allowed to gate on.
///
/// [routingState] is the one source of truth: [refresh] snapshots it to decide
/// whether the router needs to re-evaluate, and `authGuard` reads it to decide
/// where the user goes. Because both go through this one getter, a routing
/// input can never exist on one side and be missing from the other.
class AuthGate {
  AuthGate({
    required AuthCubit auth,
    required UserCubit user,
    required AppStartupCubit startup,
    required ConnectivityService connectivity,
  }) : _auth = auth,
       _user = user,
       _startup = startup,
       _connectivity = connectivity;

  final AuthCubit _auth;
  final UserCubit _user;
  final AppStartupCubit _startup;
  final ConnectivityService _connectivity;

  /// The router's `refreshListenable`. Only fires when [routingState] changes.
  late final RouterRefresh refresh = RouterRefresh(
    readSnapshot: () => routingState,
    sources: [
      _auth.stream,
      _user.stream,
      _startup.stream,
      // Connectivity picks between two *different* home routes, so it is a
      // routing input and must be able to trigger a re-evaluation. The stream
      // already emits only on a real online/offline change.
      _connectivity.onStatusChanged,
    ],
  );

  RoutingState get routingState => RoutingState(
    phase: _phase,
    isGuest: _user.state.user?.isAnonymous ?? false,
    isChild: _user.state.user?.isChild ?? false,
    needsProfileSetup: _needsProfileSetup,
    isOnline: _connectivity.isOnline,
  );

  AuthPhase get _phase {
    logger.debug(
      'AuthGate.phase: startup=${_startup.state.status}, '
      'auth=${_auth.state.status}, user=${_user.state.status}',
    );
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

  /// Whether the signed-in (non-guest, non-child) user still needs to finish
  /// the onboarding profile flow. Returning users with a complete profile go
  /// straight home; only new / unfinished accounts are sent to role-select.
  bool get _needsProfileSetup {
    final user = _user.state.user;
    if (user == null || user.isAnonymous || user.isChild) return false;
    return !user.isProfileComplete;
  }

  void dispose() => refresh.dispose();
}
