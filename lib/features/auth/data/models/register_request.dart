/// Strongly typed Address model matching FindBookStay-Backend Address schema.
class AddressModel {
  final String? street;
  final String? city;
  final String? state;
  final String? zipCode;
  final String? country;

  const AddressModel({
    this.street,
    this.city,
    this.state,
    this.zipCode,
    this.country,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      street: json['street'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      zipCode: json['zipCode'] as String?,
      country: json['country'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (street != null && street!.isNotEmpty) 'street': street!.trim(),
      if (city != null && city!.isNotEmpty) 'city': city!.trim(),
      if (state != null && state!.isNotEmpty) 'state': state!.trim(),
      if (zipCode != null && zipCode!.isNotEmpty) 'zipCode': zipCode!.trim(),
      if (country != null && country!.isNotEmpty) 'country': country!.trim(),
    };
  }

  bool get isEmpty =>
      (street == null || street!.isEmpty) &&
      (city == null || city!.isEmpty) &&
      (state == null || state!.isEmpty) &&
      (zipCode == null || zipCode!.isEmpty) &&
      (country == null || country!.isEmpty);
}

/// Data payload for registering a new user matching FindBookStay-Backend exactly.
class RegisterRequest {
  final String name;
  final String email;
  final String password;
  final String role; // "USER" or "ADMIN" (defaults to "USER")
  final String? phone;
  final String? profileImage;
  final AddressModel? presentAddress;
  final AddressModel? permanentAddress;
  final String? referredBy;

  const RegisterRequest({
    required this.name,
    required this.email,
    required this.password,
    this.role = 'USER',
    this.phone,
    this.profileImage,
    this.presentAddress,
    this.permanentAddress,
    this.referredBy,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name.trim(),
      'email': email.trim().toLowerCase(),
      'password': password,
      'role': role.trim(),
      if (phone != null && phone!.isNotEmpty) 'phone': phone!.trim(),
      if (profileImage != null && profileImage!.isNotEmpty) 'profileImage': profileImage!.trim(),
      if (presentAddress != null && !presentAddress!.isEmpty) 'presentAddress': presentAddress!.toJson(),
      if (permanentAddress != null && !permanentAddress!.isEmpty) 'permanentAddress': permanentAddress!.toJson(),
      if (referredBy != null && referredBy!.isNotEmpty) 'referredBy': referredBy!.trim(),
    };
  }
}
