import 'dart:convert';

import 'support_topic_enum.dart';

class CreateTicketRequest {
  const CreateTicketRequest({
    required this.topic,
    required this.title,
    required this.body,
    this.questionId,
  });

  final SupportTopicEnum topic;
  final String title;
  final String body;
  final int? questionId;

  Map<String, dynamic> toMap() => {
        'topic': topic.toApi(),
        'title': title,
        'body': body,
        if (questionId != null) 'questionId': questionId,
      };

  String toJson() => json.encode(toMap());
}
