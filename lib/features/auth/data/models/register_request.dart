/// Data payload for registering a new user.
class RegisterRequest {
  final String name;
  final String email;
  final String password;
  final String? phone;
  final String? role;

  const RegisterRequest({
    required this.name,
    required this.email,
    required this.password,
    this.phone,
    this.role,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name.trim(),
      'email': email.trim(),
      'password': password,
      if (phone != null && phone!.isNotEmpty) 'phone': phone!.trim(),
      if (role != null && role!.isNotEmpty) 'role': role!.trim(),
    };
  }
}
