import 'package:google_fonts/google_fonts.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/theme/app_colors.dart';
import '../../l10n/app_localizations.dart';
import 'register_form_screen.dart';
import 'sign_in_screen.dart';
import 'widgets/custom_auth_button.dart';
import 'widgets/role_selection_card.dart';

enum UserRole { tenant, host }

/// Step 1 of Registration Flow: Role-First Selection with balanced top/bottom centering.
class RegisterRoleScreen extends StatefulWidget {
  const RegisterRoleScreen({super.key});

  @override
  State<RegisterRoleScreen> createState() => _RegisterRoleScreenState();
}

class _RegisterRoleScreenState extends State<RegisterRoleScreen> {
  UserRole? _selectedRole = UserRole.tenant;

  void _onContinue() {
    if (_selectedRole == null) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RegisterFormScreen(initialRole: _selectedRole!),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Step Pill Tag
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12.0,
                            vertical: 5.0,
                          ),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF132F28) : AppColors.accentLight,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppColors.accent.withValues(alpha: 0.25),
                            ),
                          ),
                          child: Text(
                            l10n?.step1Of2 ?? 'Step 1 of 2',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: isDark ? AppColors.accent : AppColors.primary,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),

                        const SizedBox(height: 14),

                        // Title
                        Text(
                          l10n?.selectYourRole ?? 'Select your role',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                            letterSpacing: -0.6,
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Subtitle
                        Text(
                          l10n?.selectYourRoleSubtitle ?? 'Choose how you want to use FindBookStay. You can always switch or manage both from account settings.',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w400,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                            height: 1.45,
                          ),
                        ),

                        const SizedBox(height: 28),

                        // Role Cards
                        RoleSelectionCard(
                          title: l10n?.roleTenantTitle ?? 'Tenant, Guest or Player',
                          description:
                              l10n?.roleTenantDesc ?? 'Rent family apartments, bachelor seats, book hotel stays, or reserve sports turfs.',
                          icon: Icons.person_rounded,
                          isSelected: _selectedRole == UserRole.tenant,
                          onTap: () {
                            setState(() {
                              _selectedRole = UserRole.tenant;
                            });
                          },
                        ),

                        const SizedBox(height: 16),

                        RoleSelectionCard(
                          title: l10n?.roleHostTitle ?? 'Host, Landlord or Turf Owner',
                          description:
                              l10n?.roleHostDesc ?? 'List residential properties, rent shared seats, or manage sports turf reservations.',
                          icon: Icons.domain_rounded,
                          isSelected: _selectedRole == UserRole.host,
                          onTap: () {
                            setState(() {
                              _selectedRole = UserRole.host;
                            });
                          },
                        ),

                        const SizedBox(height: 32),

                        // CTA Continue Button
                        CustomAuthButton(
                          text: l10n?.continueToSignUp ?? 'Continue to Sign Up',
                          icon: Icons.arrow_forward_rounded,
                          onPressed: _selectedRole != null ? _onContinue : null,
                        ),

                        const SizedBox(height: 18),

                        // Sign In Link
                        Center(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (_) => const SignInScreen(),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4.0),
                              child: RichText(
                                text: TextSpan(
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13.5,
                                    color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                                  ),
                                  children: [
                                    TextSpan(text: l10n?.alreadyHaveAccount ?? 'Already have an account? '),
                                    TextSpan(
                                      text: l10n?.signIn ?? 'Sign In',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        color: isDark ? AppColors.accent : AppColors.primary,
                                        decoration: TextDecoration.underline,
                                        decorationColor: AppColors.accent,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
