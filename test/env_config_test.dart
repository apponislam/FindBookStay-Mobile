dd .
import 'package:flutter_test/flutter_test.dart';
import 'package:findbookstay_mobile/core/config/env_config.dart';

void main() {
  group('EnvConfig tests', () {
    test('Default API Base URL is valid and ends with slash', () {
      expect(EnvConfig.apiBaseUrl, equals('http://localhost:5075/'));
    });

    test('Endpoint helper constructs clean paths correctly', () {
      expect(
        EnvConfig.endpoint('api/v1/auth/login'),
        equals('http://localhost:5075/api/v1/auth/login'),
      );
      expect(
        EnvConfig.endpoint('/api/v1/listings'),
        equals('http://localhost:5075/api/v1/listings'),
      );
    });

    test('Default environment is development', () {
      expect(EnvConfig.appEnv, equals('development'));
      expect(EnvConfig.isDevelopment, isTrue);
      expect(EnvConfig.isProduction, isFalse);
    });
  });
}
