import 'dart:io' show Platform;

import '../constants/remote_config_keys.dart';
import '../utils/logger.dart';
import 'remote_config_service.dart';
import 'upgrader_service.dart';

/// Single facade the UI talks to for app-update concerns.
///
/// Two tiers:
/// * [isForceUpdateRequired] — blocking. Compares the installed version against
///   the platform's minimum allowed version from Remote Config.
/// * [isUpdateAvailable] — non-blocking. Compares installed vs. the store's
///   latest version (via the `upgrader` package).
class UpgradeChecker {
  UpgradeChecker({
    required UpgraderService upgrader,
    required RemoteConfigService remoteConfig,
  }) : _upgrader = upgrader,
       _remoteConfig = remoteConfig;

  final UpgraderService _upgrader;
  final RemoteConfigService _remoteConfig;

  // ---------------------------------------------------------------------------
  // DEBUG / TESTING TOGGLE
  // Set [debugForceUpdate] to true to force the blocking update dialog to show
  // on next launch, using the mock versions below — no Firebase Remote Config
  // params or an older installed build required. REMEMBER TO SET BACK TO FALSE.
  // ---------------------------------------------------------------------------
  static bool debugForceUpdate = true;
  static const String _mockInstalledVersion = '1.0.0';
  static const String _mockAvailableVersion = '2.0.0';
  static const String _mockReleaseNotes =
      'What\'s new in this test build:\n• Faster quizzes\n• Bug fixes and polish';

  Future<bool> isForceUpdateRequired({required String languageCode}) async {
    if (debugForceUpdate) return true;
    try {
      await _upgrader.initialize(languageCode: languageCode);
      return _upgrader.isCriticalUpdate(_criticalVersion);
    } catch (e) {
      logger.error('UpgradeChecker.isForceUpdateRequired failed: $e');
      return false;
    }
  }

  Future<bool> isUpdateAvailable({required String languageCode}) async {
    try {
      await _upgrader.initialize(languageCode: languageCode);
      return _upgrader.isUpdateAvailable();
    } catch (e) {
      logger.error('UpgradeChecker.isUpdateAvailable failed: $e');
      return false;
    }
  }

  Future<void> openAppStore() async {
    if (!_upgrader.isInitialized) {
      logger.debug('openAppStore skipped: upgrader not initialized');
      return;
    }
    await _upgrader.upgrader.sendUserToAppStore();
  }

  String? get installedVersion {
    if (debugForceUpdate) return _mockInstalledVersion;
    return _upgrader.isInitialized
        ? _upgrader.upgrader.state.versionInfo?.installedVersion?.toString()
        : null;
  }

  String? get availableVersion {
    if (debugForceUpdate) return _mockAvailableVersion;
    return _upgrader.isInitialized
        ? _upgrader.upgrader.state.versionInfo?.appStoreVersion?.toString()
        : null;
  }

  String? get releaseNotes {
    if (debugForceUpdate) return _mockReleaseNotes;
    return _upgrader.isInitialized
        ? _upgrader.upgrader.state.versionInfo?.releaseNotes
        : null;
  }

  String get _criticalVersion =>
      _remoteConfig.getString(
        Platform.isIOS
            ? RemoteConfigKeys.clientMinVersionIos
            : RemoteConfigKeys.clientMinVersionAndroid,
      ) ??
      '';
}
