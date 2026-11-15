/// Generic strongly typed API response wrapper for FindBookStay.
class ApiResponse<T> {
  final bool success;
  final String? message;
  final T? data;
  final int? statusCode;
  final Map<String, dynamic>? errors;
  final Map<String, dynamic>? meta;

  const ApiResponse({
    required this.success,
    this.message,
    this.data,
    this.statusCode,
    this.errors,
    this.meta,
  });

  /// Factory constructor to parse standard API JSON response structures.
  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic rawData)? fromJsonT,
  ) {
    final rawData = json['data'];
    return ApiResponse<T>(
      success: json['success'] as bool? ?? (json['status'] == 'success' || json['statusCode'] == 200),
      message: json['message'] as String?,
      statusCode: json['statusCode'] as int?,
      errors: json['errors'] is Map<String, dynamic> ? json['errors'] as Map<String, dynamic> : null,
      meta: json['meta'] is Map<String, dynamic> ? json['meta'] as Map<String, dynamic> : null,
      data: (rawData != null && fromJsonT != null)
          ? fromJsonT(rawData)
          : (rawData is T ? rawData : null),
    );
  }

  /// Convenience factory for successful client responses
  factory ApiResponse.success({
    required T data,
    String? message,
    int statusCode = 200,
    Map<String, dynamic>? meta,
  }) {
    return ApiResponse<T>(
      success: true,
      data: data,
      message: message,
      statusCode: statusCode,
      meta: meta,
    );
  }

  /// Convenience factory for failed responses
  factory ApiResponse.failure({
    required String message,
    int? statusCode,
    Map<String, dynamic>? errors,
  }) {
    return ApiResponse<T>(
      success: false,
      message: message,
      statusCode: statusCode,
      errors: errors,
    );
  }
}
