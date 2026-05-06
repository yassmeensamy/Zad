import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../../../core/utils/date_parsing.dart';
import 'reply_model.dart';
import 'support_topic_enum.dart';
import 'ticket_status_enum.dart';

class TicketModel {
  const TicketModel({
    required this.id,
    required this.userId,
    required this.userEmail,
    required this.userDisplayName,
    required this.topic,
    required this.title,
    required this.body,
    required this.status,
    this.questionId,
    this.latestReply,
    this.replyCount = 0,
    this.createdAt,
    this.updatedAt,
    this.replies = const [],
  });

  final String id;
  final String userId;
  final String userEmail;
  final String userDisplayName;
  final int? questionId;
  final SupportTopicEnum topic;
  final String title;
  final String body;
  final TicketStatusEnum status;
  final String? latestReply;
  final int replyCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<ReplyModel> replies;

  factory TicketModel.fromMap(Map<String, dynamic> map) => TicketModel(
        id: map['id'] as String? ?? '',
        userId: map['userId'] as String? ?? '',
        userEmail: map['userEmail'] as String? ?? '',
        userDisplayName: map['userDisplayName'] as String? ?? '',
        questionId: (map['questionId'] as num?)?.toInt(),
        topic: SupportTopicEnum.fromApi(map['topic'] as String?),
        title: map['title'] as String? ?? '',
        body: map['body'] as String? ?? '',
        status: TicketStatusEnum.fromApi(map['status'] as String?),
        latestReply: map['latestReply'] as String?,
        replyCount: (map['replyCount'] as num?)?.toInt() ?? 0,
        createdAt: parseIsoDate(map['createdAt']),
        updatedAt: parseIsoDate(map['updatedAt']),
        replies: (map['replies'] as List<dynamic>?)
                ?.map((e) => ReplyModel.fromMap(e as Map<String, dynamic>))
                .toList() ??
            const [],
      );

  factory TicketModel.fromJson(String source) =>
      TicketModel.fromMap(json.decode(source) as Map<String, dynamic>);

  Map<String, dynamic> toMap() => {
        'id': id,
        'userId': userId,
        'userEmail': userEmail,
        'userDisplayName': userDisplayName,
        if (questionId != null) 'questionId': questionId,
        'topic': topic.toApi(),
        'title': title,
        'body': body,
        'status': status.toApi(),
        if (latestReply != null) 'latestReply': latestReply,
        'replyCount': replyCount,
        if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
        if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
        'replies': replies.map((e) => e.toMap()).toList(),
      };

  String toJson() => json.encode(toMap());

  TicketModel copyWith({
    String? id,
    String? userId,
    String? userEmail,
    String? userDisplayName,
    int? questionId,
    SupportTopicEnum? topic,
    String? title,
    String? body,
    TicketStatusEnum? status,
    String? latestReply,
    int? replyCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<ReplyModel>? replies,
  }) =>
      TicketModel(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        userEmail: userEmail ?? this.userEmail,
        userDisplayName: userDisplayName ?? this.userDisplayName,
        questionId: questionId ?? this.questionId,
        topic: topic ?? this.topic,
        title: title ?? this.title,
        body: body ?? this.body,
        status: status ?? this.status,
        latestReply: latestReply ?? this.latestReply,
        replyCount: replyCount ?? this.replyCount,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        replies: replies ?? this.replies,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TicketModel &&
        other.id == id &&
        other.userId == userId &&
        other.userEmail == userEmail &&
        other.userDisplayName == userDisplayName &&
        other.questionId == questionId &&
        other.topic == topic &&
        other.title == title &&
        other.body == body &&
        other.status == status &&
        other.latestReply == latestReply &&
        other.replyCount == replyCount &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        listEquals(other.replies, replies);
  }

  @override
  int get hashCode => Object.hash(
        id,
        userId,
        userEmail,
        userDisplayName,
        questionId,
        topic,
        title,
        body,
        status,
        latestReply,
        replyCount,
        createdAt,
        updatedAt,
        Object.hashAll(replies),
      );

  @override
  String toString() => 'TicketModel(id: $id, status: $status, title: $title)';
}
