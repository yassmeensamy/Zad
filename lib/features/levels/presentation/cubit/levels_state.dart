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
    this.resettingLevelIds = const {},
    this.summaryCompleted,
    this.summaryTotal,
  });

  final LevelsStatus status;
  final List<LevelModel> levels;
  final Pagination? pagination;
  final bool isLoadingMore;
  final String? errorMessage;

  /// Ids of levels whose progress is currently being reset. Drives the
  /// per-level spinner so multiple resets can be in flight at once.
  final Set<int> resettingLevelIds;

  /// Category-wide completed/total counts from the backend `summary`, when
  /// available. Independent of the loaded page so progress stays correct
  /// across pagination. `null` falls back to deriving from loaded levels.
  final int? summaryCompleted;
  final int? summaryTotal;

  LevelsState copyWith({
    LevelsStatus? status,
    List<LevelModel>? levels,
    Pagination? Function()? pagination,
    bool? isLoadingMore,
    String? Function()? errorMessage,
    Set<int>? resettingLevelIds,
    int? Function()? summaryCompleted,
    int? Function()? summaryTotal,
  }) => LevelsState(
    status: status ?? this.status,
    levels: levels ?? this.levels,
    pagination: pagination != null ? pagination() : this.pagination,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
    resettingLevelIds: resettingLevelIds ?? this.resettingLevelIds,
    summaryCompleted: summaryCompleted != null
        ? summaryCompleted()
        : this.summaryCompleted,
    summaryTotal: summaryTotal != null ? summaryTotal() : this.summaryTotal,
  );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LevelsState &&
        other.status == status &&
        listEquals(other.levels, levels) &&
        other.pagination == pagination &&
        other.isLoadingMore == isLoadingMore &&
        other.errorMessage == errorMessage &&
        setEquals(other.resettingLevelIds, resettingLevelIds) &&
        other.summaryCompleted == summaryCompleted &&
        other.summaryTotal == summaryTotal;
  }

  @override
  int get hashCode => Object.hashAll([
    status,
    Object.hashAll(levels),
    pagination,
    isLoadingMore,
    errorMessage,
    Object.hashAllUnordered(resettingLevelIds),
    summaryCompleted,
    summaryTotal,
  ]);
}

extension LevelsStateX on LevelsState {
  bool get isInitial => status == LevelsStatus.initial;
  bool get isLoading => status == LevelsStatus.loading;
  bool get isError => status == LevelsStatus.error;

  bool get hasLevels => levels.isNotEmpty;
  bool get hasMore => pagination?.hasNext ?? false;

  bool isResetting(int levelId) => resettingLevelIds.contains(levelId);

  /// Category-wide completed count. Prefers the backend `summary`; otherwise
  /// falls back to counting the loaded page (which under-reports until every
  /// page is loaded — see [summaryCompleted]).
  int get completedCount =>
      summaryCompleted ?? levels.where((l) => l.isCompleted).length;

  /// Category-wide total. Prefers the backend `summary`, then pagination total,
  /// then the loaded count.
  int get totalCount => summaryTotal ?? pagination?.total ?? levels.length;

  double get progress {
    if (totalCount == 0) return 0;
    return (completedCount / totalCount).clamp(0, 1);
  }
}
