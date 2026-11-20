import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../services/notification_service.dart';
import '../../data/models/register_request.dart';
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

          // Synchronize FCM token in background if user is returning
          NotificationService.instance.getFcmToken().then((token) {
            if (token != null && token.isNotEmpty) {
              _authRepository.registerFcmToken(token).catchError((_) {});
            }
          }).catchError((_) {});

          // Fetch fresh profile from server in background to keep data current
          _authRepository.getCurrentUser().then((freshUser) {
            if (ref.mounted) {
              state = AuthState.authenticated(freshUser);
              _syncWithAuthService(freshUser, isLoggedIn: true);
            }
          }).catchError((_) {});
          return;
        } else {
          // No cached user but auth tokens exist (e.g. from cookies/refresh token)
          try {
            final serverUser = await _authRepository.getCurrentUser();
            if (!ref.mounted) return;
            state = AuthState.authenticated(serverUser);
            _syncWithAuthService(serverUser, isLoggedIn: true);
            return;
          } catch (_) {}
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

  /// User login with email and password, sending FCM token to backend
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    state = AuthState.loading(state.user);
    try {
      // 1. Fetch current FCM token
      String? fcmToken;
      try {
        fcmToken = await NotificationService.instance.getFcmToken();
        debugPrint('🔔 [FCM] Device token captured for login: $fcmToken');
      } catch (e) {
        debugPrint('⚠️ [FCM] Token retrieval before login notice: $e');
      }

      // 2. Authenticate user with credentials and optional fcmToken
      final user = await _authRepository.login(
        email: email,
        password: password,
        fcmToken: fcmToken,
      );

      if (!ref.mounted) return true;
      state = AuthState.authenticated(user);
      _syncWithAuthService(user, isLoggedIn: true);

      // 3. Ensure token is registered on the dedicated endpoint as well
      if (fcmToken != null && fcmToken.isNotEmpty) {
        _authRepository.registerFcmToken(fcmToken).catchError((e) {
          debugPrint('⚠️ [FCM] Secondary token registration notice: $e');
        });
      } else {
        // Retry capturing FCM token in background if not ready before login
        try {
          NotificationService.instance.getFcmToken().then((lateToken) {
            if (lateToken != null && lateToken.isNotEmpty) {
              _authRepository.registerFcmToken(lateToken).catchError((_) {});
            }
          }).catchError((_) {});
        } catch (_) {}
      }

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

  /// User registration matching FindBookStay-Backend
  Future<bool> register({
    required String name,
    required String email,
    required String password,
    String? phone,
    String? role,
    String? profileImage,
    AddressModel? presentAddress,
    AddressModel? permanentAddress,
    String? referredBy,
  }) async {
    state = AuthState.loading(state.user);
    try {
      final user = await _authRepository.register(
        name: name,
        email: email,
        password: password,
        phone: phone,
        role: role,
        profileImage: profileImage,
        presentAddress: presentAddress,
        permanentAddress: permanentAddress,
        referredBy: referredBy,
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

  /// Sign out, cleaning up device token on backend
  Future<void> logout() async {
    state = AuthState.loading(state.user);
    try {
      String? fcmToken;
      try {
        fcmToken = NotificationService.instance.fcmToken;
      } catch (_) {}
      await _authRepository.logout(fcmToken: fcmToken);
      try {
        await NotificationService.instance.unregisterDevice();
      } catch (_) {}
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

  /// Resend verification or password reset OTP
  Future<bool> resendCode({
    required String email,
    required bool isRegistrationFlow,
  }) async {
    try {
      if (isRegistrationFlow) {
        await _authRepository.resendVerificationEmail(email);
      } else {
        await _authRepository.resendOtp(email);
      }
      return true;
    } on AppException catch (e) {
      debugPrint('❌ [resendCode Error]: ${e.message} | User Msg: ${e.userMessage}');
      if (!ref.mounted) return false;
      state = AuthState.error(e.userMessage, state.user);
      return false;
    } catch (e, stack) {
      debugPrint('❌ [resendCode Unknown Error]: $e\n$stack');
      if (!ref.mounted) return false;
      state = AuthState.error('Failed to resend code: $e', state.user);
      return false;
    }
  }

  /// Verify email with 6-digit OTP code (Registration flow)
  Future<bool> verifyEmail({
    required String email,
    required String otp,
  }) async {
    state = AuthState.loading(state.user);
    try {
      final isValid = await _authRepository.verifyEmail(email: email, otp: otp);
      if (!ref.mounted) return isValid;
      state = state.copyWith(status: AuthStatus.unauthenticated);
      return isValid;
    } on AppException catch (e) {
      debugPrint('❌ [verifyEmail Error]: ${e.message} | User Msg: ${e.userMessage}');
      if (!ref.mounted) return false;
      state = AuthState.error(e.userMessage, state.user);
      return false;
    } catch (e, stack) {
      debugPrint('❌ [verifyEmail Unknown Error]: $e\n$stack');
      if (!ref.mounted) return false;
      state = AuthState.error('Failed to verify code: $e', state.user);
      return false;
    }
  }

  /// OTP verification (Password reset flow)
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

  /// Fetch fresh profile from GET /api/v1/auth/me
  Future<UserModel?> fetchCurrentUser() async {
    try {
      final user = await _authRepository.getCurrentUser();
      if (!ref.mounted) return user;
      state = AuthState.authenticated(user);
      _syncWithAuthService(user, isLoggedIn: true);
      return user;
    } catch (e) {
      debugPrint('Error fetching current user: $e');
      return state.user;
    }
  }

  /// Update profile via PATCH /api/v1/auth/profile
  Future<UserModel> updateProfile(
    Map<String, dynamic> data, {
    String? imageFilePath,
  }) async {
    state = AuthState.loading(state.user);
    try {
      final updatedUser = await _authRepository.updateProfile(
        data,
        imageFilePath: imageFilePath,
      );
      if (!ref.mounted) return updatedUser;
      state = AuthState.authenticated(updatedUser);
      _syncWithAuthService(updatedUser, isLoggedIn: true);
      return updatedUser;
    } on AppException catch (e) {
      if (!ref.mounted) rethrow;
      state = AuthState.error(e.userMessage, state.user);
      rethrow;
    } catch (e) {
      if (!ref.mounted) rethrow;
      state = AuthState.error('Failed to update profile. Please try again.', state.user);
      rethrow;
    }
  }

  /// Clear any error message
  void clearError() {
    if (state.hasError) {
      state = state.copyWith(errorMessage: null);
    }
  }

  /// Bi-directional sync with [AuthService] for backward compatibility with existing tests
  void _syncWithAuthService(UserModel user, {required bool isLoggedIn}) {
    try {
      if (isLoggedIn) {
        AuthService.instance.signIn(
          name: user.name,
          email: user.email,
          role: user.role,
          phone: user.phone,
          avatar: user.avatarUrl ?? user.profileImage,
        ).catchError((_) {});
      } else {
        AuthService.instance.signOut().catchError((_) {});
      }
    } catch (_) {}
  }
}
