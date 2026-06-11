import 'package:pub_semver/pub_semver.dart';
import 'package:upgrader/upgrader.dart';

import '../expections/upgrader_exception.dart';
import '../utils/logger.dart';

/// Wraps the `upgrader` package: lazy, idempotent initialization, a semver
/// comparison for force-update gating, and store-version availability.
abstract class UpgraderService {
  Upgrader get upgrader;

  bool get isInitialized;

  Future<void> initialize({
    required String languageCode,
    bool debug = false,
    String minAppVersion = '1.0.0',
    bool rethrowOnFailure = false,
  });

  /// True when the installed version is older than [criticalVersion] (semver).
  bool isCriticalUpdate(String criticalVersion);

  /// True when a newer version is available on the store (installed < store).
  Future<bool> isUpdateAvailable();
}

class UpgraderServiceImpl implements UpgraderService {
  Upgrader? _upgrader;

  @override
  bool get isInitialized => _upgrader != null;

  @override
  Upgrader get upgrader {
    final upgrader = _upgrader;
    if (upgrader == null) {
      throw UpgraderNotInitializedException(
        'UpgraderService used before initialize() completed.',
      );
    }
    return upgrader;
  }

  @override
  Future<void> initialize({
    required String languageCode,
    bool debug = false,
    String minAppVersion = '1.0.0',
    bool rethrowOnFailure = false,
  }) async {
    if (_upgrader != null) return;

    final u = Upgrader(
      debugDisplayAlways: debug,
      debugLogging: debug,
      minAppVersion: minAppVersion,
      languageCode: languageCode,
    );

    try {
      await u.initialize();
      _upgrader = u;
    } catch (e, s) {
      logger.error('Failed to initialize Upgrader: $e\n$s');
      // A network hiccup must never block the app — swallow unless asked.
      if (rethrowOnFailure) {
        throw UpgraderInitializationException(e.toString());
      }
    }
  }

  int _compareVersion(String v1, String v2) =>
      Version.parse(v1).compareTo(Version.parse(v2));

  @override
  bool isCriticalUpdate(String criticalVersion) {
    if (!isInitialized) return false;

    final installed = upgrader.state.versionInfo?.installedVersion?.toString();
    if (installed == null || installed.isEmpty || criticalVersion.isEmpty) {
      logger.debug(
        'Installed ($installed) or critical ($criticalVersion) version '
        'missing; treating as not critical.',
      );
      return false;
    }

    try {
      return _compareVersion(installed, criticalVersion) < 0;
    } catch (e) {
      logger.error('isCriticalUpdate semver parse failed: $e');
      return false;
    }
  }

  @override
  Future<bool> isUpdateAvailable() async {
    if (!isInitialized) return false;
    try {
      return upgrader.isUpdateAvailable();
    } catch (e, s) {
      logger.error('Error checking for updates: $e\n$s');
      return false;
    }
  }
}
