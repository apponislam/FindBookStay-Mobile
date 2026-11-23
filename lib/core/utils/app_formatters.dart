import 'package:intl/intl.dart';

/// Centralized date and currency formatting utilities using the official `intl` package.
/// Respects active application locale (English `en` vs Bangla `bn`).
class AppFormatters {
  AppFormatters._();

  /// Bengali numerals map
  static const Map<String, String> _bengaliDigits = {
    '0': '০',
    '1': '১',
    '2': '২',
    '3': '৩',
    '4': '৪',
    '5': '৫',
    '6': '৬',
    '7': '৭',
    '8': '৮',
    '9': '৯',
  };

  /// Converts standard ASCII digits to Bengali digits
  static String toBengaliNumerals(String input) {
    final buffer = StringBuffer();
    for (int i = 0; i < input.length; i++) {
      final char = input[i];
      buffer.write(_bengaliDigits[char] ?? char);
    }
    return buffer.toString();
  }

  /// Formats currency with BDT (৳) symbol according to active language locale.
  /// Example:
  /// - en: "৳ 1,500"
  /// - bn: "৳ ১,৫০০"
  static String formatCurrency(
    num amount, {
    String? locale,
    bool showSymbol = true,
    int decimalDigits = 0,
  }) {
    final effectiveLocale = locale ?? 'en';
    final formatter = NumberFormat.currency(
      locale: effectiveLocale == 'bn' ? 'bn_BD' : 'en_US',
      symbol: showSymbol ? '৳ ' : '',
      decimalDigits: decimalDigits,
    );

    try {
      final formatted = formatter.format(amount);
      if (effectiveLocale == 'bn') {
        return toBengaliNumerals(formatted);
      }
      return formatted;
    } catch (_) {
      // Fallback
      final basic = NumberFormat('#,##0', 'en_US').format(amount);
      final withSymbol = showSymbol ? '৳ $basic' : basic;
      return effectiveLocale == 'bn' ? toBengaliNumerals(withSymbol) : withSymbol;
    }
  }

  /// Formats integer or floating number based on locale.
  /// Example:
  /// - en: "1,250"
  /// - bn: "১,২৫০"
  static String formatNumber(num number, {String? locale}) {
    final effectiveLocale = locale ?? 'en';
    final formatted = NumberFormat('#,##0', 'en_US').format(number);
    return effectiveLocale == 'bn' ? toBengaliNumerals(formatted) : formatted;
  }

  /// Formats date according to locale.
  /// Example: "20 Nov 2026" / "২০ নভে ২০২৬"
  static String formatDate(
    DateTime date, {
    String? locale,
    String pattern = 'dd MMM yyyy',
  }) {
    final effectiveLocale = locale ?? 'en';
    try {
      final formatted = DateFormat(pattern, effectiveLocale).format(date);
      return effectiveLocale == 'bn' ? toBengaliNumerals(formatted) : formatted;
    } catch (_) {
      try {
        final formatted = DateFormat(pattern).format(date);
        return effectiveLocale == 'bn' ? toBengaliNumerals(formatted) : formatted;
      } catch (_) {
        final fallback =
            '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
        return effectiveLocale == 'bn' ? toBengaliNumerals(fallback) : fallback;
      }
    }
  }

  /// Formats time in 12-hour or 24-hour style.
  /// Example: "03:45 PM" / "০৩:৪৫ অপরাহ্ন"
  static String formatTime(
    DateTime dateTime, {
    String? locale,
    bool is24Hour = false,
  }) {
    final effectiveLocale = locale ?? 'en';
    final pattern = is24Hour ? 'HH:mm' : 'hh:mm a';
    try {
      final formatted = DateFormat(pattern, effectiveLocale).format(dateTime);
      return effectiveLocale == 'bn' ? toBengaliNumerals(formatted) : formatted;
    } catch (_) {
      try {
        final formatted = DateFormat(pattern).format(dateTime);
        return effectiveLocale == 'bn' ? toBengaliNumerals(formatted) : formatted;
      } catch (_) {
        final hour = is24Hour ? dateTime.hour : (dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12);
        final period = dateTime.hour >= 12 ? 'PM' : 'AM';
        final fallback = is24Hour
            ? '${hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}'
            : '${hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')} $period';
        return effectiveLocale == 'bn' ? toBengaliNumerals(fallback) : fallback;
      }
    }
  }
}

