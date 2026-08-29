import 'package:go_router/go_router.dart';

import 'routing_state.dart';

export 'routing_state.dart' show AuthPhase, RoutingState;

class GuardRoutes {
  const GuardRoutes({
    required this.splash,
    required this.signIn,
    required this.home,
    required this.onboarding,
    String? signedOutLanding,
    String? offlineHome,
    String? guestHome,
    String? childHome,
    String? profileSetup,
    this.setupFlow = const {},
    this.selfExitRoutes = const {},
    this.guestBlocked = const {},
    this.childBlocked = const {},
    this.publicRoutes = const {},
  }) : signedOutLanding = signedOutLanding ?? signIn,
       offlineHome = offlineHome ?? home,
       guestHome = guestHome ?? home,
       childHome = childHome ?? home,
       profileSetup = profileSetup ?? home;

  final String splash;
  final String signIn;

  /// Where a signed-out user is *sent* when they land anywhere they may not be.
  /// Defaults to [signIn]; point it at registration to make sign-up the front
  /// door while [signIn] stays reachable for returning users. Must be a route
  /// a signed-out user is allowed to sit on — [signIn] itself or a member of
  /// [publicRoutes] — or the guard would redirect it straight back to itself.
  final String signedOutLanding;
  final String home;
  final String offlineHome;

  /// Entry of the onboarding profile flow (role-select). A signed-in user with
  /// an incomplete profile is redirected here until they finish setup.
  final String profileSetup;

  /// Onboarding-only routes (role-select, complete-profile). A user whose
  /// profile is already complete is redirected out of these to [home]; a user
  /// whose profile is incomplete may stay here while finishing setup.
  final Set<String> setupFlow;

  /// Subset of [setupFlow] whose screens navigate themselves out once setup
  /// completes, so the guard must *not* bounce them to [home] the moment the
  /// profile turns complete. Without this, the very save that finishes the
  /// profile also tears the screen down mid-frame, killing any confirmation
  /// the screen wanted to show first. These screens own their own exit.
  final Set<String> selfExitRoutes;

  /// Where a guest (anonymous) user lands instead of [home]; guests skip the
  /// parent/child selection flow and go straight here.
  final String guestHome;

  /// Routes a guest may not open (e.g. children management). Hitting one
  /// redirects the guest back to [guestHome].
  final Set<String> guestBlocked;

  /// Where a child-role user lands instead of [home]; children skip the
  /// parent/child selection flow and go straight here.
  final String childHome;

  /// Routes a child may not open (e.g. the profile-selection flow). Hitting
  /// one redirects the child back to [childHome].
  final Set<String> childBlocked;
  final String onboarding;

  final Set<String> publicRoutes;

  bool isEntry(String location) {
    final path = Uri.parse(location).path;
    return path == splash ||
        path == signIn ||
        path == signedOutLanding ||
        path == onboarding;
  }
}

/// Builds the top-level redirect.
///
/// [readState] is the *only* source of routing inputs. It is the same function
/// the router's `refreshListenable` snapshots, so the guard can never depend on
/// something that would not have triggered a re-evaluation. The callback itself
/// holds no mutable state — the intended destination travels in the URL as
/// `?from=`, which keeps the redirect a pure function of (location, snapshot)
/// even when go_router re-invokes it several times in one redirect chain.
GoRouterRedirect authGuard({
  required GuardRoutes routes,
  required RoutingState Function() readState,
  String fromParam = 'from',
}) {
  return (context, state) {
    final routing = readState();
    final loc = state.matchedLocation;

    final existingFrom = state.uri.queryParameters[fromParam];
    final intended = (existingFrom != null && !routes.isEntry(existingFrom))
        ? existingFrom
        : (routes.isEntry(state.uri.toString()) ? null : state.uri.toString());
    final suffix = intended == null
        ? ''
        : '?$fromParam=${Uri.encodeComponent(intended)}';

    switch (routing.phase) {
      case AuthPhase.unknown:
        return loc == routes.splash ? null : '${routes.splash}$suffix';
      case AuthPhase.transitioning:
        return null;
      case AuthPhase.onboarding:
        return loc == routes.onboarding ? null : routes.onboarding;
      case AuthPhase.signedOut:
        if (loc == routes.signIn || routes.publicRoutes.contains(loc)) {
          return null;
        }
        return '${routes.signedOutLanding}$suffix';
      case AuthPhase.signedIn:
        if (routing.isGuest) {
          // Guests skip the parent/child flow and cannot open child screens.
          if (routes.guestBlocked.contains(loc)) return routes.guestHome;
          if (loc == routes.splash || loc == routes.signIn) {
            final wantsBlocked =
                intended != null &&
                routes.guestBlocked.contains(Uri.parse(intended).path);
            return (intended == null || wantsBlocked)
                ? routes.guestHome
                : intended;
          }
          return null;
        }
        if (routing.isChild) {
          // Children skip the parent/child selection flow and land on their
          // own home instead of the profile-selection screen.
          if (routes.childBlocked.contains(loc)) return routes.childHome;
          if (loc == routes.splash || loc == routes.signIn) {
            final wantsBlocked =
                intended != null &&
                routes.childBlocked.contains(Uri.parse(intended).path);
            return (intended == null || wantsBlocked)
                ? routes.childHome
                : intended;
          }
          return null;
        }
        if (routing.needsProfileSetup) {
          // New / unfinished accounts must complete the profile flow first.
          return routes.setupFlow.contains(loc) ? null : routes.profileSetup;
        }
        // Profile complete: never strand a returning user in the onboarding
        // flow — bounce them out of the entry/setup routes to home. Routes in
        // [selfExitRoutes] are exempt: they are the screens that *cause* the
        // profile to become complete and drive their own exit afterwards.
        if (loc == routes.splash ||
            loc == routes.signIn ||
            (routes.setupFlow.contains(loc) &&
                !routes.selfExitRoutes.contains(loc))) {
          final home = routing.isOnline ? routes.home : routes.offlineHome;
          return intended ?? home;
        }
        return null;
    }
  };
}
