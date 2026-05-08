import 'dart:convert';

class AvatarModel {
  const AvatarModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.createdAt,
  });

  final String id;
  final String name;
  final String imageUrl;
  final DateTime? createdAt;

  factory AvatarModel.fromMap(Map<String, dynamic> map) => AvatarModel(
    id: (map['id'] ?? '') as String,
    name: (map['name'] ?? '') as String,
    imageUrl: (map['imageUrl'] ?? '') as String,
    createdAt: map['createdAt'] == null
        ? null
        : DateTime.tryParse(map['createdAt'] as String),
  );

  factory AvatarModel.fromJson(String source) =>
      AvatarModel.fromMap(json.decode(source) as Map<String, dynamic>);

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'imageUrl': imageUrl,
    'createdAt': createdAt?.toIso8601String(),
  };

  String toJson() => json.encode(toMap());

  AvatarModel copyWith({
    String? id,
    String? name,
    String? imageUrl,
    DateTime? createdAt,
  }) => AvatarModel(
    id: id ?? this.id,
    name: name ?? this.name,
    imageUrl: imageUrl ?? this.imageUrl,
    createdAt: createdAt ?? this.createdAt,
  );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AvatarModel &&
        other.id == id &&
        other.name == name &&
        other.imageUrl == imageUrl &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode => Object.hash(id, name, imageUrl, createdAt);

  @override
  String toString() =>
      'AvatarModel(id: $id, name: $name, imageUrl: $imageUrl)';
}
