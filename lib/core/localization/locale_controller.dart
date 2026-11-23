import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Key used to persist locale preference in SharedPreferences.
const String _localePrefKey = 'app_locale_code';

/// Supported locales in FindBookStay: English and Bangla.
class AppLocales {
  AppLocales._();

  static const Locale english = Locale('en');
  static const Locale bangla = Locale('bn');

  static const List<Locale> supported = [english, bangla];

  static bool isSupported(Locale locale) {
    return supported.any((l) => l.languageCode == locale.languageCode);
  }
}

/// Notifier managing application locale state (English, Bangla) with persistence.
class LocaleController extends Notifier<Locale> {
  @override
  Locale build() {
    loadSavedLocale();
    return AppLocales.english;
  }

  /// Load persisted locale preference from SharedPreferences
  Future<void> loadSavedLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedCode = prefs.getString(_localePrefKey);
      if (savedCode == 'bn') {
        state = AppLocales.bangla;
      } else if (savedCode == 'en') {
        state = AppLocales.english;
      }
    } catch (_) {
      // Default to English on error
    }
  }

  /// Change application locale and persist to SharedPreferences
  Future<void> setLocale(Locale locale) async {
    if (state.languageCode == locale.languageCode) return;
    if (!AppLocales.isSupported(locale)) return;

    HapticFeedback.selectionClick();
    state = locale;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_localePrefKey, locale.languageCode);
    } catch (_) {}
  }

  /// Switch between English and Bangla
  Future<void> toggleLocale() async {
    if (state.languageCode == 'bn') {
      await setLocale(AppLocales.english);
    } else {
      await setLocale(AppLocales.bangla);
    }
  }

  /// Helper returning whether current language is Bangla
  bool get isBengali => state.languageCode == 'bn';
}

/// Global Riverpod provider for application locale state
final localeProvider =
    NotifierProvider<LocaleController, Locale>(LocaleController.new);

