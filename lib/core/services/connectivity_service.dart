import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

import '../utils/logger.dart';

/// Tracks device connectivity and exposes a de-duplicated online/offline
/// stream. This drives the offline UI banner and the sync trigger only — the
/// actual data fallback decision stays keyed on the real `DioException` outcome
/// (see [isConnectivityError]), which is correct even behind captive portals
/// where the interface reports "connected" but no internet is reachable.
class ConnectivityService {
  ConnectivityService(this._connectivity);

  final Connectivity _connectivity;
  final StreamController<bool> _controller = StreamController<bool>.broadcast();
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  bool _isOnline = true;
  bool get isOnline => _isOnline;

  /// Emits only on a real change of online/offline state.
  Stream<bool> get onStatusChanged => _controller.stream;

  Future<void> init() async {
    _isOnline = _resultsMeanOnline(await _connectivity.checkConnectivity());
    _subscription = _connectivity.onConnectivityChanged.listen((results) {
      final online = _resultsMeanOnline(results);
      if (online != _isOnline) {
        _isOnline = online;
        logger.network('Connectivity changed: ${online ? 'online' : 'offline'}');
        _controller.add(online);
      }
    });
  }

  bool _resultsMeanOnline(List<ConnectivityResult> results) =>
      results.isNotEmpty && !results.contains(ConnectivityResult.none);

  Future<void> dispose() async {
    await _subscription?.cancel();
    await _controller.close();
  }
}
