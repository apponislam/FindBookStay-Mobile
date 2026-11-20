import 'package:flutter_test/flutter_test.dart';
import 'package:findbookstay/core/config/env_config.dart';

void main() {
  group('EnvConfig tests', () {
    test('Default API Base URL is valid and ends with slash', () {
      expect(EnvConfig.apiBaseUrl, equals('https://findbookstayapi.apponislam.top/'));
      expect(EnvConfig.serverOrigin, equals('https://findbookstayapi.apponislam.top'));
    });

    test('Endpoint helper constructs clean paths correctly', () {
      expect(
        EnvConfig.endpoint('api/v1/auth/login'),
        equals('https://findbookstayapi.apponislam.top/api/v1/auth/login'),
      );
      expect(
        EnvConfig.endpoint('/api/v1/listings'),
        equals('https://findbookstayapi.apponislam.top/api/v1/listings'),
      );
    });

    test('Default environment is development', () {
      expect(EnvConfig.appEnv, equals('development'));
      expect(EnvConfig.isDevelopment, isTrue);
      expect(EnvConfig.isProduction, isFalse);
    });
  });
}
