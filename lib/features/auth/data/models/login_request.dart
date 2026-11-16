/// Data payload for logging in a user.
class LoginRequest {
  final String email;
  final String password;
  final String? fcmToken;

  const LoginRequest({
    required this.email,
    required this.password,
    this.fcmToken,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'email': email.trim(),
      'password': password,
    };
    if (fcmToken != null && fcmToken!.trim().isNotEmpty) {
      map['fcmToken'] = fcmToken!.trim();
    }
    return map;
  }
}
