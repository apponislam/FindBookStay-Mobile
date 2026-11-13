import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Lightweight reactive authentication service for FindBookStay.
/// Manages Signed-In vs Non-Signed-In (Guest) states across the app.
class AuthService extends ChangeNotifier {
  static final AuthService instance = AuthService._internal();

  AuthService._internal();

  bool _isLoggedIn = false;
  String _userName = 'Alex Tan';
  String _userEmail = 'alex.tan@example.com';
  String _userRole = 'Tenant & Player';
  String _userPhone = '+880 1712-345678';

  bool get isLoggedIn => _isLoggedIn;
  String get userName => _userName;
  String get userEmail => _userEmail;
  String get userRole => _userRole;
  String get userPhone => _userPhone;

  /// Initialize state from SharedPreferences on app launch
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    _userName = prefs.getString('userName') ?? 'Alex Tan';
    _userEmail = prefs.getString('userEmail') ?? 'alex.tan@example.com';
    _userRole = prefs.getString('userRole') ?? 'Tenant & Player';
    _userPhone = prefs.getString('userPhone') ?? '+880 1712-345678';
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
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    notifyListeners();
  }

  /// Toggle auth state (convenient for quick testing/demoing)
  Future<void> toggleAuthState() async {
    if (_isLoggedIn) {
      await signOut();
    } else {
      await signIn();
    }
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
