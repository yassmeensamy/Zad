import '../models/notification_model.dart';
import '../remote/notification_remote_data_source.dart';

abstract class NotificationRepository {
  Future<List<NotificationModel>> getNotifications();
  Future<void> deleteAllNotifications();
  Future<void> deleteNotification(int notificationId);
}

class NotificationRepositoryImpl implements NotificationRepository {
  NotificationRepositoryImpl({
    required NotificationRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final NotificationRemoteDataSource _remoteDataSource;

  @override
  Future<List<NotificationModel>> getNotifications() =>
      _remoteDataSource.getNotifications();

  @override
  Future<void> deleteAllNotifications() =>
      _remoteDataSource.deleteAllNotifications();

  @override
  Future<void> deleteNotification(int notificationId) =>
      _remoteDataSource.deleteNotification(notificationId);
}
