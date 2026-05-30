import 'level_model.dart';
import 'pagination.dart';

class LevelsResponse {
  const LevelsResponse({
    required this.levels,
    required this.pagination,
    this.completedLevels,
    this.totalLevels,
  });

  final List<LevelModel> levels;
  final Pagination pagination;

  /// Category-wide completed count, independent of the current page. Present
  /// only when the backend returns a `summary` block; `null` otherwise (the
  /// presentation layer then falls back to counting the loaded page).
  final int? completedLevels;

  /// Category-wide total count, independent of the current page. Falls back to
  /// [Pagination.total] when absent.
  final int? totalLevels;

  factory LevelsResponse.fromMap(Map<String, dynamic> map) {
    final summary = map['summary'] as Map<String, dynamic>?;
    return LevelsResponse(
      levels: (map['data'] as List<dynamic>? ?? const [])
          .map((e) => LevelModel.fromMap(e as Map<String, dynamic>))
          .toList(),
      pagination: Pagination.fromMap(
        (map['pagination'] as Map<String, dynamic>?) ?? const {},
      ),
      completedLevels: (summary?['completedLevels'] as num?)?.toInt(),
      totalLevels: (summary?['totalLevels'] as num?)?.toInt(),
    );
  }

  @override
  String toString() =>
      'LevelsResponse(levels: ${levels.length}, pagination: $pagination)';
}
