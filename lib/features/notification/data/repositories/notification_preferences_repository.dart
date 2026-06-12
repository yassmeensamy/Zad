import '../models/notification_preferences.dart';
import '../remote/notification_preferences_remote_data_source.dart';

abstract class NotificationPreferencesRepository {
  Future<NotificationPreferences> getPreferences();
  Future<NotificationPreferences> updatePreferences(
    NotificationPreferences preferences,
  );
}

class NotificationPreferencesRepositoryImpl
    implements NotificationPreferencesRepository {
  NotificationPreferencesRepositoryImpl({
    required NotificationPreferencesRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final NotificationPreferencesRemoteDataSource _remoteDataSource;

  @override
  Future<NotificationPreferences> getPreferences() =>
      _remoteDataSource.getPreferences();

  @override
  Future<NotificationPreferences> updatePreferences(
    NotificationPreferences preferences,
  ) => _remoteDataSource.updatePreferences(preferences);
}
