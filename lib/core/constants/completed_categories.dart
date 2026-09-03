abstract class CompletedCategories {
  static const Set<int> ids = {-1};

  static bool contains(int categoryId) => ids.contains(categoryId);
}
