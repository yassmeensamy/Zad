import 'dart:convert';

class JoinTeamRequest {
  const JoinTeamRequest({required this.joinCode});

  final String joinCode;

  Map<String, dynamic> toMap() => {'joinCode': joinCode};

  String toJson() => json.encode(toMap());
}
