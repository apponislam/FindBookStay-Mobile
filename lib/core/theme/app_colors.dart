import 'package:material_ui/material_ui.dart';

/// App color system for FindBookStay
class AppColors {
  AppColors._();

  // Primary Brand Colors
  static const Color primary = Color(0xFF073B35); // Deep Forest Green
  static const Color primaryDark = Color(0xFF052F2A);
  static const Color accent = Color(0xFF10B981); // Mint / Emerald
  static const Color accentLight = Color(0xFFE6F7F2); // Soft mint tint

  // Background & Surfaces
  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFF8FAF9);
  static const Color surfaceCard = Color(0xFFFFFFFF);
  static const Color surfaceElevated = Color(0xFFF0F5F2);

  // Typography Colors
  static const Color textPrimary = Color(0xFF172B2A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color textWhite = Color(0xFFFFFFFF);

  // Borders & Dividers
  static const Color border = Color(0xFFE2EAE6);
  static const Color borderSubtle = Color(0xFFF1F5F3);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryDark],
  );

  static const LinearGradient cardGlowGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0x1A10B981), Color(0x05073B35)],
  );
}

