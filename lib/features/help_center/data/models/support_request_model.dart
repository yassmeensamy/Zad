import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../../theme/theme.dart';

/// Topics surfaced on the help center landing. Each value carries its own
/// localization keys, icon, and accent so the presentation layer can render
/// without a switch-statement of its own.
enum SupportTopicEnum {
  feedback(
    label: 'help_center.topics.feedback.label',
    description: 'help_center.topics.feedback.description',
    icon: Icons.favorite_outline_rounded,
  ),
  question(
    label: 'help_center.topics.question.label',
    description: 'help_center.topics.question.description',
    icon: Icons.help_outline_rounded,
  ),
  bug(
    label: 'help_center.topics.bug.label',
    description: 'help_center.topics.bug.description',
    icon: Icons.bug_report_outlined,
  ),
  technical(
    label: 'help_center.topics.technical.label',
    description: 'help_center.topics.technical.description',
    icon: Icons.tune_rounded,
  );

  const SupportTopicEnum({
    required this.label,
    required this.description,
    required this.icon,
  });

  final String label;
  final String description;
  final IconData icon;

  Color accent(AppColorsTheme colors) => switch (this) {
    SupportTopicEnum.feedback => colors.accent,
    SupportTopicEnum.question => colors.olive,
    SupportTopicEnum.bug => colors.warning,
    SupportTopicEnum.technical => colors.info,
  };

  static SupportTopicEnum fromName(String? name) =>
      SupportTopicEnum.values.firstWhere(
        (e) => e.name == name,
        orElse: () => SupportTopicEnum.question,
      );
}

class SupportRequestModel {
  const SupportRequestModel({
    required this.topic,
    required this.subject,
    required this.message,
    this.id,
    this.createdAt,
  });

  factory SupportRequestModel.fromMap(Map<String, dynamic> map) =>
      SupportRequestModel(
        id: map['id'] as int?,
        topic: SupportTopicEnum.fromName(map['topic'] as String?),
        subject: map['subject'] as String? ?? '',
        message: map['message'] as String? ?? '',
        createdAt: map['createdAt'] == null
            ? null
            : DateTime.parse(map['createdAt'] as String).toLocal(),
      );

  factory SupportRequestModel.fromJson(String source) =>
      SupportRequestModel.fromMap(json.decode(source) as Map<String, dynamic>);

  final int? id;
  final SupportTopicEnum topic;
  final String subject;
  final String message;
  final DateTime? createdAt;

  SupportRequestModel copyWith({
    int? id,
    SupportTopicEnum? topic,
    String? subject,
    String? message,
    DateTime? createdAt,
  }) => SupportRequestModel(
    id: id ?? this.id,
    topic: topic ?? this.topic,
    subject: subject ?? this.subject,
    message: message ?? this.message,
    createdAt: createdAt ?? this.createdAt,
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'topic': topic.name,
    'subject': subject,
    'message': message,
    'createdAt': createdAt?.toIso8601String(),
  };

  String toJson() => json.encode(toMap());

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SupportRequestModel &&
        other.id == id &&
        other.topic == topic &&
        other.subject == subject &&
        other.message == message &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode => Object.hash(id, topic, subject, message, createdAt);
}
