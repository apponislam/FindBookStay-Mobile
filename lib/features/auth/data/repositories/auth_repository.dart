import '../../../../core/errors/app_exception.dart';
import '../../../../core/storage/token_storage.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/login_request.dart';
import '../models/register_request.dart';
import '../models/user_model.dart';

/// Clean repository contract for authentication operations.
abstract class AuthRepository {
  Future<UserModel> login({
    required String email,
    required String password,
    String? fcmToken,
  });

  Future<void> registerFcmToken(String fcmToken);
  Future<void> removeFcmToken(String fcmToken);

  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    String? phone,
    String? role,
    String? profileImage,
    AddressModel? presentAddress,
    AddressModel? permanentAddress,
    String? referredBy,
  });

  Future<void> logout({String? fcmToken});

  Future<UserModel?> getCachedUser();

  Future<bool> isAuthenticated();

  Future<void> forgotPassword(String email);

  Future<bool> verifyOtp({
    required String email,
    required String otp,
  });

  Future<void> resendOtp(String email);

  Future<bool> verifyEmail({
    required String email,
    required String otp,
  });

  Future<void> resendVerificationEmail(String email);

  Future<void> resetPassword({
    required String email,
    required String newPassword,
    required String otp,
  });

  Future<UserModel> saveUserProfile(UserModel user);

  Future<UserModel> getCurrentUser();

  Future<UserModel> updateProfile(
    Map<String, dynamic> data, {
    String? imageFilePath,
  });
}

/// Implementation of [AuthRepository] coordinating remote data and local persistence.
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final TokenStorage tokenStorage;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.tokenStorage,
  });

  @override
  Future<UserModel> login({
    required String email,
    required String password,
    String? fcmToken,
  }) async {
    try {
      final authResponse = await remoteDataSource.login(
        LoginRequest(
          email: email,
          password: password,
          fcmToken: fcmToken,
        ),
      );

      // Persist tokens
      await tokenStorage.saveTokens(
        accessToken: authResponse.tokens.accessToken,
        refreshToken: authResponse.tokens.refreshToken,
      );

      // Persist user profile
      await tokenStorage.saveUserRaw(authResponse.user.toJson());

      return authResponse.user;
    } on AppException {
      rethrow;
    }
  }

  @override
  Future<void> registerFcmToken(String fcmToken) async {
    await remoteDataSource.registerFcmToken(fcmToken);
  }

  @override
  Future<void> removeFcmToken(String fcmToken) async {
    await remoteDataSource.removeFcmToken(fcmToken);
  }

  @override
  Future<UserModel> register({
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
    try {
      final authResponse = await remoteDataSource.register(
        RegisterRequest(
          name: name,
          email: email,
          password: password,
          phone: phone,
          role: role ?? 'USER',
          profileImage: profileImage,
          presentAddress: presentAddress,
          permanentAddress: permanentAddress,
          referredBy: referredBy,
        ),
      );

      await tokenStorage.saveTokens(
        accessToken: authResponse.tokens.accessToken,
        refreshToken: authResponse.tokens.refreshToken,
      );

      await tokenStorage.saveUserRaw(authResponse.user.toJson());

      return authResponse.user;
    } on AppException {
      rethrow;
    }
  }

  @override
  Future<void> logout({String? fcmToken}) async {
    try {
      await remoteDataSource.logout(fcmToken);
    } catch (_) {
      // Ignore network failures on logout
    } finally {
      await tokenStorage.clearAll();
    }
  }

  @override
  Future<UserModel?> getCachedUser() async {
    final rawUser = await tokenStorage.getUserRaw();
    if (rawUser != null) {
      try {
        return UserModel.fromJson(rawUser);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  @override
  Future<bool> isAuthenticated() async {
    final hasAccess = await tokenStorage.hasAccessToken();
    if (hasAccess) return true;

    final refresh = await tokenStorage.getRefreshToken();
    if (refresh != null && refresh.isNotEmpty) {
      try {
        final newTokens = await remoteDataSource.refreshToken(refresh);
        if (newTokens.accessToken.isNotEmpty) {
          await tokenStorage.saveTokens(
            accessToken: newTokens.accessToken,
            refreshToken: newTokens.refreshToken.isNotEmpty
                ? newTokens.refreshToken
                : refresh,
          );
          return true;
        }
      } catch (_) {
        return false;
      }
    }
    return false;
  }

  @override
  Future<void> forgotPassword(String email) async {
    await remoteDataSource.forgotPassword(email);
  }

  @override
  Future<bool> verifyOtp({
    required String email,
    required String otp,
  }) async {
    return await remoteDataSource.verifyOtp(email: email, otp: otp);
  }

  @override
  Future<void> resendOtp(String email) async {
    await remoteDataSource.resendOtp(email);
  }

  @override
  Future<bool> verifyEmail({
    required String email,
    required String otp,
  }) async {
    return await remoteDataSource.verifyEmail(email: email, otp: otp);
  }

  @override
  Future<void> resendVerificationEmail(String email) async {
    await remoteDataSource.resendVerificationEmail(email);
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String newPassword,
    required String otp,
  }) async {
    await remoteDataSource.resetPassword(
      email: email,
      newPassword: newPassword,
      otp: otp,
    );
  }

  @override
  Future<UserModel> saveUserProfile(UserModel user) async {
    await tokenStorage.saveUserRaw(user.toJson());
    return user;
  }

  @override
  Future<UserModel> getCurrentUser() async {
    final user = await remoteDataSource.getCurrentUser();
    await tokenStorage.saveUserRaw(user.toJson());
    return user;
  }

  @override
  Future<UserModel> updateProfile(
    Map<String, dynamic> data, {
    String? imageFilePath,
  }) async {
    final updatedUser = await remoteDataSource.updateProfile(
      data,
      imageFilePath: imageFilePath,
    );
    await tokenStorage.saveUserRaw(updatedUser.toJson());
    return updatedUser;
  }
}
