import 'dart:io';
import 'package:dio/dio.dart';
import 'app_exception.dart';

/// Centralized error handler that translates raw network errors, Dio exceptions,
/// and HTTP responses into domain-specific [AppException] instances.
class ErrorHandler {
  const ErrorHandler._();

  /// Converts any dynamic error into a typed [AppException].
  static AppException handle(dynamic error) {
    if (error is AppException) {
      return error;
    }

    if (error is DioException) {
      return _handleDioException(error);
    }

    if (error is SocketException) {
      return NetworkException(
        message: 'SocketException: ${error.message}',
        userMessage: 'Cannot reach the server. Please check your internet connection.',
      );
    }

    if (error is FormatException) {
      return UnknownException(
        message: 'FormatException: ${error.message}',
        userMessage: 'Invalid server response format. Please try again.',
      );
    }

    return UnknownException(
      message: error.toString(),
      userMessage: 'An unexpected error occurred. Please try again.',
    );
  }

  static AppException _handleDioException(DioException dioError) {
    switch (dioError.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return TimeoutException(
          message: 'Timeout: ${dioError.message}',
          userMessage: 'The connection timed out. Please check your internet and try again.',
        );

      case DioExceptionType.connectionError:
        return NetworkException(
          message: 'ConnectionError: ${dioError.message}',
          userMessage: 'Could not connect to the server. Please ensure the server is running.',
        );

      case DioExceptionType.cancel:
        return const UnknownException(
          message: 'Request was cancelled by the client',
          userMessage: 'The operation was cancelled.',
        );

      case DioExceptionType.badCertificate:
        return const NetworkException(
          message: 'SSL/TLS certificate verification failed',
          userMessage: 'Secure connection could not be established.',
        );

      case DioExceptionType.badResponse:
        return _handleBadResponse(dioError.response);

      case DioExceptionType.unknown:
      default:
        if (dioError.error is SocketException) {
          return NetworkException(
            message: 'SocketException: ${dioError.error}',
            userMessage: 'Cannot reach the server. Please check your internet connection.',
          );
        }
        return UnknownException(
          message: dioError.message ?? 'Unknown Dio error occurred',
          userMessage: 'An unexpected error occurred. Please try again.',
        );
    }
  }

  static AppException _handleBadResponse(Response? response) {
    if (response == null) {
      return const ServerException(
        message: 'Empty response received from server',
        userMessage: 'No response from server. Please try again.',
      );
    }

    final statusCode = response.statusCode ?? 500;
    final data = response.data;

    String? serverMessage;
    Map<String, dynamic>? errors;

    if (data is Map<String, dynamic>) {
      serverMessage = data['message'] as String? ?? data['error'] as String?;
      if (data['errors'] is Map<String, dynamic>) {
        errors = data['errors'] as Map<String, dynamic>;
      }
    } else if (data is String && data.isNotEmpty) {
      serverMessage = data;
    }

    switch (statusCode) {
      case 400:
        return BadRequestException(
          message: serverMessage ?? 'Bad request (400)',
          userMessage: serverMessage ?? 'Invalid request. Please verify your data and try again.',
          statusCode: 400,
          errors: errors,
        );

      case 401:
        return UnauthorizedException(
          message: serverMessage ?? 'Unauthorized (401)',
          userMessage: serverMessage ?? 'Invalid email or password. Please try again.',
          statusCode: 401,
        );

      case 403:
        return ForbiddenException(
          message: serverMessage ?? 'Forbidden (403)',
          userMessage: serverMessage ?? 'You do not have permission to perform this action.',
          statusCode: 403,
        );

      case 404:
        return NotFoundException(
          message: serverMessage ?? 'Resource not found (404)',
          userMessage: serverMessage ?? 'The requested information could not be found.',
          statusCode: 404,
        );

      case 409:
        return ConflictException(
          message: serverMessage ?? 'Conflict (409)',
          userMessage: serverMessage ?? 'A record with these details already exists.',
          statusCode: 409,
          errors: errors,
        );

      case 422:
        return ValidationException(
          message: serverMessage ?? 'Validation failed (422)',
          userMessage: serverMessage ?? 'Validation failed. Please correct the highlighted fields.',
          statusCode: 422,
          errors: errors,
        );

      case 500:
      case 502:
      case 503:
      case 504:
        return ServerException(
          message: serverMessage ?? 'Server error ($statusCode)',
          userMessage: 'Our servers are experiencing issues. Please try again in a few moments.',
          statusCode: statusCode,
        );

      default:
        return UnknownException(
          message: serverMessage ?? 'HTTP $statusCode error',
          userMessage: serverMessage ?? 'An error occurred. Please try again.',
          statusCode: statusCode,
          errors: errors,
        );
    }
  }
}
