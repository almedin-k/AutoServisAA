class SearchResult<T> {
  SearchResult({
    this.items = const [],
    this.totalCount = 0,
    this.page = 1,
    this.pageSize = 10,
  });

  final List<T> items;
  final int totalCount;
  final int page;
  final int pageSize;

  int get totalPages => totalCount == 0 ? 1 : (totalCount + pageSize - 1) ~/ pageSize;
}
