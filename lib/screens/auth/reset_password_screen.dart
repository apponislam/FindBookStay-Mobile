import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/theme/app_colors.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../l10n/app_localizations.dart';
import 'sign_in_screen.dart';
import 'widgets/custom_auth_button.dart';
import 'widgets/custom_auth_input.dart';
import 'widgets/password_strength_meter.dart';

/// Screen for entering new password and confirm password with real-time matching indicator.
/// Vertically centered with warning badges and eye toggle animations.
class ResetPasswordScreen extends ConsumerStatefulWidget {
  final String email;
  final String otp;

  const ResetPasswordScreen({
    super.key,
    required this.email,
    this.otp = '',
  });

  @override
  ConsumerState<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  String? _passwordError;
  String? _confirmPasswordError;
  bool _isLoading = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool get _doPasswordsMatch {
    final p1 = _passwordController.text;
    final p2 = _confirmPasswordController.text;
    return p1.isNotEmpty && p2.isNotEmpty && p1 == p2;
  }

  void _onResetPassword() async {
    final p1 = _passwordController.text;
    final p2 = _confirmPasswordController.text;

    setState(() {
      if (p1.isEmpty) {
        _passwordError = 'New password is required';
      } else if (p1.length < 8) {
        _passwordError = 'Min. 8 characters required';
      } else if (!RegExp(r'[0-9]').hasMatch(p1)) {
        _passwordError = 'Must contain at least 1 number';
      } else {
        _passwordError = null;
      }

      if (p2.isEmpty) {
        _confirmPasswordError = 'Confirm password is required';
      } else if (p1 != p2) {
        _confirmPasswordError = 'Passwords do not match';
      } else {
        _confirmPasswordError = null;
      }
    });

    if (_passwordError != null || _confirmPasswordError != null) {
      HapticFeedback.mediumImpact();
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final success = await ref
        .read(authControllerProvider.notifier)
        .resetPassword(
          email: widget.email,
          newPassword: p1,
          otp: widget.otp,
        );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (success) {
      _showSuccessDialog();
    } else {
      HapticFeedback.heavyImpact();
      final error = ref.read(authErrorProvider);
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Failed to update password. Please try again.'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showSuccessDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.0),
          ),
          backgroundColor: isDark ? AppColors.darkCard : AppColors.background,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 28.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Animated green checkmark badge
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF132F28) : AppColors.accentLight,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.accent, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accent.withValues(alpha: 0.25),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.check_rounded,
                      size: 40,
                      color: AppColors.accent,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Text(
                  l10n?.passwordResetSuccessTitle ?? 'Password Updated!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  l10n?.passwordResetSuccessDesc ?? 'Your password has been changed successfully. You can now sign in with your new credentials.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.5,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                    height: 1.45,
                  ),
                ),

                const SizedBox(height: 24),

                CustomAuthButton(
                  text: l10n?.goToSignIn ?? 'Sign In Now',
                  icon: Icons.login_rounded,
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const SignInScreen()),
                      (_) => false,
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
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
                        // Category Tag
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
                            l10n?.newCredentials ?? 'Security Update',
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
                          l10n?.resetYourPassword ?? 'Create New Password',
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
                          l10n?.resetPasswordSubtitle ?? 'Your new password must be different from previously used passwords.',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w400,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                            height: 1.45,
                          ),
                        ),

                        const SizedBox(height: 32),

                        // New Password Input (Required)
                        CustomAuthInput(
                          label: l10n?.newPassword ?? 'New Password',
                          hint: '••••••••',
                          prefixIcon: Icons.lock_outline_rounded,
                          isPassword: true,
                          isRequired: true,
                          controller: _passwordController,
                          errorMessage: _passwordError,
                          onChanged: (_) {
                            setState(() {
                              if (_passwordError != null) _passwordError = null;
                            });
                          },
                        ),

                        PasswordStrengthMeter(password: _passwordController.text),

                        const SizedBox(height: 22),

                        // Confirm Password Input with Match Indicator (Required)
                        CustomAuthInput(
                          label: l10n?.confirmPassword ?? 'Confirm Password',
                          hint: '••••••••',
                          prefixIcon: Icons.lock_reset_rounded,
                          isPassword: true,
                          isRequired: true,
                          controller: _confirmPasswordController,
                          errorMessage: _confirmPasswordError,
                          onChanged: (_) {
                            setState(() {
                              if (_confirmPasswordError != null) {
                                _confirmPasswordError = null;
                              }
                            });
                          },
                        ),

                        const SizedBox(height: 10),

                        // Real-time Match Indicator Pill
                        if (_confirmPasswordController.text.isNotEmpty)
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            child: Row(
                              children: [
                                Icon(
                                  _doPasswordsMatch
                                      ? Icons.check_circle_rounded
                                      : Icons.cancel_rounded,
                                  size: 16,
                                  color: _doPasswordsMatch
                                      ? AppColors.accent
                                      : AppColors.error,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _doPasswordsMatch
                                      ? (l10n?.passwordsMatch ?? 'Passwords match perfectly')
                                      : (l10n?.passwordsDoNotMatch ?? 'Passwords do not match yet'),
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: _doPasswordsMatch
                                        ? AppColors.accent
                                        : AppColors.error,
                                  ),
                                ),
                              ],
                            ),
                          ),

                        const SizedBox(height: 36),

                        // Reset Password CTA
                        CustomAuthButton(
                          text: l10n?.resetPasswordAndSignIn ?? 'Reset Password & Sign In',
                          icon: Icons.arrow_forward_rounded,
                          isLoading: _isLoading,
                          onPressed: _onResetPassword,
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
