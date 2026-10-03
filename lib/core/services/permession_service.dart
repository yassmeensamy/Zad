import 'dart:io';

import 'package:app_settings/app_settings.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:permission_handler/permission_handler.dart';

import '../expections/app_notifiction_expection.dart';
import '../utils/logger.dart';

abstract class PermissionService {
  Future<void> checkNotificationPermission();
  Future<void> openSettings();
}

class PermissionServiceImpl implements PermissionService {
  @override
  Future<void> checkNotificationPermission() async {
    logger.debug('Checking notification permissions...');

    if (Platform.isAndroid) {
      final status = await Permission.notification.status;

      if (status.isPermanentlyDenied) {
        throw NotificationDeniedForeverException(
          'Notification permission is permanently denied. Please enable it from settings.',
        );
      }

      if (status.isDenied) {
        throw NotificationDeniedException('Notification permission is denied.');
      }
    }

    if (Platform.isIOS) {
      final settings = await FirebaseMessaging.instance
          .getNotificationSettings();

      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        logger.debug(
          'Notification permission is denied. Please enable it from settings.',
        );
        throw NotificationDeniedForeverException(
          'Notification permission is denied. Please enable it from settings.',
        );
      }
    }

    logger.debug('Notification permission granted.');
  }

  @override
  Future<void> openSettings() async {
    logger.debug('Opening notification settings...');

    // Deep-link straight to the notification settings page. On Android this
    // lands on the app's notifications screen; iOS has no public notifications
    // sub-page, so it opens the app's settings page (the closest it allows).
    await AppSettings.openAppSettings(type: AppSettingsType.notification);
  }
}
