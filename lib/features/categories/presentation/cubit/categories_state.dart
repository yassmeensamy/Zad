import 'package:flutter/foundation.dart';

import '../../data/models/category_model.dart';

enum CategoriesStatus { initial, loading, loaded, error }

class CategoriesState {
  const CategoriesState({
    this.status = CategoriesStatus.initial,
    this.categories = const [],
    this.errorMessage,
    this.resettingCategoryIds = const {},
  });

  final CategoriesStatus status;
  final List<CategoryModel> categories;
  final String? errorMessage;

  /// Ids of categories whose progress is currently being reset. Drives the
  /// per-card spinner while a reset is in flight.
  final Set<int> resettingCategoryIds;

  CategoriesState copyWith({
    CategoriesStatus? status,
    List<CategoryModel>? categories,
    String? Function()? errorMessage,
    Set<int>? resettingCategoryIds,
  }) => CategoriesState(
    status: status ?? this.status,
    categories: categories ?? this.categories,
    errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
    resettingCategoryIds: resettingCategoryIds ?? this.resettingCategoryIds,
  );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CategoriesState &&
        other.status == status &&
        listEquals(other.categories, categories) &&
        other.errorMessage == errorMessage &&
        setEquals(other.resettingCategoryIds, resettingCategoryIds);
  }

  @override
  int get hashCode => Object.hashAll([
    status,
    Object.hashAll(categories),
    errorMessage,
    Object.hashAllUnordered(resettingCategoryIds),
  ]);
}

extension CategoriesStateX on CategoriesState {
  bool get isInitial => status == CategoriesStatus.initial;
  bool get isLoading => status == CategoriesStatus.loading;
  bool get isError => status == CategoriesStatus.error;

  bool get hasCategories => categories.isNotEmpty;

  bool isResetting(int categoryId) => resettingCategoryIds.contains(categoryId);

  double get overallProgress {
    if (categories.isEmpty) return 0;
    final sum = categories.fold<double>(0, (a, c) => a + c.progress);
    return (sum / categories.length).clamp(0, 1);
  }
}
