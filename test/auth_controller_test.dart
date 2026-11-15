import 'package:findbookstay_mobile/core/errors/app_exception.dart';
import 'package:findbookstay_mobile/features/auth/data/models/user_model.dart';
import 'package:findbookstay_mobile/features/auth/data/repositories/auth_repository.dart';
import 'package:findbookstay_mobile/features/auth/domain/auth_state.dart';
import 'package:findbookstay_mobile/features/auth/presentation/providers/auth_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockTestAuthRepository implements AuthRepository {
  bool isAuthed = false;
  bool throwErrorOnLogin = false;
  UserModel? cachedUser;

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    if (throwErrorOnLogin) {
      throw const UnauthorizedException(
        message: 'Invalid credentials',
        userMessage: 'Incorrect email or password.',
      );
    }
    isAuthed = true;
    cachedUser = UserModel(
      id: 'usr_test_100',
      name: 'Alex Tan',
      email: email,
      role: 'Tenant & Player',
    );
    return cachedUser!;
  }

  @override
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    String? phone,
    String? role,
  }) async {
    isAuthed = true;
    cachedUser = UserModel(
      id: 'usr_test_200',
      name: name,
      email: email,
      role: role ?? 'Tenant & Player',
      phone: phone,
    );
    return cachedUser!;
  }

  @override
  Future<void> logout() async {
    isAuthed = false;
    cachedUser = null;
  }

  @override
  Future<UserModel?> getCachedUser() async => cachedUser;

  @override
  Future<bool> isAuthenticated() async => isAuthed;

  @override
  Future<void> forgotPassword(String email) async {}

  @override
  Future<bool> verifyOtp({required String email, required String otp}) async =>
      otp == '1234';

  @override
  Future<void> resetPassword({
    required String email,
    required String newPassword,
    required String otp,
  }) async {}

  @override
  Future<UserModel> saveUserProfile(UserModel user) async {
    cachedUser = user;
    return user;
  }
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Riverpod AuthController & Providers Tests', () {
    test(
      'Initializes with Unauthenticated state when no cached user',
      () async {
        final mockRepo = MockTestAuthRepository();
        final container = ProviderContainer(
          overrides: [authRepositoryProvider.overrideWithValue(mockRepo)],
        );
        addTearDown(container.dispose);

        // Trigger build and wait for microtask checkAuthStatus
        final initialState = container.read(authControllerProvider);
        expect(initialState.status, equals(AuthStatus.initial));

        await Future<void>.delayed(Duration.zero);

        final resolvedState = container.read(authControllerProvider);
        expect(resolvedState.status, equals(AuthStatus.unauthenticated));
        expect(container.read(isAuthenticatedProvider), isFalse);
        expect(container.read(isGuestProvider), isTrue);
      },
    );

    test(
      'Successful login transitions to Authenticated with user profile',
      () async {
        final mockRepo = MockTestAuthRepository();
        final container = ProviderContainer(
          overrides: [authRepositoryProvider.overrideWithValue(mockRepo)],
        );
        addTearDown(container.dispose);

        final notifier = container.read(authControllerProvider.notifier);
        final success = await notifier.login(
          email: 'alex@findbookstay.com',
          password: 'password123',
        );

        expect(success, isTrue);

        final state = container.read(authControllerProvider);
        expect(state.status, equals(AuthStatus.authenticated));
        expect(state.user?.email, equals('alex@findbookstay.com'));
        expect(container.read(isAuthenticatedProvider), isTrue);
        expect(container.read(currentUserProvider)?.name, equals('Alex Tan'));
      },
    );

    test(
      'Failed login transitions to Error state with friendly userMessage',
      () async {
        final mockRepo = MockTestAuthRepository()..throwErrorOnLogin = true;
        final container = ProviderContainer(
          overrides: [authRepositoryProvider.overrideWithValue(mockRepo)],
        );
        addTearDown(container.dispose);

        final notifier = container.read(authControllerProvider.notifier);
        final success = await notifier.login(
          email: 'wrong@findbookstay.com',
          password: 'wrongpassword',
        );

        expect(success, isFalse);

        final state = container.read(authControllerProvider);
        expect(state.status, equals(AuthStatus.error));
        expect(state.errorMessage, equals('Incorrect email or password.'));
        expect(
          container.read(authErrorProvider),
          equals('Incorrect email or password.'),
        );
      },
    );

    test(
      'Logout transitions back to Unauthenticated state and guest user',
      () async {
        final mockRepo = MockTestAuthRepository();
        final container = ProviderContainer(
          overrides: [authRepositoryProvider.overrideWithValue(mockRepo)],
        );
        addTearDown(container.dispose);

        final notifier = container.read(authControllerProvider.notifier);
        await notifier.login(
          email: 'alex@findbookstay.com',
          password: 'password123',
        );
        expect(container.read(isAuthenticatedProvider), isTrue);

        await notifier.logout();

        final state = container.read(authControllerProvider);
        expect(state.status, equals(AuthStatus.unauthenticated));
        expect(container.read(isAuthenticatedProvider), isFalse);
        expect(container.read(isGuestProvider), isTrue);
      },
    );

    test('toggleRole switches between Tenant and Host', () async {
      final mockRepo = MockTestAuthRepository();
      final container = ProviderContainer(
        overrides: [authRepositoryProvider.overrideWithValue(mockRepo)],
      );
      addTearDown(container.dispose);

      final notifier = container.read(authControllerProvider.notifier);
      await notifier.login(
        email: 'alex@findbookstay.com',
        password: 'password123',
      );
      expect(
        container.read(currentUserProvider)?.role,
        equals('Tenant & Player'),
      );

      await notifier.toggleRole();
      expect(
        container.read(currentUserProvider)?.role,
        equals('Host & Turf Owner'),
      );

      await notifier.toggleRole();
      expect(
        container.read(currentUserProvider)?.role,
        equals('Tenant & Player'),
      );
    });
  });
}
