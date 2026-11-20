import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/url_utils.dart';

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
  String _userAvatar = '';

  bool get isLoggedIn => _isLoggedIn;
  String get userName => _userName;
  String get userEmail => _userEmail;
  String get userRole => _userRole;
  String get userPhone => _userPhone;
  String get userAvatar => _userAvatar;

  /// Returns fully resolved avatar URL ready for NetworkImage / Image.network
  String get resolvedAvatarUrl => UrlUtils.resolveUrl(_userAvatar);

  /// Formatted short display name for top greetings:
  /// - 'Md. Appon Islam' -> 'Md. Appon'
  /// - 'Appon Islam' -> 'Appon'
  String get shortDisplayName => formatShortName(_userName);

  /// Helper to format full name into a natural short greeting name:
  /// Retains honorific/title prefixes like 'Md.', 'Mohammad', 'Dr.', 'Mst.', etc.
  static String formatShortName(String? fullName) {
    if (fullName == null || fullName.trim().isEmpty) return '';
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.length <= 1) return parts.first;

    const prefixes = {
      'md.',
      'md',
      'mohammad',
      'mohammed',
      'muhammad',
      'most.',
      'most',
      'mst.',
      'mst',
      'dr.',
      'dr',
      'mr.',
      'mr',
      'mrs.',
      'mrs',
      'ms.',
      'ms',
      'prof.',
      'prof',
      'engr.',
      'engr',
      'sk.',
      'sk',
      'sheikh',
    };

    final firstLower = parts[0].toLowerCase();
    if (prefixes.contains(firstLower) && parts.length > 1) {
      return '${parts[0]} ${parts[1]}';
    }

    return parts[0];
  }

  /// Initialize state from SharedPreferences on app launch
  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance().timeout(
        const Duration(seconds: 2),
      );
      _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
      _userName = prefs.getString('userName') ?? '';
      _userEmail = prefs.getString('userEmail') ?? '';
      _userRole = prefs.getString('userRole') ?? 'USER';
      _userPhone = prefs.getString('userPhone') ?? '';
      _userAvatar = prefs.getString('userAvatar') ?? '';
      notifyListeners();
    } catch (e) {
      debugPrint('AuthService.init notice: $e');
    }
  }

  /// Sign in user and persist state
  Future<void> signIn({
    String? email,
    String? name,
    String? role,
    String? phone,
    String? avatar,
  }) async {
    _isLoggedIn = true;
    if (email != null && email.isNotEmpty) _userEmail = email;
    if (name != null && name.isNotEmpty) _userName = name;
    if (role != null && role.isNotEmpty) _userRole = role;
    if (phone != null && phone.isNotEmpty) _userPhone = phone;
    if (avatar != null && avatar.isNotEmpty) _userAvatar = avatar;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('userName', _userName);
    await prefs.setString('userEmail', _userEmail);
    await prefs.setString('userRole', _userRole);
    await prefs.setString('userPhone', _userPhone);
    await prefs.setString('userAvatar', _userAvatar);

    notifyListeners();
  }

  /// Sign out user back to Guest / Non-Signed-In mode
  Future<void> signOut() async {
    _isLoggedIn = false;
    _userName = '';
    _userEmail = '';
    _userPhone = '';
    _userAvatar = '';
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    await prefs.remove('userName');
    await prefs.remove('userEmail');
    await prefs.remove('userPhone');
    await prefs.remove('userAvatar');
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

