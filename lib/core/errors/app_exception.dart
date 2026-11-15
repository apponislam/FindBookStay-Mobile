/// Base exception class for all errors in FindBookStay.
/// Carries both technical detail (for logs) and user-friendly messages (for UI).
abstract class AppException implements Exception {
  final String message;
  final String userMessage;
  final int? statusCode;
  final Map<String, dynamic>? errors;

  const AppException({
    required this.message,
    required this.userMessage,
    this.statusCode,
    this.errors,
  });

  @override
  String toString() => '$runtimeType: $message (Status: $statusCode)';
}

/// Thrown when device has no internet or cannot connect to host
class NetworkException extends AppException {
  const NetworkException({
    super.message = 'No internet connection or network unreachable',
    super.userMessage = 'Please check your internet connection and try again.',
    super.statusCode,
  });
}

/// Thrown on network timeout (connect, send, receive)
class TimeoutException extends AppException {
  const TimeoutException({
    super.message = 'The server took too long to respond',
    super.userMessage = 'Connection timed out. Please check your network and try again.',
    super.statusCode = 408,
  });
}

/// Thrown when request lacks valid authentication (HTTP 401)
class UnauthorizedException extends AppException {
  const UnauthorizedException({
    super.message = 'User is unauthorized or session expired',
    super.userMessage = 'Your session has expired. Please sign in again.',
    super.statusCode = 401,
  });
}

/// Thrown when authenticated user does not have permission (HTTP 403)
class ForbiddenException extends AppException {
  const ForbiddenException({
    super.message = 'Access forbidden to requested resource',
    super.userMessage = 'You do not have permission to perform this action.',
    super.statusCode = 403,
  });
}

/// Thrown when resource cannot be found (HTTP 404)
class NotFoundException extends AppException {
  const NotFoundException({
    super.message = 'Requested resource not found',
    super.userMessage = 'The requested resource could not be found.',
    super.statusCode = 404,
  });
}

/// Thrown when a conflict occurs (HTTP 409, e.g. Email already registered)
class ConflictException extends AppException {
  const ConflictException({
    required super.message,
    super.userMessage = 'A conflicting record already exists.',
    super.statusCode = 409,
    super.errors,
  });
}

/// Thrown on validation errors (HTTP 422 or 400 with field errors)
class ValidationException extends AppException {
  const ValidationException({
    required super.message,
    super.userMessage = 'Please check the highlighted fields and correct any errors.',
    super.statusCode = 422,
    super.errors,
  });

  /// Extract the first field validation error message if available
  String? get firstFieldError {
    if (errors == null || errors!.isEmpty) return null;
    final firstEntry = errors!.entries.first.value;
    if (firstEntry is List && firstEntry.isNotEmpty) {
      return firstEntry.first.toString();
    }
    return firstEntry?.toString();
  }
}

/// Thrown on bad request (HTTP 400)
class BadRequestException extends AppException {
  const BadRequestException({
    required super.message,
    super.userMessage = 'Invalid request. Please verify your data.',
    super.statusCode = 400,
    super.errors,
  });
}

/// Thrown on internal server errors (HTTP 500, 502, 503)
class ServerException extends AppException {
  const ServerException({
    super.message = 'Internal server error occurred',
    super.userMessage = 'Something went wrong on our end. Please try again later.',
    super.statusCode = 500,
    super.errors,
  });
}

/// Thrown for unclassified or unexpected exceptions
class UnknownException extends AppException {
  const UnknownException({
    required super.message,
    super.userMessage = 'An unexpected error occurred. Please try again.',
    super.statusCode,
    super.errors,
  });
}
