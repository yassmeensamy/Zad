import 'dart:convert';

class CreateDraftRequest {
  const CreateDraftRequest({required this.questionId, this.note});

  final int questionId;
  final String? note;

  Map<String, dynamic> toMap() => {
        'questionId': questionId,
        if (note != null) 'note': note,
      };

  String toJson() => json.encode(toMap());
}

class UpdateDraftRequest {
  const UpdateDraftRequest({this.note});

  final String? note;

  Map<String, dynamic> toMap() => {
        if (note != null) 'note': note,
      };

  String toJson() => json.encode(toMap());
}
