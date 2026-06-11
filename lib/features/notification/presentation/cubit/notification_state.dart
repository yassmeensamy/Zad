import 'package:flutter/foundation.dart';

import '../../data/models/notification_model.dart';

enum NotificationStatus { initial, loading, loaded, error }

class NotificationState {
  const NotificationState({
    this.status = NotificationStatus.initial,
    this.notifications = const [],
    this.errorMessage,
    this.loadingMore = false,
    this.currentPage = 0,
    this.totalPages = 0,
    this.actionError,
  });

  final NotificationStatus status;
  final List<NotificationModel> notifications;

  /// Message key shown on the full-screen error state (initial load failure).
  final String? errorMessage;

  /// True while an additional page is being appended.
  final bool loadingMore;

  final int currentPage;
  final int totalPages;

  /// One-shot message key for a failed action (read / mark-all / delete),
  /// surfaced as a snackbar then cleared via [NotificationCubit.clearActionError].
  final String? actionError;

  NotificationState copyWith({
    NotificationStatus? status,
    List<NotificationModel>? notifications,
    String? Function()? errorMessage,
    bool? loadingMore,
    int? currentPage,
    int? totalPages,
    String? Function()? actionError,
  }) => NotificationState(
    status: status ?? this.status,
    notifications: notifications ?? this.notifications,
    errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
    loadingMore: loadingMore ?? this.loadingMore,
    currentPage: currentPage ?? this.currentPage,
    totalPages: totalPages ?? this.totalPages,
    actionError: actionError != null ? actionError() : this.actionError,
  );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NotificationState &&
        other.status == status &&
        listEquals(other.notifications, notifications) &&
        other.errorMessage == errorMessage &&
        other.loadingMore == loadingMore &&
        other.currentPage == currentPage &&
        other.totalPages == totalPages &&
        other.actionError == actionError;
  }

  @override
  int get hashCode => Object.hashAll([
    status,
    Object.hashAll(notifications),
    errorMessage,
    loadingMore,
    currentPage,
    totalPages,
    actionError,
  ]);
}

extension NotificationStateX on NotificationState {
  bool get isInitial => status == NotificationStatus.initial;
  bool get isLoading => status == NotificationStatus.loading;
  bool get isLoaded => status == NotificationStatus.loaded;
  bool get isError => status == NotificationStatus.error;

  bool get hasNotifications => notifications.isNotEmpty;

  bool get hasMore => currentPage < totalPages - 1;
}
