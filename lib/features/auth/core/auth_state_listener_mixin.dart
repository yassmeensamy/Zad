import 'dart:async';

import 'auth_event_service.dart';
import 'auth_status.dart';

mixin AuthStateListenerMixin {
  AuthEventService get authEventService;

  StreamSubscription<AuthEvent>? _authSubscription;

  void initAuthListener() {
    _authSubscription?.cancel();
    _authSubscription = authEventService.onAuthEvent.listen((event) {
      switch (event) {
        case AuthEvent.loggedIn:
          onAuthenticated();
        case AuthEvent.userReady:
          onUserReady();
        case AuthEvent.loggedOut:
          onUnauthenticated();
        case AuthEvent.guest:
          onUnauthenticated();
      }
    });
  }

  void onAuthenticated() {}

  void onUnauthenticated() {}

  void onUserReady() {}

  /// Must be called in [close()] of any Cubit using this mixin.
  void disposeAuthListener() {
    _authSubscription?.cancel();
  }
}
