import 'package:flutter/foundation.dart';

import '../../data/models/learn_category.dart';

enum LearnStatus { initial, loading, loaded, error }

class LearnState {
  const LearnState({
    this.status = LearnStatus.initial,
    this.categories = const [],
    this.errorMessage,
  });

  final LearnStatus status;
  final List<LearnCategory> categories;
  final String? errorMessage;

  LearnState copyWith({
    LearnStatus? status,
    List<LearnCategory>? categories,
    String? Function()? errorMessage,
  }) =>
      LearnState(
        status: status ?? this.status,
        categories: categories ?? this.categories,
        errorMessage:
            errorMessage != null ? errorMessage() : this.errorMessage,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LearnState &&
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

extension LearnStateX on LearnState {
  bool get isInitial => status == LearnStatus.initial;
  bool get isLoading => status == LearnStatus.loading;
  bool get isLoaded => status == LearnStatus.loaded;
  bool get isError => status == LearnStatus.error;

  bool get hasCategories => categories.isNotEmpty;

  double get overallProgress {
    if (categories.isEmpty) return 0;
    final sum = categories.fold<double>(0, (a, c) => a + c.progress);
    return (sum / categories.length).clamp(0, 1);
  }

  LearnCategory? findById(LearnCategoryId id) {
    for (final c in categories) {
      if (c.id == id) return c;
    }
    return null;
  }
}
