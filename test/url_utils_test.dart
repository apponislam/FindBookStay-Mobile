import 'package:flutter_test/flutter_test.dart';
import 'package:findbookstay/core/utils/url_utils.dart';
import 'package:findbookstay/core/utils/image_utils.dart';
import 'package:findbookstay/features/auth/data/models/user_model.dart';

void main() {
  group('UrlUtils and ImageUtils Tests', () {
    test('Resolves relative backend path to full backend URL', () {
      const relative = '/uploads/profile/profile-1795109555374-157292906.webp';
      final resolved = UrlUtils.resolveUrl(relative);

      expect(
        resolved,
        equals(
          'https://findbookstayapi.apponislam.top/uploads/profile/profile-1795109555374-157292906.webp',
        ),
      );
    });

    test('Resolves relative path without leading slash cleanly', () {
      const relative = 'uploads/profile/profile-1795109555374-157292906.webp';
      final resolved = UrlUtils.resolveUrl(relative);

      expect(
        resolved,
        equals(
          'https://findbookstayapi.apponislam.top/uploads/profile/profile-1795109555374-157292906.webp',
        ),
      );
    });

    test('Preserves already full HTTP and HTTPS URLs', () {
      const fullHttps =
          'https://findbookstayapi.apponislam.top/uploads/profile/profile-1795109555374-157292906.webp';
      const fullHttp = 'http://example.com/images/avatar.jpg';

      expect(UrlUtils.resolveUrl(fullHttps), equals(fullHttps));
      expect(UrlUtils.resolveUrl(fullHttp), equals(fullHttp));
    });

    test('Preserves Base64 data and blob URLs', () {
      const dataUri =
          'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==';
      const blobUri = 'blob:https://example.com/some-uuid';

      expect(UrlUtils.resolveUrl(dataUri), equals(dataUri));
      expect(UrlUtils.resolveUrl(blobUri), equals(blobUri));
    });

    test('Normalizes backslashes to web slashes', () {
      const winPath = r'\uploads\profile\test.png';
      expect(
        UrlUtils.resolveUrl(winPath),
        equals(
          'https://findbookstayapi.apponislam.top/uploads/profile/test.png',
        ),
      );
    });

    test('Handles null and empty inputs safely', () {
      expect(UrlUtils.resolveUrl(null), equals(''));
      expect(UrlUtils.resolveUrl(''), equals(''));
      expect(UrlUtils.resolveUrl('   '), equals(''));

      expect(UrlUtils.resolveNullableUrl(null), isNull);
      expect(UrlUtils.resolveNullableUrl(''), isNull);
      expect(UrlUtils.resolveNullableUrl('   '), isNull);
    });

    test('ImageUtils delegates correctly to UrlUtils', () {
      const relative = '/uploads/profile/sample.jpg';
      expect(
        ImageUtils.resolve(relative),
        equals(
          'https://findbookstayapi.apponislam.top/uploads/profile/sample.jpg',
        ),
      );
      expect(
        ImageUtils.resolveNullable(relative),
        equals(
          'https://findbookstayapi.apponislam.top/uploads/profile/sample.jpg',
        ),
      );
      expect(ImageUtils.resolveNullable(''), isNull);
    });

    test(
      'UserModel automatically resolves avatarUrl from relative profileImage',
      () {
        final user = UserModel.fromJson({
          'id': 'usr_123',
          'name': 'Alex Tan',
          'email': 'alex@example.com',
          'role': 'USER',
          'profileImage':
              '/uploads/profile/profile-1795109555374-157292906.webp',
        });

        expect(
          user.avatarUrl,
          equals(
            'https://findbookstayapi.apponislam.top/uploads/profile/profile-1795109555374-157292906.webp',
          ),
        );
        expect(
          user.resolvedAvatarUrl,
          equals(
            'https://findbookstayapi.apponislam.top/uploads/profile/profile-1795109555374-157292906.webp',
          ),
        );
        expect(user.hasAvatar, isTrue);
      },
    );
  });
}
