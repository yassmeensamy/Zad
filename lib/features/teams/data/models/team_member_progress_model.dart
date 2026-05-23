import 'dart:convert';

class TeamMemberProgressModel {
  const TeamMemberProgressModel({
    required this.userId,
    required this.username,
    required this.completedLevels,
    required this.totalLevels,
  });

  final String userId;
  final String username;
  final int completedLevels;
  final int totalLevels;

  double get progress {
    if (totalLevels <= 0) return 0;
    return (completedLevels / totalLevels).clamp(0, 1);
  }

  int get progressPercent => (progress * 100).round();

  factory TeamMemberProgressModel.fromMap(Map<String, dynamic> map) =>
      TeamMemberProgressModel(
        userId: map['userId'] as String? ?? '',
        username: map['username'] as String? ?? '',
        completedLevels: (map['completedLevels'] as num?)?.toInt() ?? 0,
        totalLevels: (map['totalLevels'] as num?)?.toInt() ?? 0,
      );

  factory TeamMemberProgressModel.fromJson(String source) =>
      TeamMemberProgressModel.fromMap(
        json.decode(source) as Map<String, dynamic>,
      );

  Map<String, dynamic> toMap() => {
    'userId': userId,
    'username': username,
    'completedLevels': completedLevels,
    'totalLevels': totalLevels,
  };

  String toJson() => json.encode(toMap());

  TeamMemberProgressModel copyWith({
    String? userId,
    String? username,
    int? completedLevels,
    int? totalLevels,
  }) => TeamMemberProgressModel(
    userId: userId ?? this.userId,
    username: username ?? this.username,
    completedLevels: completedLevels ?? this.completedLevels,
    totalLevels: totalLevels ?? this.totalLevels,
  );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TeamMemberProgressModel &&
        other.userId == userId &&
        other.username == username &&
        other.completedLevels == completedLevels &&
        other.totalLevels == totalLevels;
  }

  @override
  int get hashCode =>
      Object.hash(userId, username, completedLevels, totalLevels);

  @override
  String toString() =>
      'TeamMemberProgressModel(userId: $userId, username: $username, '
      '$completedLevels/$totalLevels)';
}
