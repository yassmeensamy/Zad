import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';

import 'deep_links.dart';

/// Receives incoming deep links via [AppLinks] and routes them through
/// go_router.
///
/// We use the `app_links` plugin rather than Flutter's built-in deep linking
/// because the built-in handler does **not** forward custom URL schemes
/// (`zad://…`) to the router. On iOS the scene-lifecycle URL events are also
/// bridged to the application delegate in `SceneDelegate.swift` so app_links
/// receives them at all.
///
/// Links can arrive before the splash/auth flow finishes (cold start) or after
/// (warm). Early links are buffered in [_pending] and applied by the splash via
/// [consumePending]; once [isAppReady] is set, links navigate immediately.
class DeepLinkHandler {
  DeepLinkHandler._();

  static final AppLinks _appLinks = AppLinks();
  static StreamSubscription<Uri>? _sub;
  static GoRouter? _router;

  static String? _pending;

  /// Set by the splash once it has routed to its destination. After that,
  /// incoming links navigate immediately instead of being buffered.
  static bool isAppReady = false;

  /// Subscribes to incoming links and reads the launch link. **Call before
  /// `runApp`** so an early cold-start link (delivered via the stream on iOS)
  /// is not missed.
  static Future<void> init() async {
    _sub ??= _appLinks.uriLinkStream.listen(_onLink);
    final initial = await _appLinks.getInitialLink();
    debugPrint('[deeplink] init getInitialLink=$initial');
    if (initial != null) _onLink(initial);
  }

  /// Supplies the router once it exists (after `runApp`).
  static void bind(GoRouter router) => _router = router;

  static void _onLink(Uri uri) {
    final location = DeepLinks.toLocation(uri);
    debugPrint('[deeplink] onLink uri=$uri -> $location (ready=$isAppReady)');
    if (location == null) return;
    if (isAppReady && _router != null) {
      _router!.go(location);
    } else {
      // Arrived during startup — let the splash apply it once auth resolves.
      _pending = location;
    }
  }

  /// Returns and clears a buffered deep-link location, if any.
  static String? consumePending() {
    final location = _pending;
    _pending = null;
    debugPrint('[deeplink] consumePending -> $location');
    return location;
  }
}
