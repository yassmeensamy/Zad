/// Pagination envelope returned by the global ranking endpoints.
///
/// Distinct from the levels `Pagination` model: the rankings API uses
/// `currentPage` / `totalPages` / `totalElements` rather than
/// `page` / `size` / `total`.
class RankingPagination {
  const RankingPagination({
    required this.currentPage,
    required this.totalPages,
    required this.totalElements,
    this.next,
    this.previous,
  });

  final int currentPage;
  final int totalPages;
  final int totalElements;
  final String? next;
  final String? previous;

  /// True when another page can be fetched after [currentPage].
  bool get hasNext => currentPage < totalPages - 1;
  bool get hasPrevious => currentPage > 0;

  factory RankingPagination.fromMap(Map<String, dynamic> map) =>
      RankingPagination(
        currentPage: (map['currentPage'] as num?)?.toInt() ?? 0,
        totalPages: (map['totalPages'] as num?)?.toInt() ?? 0,
        totalElements: (map['totalElements'] as num?)?.toInt() ?? 0,
        next: map['next'] as String?,
        previous: map['previous'] as String?,
      );

  Map<String, dynamic> toMap() => {
    'currentPage': currentPage,
    'totalPages': totalPages,
    'totalElements': totalElements,
    'next': next,
    'previous': previous,
  };

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RankingPagination &&
        other.currentPage == currentPage &&
        other.totalPages == totalPages &&
        other.totalElements == totalElements &&
        other.next == next &&
        other.previous == previous;
  }

  @override
  int get hashCode =>
      Object.hash(currentPage, totalPages, totalElements, next, previous);

  @override
  String toString() =>
      'RankingPagination(page: $currentPage/$totalPages, '
      'total: $totalElements)';
}
