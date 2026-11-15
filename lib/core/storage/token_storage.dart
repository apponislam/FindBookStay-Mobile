import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Contract for persistent secure JWT token and session storage.
abstract class TokenStorage {
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  });

  Future<String?> getAccessToken();
  Future<String?> getRefreshToken();
  Future<void> clearTokens();
  Future<bool> hasAccessToken();

  Future<void> saveUserRaw(Map<String, dynamic> userMap);
  Future<Map<String, dynamic>?> getUserRaw();
  Future<void> clearAll();
}

/// SharedPreferences implementation of [TokenStorage].
class SharedPrefsTokenStorage implements TokenStorage {
  static const String _keyAccessToken = 'auth_access_token';
  static const String _keyRefreshToken = 'auth_refresh_token';
  static const String _keyUserJson = 'auth_user_json';

  final SharedPreferences? _prefs;

  SharedPrefsTokenStorage([this._prefs]);

  Future<SharedPreferences> _getPrefs() async {
    return _prefs ?? await SharedPreferences.getInstance();
  }

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    final prefs = await _getPrefs();
    await prefs.setString(_keyAccessToken, accessToken);
    await prefs.setString(_keyRefreshToken, refreshToken);
  }

  @override
  Future<String?> getAccessToken() async {
    final prefs = await _getPrefs();
    return prefs.getString(_keyAccessToken);
  }

  @override
  Future<String?> getRefreshToken() async {
    final prefs = await _getPrefs();
    return prefs.getString(_keyRefreshToken);
  }

  @override
  Future<void> clearTokens() async {
    final prefs = await _getPrefs();
    await prefs.remove(_keyAccessToken);
    await prefs.remove(_keyRefreshToken);
  }

  @override
  Future<bool> hasAccessToken() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  @override
  Future<void> saveUserRaw(Map<String, dynamic> userMap) async {
    final prefs = await _getPrefs();
    await prefs.setString(_keyUserJson, jsonEncode(userMap));
  }

  @override
  Future<Map<String, dynamic>?> getUserRaw() async {
    final prefs = await _getPrefs();
    final raw = prefs.getString(_keyUserJson);
    if (raw == null || raw.isEmpty) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> clearAll() async {
    final prefs = await _getPrefs();
    await prefs.remove(_keyAccessToken);
    await prefs.remove(_keyRefreshToken);
    await prefs.remove(_keyUserJson);
  }
}

/// Riverpod provider for [TokenStorage].
final tokenStorageProvider = Provider<TokenStorage>((ref) {
  return SharedPrefsTokenStorage();
});
