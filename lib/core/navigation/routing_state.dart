/// The auth/startup phase the router gates on.
enum AuthPhase { unknown, transitioning, onboarding, signedOut, signedIn }

/// Every input the router's redirect is allowed to read, captured as one
/// immutable value.
///
/// This exists so the refresh trigger and the redirect decision cannot drift
/// apart: `AuthGate` builds this once, `RouterRefresh` compares consecutive
/// snapshots to decide whether to notify, and `authGuard` reads the same
/// snapshot to decide where to send the user. Adding a routing input means
/// adding a field here, which automatically makes it a refresh trigger too.
///
/// Anything not in this class must not influence a redirect.
class RoutingState {
  const RoutingState({
    required this.phase,
    required this.isGuest,
    required this.isChild,
    required this.needsProfileSetup,
    required this.isOnline,
  });

  final AuthPhase phase;

  /// Anonymous user. Source of truth is `UserModel.isAnonymous` from /me.
  final bool isGuest;

  /// Child-role user. Source of truth is `UserModel.role` from /me.
  final bool isChild;

  /// Signed-in, non-guest, non-child user who hasn't finished the profile flow.
  final bool needsProfileSetup;

  /// Picks between the online and offline home destinations, which are
  /// different routes — so it is a routing input, not just a UI concern.
  final bool isOnline;

  @override
  String toString() =>
      'RoutingState($phase, guest=$isGuest, child=$isChild, '
      'needsSetup=$needsProfileSetup, online=$isOnline)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RoutingState &&
          other.phase == phase &&
          other.isGuest == isGuest &&
          other.isChild == isChild &&
          other.needsProfileSetup == needsProfileSetup &&
          other.isOnline == isOnline;

  @override
  int get hashCode =>
      Object.hash(phase, isGuest, isChild, needsProfileSetup, isOnline);
}
