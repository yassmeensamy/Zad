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
  bool get hasPrevious => previous != null && previous!.isNotEmpty;

  factory Pagination.fromMap(Map<String, dynamic> map) => Pagination(
    page: (map['page'] as num?)?.toInt() ?? 1,
    size: (map['size'] as num?)?.toInt() ?? 0,
    total: (map['total'] as num?)?.toInt() ?? 0,
    next: map['next'] as String?,
    previous: map['previous'] as String?,
  );

  Map<String, dynamic> toMap() => {
    'page': page,
    'size': size,
    'total': total,
    'next': next,
    'previous': previous,
  };

  Pagination copyWith({
    int? page,
    int? size,
    int? total,
    String? Function()? next,
    String? Function()? previous,
  }) => Pagination(
    page: page ?? this.page,
    size: size ?? this.size,
    total: total ?? this.total,
    next: next != null ? next() : this.next,
    previous: previous != null ? previous() : this.previous,
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
