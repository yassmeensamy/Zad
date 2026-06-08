import 'dart:convert';

import '../../../../core/models/user_model.dart';

class AuthResponse {
  static const String pendingVerificationToken = 'pending_verification';

  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final String userId;
  final UserRole role;
  final String fullName;

  final bool isAnonymous;

  const AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
    required this.userId,
    required this.role,
    required this.fullName,
    this.isAnonymous = false,
  });

  factory AuthResponse.fromMap(Map<String, dynamic> map) => AuthResponse(
    accessToken: map['accessToken'] as String? ?? '',
    refreshToken: map['refreshToken'] as String? ?? '',
    tokenType: map['tokenType'] as String? ?? 'Bearer',
    userId: map['userId'] as String? ?? '',
    role: UserRole.fromWire(map['role'] as String? ?? UserRole.parent.wire),
    fullName: map['fullName'] as String? ?? '',
    isAnonymous: map['isAnonymous'] as bool? ?? false,
  );

  factory AuthResponse.fromJson(String source) =>
      AuthResponse.fromMap(json.decode(source) as Map<String, dynamic>);

  bool get isPendingVerification => tokenType == pendingVerificationToken;

  AuthResponse copyWith({
    String? accessToken,
    String? refreshToken,
    String? tokenType,
    String? userId,
    UserRole? role,
    String? fullName,
    bool? isAnonymous,
  }) => AuthResponse(
    accessToken: accessToken ?? this.accessToken,
    refreshToken: refreshToken ?? this.refreshToken,
    tokenType: tokenType ?? this.tokenType,
    userId: userId ?? this.userId,
    role: role ?? this.role,
    fullName: fullName ?? this.fullName,
    isAnonymous: isAnonymous ?? this.isAnonymous,
  );

  Map<String, dynamic> toMap() => {
    'accessToken': accessToken,
    'refreshToken': refreshToken,
    'tokenType': tokenType,
    'userId': userId,
    'role': role.wire,
    'fullName': fullName,
    'isAnonymous': isAnonymous,
  };

  String toJson() => json.encode(toMap());

  @override
  String toString() =>
      'AuthResponse(accessToken: $accessToken, refreshToken: $refreshToken, '
      'tokenType: $tokenType, userId: $userId, role: $role, '
      'fullName: $fullName, isAnonymous: $isAnonymous)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuthResponse &&
        other.accessToken == accessToken &&
        other.refreshToken == refreshToken &&
        other.tokenType == tokenType &&
        other.userId == userId &&
        other.role == role &&
        other.fullName == fullName &&
        other.isAnonymous == isAnonymous;
  }

  @override
  int get hashCode => Object.hash(
    accessToken,
    refreshToken,
    tokenType,
    userId,
    role,
    fullName,
    isAnonymous,
  );
}
