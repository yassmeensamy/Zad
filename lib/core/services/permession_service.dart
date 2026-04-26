import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:geolocator/geolocator.dart';
import '../expections/google_map_expection.dart';
import '../utils/logger.dart';
import 'package:permission_handler/permission_handler.dart';
import '../expections/app_notifiction_expection.dart';
import '../expections/bluetooth_permission_exception.dart';
import '../expections/camera_permission_exception.dart';
import '../expections/microphone_permission_exception.dart';
import '../expections/phone_permission_exception.dart';
import '../expections/photos_permission_exception.dart';
import '../expections/storage_permission_exception.dart';

/// Android API level constants for permission handling
class _AndroidApiLevels {
  static const int api30 = 30; // Android 11 - Scoped storage
  static const int api33 = 33; // Android 13 - Photos permission
}

abstract class PermissionService {
  Future<void> checkLocationPermission();
  Future<void> checkNotificationPermission();
  Future<void> checkStoragePermission();
  Future<void> openSettings();
  Future<void> checkCameraPermission();
  Future<void> checkPhotosPermission();
  Future<void> checkMicrophonePermission();
  Future<void> checkPhonePermission();
  Future<void> checkBluetoothPermission();
}

class PermissionServiceImpl implements PermissionService {
  Future<int> _getAndroidSdkInt() async {
    final androidInfo = await DeviceInfoPlugin().androidInfo;
    return androidInfo.version.sdkInt;
  }

  @override
  @override
  Future<void> checkLocationPermission() async {
    logger.debug('Checking location permissions...');

    if (!await Geolocator.isLocationServiceEnabled()) {
      throw LocationServicesDisabledException(
        'Location services are disabled.',
      );
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      throw LocationDeniedException('Location permission is denied.');
    }

    if (permission == LocationPermission.deniedForever) {
      throw LocationDeniedForEverException(
        'Location permission is permanently denied. Please enable it from settings.',
      );
    }

    logger.debug('Location permission granted.');
  }

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
  Future<void> checkStoragePermission() async {
    logger.debug('Checking storage permissions...');

    if (!Platform.isAndroid) {
      logger.debug('Storage permission not required on non-Android platforms');
      return;
    }

    // Determine permission type based on Android SDK version
    final sdkInt = await _getAndroidSdkInt();
    final permission = sdkInt >= _AndroidApiLevels.api30
        ? Permission.manageExternalStorage
        : Permission.storage;

    final status = await permission.request();
    logger.debug('Storage permission status: $status');

    if (status.isDenied) {
      throw StoragePermissionDeniedException(
        'Storage permission is denied. Please grant storage access.',
      );
    }

    if (status.isPermanentlyDenied) {
      throw StoragePermissionDeniedForeverException(
        'Storage permission is permanently denied. Please enable it from settings.',
      );
    }

    if (status.isRestricted) {
      throw StoragePermissionRestrictedException(
        'Storage permission is restricted by system policy.',
      );
    }

    if (!status.isGranted) {
      throw StoragePermissionRequestException(
        'Failed to obtain storage permission.',
      );
    }

    logger.debug('Storage permission granted.');
  }

  @override
  Future<void> openSettings() async {
    logger.debug('Opening app settings...');

    await openAppSettings();
  }

  @override
  Future<void> checkCameraPermission() async {
    logger.debug('Checking camera permission...');

    final status = await Permission.camera.request();
    logger.debug('Camera permission status: $status');

    if (status.isPermanentlyDenied) {
      throw CameraPermissionDeniedForeverException(
        'Camera permission is permanently denied. Please enable it from settings.',
      );
    }

    if (status.isDenied) {
      throw CameraPermissionDeniedException('Camera permission is denied.');
    }

    logger.debug('Camera permission granted.');
  }

  @override
  Future<void> checkPhotosPermission() async {
    logger.debug('Checking photos permission...');

    if (Platform.isIOS) {
      final status = await Permission.photos.request();
      logger.debug('Photos permission status: $status');

      if (status.isPermanentlyDenied) {
        throw PhotosPermissionDeniedForeverException(
          'Photos permission is permanently denied. Please enable it from settings.',
        );
      }

      if (status.isDenied) {
        throw PhotosPermissionDeniedException('Photos permission is denied.');
      }

      logger.debug('Photos permission granted.');
      return;
    }

    if (Platform.isAndroid) {
      final sdkInt = await _getAndroidSdkInt();

      // Android 13+ (API 33+) uses photos permission
      final permission = sdkInt >= _AndroidApiLevels.api33
          ? Permission.photos
          : Permission.storage;

      final status = await permission.request();
      logger.debug('Photos permission status: $status');

      if (status.isPermanentlyDenied) {
        throw PhotosPermissionDeniedForeverException(
          'Photos permission is permanently denied. Please enable it from settings.',
        );
      }

      if (status.isDenied) {
        throw PhotosPermissionDeniedException('Photos permission is denied.');
      }

      logger.debug('Photos permission granted.');
    }
  }

  @override
  Future<void> checkMicrophonePermission() async {
    logger.debug('Checking microphone permission...');

    final status = await Permission.microphone.request();
    logger.debug('Microphone permission status: $status');

    if (status.isPermanentlyDenied) {
      throw MicrophonePermissionDeniedForeverException(
        'Microphone permission is permanently denied. Please enable it from settings.',
      );
    }

    if (status.isDenied) {
      throw MicrophonePermissionDeniedException(
        'Microphone permission is denied.',
      );
    }

    logger.debug('Microphone permission granted.');
  }

  @override
  Future<void> checkPhonePermission() async {
    logger.debug('Checking phone permission...');

    if (!Platform.isAndroid) {
      logger.debug('Phone permission not required on non-Android platforms');
      return;
    }

    final status = await Permission.phone.request();
    logger.debug('Phone permission status: $status');

    if (status.isPermanentlyDenied) {
      throw PhonePermissionDeniedForeverException(
        'Phone permission is permanently denied. Please enable it from settings.',
      );
    }

    if (status.isDenied) {
      throw PhonePermissionDeniedException('Phone permission is denied.');
    }

    logger.debug('Phone permission granted.');
  }

  @override
  Future<void> checkBluetoothPermission() async {
    logger.debug('Checking bluetooth permission...');

    final connectStatus = await Permission.bluetoothConnect.request();
    logger.debug('Bluetooth connect permission status: $connectStatus');

    if (connectStatus.isGranted) {
      logger.debug('Bluetooth permission granted.');
      return;
    }

    final btStatus = await Permission.bluetooth.request();
    logger.debug('Bluetooth permission status: $btStatus');

    if (btStatus.isGranted) {
      logger.debug('Bluetooth permission granted (legacy).');
      return;
    }

    if (btStatus.isPermanentlyDenied || connectStatus.isPermanentlyDenied) {
      throw BluetoothPermissionDeniedForeverException(
        'Bluetooth permission is permanently denied. Please enable it from settings.',
      );
    }

    if (btStatus.isDenied) {
      throw BluetoothPermissionDeniedException(
        'Bluetooth permission is denied.',
      );
    }

    logger.debug('Bluetooth permission granted.');
  }
}
