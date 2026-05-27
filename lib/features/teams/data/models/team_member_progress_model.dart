import 'dart:convert';

import 'member_activity_status_enum.dart';

class TeamMemberProgressModel {
  const TeamMemberProgressModel({
    required this.userId,
    required this.username,
    required this.completedLevels,
    required this.totalLevels,
    this.activityStatus = MemberActivityStatus.idle,
  });

  final String userId;
  final String username;
  final int completedLevels;
  final int totalLevels;
  final MemberActivityStatus activityStatus;

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
        activityStatus:
            MemberActivityStatus.fromApi(map['activityStatus'] as String?),
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
    'activityStatus': activityStatus.toApi(),
  };

  String toJson() => json.encode(toMap());

  TeamMemberProgressModel copyWith({
    String? userId,
    String? username,
    int? completedLevels,
    int? totalLevels,
    MemberActivityStatus? activityStatus,
  }) => TeamMemberProgressModel(
    userId: userId ?? this.userId,
    username: username ?? this.username,
    completedLevels: completedLevels ?? this.completedLevels,
    totalLevels: totalLevels ?? this.totalLevels,
    activityStatus: activityStatus ?? this.activityStatus,
  );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TeamMemberProgressModel &&
        other.userId == userId &&
        other.username == username &&
        other.completedLevels == completedLevels &&
        other.totalLevels == totalLevels &&
        other.activityStatus == activityStatus;
  }

  @override
  int get hashCode => Object.hash(
        userId,
        username,
        completedLevels,
        totalLevels,
        activityStatus,
      );

  @override
  String toString() =>
      'TeamMemberProgressModel(userId: $userId, username: $username, '
      '$completedLevels/$totalLevels, ${activityStatus.name})';
}
