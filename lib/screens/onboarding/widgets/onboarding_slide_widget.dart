import 'package:material_ui/material_ui.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/onboarding_item.dart';
import 'onboarding_illustration_card.dart';

/// Renders a single onboarding slide content cleanly, centered and responsively.
class OnboardingSlideWidget extends StatelessWidget {
  final OnboardingItem item;

  const OnboardingSlideWidget({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    String localizedTag = item.tag;
    String localizedTitle = item.title;
    String localizedSubtitle = item.subtitle;

    if (item.tag.contains('RENT')) {
      localizedTag = l10n?.onboardingRentTag ?? item.tag;
      localizedTitle = l10n?.onboardingRentTitle ?? item.title;
      localizedSubtitle = l10n?.onboardingRentSubtitle ?? item.subtitle;
    } else if (item.tag.contains('BOOK')) {
      localizedTag = l10n?.onboardingBookTag ?? item.tag;
      localizedTitle = l10n?.onboardingBookTitle ?? item.title;
      localizedSubtitle = l10n?.onboardingBookSubtitle ?? item.subtitle;
    } else if (item.tag.contains('SPORTS')) {
      localizedTag = l10n?.onboardingSportsTag ?? item.tag;
      localizedTitle = l10n?.onboardingSportsTitle ?? item.title;
      localizedSubtitle = l10n?.onboardingSportsSubtitle ?? item.subtitle;
    } else if (item.tag.contains('BUY')) {
      localizedTag = l10n?.onboardingBuyTag ?? item.tag;
      localizedTitle = l10n?.onboardingBuyTitle ?? item.title;
      localizedSubtitle = l10n?.onboardingBuySubtitle ?? item.subtitle;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableHeight = constraints.maxHeight;
        final isShortScreen = availableHeight < 560;

        return SizedBox(
          width: double.infinity,
          height: availableHeight,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: isShortScreen ? 8 : 16),

                // Illustration / Hero Area - Dead Center
                Expanded(
                  child: Center(
                    child: OnboardingIllustrationCard(item: item),
                  ),
                ),

                SizedBox(height: isShortScreen ? 14 : 22),

                // Slide Tag / Category Badge (e.g. "01 / RENT") - Centered
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14.0,
                      vertical: 6.0,
                    ),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF132F28) : AppColors.accentLight,
                      borderRadius: BorderRadius.circular(30.0),
                      border: Border.all(
                        color: AppColors.accent.withValues(alpha: 0.25),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      localizedTag,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        color: isDark ? AppColors.accent : AppColors.primary,
                        letterSpacing: 1.4,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // Title - Full Width Center
                SizedBox(
                  width: double.infinity,
                  child: Text(
                    localizedTitle,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: isShortScreen ? 22.0 : 26.0,
                      fontWeight: FontWeight.w800,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                      height: 1.25,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // Subtitle - Full Width Center
                SizedBox(
                  width: double.infinity,
                  child: Text(
                    localizedSubtitle,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: isShortScreen ? 13.0 : 14.5,
                      fontWeight: FontWeight.w400,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                      height: 1.45,
                    ),
                  ),
                ),

                SizedBox(height: isShortScreen ? 12 : 20),
              ],
            ),
          ),
        );
      },
    );
  }
}
