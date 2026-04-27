import 'dart:async';

import 'auth_status.dart';

class AuthEventService {
  final _controller = StreamController<AuthEvent>.broadcast();
  final List<Future<void> Function()> _preLogoutCallbacks = [];

  Stream<AuthEvent> get onAuthEvent => _controller.stream;

  void registerPreLogoutCallback(Future<void> Function() callback) {
    _preLogoutCallbacks.add(callback);
  }

  void removePreLogoutCallback(Future<void> Function() callback) {
    _preLogoutCallbacks.remove(callback);
  }

  Future<void> runPreLogoutCallbacks() async {
    await Future.wait(_preLogoutCallbacks.map((cb) => cb()));
  }

  void notify(AuthEvent event) {
    if (!_controller.isClosed) {
      _controller.add(event);
    }
  }

  void dispose() {
    _preLogoutCallbacks.clear();
    _controller.close();
  }
}
