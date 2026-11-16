import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../models/auth_response_model.dart';
import '../models/auth_tokens_model.dart';
import '../models/login_request.dart';
import '../models/register_request.dart';
import '../models/user_model.dart';

/// Contract for remote authentication API service.
abstract class AuthRemoteDataSource {
  Future<AuthResponseModel> login(LoginRequest request);
  Future<AuthResponseModel> register(RegisterRequest request);
  Future<AuthTokensModel> refreshToken(String refreshToken);
  Future<void> logout([String? fcmToken]);
  Future<void> registerFcmToken(String fcmToken);
  Future<void> removeFcmToken(String fcmToken);
  Future<UserModel> getCurrentUser();
  Future<void> forgotPassword(String email);
  Future<bool> verifyOtp({required String email, required String otp});
  Future<void> resendOtp(String email);
  Future<bool> verifyEmail({required String email, required String otp});
  Future<void> resendVerificationEmail(String email);
  Future<void> resetPassword({
    required String email,
    required String newPassword,
    required String otp,
  });
}

/// Dio implementation of [AuthRemoteDataSource].
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final DioClient dioClient;

  AuthRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<AuthResponseModel> login(LoginRequest request) async {
    final response = await dioClient.post(
      ApiEndpoints.authLogin,
      data: request.toJson(),
    );

    final responseData = response.data as Map<String, dynamic>;
    return AuthResponseModel.fromJson(responseData);
  }

  @override
  Future<AuthResponseModel> register(RegisterRequest request) async {
    final response = await dioClient.post(
      ApiEndpoints.authRegister,
      data: request.toJson(),
    );

    final responseData = response.data as Map<String, dynamic>;
    return AuthResponseModel.fromJson(responseData);
  }

  @override
  Future<AuthTokensModel> refreshToken(String refreshToken) async {
    final response = await dioClient.post(
      ApiEndpoints.authRefreshToken,
      data: {'refreshToken': refreshToken},
    );

    final responseData = response.data as Map<String, dynamic>;
    return AuthTokensModel.fromJson(responseData);
  }

  @override
  Future<void> logout([String? fcmToken]) async {
    try {
      final data = <String, dynamic>{};
      if (fcmToken != null && fcmToken.isNotEmpty) {
        data['fcmToken'] = fcmToken;
      }
      await dioClient.post(
        ApiEndpoints.authLogout,
        data: data.isNotEmpty ? data : null,
      );
    } catch (_) {
      // Best effort logout - server error does not prevent local cleanup
    }
  }

  @override
  Future<void> registerFcmToken(String fcmToken) async {
    try {
      await dioClient.post(
        ApiEndpoints.authFcmToken,
        data: {'fcmToken': fcmToken.trim()},
      );
    } catch (_) {
      // Best effort - do not fail if notification endpoint error occurs
    }
  }

  @override
  Future<void> removeFcmToken(String fcmToken) async {
    try {
      await dioClient.delete(
        ApiEndpoints.authFcmToken,
        data: {'fcmToken': fcmToken.trim()},
      );
    } catch (_) {
      // Best effort
    }
  }

  @override
  Future<UserModel> getCurrentUser() async {
    final response = await dioClient.get(ApiEndpoints.authMe);
    final responseData = response.data as Map<String, dynamic>;
    final userData = responseData['data'] is Map<String, dynamic>
        ? responseData['data'] as Map<String, dynamic>
        : responseData;
    return UserModel.fromJson(userData);
  }

  @override
  Future<void> forgotPassword(String email) async {
    await dioClient.post(
      ApiEndpoints.authForgotPassword,
      data: {'email': email.trim()},
    );
  }

  @override
  Future<bool> verifyOtp({required String email, required String otp}) async {
    final response = await dioClient.post(
      ApiEndpoints.authVerifyOtp,
      data: {'email': email.trim(), 'otp': otp.trim()},
    );

    final data = response.data;
    if (data is Map<String, dynamic>) {
      final isValid = data['valid'] as bool? ?? data['success'] as bool?;
      if (isValid != null) return isValid;
    }
    return true;
  }

  @override
  Future<void> resendOtp(String email) async {
    await dioClient.post(
      ApiEndpoints.authResendOtp,
      data: {'email': email.trim()},
    );
  }

  @override
  Future<bool> verifyEmail({required String email, required String otp}) async {
    final cleanEmail = email.trim();
    final cleanOtp = otp.trim();
    final response = await dioClient.post(
      ApiEndpoints.authVerifyEmail,
      data: {'email': cleanEmail, 'otp': cleanOtp},
      queryParameters: {'email': cleanEmail, 'otp': cleanOtp},
    );

    final data = response.data;
    if (data is Map<String, dynamic>) {
      final isValid = data['success'] as bool? ?? data['valid'] as bool?;
      if (isValid != null) return isValid;
    }
    return true;
  }

  @override
  Future<void> resendVerificationEmail(String email) async {
    final cleanEmail = email.trim();
    await dioClient.post(
      ApiEndpoints.authResendVerification,
      data: {'email': cleanEmail},
      queryParameters: {'email': cleanEmail},
    );
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String newPassword,
    required String otp,
  }) async {
    await dioClient.post(
      ApiEndpoints.authResetPassword,
      data: {
        'email': email.trim(),
        'newPassword': newPassword,
        'otp': otp.trim(),
      },
    );
  }
}
