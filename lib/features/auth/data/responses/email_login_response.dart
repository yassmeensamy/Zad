import 'log_in_response.dart';

class EmailLoginResponse extends LogInResponse {
  final bool isAuthenticated;

  const EmailLoginResponse({
    required super.sessionToken,
    required super.isActive,
    required this.isAuthenticated,
  });

  factory EmailLoginResponse.fromMap(Map<String, dynamic> map) =>
      EmailLoginResponse(
        sessionToken: map['meta']['session_token'] as String,
        isActive: map['meta']['is_active'] as bool,
        isAuthenticated: map['meta']['is_authenticated'] as bool,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EmailLoginResponse &&
        other.sessionToken == sessionToken &&
        other.isActive == isActive &&
        other.isAuthenticated == isAuthenticated;
  }

  @override
  int get hashCode =>
      sessionToken.hashCode ^ isActive.hashCode ^ isAuthenticated.hashCode;
}
