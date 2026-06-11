import 'package:go_router/go_router.dart';

enum AuthPhase { unknown, transitioning, onboarding, signedOut, signedIn }

class GuardRoutes {
  const GuardRoutes({
    required this.splash,
    required this.signIn,
    required this.home,
    required this.onboarding,
    String? offlineHome,
    String? guestHome,
    this.guestBlocked = const {},
    this.publicRoutes = const {},
  }) : offlineHome = offlineHome ?? home,
       guestHome = guestHome ?? home;

  final String splash;
  final String signIn;
  final String home;
  final String offlineHome;

  /// Where a guest (anonymous) user lands instead of [home]; guests skip the
  /// parent/child selection flow and go straight here.
  final String guestHome;

  /// Routes a guest may not open (e.g. children management). Hitting one
  /// redirects the guest back to [guestHome].
  final Set<String> guestBlocked;
  final String onboarding;

  final Set<String> publicRoutes;

  bool isEntry(String location) {
    final path = Uri.parse(location).path;
    return path == splash || path == signIn || path == onboarding;
  }
}

GoRouterRedirect authGuard({
  required GuardRoutes routes,
  required AuthPhase Function() phase,
  bool Function() isOnline = _alwaysOnline,
  bool Function() isGuest = _notGuest,
  String fromParam = 'from',
}) {
  return (context, state) {
    final loc = state.matchedLocation;

    final existingFrom = state.uri.queryParameters[fromParam];
    final intended = (existingFrom != null && !routes.isEntry(existingFrom))
        ? existingFrom
        : (routes.isEntry(state.uri.toString()) ? null : state.uri.toString());
    final suffix =
        intended == null ? '' : '?$fromParam=${Uri.encodeComponent(intended)}';

    switch (phase()) {
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
        return '${routes.signIn}$suffix';
      case AuthPhase.signedIn:
        if (isGuest()) {
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
        if (loc == routes.splash || loc == routes.signIn) {
          final home = isOnline() ? routes.home : routes.offlineHome;
          return intended ?? home;
        }
        return null;
    }
  };
}

bool _alwaysOnline() => true;

bool _notGuest() => false;
