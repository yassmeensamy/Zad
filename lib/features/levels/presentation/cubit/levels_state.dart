import 'package:flutter/foundation.dart';

import '../../data/models/level_model.dart';
import '../../data/models/pagination.dart';

enum LevelsStatus { initial, loading, loaded, error }

class LevelsState {
  const LevelsState({
    this.status = LevelsStatus.initial,
    this.levels = const [],
    this.pagination,
    this.isLoadingMore = false,
    this.errorMessage,
  });

  final LevelsStatus status;
  final List<LevelModel> levels;
  final Pagination? pagination;
  final bool isLoadingMore;
  final String? errorMessage;

  LevelsState copyWith({
    LevelsStatus? status,
    List<LevelModel>? levels,
    Pagination? Function()? pagination,
    bool? isLoadingMore,
    String? Function()? errorMessage,
  }) =>
      LevelsState(
        status: status ?? this.status,
        levels: levels ?? this.levels,
        pagination:
            pagination != null ? pagination() : this.pagination,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
        errorMessage:
            errorMessage != null ? errorMessage() : this.errorMessage,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LevelsState &&
        other.status == status &&
        listEquals(other.levels, levels) &&
        other.pagination == pagination &&
        other.isLoadingMore == isLoadingMore &&
        other.errorMessage == errorMessage;
  }

  @override
  int get hashCode => Object.hashAll([
        status,
        Object.hashAll(levels),
        pagination,
        isLoadingMore,
        errorMessage,
      ]);
}

extension LevelsStateX on LevelsState {
  bool get isInitial => status == LevelsStatus.initial;
  bool get isLoading => status == LevelsStatus.loading;
  bool get isLoaded => status == LevelsStatus.loaded;
  bool get isError => status == LevelsStatus.error;

  bool get hasLevels => levels.isNotEmpty;
  bool get hasMore => pagination?.hasNext ?? false;

  int get completedCount => levels.where((l) => l.isCompleted).length;
  int get totalCount => pagination?.total ?? levels.length;

  double get progress {
    if (totalCount == 0) return 0;
    return (completedCount / totalCount).clamp(0, 1);
  }
}
