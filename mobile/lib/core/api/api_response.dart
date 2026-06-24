class ApiResponse<T> {
  final T? data;
  final Map<String, dynamic> meta;
  final ApiError? error;

  const ApiResponse({this.data, this.meta = const {}, this.error});

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic json) fromJsonT,
  ) {
    return ApiResponse(
      data: json['data'] != null ? fromJsonT(json['data']) : null,
      meta: Map<String, dynamic>.from(json['meta'] ?? {}),
      error: json['error'] != null ? ApiError.fromJson(json['error']) : null,
    );
  }

  bool get isSuccess => error == null;
}

class ApiError {
  final String code;
  final String message;

  const ApiError({required this.code, required this.message});

  factory ApiError.fromJson(Map<String, dynamic> json) => ApiError(
        code: json['code'] as String? ?? 'UNKNOWN',
        message: json['message'] as String? ?? 'Unknown error',
      );
}

class PaginatedResponse<T> {
  final List<T> items;
  final int page;
  final int pageSize;
  final bool hasNextPage;
  final int total;

  const PaginatedResponse({
    required this.items,
    required this.page,
    required this.pageSize,
    required this.hasNextPage,
    required this.total,
  });
}
