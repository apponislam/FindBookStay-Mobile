import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../config/env_config.dart';

/// Clean, formatted console logging interceptor for Dio requests, responses, and errors.
/// Active only in development mode or debug mode.
class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode && EnvConfig.isDevelopment) {
      debugPrint('➡️ [DIO REQ] ${options.method} ${options.uri}');
      if (options.queryParameters.isNotEmpty) {
        debugPrint('   Params: ${options.queryParameters}');
      }
      if (options.data != null) {
        // Mask passwords before printing
        final sanitizedData = _sanitizeBody(options.data);
        debugPrint('   Body: $sanitizedData');
      }
    }
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode && EnvConfig.isDevelopment) {
      debugPrint(
        '✅ [DIO RES] ${response.statusCode} ${response.requestOptions.uri}',
      );
    }
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint(
        '❌ [DIO ERR] ${err.response?.statusCode ?? 'NO_STATUS'} ${err.requestOptions.uri}',
      );
      debugPrint('   Message: ${err.message}');
      if (err.error != null) {
        debugPrint('   Cause / Error: ${err.error}');
      }
      if (err.response?.data != null) {
        debugPrint('   Server Response: ${err.response?.data}');
      }
    }
    super.onError(err, handler);
  }

  dynamic _sanitizeBody(dynamic data) {
    if (data is Map<String, dynamic>) {
      final copy = Map<String, dynamic>.from(data);
      for (final key in [
        'password',
        'newPassword',
        'confirmPassword',
        'token',
      ]) {
        if (copy.containsKey(key)) {
          copy[key] = '******';
        }
      }
      return copy;
    }
    return data;
  }
}
