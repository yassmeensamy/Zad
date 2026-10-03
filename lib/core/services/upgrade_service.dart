import 'dart:io' show Platform;

import 'package:pub_semver/pub_semver.dart';
import 'package:upgrader/upgrader.dart';

import '../constants/remote_config_keys.dart';
import '../utils/logger.dart';
import 'remote_config_service.dart';
import 'upgrade_info.dart';

abstract class UpgradeService {
  Future<bool> isForceUpdateRequired({required String languageCode});

  Future<bool> isUpdateAvailable({required String languageCode});

  Future<void> openStore();

  UpgradeInfo get info;
}

class UpgradeServiceImpl implements UpgradeService {
  UpgradeServiceImpl({required RemoteConfigService remoteConfig})
    : _remoteConfig = remoteConfig;

  final RemoteConfigService _remoteConfig;

  Upgrader? _upgrader;

  @override
  Future<bool> isForceUpdateRequired({required String languageCode}) async {
    // Remote Config is warmed in `main` without being awaited, so wait for that
    // fetch to settle before reading the minimum version — bounded, because
    // this runs on the splash and must not stall the app behind a dead network.
    // Timing out just means we read the default (empty) and fail open.
    await _remoteConfig.ready.timeout(
      _remoteConfigWait,
      onTimeout: () => logger.error('Force-update gate: RemoteConfig not ready'),
    );
    final upgrader = await _ensureReady(languageCode);
    if (upgrader == null) return false;
    return _isBelowMinimum(upgrader);
  }

  @override
  Future<bool> isUpdateAvailable({required String languageCode}) async {
    final upgrader = await _ensureReady(languageCode);
    if (upgrader == null) return false;
    try {
      return upgrader.isUpdateAvailable();
    } catch (e, s) {
      logger.error('UpgradeService.isUpdateAvailable failed: $e\n$s');
      return false;
    }
  }

  @override
  Future<void> openStore() async {
    final upgrader = _upgrader;
    if (upgrader == null) {
      logger.debug('openStore skipped: upgrader not ready');
      return;
    }
    await upgrader.sendUserToAppStore();
  }

  @override
  UpgradeInfo get info {
    final version = _upgrader?.state.versionInfo;
    if (version == null) return UpgradeInfo.empty;
    return UpgradeInfo(
      installedVersion: version.installedVersion?.toString(),
      availableVersion: version.appStoreVersion?.toString(),
      releaseNotes: version.releaseNotes,
    );
  }

  Future<Upgrader?> _ensureReady(String languageCode) async {
    final existing = _upgrader;
    if (existing != null) return existing;
    try {
      final upgrader = Upgrader(languageCode: languageCode);
      await upgrader.initialize();
      return _upgrader = upgrader;
    } catch (e, s) {
      logger.error('UpgradeService init failed: $e\n$s');
      return null;
    }
  }

  bool _isBelowMinimum(Upgrader upgrader) {
    final installed = upgrader.state.versionInfo?.installedVersion?.toString();
    final minimum = _remoteConfig.getString(_minVersionKey);
    if (installed == null ||
        installed.isEmpty ||
        minimum == null ||
        minimum.isEmpty) {
      return false;
    }
    try {
      return Version.parse(installed) < Version.parse(minimum);
    } catch (e) {
      logger.error('UpgradeService semver parse failed: $e');
      return false;
    }
  }

  String get _minVersionKey => Platform.isIOS
      ? RemoteConfigKeys.clientMinVersionIos
      : RemoteConfigKeys.clientMinVersionAndroid;

  static const _remoteConfigWait = Duration(seconds: 5);
}
