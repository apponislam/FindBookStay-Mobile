import 'dart:async';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/theme/app_colors.dart';
import '../home/home_screen.dart';
import 'reset_password_screen.dart';
import 'widgets/custom_auth_button.dart';
import 'widgets/otp_digit_input.dart';

/// Screen for verifying 6-digit OTP code with countdown timer and auto-advance inputs.
/// Centered layout and clear state feedback.
class OtpVerificationScreen extends StatefulWidget {
  final String email;
  final bool isRegistrationFlow;

  const OtpVerificationScreen({
    super.key,
    required this.email,
    this.isRegistrationFlow = false,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  String _otpCode = '';
  String? _otpError;
  bool _isLoading = false;

  Timer? _resendTimer;
  int _secondsRemaining = 45;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _secondsRemaining = 45;
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    super.dispose();
  }

  void _onResendCode() {
    HapticFeedback.lightImpact();
    setState(() {
      _otpError = null;
    });
    _startTimer();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.primary,
        content: Text(
          'A new 6-digit verification code has been sent to ${widget.email}',
          style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 13),
        ),
      ),
    );
  }

  void _onVerifyCode() async {
    if (_otpCode.length < 6) {
      HapticFeedback.mediumImpact();
      setState(() {
        _otpError = 'Please enter all 6 digits of your code';
      });
      return;
    }

    setState(() {
      _otpError = null;
      _isLoading = true;
    });

    // Simulate OTP verification API
    await Future.delayed(const Duration(milliseconds: 1200));

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (widget.isRegistrationFlow) {
      // Mark onboarding & login state in SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('hasSeenOnboarding', true);

      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (_) => false,
      );
    } else {
      // Navigate to create new password
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ResetPasswordScreen(email: widget.email),
        ),
      );
    }
  }

  String get _formattedTimer {
    final minutes = (_secondsRemaining ~/ 60).toString().padLeft(2, '0');
    final seconds = (_secondsRemaining % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
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
                            'Verification',
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
                          'Enter 6-Digit Code',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.6,
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Subtitle
                        Text.rich(
                          TextSpan(
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w400,
                              color: AppColors.textSecondary,
                              height: 1.45,
                            ),
                            children: [
                              const TextSpan(
                                text: 'We sent a 6-digit verification code to ',
                              ),
                              TextSpan(
                                text: widget.email.isNotEmpty
                                    ? widget.email
                                    : 'your email address',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                              const TextSpan(text: '. Enter it below to proceed.'),
                            ],
                          ),
                        ),

                        const SizedBox(height: 36),

                        // 6 Squircle Digit Boxes
                        OtpDigitInput(
                          length: 6,
                          onChanged: (val) {
                            setState(() {
                              _otpCode = val;
                              if (_otpError != null) _otpError = null;
                            });
                          },
                          onCompleted: (val) {
                            setState(() {
                              _otpCode = val;
                              _otpError = null;
                            });
                            _onVerifyCode();
                          },
                        ),

                        if (_otpError != null) ...[
                          const SizedBox(height: 14),
                          Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.error.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: AppColors.error.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.warning_amber_rounded,
                                    size: 15,
                                    color: AppColors.error,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    _otpError!,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.error,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],

                        const SizedBox(height: 32),

                        // Resend Countdown Timer
                        Center(
                          child: _secondsRemaining > 0
                              ? RichText(
                                  text: TextSpan(
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 13.5,
                                      color: AppColors.textSecondary,
                                    ),
                                    children: [
                                      const TextSpan(
                                        text: "Didn't receive code? Resend in ",
                                      ),
                                      TextSpan(
                                        text: _formattedTimer,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : TextButton.icon(
                                  onPressed: _onResendCode,
                                  icon: const Icon(
                                    Icons.refresh_rounded,
                                    size: 18,
                                    color: AppColors.primary,
                                  ),
                                  label: Text(
                                    'Resend Code',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primary,
                                      decoration: TextDecoration.underline,
                                      decorationColor: AppColors.accent,
                                    ),
                                  ),
                                ),
                        ),

                        const SizedBox(height: 32),

                        // Verify Code CTA
                        CustomAuthButton(
                          text: 'Verify Code',
                          icon: Icons.arrow_forward_rounded,
                          isLoading: _isLoading,
                          onPressed: _onVerifyCode,
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
