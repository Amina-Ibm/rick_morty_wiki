class PaginatedResponseDto<T> {
  final int count;
  final int pages;
  final String? next;
  final String? prev;
  final List<T> results;

  PaginatedResponseDto({
    required this.count,
    required this.pages,
    this.next,
    this.prev,
    required this.results,
  });

  factory PaginatedResponseDto.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    final info = json['info'] as Map<String, dynamic>;
    return PaginatedResponseDto(
      count: info['count'] as int,
      pages: info['pages'] as int,
      next: info['next'] as String?,
      prev: info['prev'] as String?,
      results: (json['results'] as List)
          .map((item) => fromJsonT(item as Map<String, dynamic>))
          .toList(),
    );
  }
}
