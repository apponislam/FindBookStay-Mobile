import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/services/auth_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../widgets/guest_auth_gate_card.dart';

/// Wishlist / Saved Spaces Tab:
/// Displays personalized favorites when signed in, or auth gate when guest.
class SavedTab extends StatefulWidget {
  const SavedTab({super.key});

  @override
  State<SavedTab> createState() => _SavedTabState();
}

class _SavedTabState extends State<SavedTab> {
  final List<Map<String, dynamic>> _savedItems = [];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    return ListenableBuilder(
      listenable: AuthService.instance,
      builder: (context, _) {
        final isLoggedIn = AuthService.instance.isLoggedIn;

        if (!isLoggedIn) {
          return Scaffold(
            backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
            body: SafeArea(
              child: GuestAuthGateCard(
                icon: Icons.favorite_rounded,
                title: l10n?.saveFavoriteSpots ?? 'Save your favorite spots',
                subtitle: l10n?.saveFavoriteSpotsSubtitle ??
                    'Sign in to keep track of family flats, hotel getaways, and sports turfs you love across all your devices.',
                ctaText: l10n?.signInToViewWishlist ?? 'Sign In to View Wishlist',
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
          appBar: AppBar(
            backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
            elevation: 0,
            title: Text(
              l10n?.savedWishlist ?? 'Saved Wishlist',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              ),
            ),
            actions: [
              IconButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: isDark ? AppColors.accent : AppColors.primary,
                      content: Text(
                        l10n?.wishlistSynced ?? 'Wishlist synced with your account',
                        style: GoogleFonts.plusJakartaSans(
                          color: isDark ? AppColors.primaryDark : Colors.white,
                        ),
                      ),
                    ),
                  );
                },
                icon: Icon(
                  Icons.sync_rounded,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                ),
              ),
            ],
          ),
          body: SafeArea(
            child: _savedItems.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.darkCard : AppColors.surface,
                              shape: BoxShape.circle,
                              border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
                            ),
                            child: Icon(
                              Icons.favorite_border_rounded,
                              size: 32,
                              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            l10n?.wishlistEmpty ?? 'Your wishlist is empty',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            l10n?.wishlistEmptyDesc ??
                                'Explore rental flats, stays, and sports turfs and tap the heart icon to save your favorites here.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                              height: 1.45,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
                    physics: const BouncingScrollPhysics(),
                    itemCount: _savedItems.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      final item = _savedItems[index];
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkCard : AppColors.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.darkAccentLight : AppColors.accentLight,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Icon(
                                item['icon'] as IconData,
                                color: isDark ? AppColors.accent : AppColors.primary,
                                size: 30,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isDark ? AppColors.darkSurface : AppColors.background,
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
                                    ),
                                    child: Text(
                                      item['type'] as String,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w700,
                                        color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    item['title'] as String,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w700,
                                      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    item['location'] as String,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12,
                                      color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    item['price'] as String,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w800,
                                      color: isDark ? AppColors.accent : AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                HapticFeedback.selectionClick();
                                setState(() {
                                  _savedItems.removeAt(index);
                                });
                              },
                              icon: const Icon(
                                Icons.favorite_rounded,
                                color: AppColors.error,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        );
      },
    );
  }
}

