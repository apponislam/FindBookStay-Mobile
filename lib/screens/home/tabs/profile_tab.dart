import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/localization/locale_controller.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/theme_controller.dart';
import '../../../core/utils/url_utils.dart';
import '../../../features/auth/presentation/providers/auth_providers.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/register_form_screen.dart';
import '../../auth/sign_in_screen.dart';
import '../../common/legal_modal_sheet.dart';
import '../../profile/personal_info_screen.dart';

/// Profile / Account Tab:
/// Supports both Signed-In user and Non-Signed-In (Guest) user views via Riverpod & AuthService.
class ProfileTab extends ConsumerWidget {
  const ProfileTab({super.key});

  void _confirmSignOut(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    HapticFeedback.mediumImpact();
    showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkCard : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          l10n?.signOutConfirmTitle ?? 'Sign Out',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          ),
        ),
        content: Text(
          l10n?.signOutConfirmMessage ?? 'Are you sure you want to sign out? You can sign back in at any time.',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: Text(
              l10n?.cancel ?? 'Cancel',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(dialogCtx).pop();
              await ref.read(authControllerProvider.notifier).logout();
              await AuthService.instance.signOut();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: AppColors.primary,
                    content: Text(
                      l10n?.signedOutSuccess ?? 'Signed out successfully. Switched to Guest mode.',
                      style: GoogleFonts.plusJakartaSans(color: Colors.white),
                    ),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              l10n?.signOut ?? 'Sign Out',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;
    final currentLocale = ref.watch(localeProvider);
    final l10n = AppLocalizations.of(context);
    final authState = ref.watch(authControllerProvider);
    final user = authState.user;

    final bgColor = isDark ? AppColors.darkBackground : AppColors.background;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;

    return ListenableBuilder(
      listenable: AuthService.instance,
      builder: (context, _) {
        final isLoggedIn = authState.isAuthenticated || AuthService.instance.isLoggedIn;
        final userName = (user != null && !user.isGuest) ? user.name : AuthService.instance.userName;
        final userEmail = (user != null && !user.isGuest) ? user.email : AuthService.instance.userEmail;

        return Scaffold(
          backgroundColor: bgColor,
          appBar: AppBar(
            backgroundColor: bgColor,
            elevation: 0,
            scrolledUnderElevation: 0,
            title: Text(
              isLoggedIn
                  ? (l10n?.accountProfile ?? l10n?.navProfile ?? 'Account Profile')
                  : (l10n?.appName ?? 'FindBookStay'),
              style: GoogleFonts.plusJakartaSans(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: textColor,
              ),
            ),
          ),
          body: SafeArea(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
              children: [
                if (isLoggedIn)
                  _buildSignedInHeader(
                    context,
                    ref,
                    name: userName,
                    email: userEmail,
                    avatarUrl: user?.avatarUrl,
                    isDark: isDark,
                  )
                else
                  _buildGuestHero(context),

                const SizedBox(height: 24),

                // ── Account / App Settings Section ────────────────────
                _buildSectionTitle(
                  isLoggedIn
                      ? (l10n?.accountSettings ?? 'Account Settings')
                      : (l10n?.preferences ?? 'Preferences'),
                  isDark: isDark,
                ),
                const SizedBox(height: 10),

                if (isLoggedIn) ...[
                  _buildMenuTile(
                    icon: Icons.person_outline_rounded,
                    title: l10n?.personalInfo ?? 'Personal Information',
                    subtitle: l10n?.personalInfoSubtitle ?? 'Name, phone, address, and profile details',
                    isDark: isDark,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const PersonalInfoScreen(),
                        ),
                      );
                    },
                  ),
                  _buildMenuTile(
                    icon: Icons.payment_rounded,
                    title: l10n?.paymentMethods ?? 'Payment Methods & Invoices',
                    subtitle: l10n?.paymentMethodsSubtitle ?? 'Cards, bKash, transaction history',
                    isDark: isDark,
                    onTap: () {},
                  ),
                  _buildMenuTile(
                    icon: Icons.notifications_none_rounded,
                    title: l10n?.notifications ?? 'Notification Preferences',
                    subtitle: l10n?.notificationsSubtitle ?? 'Booking alerts, owner messages',
                    isDark: isDark,
                    onTap: () {},
                  ),
                ],

                _buildMenuTile(
                  icon: Icons.language_rounded,
                  title: l10n?.languageAndCurrency ?? 'Language & Currency',
                  subtitle: currentLocale.languageCode == 'bn'
                      ? 'বাংলা (BD) · BDT (৳)'
                      : 'English (US) · BDT (৳)',
                  isDark: isDark,
                  onTap: () => _showLanguageSelector(context, ref, isDark: isDark),
                ),

                // ── Theme / Appearance Toggle ────────────────────────
                _buildThemeToggleTile(context, ref, isDark: isDark),

                const SizedBox(height: 20),

                // ── Legal & Support Section ───────────────────────────
                _buildSectionTitle(
                  l10n?.legalAndSupport ?? 'Legal & Support',
                  isDark: isDark,
                ),
                const SizedBox(height: 10),

                _buildMenuTile(
                  icon: Icons.gavel_rounded,
                  title: l10n?.termsOfService ?? 'Terms of Service',
                  subtitle: l10n?.termsOfServiceSubtitle ?? 'Platform rules and direct booking terms',
                  isDark: isDark,
                  onTap: () => showLegalModalSheet(context, isTerms: true),
                ),
                _buildMenuTile(
                  icon: Icons.shield_outlined,
                  title: l10n?.privacyPolicy ?? 'Privacy Policy',
                  subtitle: l10n?.privacyPolicySubtitle ?? 'How FindBookStay protects your data',
                  isDark: isDark,
                  onTap: () => showLegalModalSheet(context, isTerms: false),
                ),
                _buildMenuTile(
                  icon: Icons.help_outline_rounded,
                  title: l10n?.helpCenter ?? 'Help Center & 24/7 Support',
                  subtitle: l10n?.helpCenterSubtitle ?? 'FAQs, contact agent, safety center',
                  isDark: isDark,
                  onTap: () {},
                ),

                const SizedBox(height: 24),

                // ── Sign Out Button (When Signed In) ──────────────────
                if (isLoggedIn)
                  OutlinedButton.icon(
                    onPressed: () => _confirmSignOut(context, ref),
                    icon: const Icon(
                      Icons.logout_rounded,
                      size: 18,
                      color: AppColors.error,
                    ),
                    label: Text(
                      l10n?.signOut ?? 'Sign Out',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.error,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      side: const BorderSide(color: AppColors.error, width: 1.2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),

                const SizedBox(height: 16),

                // App Version info
                Center(
                  child: Text(
                    l10n?.appVersionInfo ?? 'FindBookStay v1.0.0 (Build 1) · 0% Broker Fees',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5,
                      color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Signed-in user header card
  Widget _buildSignedInHeader(
    BuildContext context,
    WidgetRef ref, {
    required String name,
    required String email,
    String? avatarUrl,
    required bool isDark,
  }) {
    final initials = name.trim().split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join();
    final resolvedAvatar = UrlUtils.resolveNullableUrl(avatarUrl);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const PersonalInfoScreen()),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black.withValues(alpha: 0.3) : AppColors.primary.withValues(alpha: 0.04),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: isDark ? AppColors.darkPrimaryGradient : AppColors.primaryGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipOval(
                child: (resolvedAvatar != null && resolvedAvatar.isNotEmpty)
                    ? Image.network(
                        resolvedAvatar,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return const Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                          );
                        },
                        errorBuilder: (_, _, _) => Center(
                          child: Text(
                            initials.isNotEmpty ? initials : 'U',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      )
                    : Center(
                        child: Text(
                          initials.isNotEmpty ? initials : 'U',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    email,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.5,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkAccentLight : AppColors.accentLight,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.accent.withValues(alpha: isDark ? 0.45 : 0.3),
                ),
              ),
              child: Icon(
                Icons.arrow_forward_ios_rounded,
                size: 13,
                color: isDark ? AppColors.accent : AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Guest (Non-signed-in) hero card
  Widget _buildGuestHero(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.accent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              l10n?.findBookStayBadge ?? 'FIND · BOOK · STAY',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryDark,
                letterSpacing: 0.8,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            l10n?.joinFindBookStay ?? 'Join FindBookStay',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l10n?.guestHeroSubtitle ??
                'Sign in or create an account to book stays, rent flats, and reserve sports turfs with zero broker fees.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13.5,
              color: Colors.white.withValues(alpha: 0.85),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const SignInScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    l10n?.signIn ?? 'Sign In',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const RegisterFormScreen(),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white, width: 1.5),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    l10n?.register ?? 'Register',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, {required bool isDark}) {
    return Text(
      title,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w800,
        color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
        letterSpacing: 0.2,
      ),
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: isDark ? AppColors.darkCard : AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          onTap: () {
            HapticFeedback.lightImpact();
            onTap();
          },
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.background,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
            ),
            child: Icon(icon, size: 20, color: isDark ? AppColors.accent : AppColors.primary),
          ),
          title: Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
            ),
          ),
          trailing: Icon(
            Icons.arrow_forward_ios_rounded,
            size: 14,
            color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
          ),
        ),
      ),
    );
  }

  Widget _buildThemeToggleTile(BuildContext context, WidgetRef ref, {required bool isDark}) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: isDark ? AppColors.darkCard : AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          onTap: () {
            ref.read(themeModeProvider.notifier).toggleTheme();
          },
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.background,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
            ),
            child: Icon(
              isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
              size: 20,
              color: isDark ? AppColors.accent : const Color(0xFFF59E0B),
            ),
          ),
          title: Text(
            l10n?.themeMode ?? 'Theme Mode',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            ),
          ),
          subtitle: Text(
            isDark
                ? (l10n?.activeDarkMode ?? 'Dark Mode (Active)')
                : (l10n?.activeLightMode ?? 'Light Mode (Active)'),
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
            ),
          ),
          trailing: Switch.adaptive(
            value: isDark,
            activeThumbColor: AppColors.accent,
            activeTrackColor: AppColors.accent.withValues(alpha: 0.35),
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: isDark ? AppColors.darkBorder : AppColors.border,
            onChanged: (val) {
              ref.read(themeModeProvider.notifier).setThemeMode(
                    val ? ThemeMode.dark : ThemeMode.light,
                  );
            },
          ),
        ),
      ),
    );
  }

  void _showLanguageSelector(BuildContext context, WidgetRef ref, {required bool isDark}) {
    final currentLocale = ref.read(localeProvider);
    final l10n = AppLocalizations.of(context);

    HapticFeedback.selectionClick();
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final sheetIsDark = Theme.of(ctx).brightness == Brightness.dark;
        final textColor = sheetIsDark ? AppColors.darkTextPrimary : AppColors.textPrimary;

        return SafeArea(
          top: false,
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            decoration: BoxDecoration(
              color: sheetIsDark ? AppColors.darkCard : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: sheetIsDark ? AppColors.darkBorder : AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n?.selectLanguage ?? 'Select Language',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 18),
                _buildLanguageOption(
                  title: 'English',
                  subtitle: 'English (US)',
                  isSelected: currentLocale.languageCode == 'en',
                  sheetIsDark: sheetIsDark,
                  onTap: () {
                    ref.read(localeProvider.notifier).setLocale(AppLocales.english);
                    Navigator.of(ctx).pop();
                  },
                ),
                const SizedBox(height: 10),
                _buildLanguageOption(
                  title: 'বাংলা',
                  subtitle: 'Bangla (BD)',
                  isSelected: currentLocale.languageCode == 'bn',
                  sheetIsDark: sheetIsDark,
                  onTap: () {
                    ref.read(localeProvider.notifier).setLocale(AppLocales.bangla);
                    Navigator.of(ctx).pop();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLanguageOption({
    required String title,
    required String subtitle,
    required bool isSelected,
    required bool sheetIsDark,
    required VoidCallback onTap,
  }) {
    final textColor = sheetIsDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final secondaryTextColor = sheetIsDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    return Material(
      color: isSelected
          ? (sheetIsDark ? const Color(0xFF132F28) : AppColors.accentLight)
          : (sheetIsDark ? AppColors.darkSurface : AppColors.surface),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isSelected
              ? AppColors.accent
              : (sheetIsDark ? AppColors.darkBorder : AppColors.border),
          width: isSelected ? 1.5 : 1.0,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        title: Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
            color: textColor,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            color: secondaryTextColor,
          ),
        ),
        trailing: isSelected
            ? const Icon(
                Icons.check_circle_rounded,
                color: AppColors.accent,
                size: 22,
              )
            : null,
      ),
    );
  }
}
