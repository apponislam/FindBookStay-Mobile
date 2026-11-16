import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Centralized environment configuration for FindBookStay.
/// Reads from root `.env` with safe, graceful fallbacks for all platforms and tests.
class EnvConfig {
  EnvConfig._();

  /// Default fallback API Base URL
  static const String _defaultApiBaseUrl = 'https://findbookstayapi.apponislam.top/';

  /// Default timeout in milliseconds
  static const int _defaultTimeoutMs = 15000;

  /// Default environment
  static const String _defaultAppEnv = 'development';

  /// Initializes the environment by loading the `.env` file.
  /// If `.env` is not present (e.g. during headless widget tests),
  /// defaults are safely used without crashing.
  static Future<void> init() async {
    try {
      await dotenv.load(fileName: '.env');
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
          'EnvConfig: .env not loaded ($e). Falling back to default configuration.',
        );
      }
    }
  }

  /// Backend API Base URL (guaranteed to end with a trailing slash).
  /// Configured via `API_BASE_URL` in `.env`.
  static String get apiBaseUrl {
    String url = _defaultApiBaseUrl;
    if (dotenv.isInitialized) {
      url = dotenv.env['API_BASE_URL'] ?? _defaultApiBaseUrl;
    }
    return url.endsWith('/') ? url : '$url/';
  }

  /// Request timeout duration.
  static Duration get apiTimeout {
    int timeoutMs = _defaultTimeoutMs;
    if (dotenv.isInitialized && dotenv.env['API_TIMEOUT_MS'] != null) {
      timeoutMs =
          int.tryParse(dotenv.env['API_TIMEOUT_MS']!) ?? _defaultTimeoutMs;
    }
    return Duration(milliseconds: timeoutMs);
  }

  /// Current environment name: development, staging, or production.
  static String get appEnv {
    if (dotenv.isInitialized) {
      return dotenv.env['APP_ENV'] ?? _defaultAppEnv;
    }
    return _defaultAppEnv;
  }

  /// Whether running in development mode.
  static bool get isDevelopment => appEnv.toLowerCase() == 'development';

  /// Whether running in production mode.
  static bool get isProduction => appEnv.toLowerCase() == 'production';

  /// Helper to construct full endpoint URL.
  /// Usage: `EnvConfig.endpoint('api/v1/auth/login')` -> `http://localhost:5075/api/v1/auth/login`
  static String endpoint(String path) {
    final cleanPath = path.startsWith('/') ? path.substring(1) : path;
    return '$apiBaseUrl$cleanPath';
  }

  /// Device-specific helper:
  /// When running on Android physical devices (like your connected Vivo) or emulators,
  /// `localhost` refers to the device itself.
  /// Run: `adb reverse tcp:5075 tcp:5075` on PC so the mobile device can reach `http://localhost:5075/`.
  static String get adbReverseCommand => 'adb reverse tcp:5075 tcp:5075';
}
