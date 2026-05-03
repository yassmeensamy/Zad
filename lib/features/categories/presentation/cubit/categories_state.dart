import 'package:flutter/foundation.dart';

import '../../data/models/category_model.dart';

enum CategoriesStatus { initial, loading, loaded, error }

class CategoriesState {
  const CategoriesState({
    this.status = CategoriesStatus.initial,
    this.categories = const [],
    this.errorMessage,
  });

  final CategoriesStatus status;
  final List<CategoryModel> categories;
  final String? errorMessage;

  CategoriesState copyWith({
    CategoriesStatus? status,
    List<CategoryModel>? categories,
    String? Function()? errorMessage,
  }) =>
      CategoriesState(
        status: status ?? this.status,
        categories: categories ?? this.categories,
        errorMessage:
            errorMessage != null ? errorMessage() : this.errorMessage,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CategoriesState &&
        other.status == status &&
        listEquals(other.categories, categories) &&
        other.errorMessage == errorMessage;
  }

  @override
  int get hashCode => Object.hashAll([
        status,
        Object.hashAll(categories),
        errorMessage,
      ]);
}

extension CategoriesStateX on CategoriesState {
  bool get isInitial => status == CategoriesStatus.initial;
  bool get isLoading => status == CategoriesStatus.loading;
  bool get isLoaded => status == CategoriesStatus.loaded;
  bool get isError => status == CategoriesStatus.error;

  bool get hasCategories => categories.isNotEmpty;

  double get overallProgress {
    if (categories.isEmpty) return 0;
    final sum = categories.fold<double>(0, (a, c) => a + c.progress);
    return (sum / categories.length).clamp(0, 1);
  }

  CategoryModel? findById(int id) {
    for (final c in categories) {
      if (c.id == id) return c;
    }
    return null;
  }
}
