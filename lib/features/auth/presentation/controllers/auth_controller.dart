import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/services/auth_service.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';
import '../../domain/auth_state.dart';
import '../providers/auth_providers.dart';

/// Riverpod Notifier orchestrating authentication business logic and state.
class AuthController extends Notifier<AuthState> {
  late final AuthRepository _authRepository;

  @override
  AuthState build() {
    _authRepository = ref.watch(authRepositoryProvider);
    Future.microtask(() => checkAuthStatus());
    return AuthState.initial();
  }

  /// Initialize and check persistent session on launch
  Future<void> checkAuthStatus() async {
    state = AuthState.loading(state.user);
    try {
      final isAuth = await _authRepository.isAuthenticated();
      if (!ref.mounted) return;
      if (isAuth) {
        final cachedUser = await _authRepository.getCachedUser();
        if (!ref.mounted) return;
        if (cachedUser != null) {
          state = AuthState.authenticated(cachedUser);
          _syncWithAuthService(cachedUser, isLoggedIn: true);
          return;
        }
      }
      if (!ref.mounted) return;
      state = AuthState.unauthenticated();
      _syncWithAuthService(UserModel.guest, isLoggedIn: false);
    } catch (_) {
      if (!ref.mounted) return;
      state = AuthState.unauthenticated();
      _syncWithAuthService(UserModel.guest, isLoggedIn: false);
    }
  }

  /// User login with email and password
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    state = AuthState.loading(state.user);
    try {
      final user = await _authRepository.login(
        email: email,
        password: password,
      );

      if (!ref.mounted) return true;
      state = AuthState.authenticated(user);
      _syncWithAuthService(user, isLoggedIn: true);
      return true;
    } on AppException catch (e) {
      if (!ref.mounted) return false;
      state = AuthState.error(e.userMessage, state.user);
      return false;
    } catch (_) {
      if (!ref.mounted) return false;
      state = AuthState.error('An unexpected error occurred during sign in.', state.user);
      return false;
    }
  }

  /// User registration
  Future<bool> register({
    required String name,
    required String email,
    required String password,
    String? phone,
    String? role,
  }) async {
    state = AuthState.loading(state.user);
    try {
      final user = await _authRepository.register(
        name: name,
        email: email,
        password: password,
        phone: phone,
        role: role,
      );

      if (!ref.mounted) return true;
      state = AuthState.authenticated(user);
      _syncWithAuthService(user, isLoggedIn: true);
      return true;
    } on AppException catch (e) {
      if (!ref.mounted) return false;
      state = AuthState.error(e.userMessage, state.user);
      return false;
    } catch (_) {
      if (!ref.mounted) return false;
      state = AuthState.error('An unexpected error occurred during registration.', state.user);
      return false;
    }
  }

  /// Sign out
  Future<void> logout() async {
    state = AuthState.loading(state.user);
    try {
      await _authRepository.logout();
    } finally {
      if (ref.mounted) {
        state = AuthState.unauthenticated();
        _syncWithAuthService(UserModel.guest, isLoggedIn: false);
      }
    }
  }

  /// Forgot password initiation
  Future<bool> forgotPassword(String email) async {
    state = AuthState.loading(state.user);
    try {
      await _authRepository.forgotPassword(email);
      if (!ref.mounted) return true;
      state = state.copyWith(status: AuthStatus.unauthenticated);
      return true;
    } on AppException catch (e) {
      if (!ref.mounted) return false;
      state = AuthState.error(e.userMessage, state.user);
      return false;
    }
  }

  /// OTP verification
  Future<bool> verifyOtp({
    required String email,
    required String otp,
  }) async {
    state = AuthState.loading(state.user);
    try {
      final isValid = await _authRepository.verifyOtp(email: email, otp: otp);
      if (!ref.mounted) return isValid;
      state = state.copyWith(status: AuthStatus.unauthenticated);
      return isValid;
    } on AppException catch (e) {
      if (!ref.mounted) return false;
      state = AuthState.error(e.userMessage, state.user);
      return false;
    }
  }

  /// Password reset
  Future<bool> resetPassword({
    required String email,
    required String newPassword,
    required String otp,
  }) async {
    state = AuthState.loading(state.user);
    try {
      await _authRepository.resetPassword(
        email: email,
        newPassword: newPassword,
        otp: otp,
      );
      if (!ref.mounted) return true;
      state = state.copyWith(status: AuthStatus.unauthenticated);
      return true;
    } on AppException catch (e) {
      if (!ref.mounted) return false;
      state = AuthState.error(e.userMessage, state.user);
      return false;
    }
  }

  /// Toggle user role (Tenant vs Host)
  Future<void> toggleRole() async {
    final currentUser = state.user;
    if (currentUser == null || currentUser.isGuest) return;

    final newRole = currentUser.role.contains('Tenant')
        ? 'Host & Turf Owner'
        : 'Tenant & Player';

    final updatedUser = currentUser.copyWith(role: newRole);
    await _authRepository.saveUserProfile(updatedUser);

    if (!ref.mounted) return;
    state = AuthState.authenticated(updatedUser);
    _syncWithAuthService(updatedUser, isLoggedIn: true);
  }

  /// Clear any error message
  void clearError() {
    if (state.hasError) {
      state = state.copyWith(errorMessage: null);
    }
  }

  /// Bi-directional sync with [AuthService] for backward compatibility with existing tests
  void _syncWithAuthService(UserModel user, {required bool isLoggedIn}) {
    if (isLoggedIn) {
      AuthService.instance.signIn(
        name: user.name,
        email: user.email,
        role: user.role,
        phone: user.phone,
      );
    } else {
      AuthService.instance.signOut();
    }
  }
}
