import 'dart:convert';

enum LevelStatus {
  locked('locked'),
  unlocked('unlocked', aliases: {'available'}),
  inProgress('in_progress', aliases: {'inprogress', 'in-progress'}),
  completed('completed', aliases: {'done'}),
  unknown('unknown');

  const LevelStatus(this.wire, {this.aliases = const {}});

  final String wire;
  final Set<String> aliases;

  static LevelStatus fromWire(String? raw) {
    if (raw == null) return LevelStatus.unknown;
    final key = raw.toLowerCase();
    return values.firstWhere(
      (v) => v.wire == key || v.aliases.contains(key),
      orElse: () => LevelStatus.unknown,
    );
  }
}

class LevelModel {
  const LevelModel({
    required this.id,
    required this.title,
    required this.order,
    required this.questionCount,
    required this.completedQuestions,
    required this.passingGrade,
    required this.status,
  });

  final int id;
  final String title;
  final int order;
  final int questionCount;
  final int completedQuestions;
  final int passingGrade;
  final LevelStatus status;

  bool get isCompleted => status == LevelStatus.completed;
  bool get isInProgress => status == LevelStatus.inProgress;
  bool get isUnlocked =>
      status == LevelStatus.unlocked || status == LevelStatus.inProgress;
  bool get isLocked => status == LevelStatus.locked;

  double get progress {
    if (questionCount <= 0) return 0;
    return (completedQuestions / questionCount).clamp(0, 1);
  }

  int get progressPercent => (progress * 100).round();

  factory LevelModel.fromMap(Map<String, dynamic> map) => LevelModel(
    id: (map['id'] as num).toInt(),
    title: (map['title'] ?? '') as String,
    order: (map['order'] as num?)?.toInt() ?? 0,
    questionCount: (map['questionCount'] as num?)?.toInt() ?? 0,
    completedQuestions: (map['completedQuestions'] as num?)?.toInt() ?? 0,
    passingGrade: (map['passingGrade'] as num?)?.toInt() ?? 0,
    status: LevelStatus.fromWire(map['status'] as String?),
  );

  factory LevelModel.fromJson(String source) =>
      LevelModel.fromMap(json.decode(source) as Map<String, dynamic>);

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'order': order,
    'questionCount': questionCount,
    'completedQuestions': completedQuestions,
    'passingGrade': passingGrade,
    'status': status.wire,
  };

  String toJson() => json.encode(toMap());

  LevelModel copyWith({
    int? id,
    String? title,
    int? order,
    int? questionCount,
    int? completedQuestions,
    int? passingGrade,
    LevelStatus? status,
  }) => LevelModel(
    id: id ?? this.id,
    title: title ?? this.title,
    order: order ?? this.order,
    questionCount: questionCount ?? this.questionCount,
    completedQuestions: completedQuestions ?? this.completedQuestions,
    passingGrade: passingGrade ?? this.passingGrade,
    status: status ?? this.status,
  );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LevelModel &&
        other.id == id &&
        other.title == title &&
        other.order == order &&
        other.questionCount == questionCount &&
        other.completedQuestions == completedQuestions &&
        other.passingGrade == passingGrade &&
        other.status == status;
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    order,
    questionCount,
    completedQuestions,
    passingGrade,
    status,
  );

  @override
  String toString() =>
      'LevelModel(id: $id, title: $title, order: $order, status: ${status.wire}, '
      '$completedQuestions/$questionCount Q, pass: $passingGrade)';
}
