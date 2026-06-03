import 'dart:convert';

class StreakModel {
  const StreakModel({
    required this.currentStreak,
    required this.longestStreak,
    required this.status,
    this.lastActivityDate,
    this.statusName,
    this.statusLabel,
  });

  final int currentStreak;
  final int longestStreak;
  final DateTime? lastActivityDate;
  final String status;
  final String? statusName;
  final String? statusLabel;

  factory StreakModel.fromMap(Map<String, dynamic> map) => StreakModel(
    currentStreak: (map['currentStreak'] as num?)?.toInt() ?? 0,
    longestStreak: (map['longestStreak'] as num?)?.toInt() ?? 0,
    lastActivityDate: map['lastActivityDate'] == null
        ? null
        : DateTime.tryParse(map['lastActivityDate'] as String),
    status: (map['status'] ?? '') as String,
    statusName: map['statusName'] as String?,
    statusLabel: map['statusLabel'] as String?,
  );

  factory StreakModel.fromJson(String source) =>
      StreakModel.fromMap(json.decode(source) as Map<String, dynamic>);

  Map<String, dynamic> toMap() => {
    'currentStreak': currentStreak,
    'longestStreak': longestStreak,
    'lastActivityDate': lastActivityDate?.toIso8601String(),
    'status': status,
    'statusName': statusName,
    'statusLabel': statusLabel,
  };

  String toJson() => json.encode(toMap());

  StreakModel copyWith({
    int? currentStreak,
    int? longestStreak,
    DateTime? lastActivityDate,
    String? status,
    String? statusName,
    String? statusLabel,
  }) => StreakModel(
    currentStreak: currentStreak ?? this.currentStreak,
    longestStreak: longestStreak ?? this.longestStreak,
    lastActivityDate: lastActivityDate ?? this.lastActivityDate,
    status: status ?? this.status,
    statusName: statusName ?? this.statusName,
    statusLabel: statusLabel ?? this.statusLabel,
  );

  @override
  String toString() =>
      'StreakModel(currentStreak: $currentStreak, '
      'longestStreak: $longestStreak, lastActivityDate: $lastActivityDate, '
      'status: $status, statusName: $statusName, statusLabel: $statusLabel)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is StreakModel &&
        other.currentStreak == currentStreak &&
        other.longestStreak == longestStreak &&
        other.lastActivityDate == lastActivityDate &&
        other.status == status &&
        other.statusName == statusName &&
        other.statusLabel == statusLabel;
  }

  @override
  int get hashCode => Object.hash(
    currentStreak,
    longestStreak,
    lastActivityDate,
    status,
    statusName,
    statusLabel,
  );
}
