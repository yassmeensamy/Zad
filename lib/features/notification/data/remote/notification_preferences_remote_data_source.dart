import '../../../../core/api/endpoints/app_endpoints.dart';
import '../../../../core/api/network_service.dart';
import '../models/notification_preferences.dart';

abstract class NotificationPreferencesRemoteDataSource {
  Future<NotificationPreferences> getPreferences();
  Future<NotificationPreferences> updatePreferences(
    NotificationPreferences preferences,
  );
}

class NotificationPreferencesRemoteDataSourceImpl
    implements NotificationPreferencesRemoteDataSource {
  NotificationPreferencesRemoteDataSourceImpl({
    required NetworkService networkService,
    required AppEndpoint endpoints,
  }) : _networkService = networkService,
       _endpoints = endpoints;

  final NetworkService _networkService;
  final AppEndpoint _endpoints;

  @override
  Future<NotificationPreferences> getPreferences() async {
    final response = await _networkService.get(
      _endpoints.notificationsPreferences,
    );
    response.validated();
    return NotificationPreferences.fromMap(
      (response.data as Map).cast<String, dynamic>(),
    );
  }

  @override
  Future<NotificationPreferences> updatePreferences(
    NotificationPreferences preferences,
  ) async {
    final response = await _networkService.put(
      _endpoints.notificationsPreferences,
      data: preferences.toMap(),
    );
    response.validated();
    // The endpoint echoes the saved preferences back, so the cubit can trust
    // the response over its optimistic copy.
    return NotificationPreferences.fromMap(
      (response.data as Map).cast<String, dynamic>(),
    );
  }
}
