import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/theme/app_colors.dart';
import 'otp_verification_screen.dart';
import 'widgets/custom_auth_button.dart';
import 'widgets/custom_auth_input.dart';

/// Screen for initiating password reset with registered email or mobile.
/// Centered layout, clean placeholders, and upper warning badge.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _identifierController = TextEditingController();
  String? _identifierError;
  bool _isLoading = false;

  @override
  void dispose() {
    _identifierController.dispose();
    super.dispose();
  }

  void _onSendResetCode() async {
    final text = _identifierController.text.trim();
    if (text.isEmpty) {
      HapticFeedback.mediumImpact();
      setState(() {
        _identifierError = 'Email or mobile is required';
      });
      return;
    }

    setState(() {
      _identifierError = null;
      _isLoading = true;
    });

    // Simulate API request to send reset code
    await Future.delayed(const Duration(milliseconds: 1000));

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    // Navigate to OTP verification screen
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => OtpVerificationScreen(
          email: text,
          isRegistrationFlow: false,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.textPrimary,
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
                            color: AppColors.accentLight,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppColors.accent.withValues(alpha: 0.25),
                            ),
                          ),
                          child: Text(
                            'Account Recovery',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),

                        const SizedBox(height: 14),

                        // Title
                        Text(
                          'Forgot your password?',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.6,
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Subtitle
                        Text(
                          'Enter your registered email address or phone number and we will send you a 6-digit code to reset your password.',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w400,
                            color: AppColors.textSecondary,
                            height: 1.45,
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Form Input (Required)
                        CustomAuthInput(
                          label: 'Email or Mobile Number',
                          hint: 'e.g. alex.tan@example.com or +880 1XXXXXXXXX',
                          prefixIcon: Icons.alternate_email_rounded,
                          isRequired: true,
                          controller: _identifierController,
                          errorMessage: _identifierError,
                          keyboardType: TextInputType.emailAddress,
                          onChanged: (_) {
                            if (_identifierError != null) {
                              setState(() => _identifierError = null);
                            }
                          },
                        ),

                        const SizedBox(height: 32),

                        // Primary CTA
                        CustomAuthButton(
                          text: 'Send Reset Code',
                          icon: Icons.arrow_forward_rounded,
                          isLoading: _isLoading,
                          onPressed: _onSendResetCode,
                        ),

                        const SizedBox(height: 24),

                        // Secondary Back to Sign In
                        Center(
                          child: GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4.0),
                              child: RichText(
                                text: TextSpan(
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13.5,
                                    color: AppColors.textSecondary,
                                  ),
                                  children: const [
                                    TextSpan(text: 'Remember your password? '),
                                    TextSpan(
                                      text: 'Back to Sign In',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.primary,
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
