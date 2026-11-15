import 'package:dio/dio.dart';

import '../api_endpoints.dart';
import '../../storage/token_storage.dart';

/// Interceptor that handles JWT authentication:
/// 1. Attaches `Authorization: Bearer <token>` to outgoing requests.
/// 2. Queues concurrent requests and performs automatic token refresh on HTTP 401.
/// 3. Retries original request with new token on successful refresh.
/// 4. Cleans up tokens and notifies session expiration if refresh fails.
class AuthInterceptor extends QueuedInterceptor {
  final TokenStorage tokenStorage;
  final Dio dio;
  final void Function()? onSessionExpired;

  AuthInterceptor({
    required this.tokenStorage,
    required this.dio,
    this.onSessionExpired,
  });

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Add default JSON headers if missing
    options.headers['Accept'] ??= 'application/json';
    options.headers['Content-Type'] ??= 'application/json';

    // Skip Authorization header on public auth endpoints
    final path = options.path;
    final isPublicAuthEndpoint =
        path.contains(ApiEndpoints.authLogin) ||
        path.contains(ApiEndpoints.authRegister) ||
        path.contains(ApiEndpoints.authRefreshToken) ||
        path.contains(ApiEndpoints.authForgotPassword);

    if (!isPublicAuthEndpoint) {
      final token = await tokenStorage.getAccessToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }

    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final response = err.response;
    final path = err.requestOptions.path;

    // Only intercept 401 Unauthorized errors on non-auth paths
    final isAuthEndpoint =
        path.contains(ApiEndpoints.authLogin) ||
        path.contains(ApiEndpoints.authRefreshToken);

    if (response?.statusCode == 401 && !isAuthEndpoint) {
      final refreshToken = await tokenStorage.getRefreshToken();

      if (refreshToken != null && refreshToken.isNotEmpty) {
        try {
          // Create isolated Dio to perform refresh without triggering this interceptor
          final refreshDio = Dio(
            BaseOptions(
              baseUrl: dio.options.baseUrl,
              headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
              },
            ),
          );

          final refreshResponse = await refreshDio.post(
            ApiEndpoints.authRefreshToken,
            data: {'refreshToken': refreshToken},
          );

          if (refreshResponse.statusCode == 200 &&
              refreshResponse.data != null) {
            final data = refreshResponse.data;
            final newAccessToken =
                data['accessToken'] as String? ??
                data['data']?['accessToken'] as String?;
            final newRefreshToken =
                data['refreshToken'] as String? ??
                data['data']?['refreshToken'] as String? ??
                refreshToken;

            if (newAccessToken != null) {
              await tokenStorage.saveTokens(
                accessToken: newAccessToken,
                refreshToken: newRefreshToken,
              );

              // Update failed request's Authorization header and retry
              final retryOptions = err.requestOptions;
              retryOptions.headers['Authorization'] = 'Bearer $newAccessToken';

              final retryResponse = await dio.fetch(retryOptions);
              return handler.resolve(retryResponse);
            }
          }
        } catch (_) {
          // Token refresh failed - session has expired
          await tokenStorage.clearTokens();
          onSessionExpired?.call();
        }
      } else {
        // No refresh token available - clear local session
        await tokenStorage.clearTokens();
        onSessionExpired?.call();
      }
    }

    return handler.next(err);
  }
}
