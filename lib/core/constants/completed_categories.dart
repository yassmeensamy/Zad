/// Categories whose level list is finished, so the rail should stop at the
/// last real level instead of ending on a "coming soon" row that promises
/// content nobody is writing.
///
/// Hardcoded because the API has no "complete" flag to read; drop an id from
/// here again the moment that category starts taking new levels.
abstract class CompletedCategories {
  static const Set<int> ids = {212};

  static bool contains(int categoryId) => ids.contains(categoryId);
}
