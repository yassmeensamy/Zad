import 'dart:convert';

class DailyCheckInModel {
  const DailyCheckInModel({
    required this.pointAwarded,
    required this.totalPoints,
    this.message,
    this.checkInDate,
  });

  final bool pointAwarded;
  final int totalPoints;
  final String? message;
  final DateTime? checkInDate;

  factory DailyCheckInModel.fromMap(Map<String, dynamic> map) =>
      DailyCheckInModel(
        pointAwarded: map['pointAwarded'] as bool? ?? false,
        totalPoints: (map['totalPoints'] as num?)?.toInt() ?? 0,
        message: map['message'] as String?,
        checkInDate: map['checkInDate'] == null
            ? null
            : DateTime.tryParse(map['checkInDate'] as String),
      );

  factory DailyCheckInModel.fromJson(String source) =>
      DailyCheckInModel.fromMap(json.decode(source) as Map<String, dynamic>);

  Map<String, dynamic> toMap() => {
    'pointAwarded': pointAwarded,
    'totalPoints': totalPoints,
    'message': message,
    'checkInDate': checkInDate?.toIso8601String(),
  };

  String toJson() => json.encode(toMap());

  DailyCheckInModel copyWith({
    bool? pointAwarded,
    int? totalPoints,
    String? message,
    DateTime? checkInDate,
  }) => DailyCheckInModel(
    pointAwarded: pointAwarded ?? this.pointAwarded,
    totalPoints: totalPoints ?? this.totalPoints,
    message: message ?? this.message,
    checkInDate: checkInDate ?? this.checkInDate,
  );

  @override
  String toString() =>
      'DailyCheckInModel(pointAwarded: $pointAwarded, '
      'totalPoints: $totalPoints, message: $message, '
      'checkInDate: $checkInDate)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DailyCheckInModel &&
        other.pointAwarded == pointAwarded &&
        other.totalPoints == totalPoints &&
        other.message == message &&
        other.checkInDate == checkInDate;
  }

  @override
  int get hashCode =>
      Object.hash(pointAwarded, totalPoints, message, checkInDate);
}
