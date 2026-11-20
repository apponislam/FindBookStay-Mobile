import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Key used to persist theme mode preference in SharedPreferences.
const String _themePrefKey = 'app_theme_mode';

/// Notifier managing application theme mode (Light, Dark, System).
class ThemeController extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    _loadSavedTheme();
    return ThemeMode.light;
  }

  Future<void> _loadSavedTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_themePrefKey);
      if (saved == 'dark') {
        state = ThemeMode.dark;
      } else if (saved == 'system') {
        state = ThemeMode.system;
      } else {
        state = ThemeMode.light;
      }
    } catch (_) {
      // Default to light mode on error
    }
  }

  /// Change theme mode and persist to SharedPreferences
  Future<void> setThemeMode(ThemeMode mode) async {
    if (state == mode) return;
    HapticFeedback.selectionClick();
    state = mode;

    try {
      final prefs = await SharedPreferences.getInstance();
      final value = mode == ThemeMode.dark
          ? 'dark'
          : mode == ThemeMode.system
              ? 'system'
              : 'light';
      await prefs.setString(_themePrefKey, value);
    } catch (_) {}
  }

  /// Toggle between Light and Dark mode
  Future<void> toggleTheme() async {
    final nextMode = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await setThemeMode(nextMode);
  }
}

/// Riverpod provider for application theme mode.
final themeModeProvider =
    NotifierProvider<ThemeController, ThemeMode>(ThemeController.new);

/// Convenience provider checking if current effective theme is dark.
final isDarkModeProvider = Provider<bool>((ref) {
  final mode = ref.watch(themeModeProvider);
  return mode == ThemeMode.dark;
});
