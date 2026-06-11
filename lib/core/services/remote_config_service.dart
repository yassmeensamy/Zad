import 'dart:async';

import 'package:firebase_remote_config/firebase_remote_config.dart';

import '../utils/logger.dart';

/// Thin abstraction over [FirebaseRemoteConfig] so the rest of the app reads
/// remote values through a single, mockable surface. Used by [UpgradeChecker]
/// to read the platform-specific minimum allowed client version.
abstract class RemoteConfigService {
  Future<void> init();
  Future<void> refresh();
  String? getString(String key);
  bool getBool(String key);
  num getNumber(String key);
}

class RemoteConfigServiceImpl implements RemoteConfigService {
  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;

  @override
  Future<void> init() async {
    // `minimumFetchInterval: Duration.zero` always pulls fresh values (no
    // throttling) — appropriate for force-update gating on every cold start.
    await _remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 30),
        minimumFetchInterval: Duration.zero,
      ),
    );
    await _remoteConfig.fetchAndActivate();
  }

  @override
  Future<void> refresh() async {
    final activated = await _remoteConfig.fetchAndActivate();
    logger.debug(
      activated
          ? 'RemoteConfig refreshed and activated'
          : 'RemoteConfig refreshed but no new values activated',
    );
  }

  @override
  String? getString(String key) => _remoteConfig.getString(key);

  @override
  bool getBool(String key) => _remoteConfig.getBool(key);

  @override
  num getNumber(String key) => _remoteConfig.getDouble(key);
}
