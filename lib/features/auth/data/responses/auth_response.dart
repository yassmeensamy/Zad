import 'dart:convert';

import '../../../../core/models/user_model.dart';

class AuthResponse {
  /// Returned by the signup endpoint (HTTP 202) when the account exists but the
  /// email has not been verified yet. In this state [accessToken] /
  /// [refreshToken] are empty and the user must confirm via a verification code.
  static const String pendingVerificationToken = 'pending_verification';

  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final String userId;
  final UserRole role;
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
    // Empty/absent during a `pending_verification` signup (HTTP 202).
    accessToken: map['accessToken'] as String? ?? '',
    refreshToken: map['refreshToken'] as String? ?? '',
    tokenType: map['tokenType'] as String? ?? 'Bearer',
    userId: map['userId'] as String? ?? '',
    role: UserRole.fromWire(map['role'] as String? ?? UserRole.parent.wire),
    fullName: map['fullName'] as String? ?? '',
  );

  factory AuthResponse.fromJson(String source) =>
      AuthResponse.fromMap(json.decode(source) as Map<String, dynamic>);

  /// Whether this response represents an account awaiting email verification.
  bool get isPendingVerification => tokenType == pendingVerificationToken;

  AuthResponse copyWith({
    String? accessToken,
    String? refreshToken,
    String? tokenType,
    String? userId,
    UserRole? role,
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
    'role': role.wire,
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
