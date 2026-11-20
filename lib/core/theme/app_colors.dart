import 'package:material_ui/material_ui.dart';

/// App color system for FindBookStay supporting both Light and Dark modes.
class AppColors {
  AppColors._();

  // Primary Brand Colors
  static const Color primary = Color(0xFF073B35); // Deep Forest Green
  static const Color primaryDark = Color(0xFF052F2A);
  static const Color accent = Color(0xFF10B981); // Mint / Emerald
  static const Color accentDark = Color(0xFF059669);
  static const Color accentLight = Color(0xFFE6F7F2); // Soft mint tint

  // Light Theme Palette
  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFF8FAF9);
  static const Color surfaceCard = Color(0xFFFFFFFF);
  static const Color surfaceElevated = Color(0xFFF0F5F2);

  // Typography Colors (Light)
  static const Color textPrimary = Color(0xFF172B2A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color textWhite = Color(0xFFFFFFFF);

  // Borders & Dividers (Light)
  static const Color border = Color(0xFFE2EAE6);
  static const Color borderSubtle = Color(0xFFF1F5F3);

  // Status & Feedback Colors
  static const Color error = Color(0xFFDC2626);
  static const Color warning = Color(0xFFF59E0B);
  static const Color success = Color(0xFF10B981);

  // Dark Theme Palette
  static const Color darkBackground = Color(0xFF0C1412);
  static const Color darkSurface = Color(0xFF13201D);
  static const Color darkCard = Color(0xFF182622);
  static const Color darkElevated = Color(0xFF1F302B);
  static const Color darkBorder = Color(0xFF223530);
  static const Color darkBorderSubtle = Color(0xFF1A2A26);
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkTextMuted = Color(0xFF64748B);
  static const Color darkAccentLight = Color(0xFF13382E);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryDark],
  );

  static const LinearGradient darkPrimaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF10B981), Color(0xFF073B35)],
  );

  static const LinearGradient cardGlowGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0x1A10B981), Color(0x05073B35)],
  );

  /// Helper returning dynamic background color based on active brightness
  static Color bg(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkBackground : background;

  /// Helper returning dynamic surface color based on active brightness
  static Color surf(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkSurface : surface;

  /// Helper returning dynamic card color based on active brightness
  static Color card(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkCard : surfaceCard;

  /// Helper returning dynamic border color based on active brightness
  static Color brd(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkBorder : border;

  /// Helper returning dynamic primary text color based on active brightness
  static Color txtPrimary(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkTextPrimary : textPrimary;

  /// Helper returning dynamic secondary text color based on active brightness
  static Color txtSecondary(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkTextSecondary : textSecondary;
}
