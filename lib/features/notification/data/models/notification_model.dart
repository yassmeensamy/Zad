import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../../theme/theme.dart';

/// Notification categories surfaced in the inbox. Each value carries its
/// own localization key, accent color, and icon so the card layer can stay
/// presentation-agnostic.
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

  static NotificationTypeEnum fromName(String? name) =>
      NotificationTypeEnum.values.firstWhere(
        (e) => e.name == name,
        orElse: () => NotificationTypeEnum.other,
      );
}

class NotificationModel {
  const NotificationModel({
    required this.id,
    required this.notificationType,
    this.title,
    this.messageBody,
    this.createdAt,
  });

  factory NotificationModel.fromMap(Map<String, dynamic> map) =>
      NotificationModel(
        id: map['id'] as int,
        notificationType: NotificationTypeEnum.fromName(
          map['notificationType'] as String?,
        ),
        title: map['title'] as String?,
        messageBody: map['messageBody'] as String?,
        createdAt: map['createdAt'] == null
            ? null
            : DateTime.parse(map['createdAt'] as String).toLocal(),
      );

  factory NotificationModel.fromJson(String source) =>
      NotificationModel.fromMap(json.decode(source) as Map<String, dynamic>);

  final int id;
  final NotificationTypeEnum notificationType;
  final String? title;
  final String? messageBody;
  final DateTime? createdAt;

  NotificationModel copyWith({
    int? id,
    NotificationTypeEnum? notificationType,
    String? title,
    String? messageBody,
    DateTime? createdAt,
  }) => NotificationModel(
    id: id ?? this.id,
    notificationType: notificationType ?? this.notificationType,
    title: title ?? this.title,
    messageBody: messageBody ?? this.messageBody,
    createdAt: createdAt ?? this.createdAt,
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'notificationType': notificationType.name,
    'title': title,
    'messageBody': messageBody,
    'createdAt': createdAt?.toIso8601String(),
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
        other.createdAt == createdAt;
  }

  @override
  int get hashCode =>
      Object.hash(id, notificationType, title, messageBody, createdAt);
}
