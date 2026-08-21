import 'dart:async';

import 'package:flutter/foundation.dart';

import 'routing_state.dart';

/// The router's `refreshListenable`, gated on a [RoutingState] snapshot.
///
/// It subscribes to the same sources as before, but notifies only when the
/// routing-relevant projection of those sources actually changed. The previous
/// implementation forwarded every emit, so unrelated state — a profile field
/// update, a password change, an avatar upload, the post-quiz /me re-read —
/// re-parsed the route information and rebuilt the whole page stack.
///
/// [readSnapshot] must be the same function the redirect reads from, so the
/// trigger and the decision can never disagree about what routing depends on.
class RouterRefresh extends ChangeNotifier {
  RouterRefresh({
    required RoutingState Function() readSnapshot,
    required List<Stream<dynamic>> sources,
  }) : _readSnapshot = readSnapshot,
       _lastSnapshot = readSnapshot() {
    _subscriptions = sources
        .map((source) => source.listen((_) => _notifyIfSnapshotChanged()))
        .toList();
  }

  final RoutingState Function() _readSnapshot;

  late final List<StreamSubscription<dynamic>> _subscriptions;
  RoutingState _lastSnapshot;

  /// The snapshot the last notification was based on. Exposed for debugging.
  RoutingState get snapshot => _lastSnapshot;

  void _notifyIfSnapshotChanged() {
    final next = _readSnapshot();
    if (next == _lastSnapshot) return;
    _lastSnapshot = next;
    notifyListeners();
  }

  @override
  void dispose() {
    for (final subscription in _subscriptions) {
      unawaited(subscription.cancel());
    }
    super.dispose();
  }
}
