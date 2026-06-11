import '../../../../core/cubits/base_cubit.dart';
import '../../../../core/utils/logger.dart';
import '../../data/repositories/notification_repository.dart';

/// Holds the unread-notification count for the home bell badge.
///
/// Kept separate from [NotificationCubit] (which is screen-scoped and rebuilt
/// per visit) so the badge can live for the lifetime of the home shell. Backed
/// by `GET /api/notifications/unread-count`. The state is just the count.
class NotificationBadgeCubit extends BaseCubit<int> {
  NotificationBadgeCubit({required NotificationRepository notificationRepository})
    : _notificationRepository = notificationRepository,
      super(0);

  final NotificationRepository _notificationRepository;

  /// Fetches the latest unread count. Silent on failure — the badge simply
  /// keeps its previous value rather than disrupting the home screen.
  Future<void> refresh() async {
    try {
      final count = await _notificationRepository.getUnreadCount();
      emit(count);
    } catch (e) {
      logger.debug('NotificationBadgeCubit.refresh failed: $e');
    }
  }
}
