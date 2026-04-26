abstract class AppNotificationException implements Exception {
  AppNotificationException(this.message);
  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// Notification permission is denied but can be requested again
class NotificationDeniedException extends AppNotificationException {
  NotificationDeniedException(super.message);
}

/// Notification permission is permanently denied, user must go to settings
class NotificationDeniedForeverException extends AppNotificationException {
  NotificationDeniedForeverException(super.message);
}

/// Notification permission is restricted (iOS specific)
class NotificationRestrictedException extends AppNotificationException {
  NotificationRestrictedException(super.message);
}
