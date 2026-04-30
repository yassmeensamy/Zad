import '../../../../core/cubits/base_cubit.dart';
import '../../../../core/expections/server_exception.dart';
import '../../../../core/utils/logger.dart';
import '../../data/repositories/notification_repository.dart';
import 'notification_state.dart';

class NotificationCubit extends BaseCubit<NotificationState> {
  NotificationCubit({required NotificationRepository notificationRepository})
    : _notificationRepository = notificationRepository,
      super(const NotificationState());

  final NotificationRepository _notificationRepository;

  Future<void> getNotifications({bool refresh = false}) async {
    if (!refresh) {
      emit(
        state.copyWith(
          status: NotificationStatus.loading,
          errorMessage: () => null,
        ),
      );
    }
    try {
      final notifications = await _notificationRepository.getNotifications();
      emit(
        state.copyWith(
          status: NotificationStatus.loaded,
          notifications: notifications,
        ),
      );
    } on ServerException catch (e) {
      emit(
        state.copyWith(
          status: NotificationStatus.error,
          errorMessage: () => e.message,
        ),
      );
    } catch (e) {
      logger.error('NotificationCubit.getNotifications failed: $e');
      emit(
        state.copyWith(
          status: NotificationStatus.error,
          errorMessage: () => 'notifications.load_failed',
        ),
      );
    }
  }

  Future<void> deleteNotification(int notificationId) async {
    emit(
      state.copyWith(
        deleteStatus: DeleteNotificationStatus.loading,
        deleteErrorMessage: () => null,
      ),
    );
    try {
      await _notificationRepository.deleteNotification(notificationId);
      emit(
        state.copyWith(
          deleteStatus: DeleteNotificationStatus.success,
          notifications: state.notifications
              .where((n) => n.id != notificationId)
              .toList(),
        ),
      );
    } on ServerException catch (e) {
      emit(
        state.copyWith(
          deleteStatus: DeleteNotificationStatus.error,
          deleteErrorMessage: () => e.message,
        ),
      );
    } catch (e) {
      logger.error('NotificationCubit.deleteNotification failed: $e');
      emit(
        state.copyWith(
          deleteStatus: DeleteNotificationStatus.error,
          deleteErrorMessage: () => 'notifications.delete_failed',
        ),
      );
    }
  }

  Future<void> deleteAllNotifications() async {
    emit(
      state.copyWith(
        deleteStatus: DeleteNotificationStatus.loading,
        deleteErrorMessage: () => null,
      ),
    );
    try {
      await _notificationRepository.deleteAllNotifications();
      emit(
        state.copyWith(
          deleteStatus: DeleteNotificationStatus.success,
          notifications: const [],
        ),
      );
    } on ServerException catch (e) {
      emit(
        state.copyWith(
          deleteStatus: DeleteNotificationStatus.error,
          deleteErrorMessage: () => e.message,
        ),
      );
    } catch (e) {
      logger.error('NotificationCubit.deleteAllNotifications failed: $e');
      emit(
        state.copyWith(
          deleteStatus: DeleteNotificationStatus.error,
          deleteErrorMessage: () => 'notifications.delete_failed',
        ),
      );
    }
  }

  void resetDeleteStatus() {
    emit(
      state.copyWith(
        deleteStatus: DeleteNotificationStatus.initial,
        deleteErrorMessage: () => null,
      ),
    );
  }
}
