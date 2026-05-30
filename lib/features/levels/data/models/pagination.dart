class Pagination {
  const Pagination({
    required this.page,
    required this.size,
    required this.total,
    this.next,
    this.previous,
  });

  final int page;
  final int size;
  final int total;
  final String? next;
  final String? previous;

  bool get hasNext => next != null && next!.isNotEmpty;

  factory Pagination.fromMap(Map<String, dynamic> map) => Pagination(
    page: (map['page'] as num?)?.toInt() ?? 1,
    size: (map['size'] as num?)?.toInt() ?? 0,
    total: (map['total'] as num?)?.toInt() ?? 0,
    next: map['next'] as String?,
    previous: map['previous'] as String?,
  );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Pagination &&
        other.page == page &&
        other.size == size &&
        other.total == total &&
        other.next == next &&
        other.previous == previous;
  }

  @override
  int get hashCode => Object.hash(page, size, total, next, previous);
}
