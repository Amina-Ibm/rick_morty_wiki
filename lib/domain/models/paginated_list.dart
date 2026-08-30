class PaginatedList<T> {
  final List<T> items;
  final bool hasMore;
  final bool isFromCache;
  final DateTime? cachedAt;

  const PaginatedList({
    required this.items,
    required this.hasMore,
    this.isFromCache = false,
    this.cachedAt,
  });
}
