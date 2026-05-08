import 'dart:convert';

import '../../features/onboarding_flow/data/avatar_model.dart';

enum UserRole {
  parent('ROLE_PARENT'),
  child('ROLE_CHILD');

  const UserRole(this.wire);

  final String wire;

  static UserRole fromWire(String value) =>
      UserRole.values.firstWhere((r) => r.wire == value);
}

class UserModel {
  final String id;
  final String? email;
  final String? username;
  final String fullName;
  final UserRole role;
  final bool googleLinked;
  final DateTime? birthDate;
  final String? parentId;
  final DateTime createdAt;
  final AvatarModel? avatar;

  const UserModel({
    required this.id,
    required this.fullName,
    required this.role,
    required this.createdAt,
    this.email,
    this.username,
    this.googleLinked = false,
    this.birthDate,
    this.parentId,
    this.avatar,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) => UserModel(
    id: map['id'] as String,
    email: map['email'] as String?,
    username: map['username'] as String?,
    fullName: map['fullName'] as String,
    role: UserRole.fromWire(map['role'] as String),
    googleLinked: map['googleLinked'] as bool? ?? false,
    birthDate: map['birthDate'] == null
        ? null
        : DateTime.parse(map['birthDate'] as String).toLocal(),
    parentId: map['parentId'] as String?,
    createdAt: DateTime.parse(map['createdAt'] as String).toLocal(),
    avatar: map['avatar'] == null
        ? null
        : AvatarModel.fromMap(map['avatar'] as Map<String, dynamic>),
  );

  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(json.decode(source) as Map<String, dynamic>);

  UserModel copyWith({
    String? id,
    String? email,
    String? username,
    String? fullName,
    UserRole? role,
    bool? googleLinked,
    DateTime? birthDate,
    String? parentId,
    DateTime? createdAt,
    AvatarModel? avatar,
  }) => UserModel(
    id: id ?? this.id,
    email: email ?? this.email,
    username: username ?? this.username,
    fullName: fullName ?? this.fullName,
    role: role ?? this.role,
    googleLinked: googleLinked ?? this.googleLinked,
    birthDate: birthDate ?? this.birthDate,
    parentId: parentId ?? this.parentId,
    createdAt: createdAt ?? this.createdAt,
    avatar: avatar ?? this.avatar,
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'email': email,
    'username': username,
    'fullName': fullName,
    'role': role.wire,
    'googleLinked': googleLinked,
    'birthDate': birthDate?.toIso8601String(),
    'parentId': parentId,
    'createdAt': createdAt.toIso8601String(),
    'avatar': avatar?.toMap(),
  };

  String toJson() => json.encode(toMap());

  bool get isParent => role == UserRole.parent;
  bool get isChild => role == UserRole.child;

  int? get age {
    if (birthDate == null) return null;
    final now = DateTime.now();
    var years = now.year - birthDate!.year;
    final hadBirthday =
        now.month > birthDate!.month ||
        (now.month == birthDate!.month && now.day >= birthDate!.day);
    if (!hadBirthday) years--;
    return years;
  }

  @override
  String toString() =>
      'UserModel(id: $id, email: $email, username: $username, '
      'fullName: $fullName, role: $role, googleLinked: $googleLinked, '
      'birthDate: $birthDate, parentId: $parentId, createdAt: $createdAt)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel &&
        other.id == id &&
        other.email == email &&
        other.username == username &&
        other.fullName == fullName &&
        other.role == role &&
        other.googleLinked == googleLinked &&
        other.birthDate == birthDate &&
        other.parentId == parentId &&
        other.createdAt == createdAt &&
        other.avatar == avatar;
  }

  @override
  int get hashCode => Object.hash(
    id,
    email,
    username,
    fullName,
    role,
    googleLinked,
    birthDate,
    parentId,
    createdAt,
    avatar,
  );
}
