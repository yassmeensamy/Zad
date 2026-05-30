class CategoryModel {
  const CategoryModel({
    required this.id,
    required this.name,
    required this.description,
    required this.iconUrl,
    required this.levelCount,
    required this.completedLevels,
    required this.orderIndex,
  });

  final int id;
  final String name;
  final String description;
  final String iconUrl;
  final int levelCount;
  final int completedLevels;
  final int orderIndex;

  double get progress {
    if (levelCount <= 0) return 0;
    return (completedLevels / levelCount).clamp(0, 1);
  }

  int get progressPercent => (progress * 100).round();

  factory CategoryModel.fromMap(Map<String, dynamic> map) => CategoryModel(
    id: (map['id'] as num).toInt(),
    name: (map['name'] ?? '') as String,
    description: (map['description'] ?? '') as String,
    iconUrl: (map['iconUrl'] ?? '') as String,
    levelCount: (map['levelCount'] as num?)?.toInt() ?? 0,
    completedLevels: (map['completedLevels'] as num?)?.toInt() ?? 0,
    orderIndex: (map['orderIndex'] as num?)?.toInt() ?? 0,
  );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CategoryModel &&
        other.id == id &&
        other.name == name &&
        other.description == description &&
        other.iconUrl == iconUrl &&
        other.levelCount == levelCount &&
        other.completedLevels == completedLevels &&
        other.orderIndex == orderIndex;
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    description,
    iconUrl,
    levelCount,
    completedLevels,
    orderIndex,
  );

  @override
  String toString() =>
      'CategoryModel(id: $id, name: $name, levelCount: $levelCount, '
      'completedLevels: $completedLevels, orderIndex: $orderIndex)';
}
