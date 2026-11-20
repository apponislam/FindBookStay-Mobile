import 'package:dio/dio.dart';

import 'auth_tokens_model.dart';
import 'user_model.dart';

/// Aggregates user profile and JWT tokens returned by authentication endpoints.
class AuthResponseModel {
  final UserModel user;
  final AuthTokensModel tokens;

  const AuthResponseModel({required this.user, required this.tokens});

  factory AuthResponseModel.fromResponse(Response response) {
    final responseData = response.data is Map<String, dynamic>
        ? response.data as Map<String, dynamic>
        : <String, dynamic>{};
    final setCookieHeader = response.headers['set-cookie']?.join('; ');
    return AuthResponseModel.fromJson(responseData, setCookie: setCookieHeader);
  }

  factory AuthResponseModel.fromJson(
    Map<String, dynamic> json, {
    String? setCookie,
  }) {
    final dataMap = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : null;

    final userData = json['user'] is Map<String, dynamic>
        ? json['user'] as Map<String, dynamic>
        : dataMap?['user'] is Map<String, dynamic>
            ? dataMap!['user'] as Map<String, dynamic>
            : json;

    final tokensMap = json['tokens'] is Map<String, dynamic>
        ? json['tokens'] as Map<String, dynamic>
        : dataMap?['tokens'] is Map<String, dynamic>
            ? dataMap!['tokens'] as Map<String, dynamic>
            : null;

    final accessToken = json['accessToken'] as String? ??
        dataMap?['accessToken'] as String? ??
        tokensMap?['accessToken'] as String? ??
        json['token'] as String? ??
        dataMap?['token'] as String? ??
        '';

    String refreshToken = json['refreshToken'] as String? ??
        dataMap?['refreshToken'] as String? ??
        tokensMap?['refreshToken'] as String? ??
        '';

    // If refreshToken wasn't in JSON body, look in Set-Cookie header from backend
    if (refreshToken.isEmpty && setCookie != null) {
      final match = RegExp(r'refreshToken=([^;]+)').firstMatch(setCookie);
      if (match != null) {
        refreshToken = match.group(1) ?? '';
      }
    }

    return AuthResponseModel(
      user: UserModel.fromJson(userData),
      tokens: AuthTokensModel(
        accessToken: accessToken,
        refreshToken: refreshToken,
        tokenType: json['tokenType'] as String? ??
            dataMap?['tokenType'] as String? ??
            'Bearer',
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {'user': user.toJson(), 'tokens': tokens.toJson()};
  }
}
