import 'package:flutter/foundation.dart';

import '../../data/models/notification_model.dart';

enum NotificationStatus { initial, loading, loaded, error }

enum DeleteNotificationStatus { initial, loading, success, error }

class NotificationState {
  const NotificationState({
    this.status = NotificationStatus.initial,
    this.notifications = const [],
    this.errorMessage,
    this.deleteStatus = DeleteNotificationStatus.initial,
    this.deleteErrorMessage,
  });

  final NotificationStatus status;
  final List<NotificationModel> notifications;
  final String? errorMessage;
  final DeleteNotificationStatus deleteStatus;
  final String? deleteErrorMessage;

  NotificationState copyWith({
    NotificationStatus? status,
    List<NotificationModel>? notifications,
    String? Function()? errorMessage,
    DeleteNotificationStatus? deleteStatus,
    String? Function()? deleteErrorMessage,
  }) => NotificationState(
    status: status ?? this.status,
    notifications: notifications ?? this.notifications,
    errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
    deleteStatus: deleteStatus ?? this.deleteStatus,
    deleteErrorMessage: deleteErrorMessage != null
        ? deleteErrorMessage()
        : this.deleteErrorMessage,
  );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NotificationState &&
        other.status == status &&
        listEquals(other.notifications, notifications) &&
        other.errorMessage == errorMessage &&
        other.deleteStatus == deleteStatus &&
        other.deleteErrorMessage == deleteErrorMessage;
  }

  @override
  int get hashCode => Object.hashAll([
    status,
    Object.hashAll(notifications),
    errorMessage,
    deleteStatus,
    deleteErrorMessage,
  ]);
}

extension NotificationStateX on NotificationState {
  bool get isInitial => status == NotificationStatus.initial;
  bool get isLoading => status == NotificationStatus.loading;
  bool get isLoaded => status == NotificationStatus.loaded;
  bool get isError => status == NotificationStatus.error;

  bool get isDeleteInitial => deleteStatus == DeleteNotificationStatus.initial;
  bool get isDeleteLoading => deleteStatus == DeleteNotificationStatus.loading;
  bool get isDeleteSuccess => deleteStatus == DeleteNotificationStatus.success;
  bool get isDeleteError => deleteStatus == DeleteNotificationStatus.error;

  bool get hasNotifications => notifications.isNotEmpty;
}
