abstract class UpgraderException implements Exception {
  UpgraderException(this.message);
  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// Thrown when [UpgraderService] is used before `initialize()` completed.
class UpgraderNotInitializedException extends UpgraderException {
  UpgraderNotInitializedException(super.message);
}

/// Thrown when upgrader initialization fails.
class UpgraderInitializationException extends UpgraderException {
  UpgraderInitializationException(super.message);
}
