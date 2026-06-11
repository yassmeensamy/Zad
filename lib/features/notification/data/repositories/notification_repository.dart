import '../models/notification_model.dart';
import '../remote/notification_remote_data_source.dart';

abstract class NotificationRepository {
  Future<PaginatedNotifications> getNotifications({
    required int page,
    required int size,
  });
  Future<int> getUnreadCount();
  Future<void> markAllAsRead();
  Future<void> deleteNotification(int notificationId);
}

class NotificationRepositoryImpl implements NotificationRepository {
  NotificationRepositoryImpl({
    required NotificationRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final NotificationRemoteDataSource _remoteDataSource;

  @override
  Future<PaginatedNotifications> getNotifications({
    required int page,
    required int size,
  }) => _remoteDataSource.getNotifications(page: page, size: size);

  @override
  Future<int> getUnreadCount() => _remoteDataSource.getUnreadCount();

  @override
  Future<void> markAllAsRead() => _remoteDataSource.markAllAsRead();

  @override
  Future<void> deleteNotification(int notificationId) =>
      _remoteDataSource.deleteNotification(notificationId);
}
