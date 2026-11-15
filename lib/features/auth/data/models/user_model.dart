import 'register_request.dart';

/// Strongly typed immutable domain model for a registered or guest user,
/// matching FindBookStay-Backend schema exactly.
class UserModel {
  final String id;
  final String name;
  final String email;
  final String role;
  final String? phone;
  final String? profileImage;
  final String? avatarUrl;
  final AddressModel? presentAddress;
  final AddressModel? permanentAddress;
  final bool isEmailVerified;
  final DateTime? createdAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.phone,
    this.profileImage,
    this.avatarUrl,
    this.presentAddress,
    this.permanentAddress,
    this.isEmailVerified = false,
    this.createdAt,
  });

  /// Default demo/fallback profile for quick starts
  static const UserModel defaultUser = UserModel(
    id: 'usr_default_01',
    name: 'Alex Tan',
    email: 'alex.tan@example.com',
    role: 'USER',
    phone: '+880 1712-345678',
    isEmailVerified: true,
  );

  /// Guest representation
  static const UserModel guest = UserModel(
    id: 'usr_guest',
    name: 'Guest User',
    email: '',
    role: 'Guest',
    isEmailVerified: false,
  );

  bool get isGuest => id == 'usr_guest' || email.isEmpty;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final image = json['profileImage'] as String? ??
        json['avatarUrl'] as String? ??
        json['avatar'] as String?;

    return UserModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      name: json['name'] as String? ?? 'User',
      email: json['email'] as String? ?? '',
      role: json['role'] as String? ?? 'USER',
      phone: json['phone'] as String?,
      profileImage: image,
      avatarUrl: image,
      presentAddress: json['presentAddress'] is Map<String, dynamic>
          ? AddressModel.fromJson(json['presentAddress'] as Map<String, dynamic>)
          : null,
      permanentAddress: json['permanentAddress'] is Map<String, dynamic>
          ? AddressModel.fromJson(json['permanentAddress'] as Map<String, dynamic>)
          : null,
      isEmailVerified: json['isEmailVerified'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      if (phone != null) 'phone': phone,
      if (profileImage != null) 'profileImage': profileImage,
      if (avatarUrl != null) 'avatarUrl': avatarUrl,
      if (presentAddress != null && !presentAddress!.isEmpty)
        'presentAddress': presentAddress!.toJson(),
      if (permanentAddress != null && !permanentAddress!.isEmpty)
        'permanentAddress': permanentAddress!.toJson(),
      'isEmailVerified': isEmailVerified,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? role,
    String? phone,
    String? profileImage,
    String? avatarUrl,
    AddressModel? presentAddress,
    AddressModel? permanentAddress,
    bool? isEmailVerified,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      profileImage: profileImage ?? this.profileImage,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      presentAddress: presentAddress ?? this.presentAddress,
      permanentAddress: permanentAddress ?? this.permanentAddress,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          email == other.email &&
          role == other.role;

  @override
  int get hashCode => id.hashCode ^ email.hashCode ^ role.hashCode;

  @override
  String toString() =>
      'UserModel(id: $id, name: $name, email: $email, role: $role)';
}
