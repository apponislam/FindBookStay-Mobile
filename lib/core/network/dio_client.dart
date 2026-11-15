import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/env_config.dart';
import '../errors/error_handler.dart';
import '../storage/token_storage.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/logging_interceptor.dart';

/// Reusable HTTP Client wrapping [Dio] with base configuration, centralized error handling,
/// logging, and automatic JWT authentication interceptors.
class DioClient {
  final Dio dio;

  DioClient({
    required this.dio,
  });

  /// Factory constructor initializing Dio with [EnvConfig] and [TokenStorage].
  factory DioClient.create({
    required TokenStorage tokenStorage,
    String? baseUrl,
    void Function()? onSessionExpired,
  }) {
    final effectiveBaseUrl = baseUrl ?? EnvConfig.apiBaseUrl;

    final baseOptions = BaseOptions(
      baseUrl: effectiveBaseUrl,
      connectTimeout: EnvConfig.apiTimeout,
      receiveTimeout: EnvConfig.apiTimeout,
      sendTimeout: EnvConfig.apiTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      responseType: ResponseType.json,
    );

    final dioInstance = Dio(baseOptions);

    dioInstance.interceptors.addAll([
      LoggingInterceptor(),
      AuthInterceptor(
        tokenStorage: tokenStorage,
        dio: dioInstance,
        onSessionExpired: onSessionExpired,
      ),
    ]);

    return DioClient(dio: dioInstance);
  }

  /// Perform a GET request with centralized error mapping.
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  /// Perform a POST request with centralized error mapping.
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  /// Perform a PUT request with centralized error mapping.
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  /// Perform a PATCH request with centralized error mapping.
  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await dio.patch<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  /// Perform a DELETE request with centralized error mapping.
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }
}

/// Riverpod provider for [DioClient].
final dioClientProvider = Provider<DioClient>((ref) {
  final tokenStorage = ref.watch(tokenStorageProvider);
  return DioClient.create(
    tokenStorage: tokenStorage,
  );
});

/// Riverpod provider directly exposing underlying [Dio] instance.
final dioProvider = Provider<Dio>((ref) {
  return ref.watch(dioClientProvider).dio;
});
