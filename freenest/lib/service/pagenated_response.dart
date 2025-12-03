class PaginatedResponse<T> {
  final List<T> data;
  final int total;
  final int page;
  final int limit;
  final int totalPages;
  final bool hasNext;

  PaginatedResponse({
    required this.data,
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
    required this.hasNext,
  });

  factory PaginatedResponse.fromMap(Map<String, dynamic> map, List<T> data) {
    return PaginatedResponse(
      data: data,
      total: map['total'] ?? 0,
      page: map['page'] ?? 1,
      limit: map['limit'] ?? 10,
      totalPages: map['totalPages'] ?? 1,
      hasNext: map['hasNext'] ?? false,
    );
  }
}
