import 'dart:convert';

import 'level_model.dart';
import 'pagination.dart';

class LevelsResponse {
  const LevelsResponse({required this.levels, required this.pagination});

  final List<LevelModel> levels;
  final Pagination pagination;

  factory LevelsResponse.fromMap(Map<String, dynamic> map) => LevelsResponse(
    levels: (map['data'] as List<dynamic>? ?? const [])
        .map((e) => LevelModel.fromMap(e as Map<String, dynamic>))
        .toList(),
    pagination: Pagination.fromMap(
      (map['pagination'] as Map<String, dynamic>?) ?? const {},
    ),
  );

  factory LevelsResponse.fromJson(String source) =>
      LevelsResponse.fromMap(json.decode(source) as Map<String, dynamic>);

  Map<String, dynamic> toMap() => {
    'data': levels.map((l) => l.toMap()).toList(),
    'pagination': pagination.toMap(),
  };

  String toJson() => json.encode(toMap());

  LevelsResponse copyWith({
    List<LevelModel>? levels,
    Pagination? pagination,
  }) => LevelsResponse(
    levels: levels ?? this.levels,
    pagination: pagination ?? this.pagination,
  );

  @override
  String toString() =>
      'LevelsResponse(levels: ${levels.length}, pagination: $pagination)';
}
