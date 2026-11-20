import 'package:material_ui/material_ui.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../models/onboarding_item.dart';

/// Renders either the asset image (if provided and valid) or a stunning
/// production-grade procedural illustration card crafted with Flutter widgets.
class OnboardingIllustrationCard extends StatelessWidget {
  final OnboardingItem item;

  const OnboardingIllustrationCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 280.0, maxWidth: 340.0),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.surface,
          borderRadius: BorderRadius.circular(28.0),
          border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.04),
              blurRadius: 24.0,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: AppColors.accent.withValues(alpha: 0.05),
              blurRadius: 30.0,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(27.0),
          child: Stack(
            children: [
              // Background subtle decorative rings
              Positioned(
                top: -40,
                right: -40,
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.accent.withValues(alpha: 0.07),
                  ),
                ),
              ),
              Positioned(
                bottom: -50,
                left: -30,
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withValues(alpha: 0.04),
                  ),
                ),
              ),

              // Main Content or Image with graceful fallback
              if (item.imageAssetPath != null)
                Image.asset(
                  item.imageAssetPath!,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return _buildProceduralIllustration(context);
                  },
                )
              else
                _buildProceduralIllustration(context),
            ],
          ),
        ),
      ),
    );
  }

  /// High-finish procedural illustration card
  Widget _buildProceduralIllustration(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Floating Stat / Trust Pill
          Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14.0,
                  vertical: 6.0,
                ),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : AppColors.background,
                  borderRadius: BorderRadius.circular(20.0),
                  border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.accent,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      item.metricValue,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: isDark ? AppColors.accent : AppColors.primary,
                        letterSpacing: 0.3,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 7),
                      width: 3.5,
                      height: 3.5,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Text(
                      item.metricLabel,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const Spacer(),

          // Hero Icon Badge with Concentric Rings
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Outer pulse ring
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.accent.withValues(alpha: 0.12),
                  ),
                ),
                // Inner glowing ring
                Container(
                  width: 82,
                  height: 82,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.accent.withValues(alpha: 0.22),
                  ),
                ),
                // Central Icon Container
                Container(
                  width: 66,
                  height: 66,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryDark.withValues(alpha: 0.35),
                        blurRadius: 14.0,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Icon(
                    item.primaryIcon,
                    size: 32.0,
                    color: AppColors.textWhite,
                  ),
                ),
              ],
            ),
          ),

          const Spacer(),

          // Highlights Chip Row (Explicit full-width centering)
          SizedBox(
            width: double.infinity,
            child: Wrap(
              alignment: WrapAlignment.center,
              runAlignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8.0,
              runSpacing: 6.0,
              children: item.highlights.map((highlight) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10.0,
                  vertical: 5.0,
                ),
                decoration: BoxDecoration(
                  color: (isDark ? AppColors.darkSurface : AppColors.background).withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(12.0),
                  border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border, width: 0.8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.check_circle_rounded,
                      size: 13,
                      color: AppColors.accent,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      highlight,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 4),
        ],
      ),
    );
  }
}
