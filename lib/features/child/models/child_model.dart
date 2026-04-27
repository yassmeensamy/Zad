import 'dart:convert';

class ChildModel {
  final String id;
  final String? username;
  final String fullName;
  final DateTime? birthDate;
  final String? parentId;
  final DateTime? createdAt;

  const ChildModel({
    required this.id,
    required this.fullName,
    this.username,
    this.parentId,
    this.createdAt,
    this.birthDate,
  });

  factory ChildModel.fromMap(Map<String, dynamic> map) => ChildModel(
    id: map['id'] as String,
    username: map['username'] as String?,
    fullName: (map['fullName'] ?? map['name'] ?? '') as String,
    birthDate: map['birthDate'] == null
        ? null
        : DateTime.parse(map['birthDate'] as String).toLocal(),
    parentId: map['parentId'] as String?,
    createdAt: map['createdAt'] == null
        ? null
        : DateTime.parse(map['createdAt'] as String).toLocal(),
  );

  factory ChildModel.fromJson(String source) =>
      ChildModel.fromMap(json.decode(source) as Map<String, dynamic>);

  Map<String, dynamic> toMap() => {
    'id': id,
    'username': username,
    'fullName': fullName,
    'birthDate': birthDate?.toIso8601String(),
    'parentId': parentId,
    'createdAt': createdAt?.toIso8601String(),
  };

  String toJson() => json.encode(toMap());

  ChildModel copyWith({
    String? id,
    String? username,
    String? fullName,
    DateTime? birthDate,
    String? parentId,
    DateTime? createdAt,
  }) => ChildModel(
    id: id ?? this.id,
    username: username ?? this.username,
    fullName: fullName ?? this.fullName,
    birthDate: birthDate ?? this.birthDate,
    parentId: parentId ?? this.parentId,
    createdAt: createdAt ?? this.createdAt,
  );

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
      'ChildModel(id: $id, username: $username, fullName: $fullName, '
      'birthDate: $birthDate, parentId: $parentId, createdAt: $createdAt)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChildModel &&
        other.id == id &&
        other.username == username &&
        other.fullName == fullName &&
        other.birthDate == birthDate &&
        other.parentId == parentId &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode =>
      Object.hash(id, username, fullName, birthDate, parentId, createdAt);
}
