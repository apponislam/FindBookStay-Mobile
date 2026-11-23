import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/services/auth_service.dart';
import '../../core/theme/app_colors.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../l10n/app_localizations.dart';
import '../home/home_screen.dart';
import 'reset_password_screen.dart';
import 'widgets/custom_auth_button.dart';
import 'widgets/otp_digit_input.dart';

/// Screen for verifying 6-digit OTP code with countdown timer and auto-advance inputs.
/// Connected directly to the backend verification and resend endpoints.
class OtpVerificationScreen extends ConsumerStatefulWidget {
  final String email;
  final bool isRegistrationFlow;

  const OtpVerificationScreen({
    super.key,
    required this.email,
    this.isRegistrationFlow = false,
  });

  @override
  ConsumerState<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends ConsumerState<OtpVerificationScreen> {
  final TextEditingController _otpTextController = TextEditingController();
  String _otpCode = '';
  String? _otpError;
  bool _isLoading = false;
  bool _isResending = false;

  Timer? _resendTimer;
  int _secondsRemaining = 60;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _secondsRemaining = 60;
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
    _otpTextController.dispose();
    _resendTimer?.cancel();
    super.dispose();
  }

  void _onClearCode() {
    HapticFeedback.lightImpact();
    _otpTextController.clear();
    setState(() {
      _otpCode = '';
      _otpError = null;
    });
  }

  void _onResendCode() async {
    HapticFeedback.lightImpact();
    _otpTextController.clear();
    setState(() {
      _otpCode = '';
      _otpError = null;
      _isResending = true;
    });

    final success = await ref.read(authControllerProvider.notifier).resendCode(
      email: widget.email,
      isRegistrationFlow: widget.isRegistrationFlow,
    );

    if (!mounted) return;

    setState(() {
      _isResending = false;
    });

    if (success) {
      _startTimer();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: Text(
            'A new 6-digit verification code has been sent to ${widget.email}',
            style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ),
      );
    } else {
      final error = ref.read(authErrorProvider);
      HapticFeedback.heavyImpact();
      debugPrint('❌ [OTP RESEND CODE FAILED]: $error');
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: Text(
            error ?? 'Failed to resend code. Please try again.',
            style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ),
      );
    }
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

    bool success = false;
    if (widget.isRegistrationFlow) {
      success = await ref.read(authControllerProvider.notifier).verifyEmail(
        email: widget.email,
        otp: _otpCode,
      );
    } else {
      success = await ref.read(authControllerProvider.notifier).verifyOtp(
        email: widget.email,
        otp: _otpCode,
      );
    }

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (success) {
      ScaffoldMessenger.of(context).clearSnackBars();
      if (widget.isRegistrationFlow) {
        await AuthService.instance.signIn(email: widget.email);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('hasSeenOnboarding', true);

        if (!mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (_) => false,
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => ResetPasswordScreen(
              email: widget.email,
              otp: _otpCode,
            ),
          ),
        );
      }
    } else {
      final error = ref.read(authErrorProvider);
      HapticFeedback.heavyImpact();
      debugPrint('❌ [OTP VERIFICATION FAILED]: $error');
      setState(() {
        _otpError = error ?? 'Invalid or expired verification code';
      });
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 4),
          content: Text(
            error ?? 'Verification failed. Please check the code and try again.',
            style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
          ),
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
                            l10n?.verification ?? 'Verification',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: isDark ? AppColors.accent : AppColors.primary,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),

                        const SizedBox(height: 14),

                        // Title Row with Quick Clear Button
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              l10n?.verifyYourEmail ?? 'Enter 6-Digit Code',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                                letterSpacing: -0.6,
                              ),
                            ),
                            if (_otpCode.isNotEmpty)
                              GestureDetector(
                                onTap: _onClearCode,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isDark ? AppColors.darkCard : AppColors.surface,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: isDark ? AppColors.darkBorder : AppColors.border,
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.backspace_outlined,
                                        size: 13,
                                        color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        l10n?.clearCode ?? 'Clear',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        // Subtitle
                        RichText(
                          text: TextSpan(
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w400,
                              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                              height: 1.45,
                            ),
                            children: [
                              TextSpan(
                                text: l10n?.otpSubtitle(widget.email) ?? 'We have sent a 6-digit confirmation code to ${widget.email}. Enter the code below to confirm your identity.',
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 36),

                        // 6-Digit OTP Block Input
                        OtpDigitInput(
                          length: 6,
                          controller: _otpTextController,
                          hasError: _otpError != null,
                          onCompleted: (code) {
                            setState(() {
                              _otpCode = code;
                              _otpError = null;
                            });
                          },
                          onChanged: (code) {
                            setState(() {
                              _otpCode = code;
                              if (_otpError != null) _otpError = null;
                            });
                          },
                        ),

                        // Error Banner
                        if (_otpError != null) ...[
                          const SizedBox(height: 18),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.error.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.error.withValues(alpha: 0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(top: 1.5),
                                  child: Icon(
                                    Icons.error_outline_rounded,
                                    size: 18,
                                    color: AppColors.error,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    _otpError!,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.error,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        const SizedBox(height: 32),

                        // Resend Countdown Timer / Button
                        Center(
                          child: _secondsRemaining > 0
                              ? RichText(
                                  text: TextSpan(
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 13.5,
                                      color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: l10n?.resendCodeIn(_secondsRemaining) ?? "Didn't receive code? Resend in $_formattedTimer",
                                      ),
                                    ],
                                  ),
                                )
                              : _isResending
                                  ? SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.2,
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          isDark ? AppColors.accent : AppColors.primary,
                                        ),
                                      ),
                                    )
                                  : TextButton.icon(
                                      onPressed: _onResendCode,
                                      icon: Icon(
                                        Icons.refresh_rounded,
                                        size: 18,
                                        color: isDark ? AppColors.accent : AppColors.primary,
                                      ),
                                      label: Text(
                                        l10n?.resendCode ?? 'Resend Code',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: isDark ? AppColors.accent : AppColors.primary,
                                          decoration: TextDecoration.underline,
                                          decorationColor: AppColors.accent,
                                        ),
                                      ),
                                    ),
                        ),

                        const SizedBox(height: 32),

                        // Verify Code CTA
                        CustomAuthButton(
                          text: l10n?.verifyCode ?? 'Verify Code',
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
