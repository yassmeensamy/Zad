import 'dart:convert';

import '../../../support_tickets/data/models/support_topic_enum.dart';

export '../../../support_tickets/data/models/support_topic_enum.dart';

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
  }) =>
      SupportRequestModel(
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
