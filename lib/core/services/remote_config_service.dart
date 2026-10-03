import 'dart:async';

import 'package:firebase_remote_config/firebase_remote_config.dart';

import '../constants/remote_config_keys.dart';
import '../utils/logger.dart';

/// Thin abstraction over [FirebaseRemoteConfig] so the rest of the app reads
/// remote values through a single, mockable surface. Used by [UpgradeService]
/// to read the platform-specific minimum allowed client version.
abstract class RemoteConfigService {
  /// Kicks off the fetch. Never throws and never blocks longer than
  /// [RemoteConfigServiceImpl.warmupTimeout] — callers may safely fire this
  /// without awaiting it.
  Future<void> init();

  /// Completes when the first fetch has settled (succeeded, failed, or timed
  /// out). Await this — always with your own timeout — when a read has to see
  /// fresh values; never await it before the first frame is rendered.
  Future<void> get ready;

  String? getString(String key);
}

class RemoteConfigServiceImpl implements RemoteConfigService {
  /// Upper bound on the whole warm-up.
  ///
  /// `RemoteConfigSettings.fetchTimeout` only bounds the config HTTP request —
  /// it does *not* cover acquiring the Firebase Installations (FIS) token that
  /// `fetchAndActivate` needs first. When FIS is rejected (e.g. the signing
  /// certificate SHA-1 of a Play-signed build isn't registered on the Firebase
  /// project) it retries with backoff and the call can hang indefinitely, so
  /// this timeout is the only real guarantee we get.
  static const warmupTimeout = Duration(seconds: 8);

  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;

  final Completer<void> _ready = Completer<void>();

  @override
  Future<void> get ready => _ready.future;

  @override
  Future<void> init() async {
    try {
      // Defaults first, so every getter returns a sane value even if the fetch
      // never lands. Empty min-version => the force-update gate fails open.
      await _remoteConfig.setDefaults(const {
        RemoteConfigKeys.clientMinVersionIos: '',
        RemoteConfigKeys.clientMinVersionAndroid: '',
      });
      // `minimumFetchInterval: Duration.zero` always pulls fresh values (no
      // throttling) — appropriate for force-update gating on every cold start.
      await _remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: warmupTimeout,
          minimumFetchInterval: Duration.zero,
        ),
      );
      await _remoteConfig.fetchAndActivate().timeout(warmupTimeout);
    } on TimeoutException {
      logger.error('RemoteConfig warm-up timed out after $warmupTimeout');
    } catch (e) {
      logger.error('RemoteConfig init failed: $e');
    } finally {
      if (!_ready.isCompleted) _ready.complete();
    }
  }

  @override
  String? getString(String key) => _remoteConfig.getString(key);
}
