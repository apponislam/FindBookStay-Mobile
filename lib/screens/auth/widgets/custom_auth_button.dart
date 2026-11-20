import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/theme/app_colors.dart';

/// Primary call-to-action button for authentication flows.
/// 54px height, 16px corner radius, loading spinner, and haptic feedback.
class CustomAuthButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;

  const CustomAuthButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveBg = backgroundColor ?? (isDark ? AppColors.accent : AppColors.primary);
    final effectiveText = textColor ?? (isDark ? AppColors.primaryDark : AppColors.textWhite);

    return SizedBox(
      width: double.infinity,
      height: 54.0,
      child: ElevatedButton(
        onPressed: isLoading
            ? null
            : () {
                HapticFeedback.lightImpact();
                onPressed?.call();
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: effectiveBg,
          disabledBackgroundColor: effectiveBg.withValues(alpha: 0.65),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          shadowColor: effectiveBg.withValues(alpha: isDark ? 0.4 : 0.3),
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    text,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w700,
                      color: effectiveText,
                      letterSpacing: 0.2,
                    ),
                  ),
                  if (icon != null) ...[
                    const SizedBox(width: 8.0),
                    Icon(
                      icon,
                      size: 19.0,
                      color: isDark ? AppColors.primaryDark : AppColors.accent,
                    ),
                  ],
                ],
              ),
      ),
    );
  }
}
