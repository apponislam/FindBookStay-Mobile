import 'package:findbookstay_mobile/core/storage/token_storage.dart';
import 'package:findbookstay_mobile/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:findbookstay_mobile/features/auth/data/models/auth_response_model.dart';
import 'package:findbookstay_mobile/features/auth/data/models/auth_tokens_model.dart';
import 'package:findbookstay_mobile/features/auth/data/models/login_request.dart';
import 'package:findbookstay_mobile/features/auth/data/models/register_request.dart';
import 'package:findbookstay_mobile/features/auth/data/models/user_model.dart';
import 'package:findbookstay_mobile/features/auth/data/repositories/auth_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockAuthRemoteDataSource implements AuthRemoteDataSource {
  bool shouldFail = false;

  @override
  Future<AuthResponseModel> login(LoginRequest request) async {
    if (shouldFail) {
      throw Exception('Server down');
    }
    return AuthResponseModel(
      user: UserModel(
        id: 'usr_001',
        name: 'Alex Tan',
        email: request.email,
        role: 'Tenant & Player',
      ),
      tokens: const AuthTokensModel(
        accessToken: 'mock_access_jwt',
        refreshToken: 'mock_refresh_jwt',
      ),
    );
  }

  @override
  Future<AuthResponseModel> register(RegisterRequest request) async {
    return AuthResponseModel(
      user: UserModel(
        id: 'usr_002',
        name: request.name,
        email: request.email,
        role: request.role ?? 'Tenant & Player',
      ),
      tokens: const AuthTokensModel(
        accessToken: 'mock_reg_access_jwt',
        refreshToken: 'mock_reg_refresh_jwt',
      ),
    );
  }

  @override
  Future<AuthTokensModel> refreshToken(String refreshToken) async {
    return const AuthTokensModel(
      accessToken: 'new_refreshed_access_token',
      refreshToken: 'new_refreshed_refresh_token',
    );
  }

  @override
  Future<void> logout() async {}

  @override
  Future<UserModel> getCurrentUser() async {
    return UserModel.defaultUser;
  }

  @override
  Future<void> forgotPassword(String email) async {}

  @override
  Future<bool> verifyOtp({required String email, required String otp}) async {
    return otp == '1234';
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String newPassword,
    required String otp,
  }) async {}
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('UserModel and AuthTokensModel Tests', () {
    test('UserModel serializes and deserializes to/from JSON cleanly', () {
      final user = UserModel(
        id: 'usr_test_1',
        name: 'Sarah Connor',
        email: 'sarah@example.com',
        role: 'Host & Turf Owner',
        phone: '+1 555-0199',
        isEmailVerified: true,
      );

      final json = user.toJson();
      final parsed = UserModel.fromJson(json);

      expect(parsed.id, equals(user.id));
      expect(parsed.name, equals(user.name));
      expect(parsed.email, equals(user.email));
      expect(parsed.role, equals(user.role));
      expect(parsed.phone, equals(user.phone));
      expect(parsed.isEmailVerified, isTrue);
      expect(parsed.isGuest, isFalse);
    });

    test('UserModel.guest represents unauthenticated state', () {
      const guest = UserModel.guest;
      expect(guest.isGuest, isTrue);
      expect(guest.email, isEmpty);
      expect(guest.role, equals('Guest'));
    });

    test('UserModel copyWith modifies only targeted fields', () {
      final initial = UserModel.defaultUser;
      final updated = initial.copyWith(role: 'Host & Turf Owner');

      expect(updated.role, equals('Host & Turf Owner'));
      expect(updated.name, equals(initial.name));
      expect(updated.email, equals(initial.email));
    });

    test('AuthTokensModel serializes to/from JSON', () {
      const tokens = AuthTokensModel(
        accessToken: 'access_abc',
        refreshToken: 'refresh_xyz',
        expiresIn: 3600,
      );

      final json = tokens.toJson();
      final fromJson = AuthTokensModel.fromJson(json);

      expect(fromJson.accessToken, equals('access_abc'));
      expect(fromJson.refreshToken, equals('refresh_xyz'));
      expect(fromJson.expiresIn, equals(3600));
    });
  });

  group('TokenStorage Tests', () {
    test('Saves, retrieves, and clears JWT tokens and user cache', () async {
      final tokenStorage = SharedPrefsTokenStorage();

      // Initially empty
      expect(await tokenStorage.hasAccessToken(), isFalse);
      expect(await tokenStorage.getAccessToken(), isNull);
      expect(await tokenStorage.getRefreshToken(), isNull);

      // Save tokens
      await tokenStorage.saveTokens(
        accessToken: 'jwt_access_123',
        refreshToken: 'jwt_refresh_456',
      );

      expect(await tokenStorage.hasAccessToken(), isTrue);
      expect(await tokenStorage.getAccessToken(), equals('jwt_access_123'));
      expect(await tokenStorage.getRefreshToken(), equals('jwt_refresh_456'));

      // Save user raw
      await tokenStorage.saveUserRaw(UserModel.defaultUser.toJson());
      final cachedUser = await tokenStorage.getUserRaw();
      expect(cachedUser?['email'], equals(UserModel.defaultUser.email));

      // Clear tokens
      await tokenStorage.clearTokens();
      expect(await tokenStorage.hasAccessToken(), isFalse);
      expect(await tokenStorage.getAccessToken(), isNull);

      // Clear all
      await tokenStorage.clearAll();
      expect(await tokenStorage.getUserRaw(), isNull);
    });
  });

  group('AuthRepositoryImpl Tests', () {
    late MockAuthRemoteDataSource mockRemote;
    late TokenStorage tokenStorage;
    late AuthRepositoryImpl repository;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    mockRemote = MockAuthRemoteDataSource();
    tokenStorage = SharedPrefsTokenStorage();
    repository = AuthRepositoryImpl(
      remoteDataSource: mockRemote,
      tokenStorage: tokenStorage,
    );
  });

    test('Successful login persists tokens and user profile', () async {
      final user = await repository.login(
        email: 'alex.tan@example.com',
        password: 'password123',
      );

      expect(user.email, equals('alex.tan@example.com'));
      expect(await repository.isAuthenticated(), isTrue);

      final cached = await repository.getCachedUser();
      expect(cached?.name, equals('Alex Tan'));
    });

    test('Successful register persists tokens and user profile', () async {
      final user = await repository.register(
        name: 'John Doe',
        email: 'john@example.com',
        password: 'securePass123',
        role: 'Host & Turf Owner',
      );

      expect(user.name, equals('John Doe'));
      expect(user.role, equals('Host & Turf Owner'));
      expect(await repository.isAuthenticated(), isTrue);
    });

    test('Logout clears all persistent storage tokens', () async {
      await repository.login(
        email: 'alex.tan@example.com',
        password: 'password123',
      );
      expect(await repository.isAuthenticated(), isTrue);

      await repository.logout();

      expect(await repository.isAuthenticated(), isFalse);
      expect(await repository.getCachedUser(), isNull);
    });

    test('Verify OTP returns boolean check', () async {
      expect(await repository.verifyOtp(email: 'user@test.com', otp: '1234'), isTrue);
      expect(await repository.verifyOtp(email: 'user@test.com', otp: '0000'), isFalse);
    });
  });
}
