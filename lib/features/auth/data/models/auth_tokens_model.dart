/// Strongly typed model representing JWT access and refresh token pair.
class AuthTokensModel {
  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final int? expiresIn;

  const AuthTokensModel({
    required this.accessToken,
    required this.refreshToken,
    this.tokenType = 'Bearer',
    this.expiresIn,
  });

  factory AuthTokensModel.fromJson(Map<String, dynamic> json) {
    final dataMap = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : null;

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

    final refreshToken = json['refreshToken'] as String? ??
        dataMap?['refreshToken'] as String? ??
        tokensMap?['refreshToken'] as String? ??
        '';

    return AuthTokensModel(
      accessToken: accessToken,
      refreshToken: refreshToken,
      tokenType: json['tokenType'] as String? ??
          dataMap?['tokenType'] as String? ??
          'Bearer',
      expiresIn: json['expiresIn'] as int? ?? dataMap?['expiresIn'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'tokenType': tokenType,
      'expiresIn': expiresIn,
    };
  }
}
