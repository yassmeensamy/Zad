class LogInResponse {
  final String sessionToken;
  final bool isActive;

  const LogInResponse({required this.sessionToken, required this.isActive});

  factory LogInResponse.fromMap(Map<String, dynamic> map) => LogInResponse(
    sessionToken: map['meta']['session_token'] as String,
    isActive: map['meta']['is_active'] as bool,
  );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LogInResponse &&
        other.sessionToken == sessionToken &&
        other.isActive == isActive;
  }

  @override
  int get hashCode => sessionToken.hashCode ^ isActive.hashCode;
}
