import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../../theme/theme.dart';

/// Notification categories surfaced in the inbox. Each value carries its
/// own localization key, accent color, and icon so the card layer can stay
/// presentation-agnostic. The backend `notificationType` string maps onto
/// these via [fromName]; unknown/absent values fall back to [other].
enum NotificationTypeEnum {
  reminder(
    label: 'notifications.types.reminder',
    icon: Icons.notifications_active_rounded,
  ),
  reading(
    label: 'notifications.types.reading',
    icon: Icons.menu_book_rounded,
  ),
  achievement(
    label: 'notifications.types.achievement',
    icon: Icons.emoji_events_rounded,
  ),
  childActivity(
    label: 'notifications.types.child_activity',
    icon: Icons.family_restroom_rounded,
  ),
  announcement(
    label: 'notifications.types.announcement',
    icon: Icons.campaign_rounded,
  ),
  other(
    label: 'notifications.types.other',
    icon: Icons.notifications_none_rounded,
  );

  const NotificationTypeEnum({required this.label, required this.icon});

  final String label;
  final IconData icon;

  Color accent(AppColorsTheme colors) => switch (this) {
    NotificationTypeEnum.reminder => colors.accent,
    NotificationTypeEnum.reading => colors.olive,
    NotificationTypeEnum.achievement => colors.warning,
    NotificationTypeEnum.childActivity => colors.oliveLeaf,
    NotificationTypeEnum.announcement => colors.info,
    NotificationTypeEnum.other => colors.textTertiary,
  };

  /// Matches a backend type name case-insensitively against the enum's
  /// camelCase values (e.g. `CHILD_ACTIVITY` → [childActivity]).
  static NotificationTypeEnum fromName(String? name) {
    if (name == null || name.isEmpty) return NotificationTypeEnum.other;
    final normalized = name.replaceAll('_', '').toLowerCase();
    return NotificationTypeEnum.values.firstWhere(
      (e) => e.name.toLowerCase() == normalized,
      orElse: () => NotificationTypeEnum.other,
    );
  }
}

/// A single in-app notification returned by `GET /api/notifications`.
///
/// Field mapping is intentionally tolerant of the exact backend key casing:
/// the body is read from `messageBody`/`body`, the timestamp from
/// `sentAt`/`createdAt`, and the read flag from `read`/`isRead`.
class NotificationModel {
  const NotificationModel({
    required this.id,
    required this.notificationType,
    this.title,
    this.messageBody,
    this.sentAt,
    this.isRead = false,
  });

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    final sentRaw = (map['sentAt'] ?? map['createdAt']) as String?;
    return NotificationModel(
      id: (map['id'] as num).toInt(),
      notificationType: NotificationTypeEnum.fromName(
        map['notificationType'] as String?,
      ),
      title: map['title'] as String?,
      messageBody: (map['messageBody'] ?? map['body']) as String?,
      sentAt: sentRaw == null ? null : DateTime.parse(sentRaw).toLocal(),
      isRead: (map['read'] ?? map['isRead'] ?? false) as bool,
    );
  }

  factory NotificationModel.fromJson(String source) =>
      NotificationModel.fromMap(json.decode(source) as Map<String, dynamic>);

  final int id;
  final NotificationTypeEnum notificationType;
  final String? title;
  final String? messageBody;
  final DateTime? sentAt;
  final bool isRead;

  NotificationModel copyWith({
    int? id,
    NotificationTypeEnum? notificationType,
    String? title,
    String? messageBody,
    DateTime? sentAt,
    bool? isRead,
  }) => NotificationModel(
    id: id ?? this.id,
    notificationType: notificationType ?? this.notificationType,
    title: title ?? this.title,
    messageBody: messageBody ?? this.messageBody,
    sentAt: sentAt ?? this.sentAt,
    isRead: isRead ?? this.isRead,
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'notificationType': notificationType.name,
    'title': title,
    'messageBody': messageBody,
    'sentAt': sentAt?.toIso8601String(),
    'read': isRead,
  };

  String toJson() => json.encode(toMap());

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NotificationModel &&
        other.id == id &&
        other.notificationType == notificationType &&
        other.title == title &&
        other.messageBody == messageBody &&
        other.sentAt == sentAt &&
        other.isRead == isRead;
  }

  @override
  int get hashCode =>
      Object.hash(id, notificationType, title, messageBody, sentAt, isRead);
}

/// A page of notifications returned by `GET /api/notifications`.
///
/// The parser tolerates both the project's custom envelope
/// (`{ pagination: { currentPage, totalPages, ... }, notifications: [...] }`)
/// and a Spring `Page` payload (`{ content: [...], number, totalPages, ... }`),
/// so it keeps working regardless of which the backend emits.
class PaginatedNotifications {
  const PaginatedNotifications({
    required this.notifications,
    required this.currentPage,
    required this.totalPages,
    required this.totalElements,
  });

  final List<NotificationModel> notifications;
  final int currentPage;
  final int totalPages;
  final int totalElements;

  /// True when another page can be requested after [currentPage].
  bool get hasNext => currentPage < totalPages - 1;

  factory PaginatedNotifications.fromMap(Map<String, dynamic> map) {
    final pagination = map['pagination'] as Map<String, dynamic>?;
    final rawList =
        (map['notifications'] ?? map['content'] ?? map['data']) as List<dynamic>?;

    int readInt(List<String> keys) {
      for (final key in keys) {
        final fromPagination = pagination?[key];
        if (fromPagination is num) return fromPagination.toInt();
        final fromRoot = map[key];
        if (fromRoot is num) return fromRoot.toInt();
      }
      return 0;
    }

    return PaginatedNotifications(
      notifications: (rawList ?? const [])
          .map((e) => NotificationModel.fromMap(e as Map<String, dynamic>))
          .toList(),
      currentPage: readInt(const ['currentPage', 'number', 'page']),
      totalPages: readInt(const ['totalPages']),
      totalElements: readInt(const ['totalElements', 'total']),
    );
  }

  @override
  String toString() =>
      'PaginatedNotifications(${notifications.length} items, '
      'page $currentPage/$totalPages)';
}
