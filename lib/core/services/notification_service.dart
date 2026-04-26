import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import '../utils/logger.dart';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:path_provider/path_provider.dart';

import 'permession_service.dart';

class NotificationService {
  NotificationService({PermissionService? permissionService})
    : _permissionService = permissionService;
  late ValueChanged<Map<String, dynamic>> _onNotificationTap;
  final PermissionService? _permissionService;
  final _listenersCallbacks = <ValueChanged<Map<String, dynamic>>>[];

  void addListener(ValueChanged<Map<String, dynamic>> callback) {
    if (!_listenersCallbacks.contains(callback)) {
      _listenersCallbacks.add(callback);
    }
  }

  void removeListener(ValueChanged<Map<String, dynamic>> callback) {
    _listenersCallbacks.remove(callback);
  }

  Future<void> init() async {
    await _FlutterLocalNotificationHelper.init(
      onNotificationTab: (payload) => _onNotificationTap(payload),
    );

    await _init();
    /*
    try {
      await getDeviceToken();
      await cancelAll();
    } on Exception catch (e) {
      log(e.toString());
    }
    */
  }

  Future<String> getDeviceToken() async {
    if (Platform.isIOS || Platform.isAndroid) {
      await _permissionService?.checkNotificationPermission();
      final messaging = FirebaseMessaging.instance;
      final token = await messaging.getToken();
      logger.debug('Firebase token: $token');
      return token!;
    } else {
      throw Exception('platform not supported');
    }
  }

  Future<void> deleteDeviceToken() async {
    final messaging = FirebaseMessaging.instance;
    await messaging.deleteToken();
  }

  @pragma('vm:entry-point')
  Future<void> _init() async {
    await _openNotificationsPageIfAppOpenedFromTerminated();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      logger.debug('Received FCM message: $message');
      logger.debug('run notification in foreground');
      final notification = message.notification;

      final image =
          message.data['image'] ??
          notification?.android?.imageUrl ??
          notification?.apple?.imageUrl;

      if (notification != null) {
        await _FlutterLocalNotificationHelper.showFCMNotification(
          title: notification.title,
          body: notification.body,
          image: image as String?,
          payload: message.data,
        );
      }

      for (var callback in _listenersCallbacks) {
        callback(message.data);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((notification) {
      logger.debug('run notification in background');
      _onNotificationTap(notification.data);
    });
  }

  Future<void> _openNotificationsPageIfAppOpenedFromTerminated() async {
    final notification = await FirebaseMessaging.instance.getInitialMessage();
    if (notification != null) {
      await Future.delayed(const Duration(milliseconds: 500));
    }
  }

  Future<void> cancelAll() => _FlutterLocalNotificationHelper.cancelAll();
}

class _FlutterLocalNotificationHelper {
  static const channel = AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    importance: Importance.max,
  );

  static FlutterLocalNotificationsPlugin? flutterLocalNotificationsPlugin;

  static Future<void> init({
    required void Function(Map<String, dynamic>) onNotificationTab,
  }) async {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    if (Platform.isAndroid) {
      await flutterLocalNotificationsPlugin!
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()!
          .requestNotificationsPermission();
    }

    await flutterLocalNotificationsPlugin!
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);

    await flutterLocalNotificationsPlugin!.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestSoundPermission: true,
          requestAlertPermission: true,
          requestBadgePermission: true,
        ),
      ),
      //handle navigating in foreground state
      onDidReceiveNotificationResponse: (details) {
        if (details.payload == null) return;
        final payloadDecoded = json.decode(details.payload!);
        onNotificationTab(payloadDecoded as Map<String, dynamic>);
      },
    );
  }

  static Future<void> showFCMNotification({
    String? title,
    String? body,
    Map<String, dynamic>? payload,
    String? image,
  }) async {
    final imagePath = image == null ? null : await _downloadAndSaveFile(image);

    return flutterLocalNotificationsPlugin!.show(
      const _NotificationIdGenerator().generate(),
      title,
      body,
      NotificationDetails(
        iOS: DarwinNotificationDetails(
          presentSound: true,
          presentAlert: true,
          presentBadge: true,
          attachments: imagePath == null
              ? null
              : [DarwinNotificationAttachment(imagePath)],
        ),
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          priority: Priority.max,
          importance: Importance.max,
          icon: '@mipmap/ic_launcher',
          largeIcon:
              imagePath == null ? null : FilePathAndroidBitmap(imagePath),
        ),
      ),
      payload: payload == null ? null : json.encode(payload),
    );
  }

  static Future<void> cancelAll() async =>
      flutterLocalNotificationsPlugin?.cancelAll();

  static Future<String> _downloadAndSaveFile(String url) async {
    final uri = Uri.parse(url);
    final fileName = uri.pathSegments.last;
    final Directory directory = await getApplicationDocumentsDirectory();
    final String filePath = '${directory.path}/$fileName';
    final Response response = await Dio().get(
      url,
      options: Options(responseType: ResponseType.bytes),
    );
    final File file = File(filePath);
    await file.writeAsBytes(response.data as List<int>);
    return filePath;
  }
}

Future<void> navigateToNotificationPage([int? notificationId]) async {
  if (notificationId == null) return Future.value();
  // return navigatorKey.currentState!.push(
  //   MaterialPageRoute(
  //     builder: (context) =>
  //         NotificationDetailsView(notificationId: notificationId),
  //     settings: const RouteSettings(name: NotificationDetailsView.routeName),
  //   ),
  // );
}

class _NotificationIdGenerator {
  const _NotificationIdGenerator();

  static final random = math.Random();

  int generate() => random.nextInt(math.pow(2, 31).toInt() - 1);
}
