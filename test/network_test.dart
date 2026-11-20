import 'package:dio/dio.dart';
import 'package:findbookstay/core/errors/app_exception.dart';
import 'package:findbookstay/core/errors/error_handler.dart';
import 'package:findbookstay/core/network/api_response.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ApiResponse Tests', () {
    test('Constructs success response correctly', () {
      final res = ApiResponse<String>.success(
        data: 'Hello FindBookStay',
        message: 'Loaded successfully',
      );

      expect(res.success, isTrue);
      expect(res.data, equals('Hello FindBookStay'));
      expect(res.message, equals('Loaded successfully'));
      expect(res.statusCode, equals(200));
    });

    test('Constructs failure response correctly', () {
      final res = ApiResponse<void>.failure(
        message: 'Invalid credentials',
        statusCode: 401,
        errors: {'email': ['Not found']},
      );

      expect(res.success, isFalse);
      expect(res.message, equals('Invalid credentials'));
      expect(res.statusCode, equals(401));
      expect(res.errors, isNotNull);
      expect(res.errors!['email'], contains('Not found'));
    });

    test('Parses from standard API JSON payload', () {
      final json = {
        'success': true,
        'message': 'OK',
        'statusCode': 200,
        'data': {'id': 'prop_123', 'title': 'Luxury Villa'},
      };

      final response = ApiResponse<Map<String, dynamic>>.fromJson(
        json,
        (data) => data as Map<String, dynamic>,
      );

      expect(response.success, isTrue);
      expect(response.data?['title'], equals('Luxury Villa'));
    });
  });

  group('ErrorHandler and AppException Tests', () {
    test('Maps connection error to NetworkException', () {
      final dioError = DioException(
        requestOptions: RequestOptions(path: '/api/v1/auth/login'),
        type: DioExceptionType.connectionError,
        message: 'Connection failed',
      );

      final appException = ErrorHandler.handle(dioError);

      expect(appException, isA<NetworkException>());
      expect(appException.userMessage, contains('connect to the server'));
    });

    test('Maps connectionTimeout to TimeoutException', () {
      final dioError = DioException(
        requestOptions: RequestOptions(path: '/api/v1/properties'),
        type: DioExceptionType.connectionTimeout,
      );

      final appException = ErrorHandler.handle(dioError);

      expect(appException, isA<TimeoutException>());
      expect(appException.statusCode, equals(408));
    });

    test('Maps HTTP 401 response to UnauthorizedException', () {
      final dioError = DioException(
        requestOptions: RequestOptions(path: '/api/v1/auth/me'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/api/v1/auth/me'),
          statusCode: 401,
          data: {'message': 'Token has expired'},
        ),
      );

      final appException = ErrorHandler.handle(dioError);

      expect(appException, isA<UnauthorizedException>());
      expect(appException.statusCode, equals(401));
      expect(appException.message, equals('Token has expired'));
    });

    test('Maps HTTP 409 Conflict response to ConflictException', () {
      final dioError = DioException(
        requestOptions: RequestOptions(path: '/api/v1/auth/register'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/api/v1/auth/register'),
          statusCode: 409,
          data: {'message': 'Email already registered'},
        ),
      );

      final appException = ErrorHandler.handle(dioError);

      expect(appException, isA<ConflictException>());
      expect(appException.statusCode, equals(409));
    });

    test('Maps HTTP 422 Validation error and parses field errors', () {
      final dioError = DioException(
        requestOptions: RequestOptions(path: '/api/v1/auth/register'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/api/v1/auth/register'),
          statusCode: 422,
          data: {
            'message': 'Validation failed',
            'errors': {
              'email': ['Email format is invalid'],
              'password': ['Password is too short'],
            },
          },
        ),
      );

      final appException = ErrorHandler.handle(dioError);

      expect(appException, isA<ValidationException>());
      final valEx = appException as ValidationException;
      expect(valEx.firstFieldError, equals('Email format is invalid'));
    });

    test('Maps HTTP 500 Server error to ServerException', () {
      final dioError = DioException(
        requestOptions: RequestOptions(path: '/api/v1/bookings'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/api/v1/bookings'),
          statusCode: 500,
          data: {'message': 'Database connection lost'},
        ),
      );

      final appException = ErrorHandler.handle(dioError);

      expect(appException, isA<ServerException>());
      expect(appException.statusCode, equals(500));
      expect(appException.userMessage, equals('Database connection lost'));
    });
  });
}
