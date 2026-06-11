import '../../../../core/api/endpoints/app_endpoints.dart';
import '../../../../core/api/network_service.dart';
import '../models/notification_model.dart';

abstract class NotificationRemoteDataSource {
  Future<PaginatedNotifications> getNotifications({
    required int page,
    required int size,
  });
  Future<int> getUnreadCount();
  Future<void> markAllAsRead();
  Future<void> deleteNotification(int notificationId);
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  NotificationRemoteDataSourceImpl({
    required NetworkService networkService,
    required AppEndpoint endpoints,
  }) : _networkService = networkService,
       _endpoints = endpoints;

  final NetworkService _networkService;
  final AppEndpoint _endpoints;

  @override
  Future<PaginatedNotifications> getNotifications({
    required int page,
    required int size,
  }) async {
    final response = await _networkService.get(
      _endpoints.notifications,
      queryParameters: {'page': page, 'size': size},
    );
    response.validated();
    return PaginatedNotifications.fromMap(
      response.data as Map<String, dynamic>,
    );
  }

  @override
  Future<int> getUnreadCount() async {
    final response = await _networkService.get(
      _endpoints.notificationsUnreadCount,
    );
    response.validated();
    return ((response.data as Map<String, dynamic>)['count'] as num?)?.toInt() ??
        0;
  }

  @override
  Future<void> markAllAsRead() async {
    final response = await _networkService.patch(_endpoints.notificationsReadAll);
    response.validated(const [200, 204]);
  }

  @override
  Future<void> deleteNotification(int notificationId) async {
    final response = await _networkService.delete(
      _endpoints.notificationById(notificationId),
    );
    // 204 → deleted. 404 → already gone / not owned; the desired end state is
    // the same (absent from the inbox), so we treat it as success and let the
    // cubit drop it from the UI rather than surfacing an error.
    response.validated(const [200, 204, 404]);
  }
}
