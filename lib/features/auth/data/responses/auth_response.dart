import 'dart:convert';

class AuthResponse {
  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final String userId;
  final String role;
  final String fullName;

  const AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
    required this.userId,
    required this.role,
    required this.fullName,
  });

  factory AuthResponse.fromMap(Map<String, dynamic> map) => AuthResponse(
    accessToken: map['accessToken'] as String,
    refreshToken: map['refreshToken'] as String,
    tokenType: map['tokenType'] as String? ?? 'Bearer',
    userId: map['userId'] as String,
    role: map['role'] as String,
    fullName: map['fullName'] as String,
  );

  factory AuthResponse.fromJson(String source) =>
      AuthResponse.fromMap(json.decode(source) as Map<String, dynamic>);

  AuthResponse copyWith({
    String? accessToken,
    String? refreshToken,
    String? tokenType,
    String? userId,
    String? role,
    String? fullName,
  }) => AuthResponse(
    accessToken: accessToken ?? this.accessToken,
    refreshToken: refreshToken ?? this.refreshToken,
    tokenType: tokenType ?? this.tokenType,
    userId: userId ?? this.userId,
    role: role ?? this.role,
    fullName: fullName ?? this.fullName,
  );

  Map<String, dynamic> toMap() => {
    'accessToken': accessToken,
    'refreshToken': refreshToken,
    'tokenType': tokenType,
    'userId': userId,
    'role': role,
    'fullName': fullName,
  };

  String toJson() => json.encode(toMap());

  @override
  String toString() =>
      'AuthResponse(accessToken: $accessToken, refreshToken: $refreshToken, '
      'tokenType: $tokenType, userId: $userId, role: $role, fullName: $fullName)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuthResponse &&
        other.accessToken == accessToken &&
        other.refreshToken == refreshToken &&
        other.tokenType == tokenType &&
        other.userId == userId &&
        other.role == role &&
        other.fullName == fullName;
  }

  @override
  int get hashCode =>
      Object.hash(accessToken, refreshToken, tokenType, userId, role, fullName);
}
