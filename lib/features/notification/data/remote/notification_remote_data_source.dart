import '../models/notification_model.dart';

abstract class NotificationRemoteDataSource {
  Future<List<NotificationModel>> getNotifications();
  Future<void> deleteAllNotifications();
  Future<void> deleteNotification(int notificationId);
}

/// Mock implementation that fakes a network round-trip with [Future.delayed]
/// and keeps the list in-memory. Swap this out for an API-backed source when
/// the backend is available — the cubit/repository contract stays the same.
class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  NotificationRemoteDataSourceImpl()
    : _notifications = List.of(_seedNotifications);

  final List<NotificationModel> _notifications;

  @override
  Future<List<NotificationModel>> getNotifications() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return List.unmodifiable(_notifications);
  }

  @override
  Future<void> deleteAllNotifications() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _notifications.clear();
  }

  @override
  Future<void> deleteNotification(int notificationId) async {
    await Future.delayed(const Duration(milliseconds: 250));
    _notifications.removeWhere((n) => n.id == notificationId);
  }

  static final List<NotificationModel> _seedNotifications = [
    NotificationModel(
      id: 1,
      notificationType: NotificationTypeEnum.reminder,
      title: 'notifications.mock.reminder_title',
      messageBody: 'notifications.mock.reminder_body',
      createdAt: DateTime.now().subtract(const Duration(minutes: 12)),
    ),
    NotificationModel(
      id: 2,
      notificationType: NotificationTypeEnum.achievement,
      title: 'notifications.mock.achievement_title',
      messageBody: 'notifications.mock.achievement_body',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    NotificationModel(
      id: 3,
      notificationType: NotificationTypeEnum.reading,
      title: 'notifications.mock.reading_title',
      messageBody: 'notifications.mock.reading_body',
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    NotificationModel(
      id: 4,
      notificationType: NotificationTypeEnum.childActivity,
      title: 'notifications.mock.child_activity_title',
      messageBody: 'notifications.mock.child_activity_body',
      createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
    ),
    NotificationModel(
      id: 5,
      notificationType: NotificationTypeEnum.announcement,
      title: 'notifications.mock.announcement_title',
      messageBody: 'notifications.mock.announcement_body',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    NotificationModel(
      id: 6,
      notificationType: NotificationTypeEnum.reminder,
      title: 'notifications.mock.evening_reminder_title',
      messageBody: 'notifications.mock.evening_reminder_body',
      createdAt: DateTime.now().subtract(const Duration(days: 5, hours: 8)),
    ),
  ];
}
