import 'auth_tokens_model.dart';
import 'user_model.dart';

/// Aggregates user profile and JWT tokens returned by authentication endpoints.
class AuthResponseModel {
  final UserModel user;
  final AuthTokensModel tokens;

  const AuthResponseModel({
    required this.user,
    required this.tokens,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    final userData = json['user'] is Map<String, dynamic>
        ? json['user'] as Map<String, dynamic>
        : json['data']?['user'] is Map<String, dynamic>
            ? json['data']['user'] as Map<String, dynamic>
            : json;

    final tokensData = json['tokens'] is Map<String, dynamic>
        ? json['tokens'] as Map<String, dynamic>
        : json['data']?['tokens'] is Map<String, dynamic>
            ? json['data']['tokens'] as Map<String, dynamic>
            : json;

    return AuthResponseModel(
      user: UserModel.fromJson(userData),
      tokens: AuthTokensModel.fromJson(tokensData),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'tokens': tokens.toJson(),
    };
  }
}
