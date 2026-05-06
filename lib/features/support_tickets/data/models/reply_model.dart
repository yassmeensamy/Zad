import 'dart:convert';

import '../../../../core/utils/date_parsing.dart';

class ReplyModel {
  const ReplyModel({
    required this.id,
    required this.content,
    required this.adminReply,
    this.internalNote,
    this.createdAt,
  });

  final int id;
  final String content;
  final String? internalNote;
  final DateTime? createdAt;
  final bool adminReply;

  factory ReplyModel.fromMap(Map<String, dynamic> map) => ReplyModel(
        id: (map['id'] as num).toInt(),
        content: map['content'] as String? ?? '',
        internalNote: map['internalNote'] as String?,
        createdAt: parseIsoDate(map['createdAt']),
        adminReply: map['adminReply'] as bool? ?? false,
      );

  factory ReplyModel.fromJson(String source) =>
      ReplyModel.fromMap(json.decode(source) as Map<String, dynamic>);

  Map<String, dynamic> toMap() => {
        'id': id,
        'content': content,
        if (internalNote != null) 'internalNote': internalNote,
        if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
        'adminReply': adminReply,
      };

  String toJson() => json.encode(toMap());

  ReplyModel copyWith({
    int? id,
    String? content,
    String? internalNote,
    DateTime? createdAt,
    bool? adminReply,
  }) =>
      ReplyModel(
        id: id ?? this.id,
        content: content ?? this.content,
        internalNote: internalNote ?? this.internalNote,
        createdAt: createdAt ?? this.createdAt,
        adminReply: adminReply ?? this.adminReply,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ReplyModel &&
        other.id == id &&
        other.content == content &&
        other.internalNote == internalNote &&
        other.createdAt == createdAt &&
        other.adminReply == adminReply;
  }

  @override
  int get hashCode =>
      Object.hash(id, content, internalNote, createdAt, adminReply);
}
