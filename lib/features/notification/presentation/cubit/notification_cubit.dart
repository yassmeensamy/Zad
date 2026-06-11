import '../../../../core/cubits/base_cubit.dart';
import '../../../../core/expections/server_exception.dart';
import '../../../../core/utils/logger.dart';
import '../../data/models/notification_model.dart';
import '../../data/repositories/notification_repository.dart';
import 'notification_state.dart';

class NotificationCubit extends BaseCubit<NotificationState> {
  NotificationCubit({required NotificationRepository notificationRepository})
    : _notificationRepository = notificationRepository,
      super(const NotificationState());

  final NotificationRepository _notificationRepository;

  static const int _pageSize = 20;

  /// Entry point when the inbox screen opens: loads the first page and then
  /// marks everything read on the server. The list is loaded *first* so the
  /// session still shows which items were unread; the read-all call only
  /// affects the badge/count and the next visit.
  Future<void> openInbox() async {
    await getNotifications();
    await _markAllReadSilently();
  }

  /// Loads the first page. Used on screen open and pull-to-refresh.
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
      final page = await _notificationRepository.getNotifications(
        page: 0,
        size: _pageSize,
      );
      emit(
        state.copyWith(
          status: NotificationStatus.loaded,
          notifications: page.notifications,
          currentPage: page.currentPage,
          totalPages: page.totalPages,
          loadingMore: false,
          errorMessage: () => null,
        ),
      );
    } on ServerException catch (e) {
      _emitLoadError(e.message);
    } catch (e) {
      logger.error('NotificationCubit.getNotifications failed: $e');
      _emitLoadError('notifications.load_failed');
    }
  }

  /// Appends the next page when the user scrolls to the end.
  Future<void> loadMore() async {
    if (state.loadingMore || !state.hasMore || !state.isLoaded) return;
    emit(state.copyWith(loadingMore: true));
    final nextPage = state.currentPage + 1;
    try {
      final page = await _notificationRepository.getNotifications(
        page: nextPage,
        size: _pageSize,
      );
      emit(
        state.copyWith(
          notifications: [...state.notifications, ...page.notifications],
          currentPage: page.currentPage,
          totalPages: page.totalPages,
          loadingMore: false,
        ),
      );
    } on ServerException catch (e) {
      logger.debug('NotificationCubit.loadMore server: ${e.message}');
      emit(state.copyWith(loadingMore: false));
    } catch (e) {
      logger.error('NotificationCubit.loadMore failed: $e');
      emit(state.copyWith(loadingMore: false));
    }
  }

  /// Marks every notification read on the server. Fire-and-forget: failures are
  /// logged but never surfaced, and the local read flags are left untouched so
  /// the current session keeps highlighting what was new. The next inbox open
  /// (and the home badge) will reflect the read state from the backend.
  Future<void> _markAllReadSilently() async {
    try {
      await _notificationRepository.markAllAsRead();
    } catch (e) {
      logger.debug('NotificationCubit.markAllAsRead failed: $e');
    }
  }

  /// Soft-deletes a notification. Optimistic: removed from the list right away,
  /// restored if the backend rejects it (404 is treated as success upstream).
  Future<void> deleteNotification(int notificationId) async {
    final previous = state.notifications;
    if (previous.every((n) => n.id != notificationId)) return;

    emit(
      state.copyWith(
        notifications: previous
            .where((n) => n.id != notificationId)
            .toList(),
      ),
    );
    try {
      await _notificationRepository.deleteNotification(notificationId);
    } on ServerException catch (e) {
      _rollbackAll(previous, e.message);
    } catch (e) {
      logger.error('NotificationCubit.deleteNotification failed: $e');
      _rollbackAll(previous, 'notifications.delete_failed');
    }
  }

  /// Clears the one-shot action error after it has been shown.
  void clearActionError() {
    if (state.actionError == null) return;
    emit(state.copyWith(actionError: () => null));
  }

  void _emitLoadError(String? message) {
    emit(
      state.copyWith(
        status: NotificationStatus.error,
        loadingMore: false,
        errorMessage: () => message,
      ),
    );
  }

  void _rollbackAll(List<NotificationModel> previous, String? message) {
    emit(
      state.copyWith(
        notifications: previous,
        actionError: () => message,
      ),
    );
  }
}
