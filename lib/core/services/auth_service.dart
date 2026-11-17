import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Lightweight reactive authentication service for FindBookStay.
/// Manages Signed-In vs Non-Signed-In (Guest) states across the app.
class AuthService extends ChangeNotifier {
  static final AuthService instance = AuthService._internal();

  AuthService._internal();

  bool _isLoggedIn = false;
  String _userName = '';
  String _userEmail = '';
  String _userRole = 'USER';
  String _userPhone = '';

  bool get isLoggedIn => _isLoggedIn;
  String get userName => _userName;
  String get userEmail => _userEmail;
  String get userRole => _userRole;
  String get userPhone => _userPhone;

  /// Initialize state from SharedPreferences on app launch
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    _userName = prefs.getString('userName') ?? '';
    _userEmail = prefs.getString('userEmail') ?? '';
    _userRole = prefs.getString('userRole') ?? 'USER';
    _userPhone = prefs.getString('userPhone') ?? '';
    notifyListeners();
  }

  /// Sign in user and persist state
  Future<void> signIn({
    String? email,
    String? name,
    String? role,
    String? phone,
  }) async {
    _isLoggedIn = true;
    if (email != null && email.isNotEmpty) _userEmail = email;
    if (name != null && name.isNotEmpty) _userName = name;
    if (role != null && role.isNotEmpty) _userRole = role;
    if (phone != null && phone.isNotEmpty) _userPhone = phone;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('userName', _userName);
    await prefs.setString('userEmail', _userEmail);
    await prefs.setString('userRole', _userRole);
    await prefs.setString('userPhone', _userPhone);

    notifyListeners();
  }

  /// Sign out user back to Guest / Non-Signed-In mode
  Future<void> signOut() async {
    _isLoggedIn = false;
    _userName = '';
    _userEmail = '';
    _userPhone = '';
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    await prefs.remove('userName');
    await prefs.remove('userEmail');
    await prefs.remove('userPhone');
    notifyListeners();
  }

  /// Switch user role between Tenant and Host
  Future<void> toggleRole() async {
    if (_userRole.contains('Tenant')) {
      _userRole = 'Host & Turf Owner';
    } else {
      _userRole = 'Tenant & Player';
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userRole', _userRole);
    notifyListeners();
  }
}

