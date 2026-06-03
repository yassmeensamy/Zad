import 'dart:convert';

class DailyActivityModel {
  const DailyActivityModel({
    required this.date,
    required this.dayName,
    required this.active,
  });

  final DateTime? date;
  final String dayName;
  final bool active;

  factory DailyActivityModel.fromMap(Map<String, dynamic> map) =>
      DailyActivityModel(
        date: map['date'] == null
            ? null
            : DateTime.tryParse(map['date'] as String),
        dayName: (map['dayName'] ?? '') as String,
        active: map['active'] as bool? ?? false,
      );

  factory DailyActivityModel.fromJson(String source) =>
      DailyActivityModel.fromMap(json.decode(source) as Map<String, dynamic>);

  Map<String, dynamic> toMap() => {
    'date': date?.toIso8601String(),
    'dayName': dayName,
    'active': active,
  };

  String toJson() => json.encode(toMap());

  DailyActivityModel copyWith({
    DateTime? date,
    String? dayName,
    bool? active,
  }) => DailyActivityModel(
    date: date ?? this.date,
    dayName: dayName ?? this.dayName,
    active: active ?? this.active,
  );

  @override
  String toString() =>
      'DailyActivityModel(date: $date, dayName: $dayName, active: $active)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DailyActivityModel &&
        other.date == date &&
        other.dayName == dayName &&
        other.active == active;
  }

  @override
  int get hashCode => Object.hash(date, dayName, active);
}
