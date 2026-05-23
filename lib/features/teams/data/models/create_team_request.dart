import 'dart:convert';

class CreateTeamRequest {
  const CreateTeamRequest({required this.name});

  final String name;

  Map<String, dynamic> toMap() => {'name': name};

  String toJson() => json.encode(toMap());
}
