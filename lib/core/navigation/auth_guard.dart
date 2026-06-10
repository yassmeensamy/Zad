import 'package:go_router/go_router.dart';

enum AuthPhase { unknown, transitioning, onboarding, signedOut, signedIn }

class GuardRoutes {
  const GuardRoutes({
    required this.splash,
    required this.signIn,
    required this.home,
    required this.onboarding,
    String? offlineHome,
    this.publicRoutes = const {},
  }) : offlineHome = offlineHome ?? home;

  final String splash;
  final String signIn;
  final String home;
  final String offlineHome;
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
        if (loc == routes.splash || loc == routes.signIn) {
          final home = isOnline() ? routes.home : routes.offlineHome;
          return intended ?? home;
        }
        return null;
    }
  };
}

bool _alwaysOnline() => true;
