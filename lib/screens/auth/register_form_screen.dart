import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/theme/app_colors.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';
import 'otp_verification_screen.dart';
import 'register_role_screen.dart';
import 'widgets/custom_auth_button.dart';
import 'widgets/custom_auth_input.dart';
import 'widgets/password_strength_meter.dart';

/// Complete 2-Step Sign Up Page for FindBookStay.
///
/// Flow:
/// - Step 1: Personal & Contact Information (Full Name, Email, Phone Number).
/// - Step 2: Account Security (Password, Confirm Password, Terms & Policy).
class RegisterFormScreen extends ConsumerStatefulWidget {
  final UserRole initialRole;

  const RegisterFormScreen({
    super.key,
    this.initialRole = UserRole.tenant,
  });

  @override
  ConsumerState<RegisterFormScreen> createState() => _RegisterFormScreenState();
}

class _RegisterFormScreenState extends ConsumerState<RegisterFormScreen> {
  int _currentStep = 0;
  late final PageController _pageController;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  String? _nameError;
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;
  bool _termsAccepted = false;
  String? _termsError;
  bool _isLoading = false;

  late final TapGestureRecognizer _termsRecognizer;
  late final TapGestureRecognizer _privacyRecognizer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentStep);
    _termsRecognizer = TapGestureRecognizer()
      ..onTap = () => _showLegalModal(isTerms: true);
    _privacyRecognizer = TapGestureRecognizer()
      ..onTap = () => _showLegalModal(isTerms: false);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _termsRecognizer.dispose();
    _privacyRecognizer.dispose();
    super.dispose();
  }

  void _goToStep(int step) {
    HapticFeedback.selectionClick();
    setState(() {
      _currentStep = step;
    });
    _pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeInOutCubic,
    );
  }

  bool _validateStep1() {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();

    setState(() {
      _nameError = name.isEmpty ? 'Full name is required' : null;

      if (email.isEmpty) {
        _emailError = 'Email address is required';
      } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
        _emailError = 'Please enter a valid email';
      } else {
        _emailError = null;
      }
    });

    if (_nameError != null || _emailError != null) {
      HapticFeedback.mediumImpact();
      return false;
    }
    return true;
  }

  void _onStep1Continue() {
    if (_validateStep1()) {
      _goToStep(1);
    }
  }

  void _validateAndSubmit() async {
    // Validate both steps
    final isStep1Valid = _validateStep1();
    if (!isStep1Valid) {
      _goToStep(0);
      return;
    }

    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    setState(() {
      if (password.isEmpty) {
        _passwordError = 'Password is required';
      } else if (password.length < 8) {
        _passwordError = 'Min. 8 characters required';
      } else if (!RegExp(r'[0-9]').hasMatch(password)) {
        _passwordError = 'Include at least 1 number';
      } else {
        _passwordError = null;
      }

      if (confirmPassword.isEmpty) {
        _confirmPasswordError = 'Please confirm your password';
      } else if (confirmPassword != password) {
        _confirmPasswordError = 'Passwords do not match';
      } else {
        _confirmPasswordError = null;
      }

      if (!_termsAccepted) {
        _termsError = 'Please accept the Terms to continue';
      } else {
        _termsError = null;
      }
    });

    if (_passwordError != null || _confirmPasswordError != null || _termsError != null) {
      HapticFeedback.mediumImpact();
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final roleTitle = widget.initialRole == UserRole.host
        ? 'Host & Turf Owner'
        : 'Tenant & Player';

    final success = await ref.read(authControllerProvider.notifier).register(
      name: name,
      email: email,
      password: password,
      phone: _phoneController.text.trim(),
      role: roleTitle,
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (success) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => OtpVerificationScreen(
            email: email,
            isRegistrationFlow: true,
          ),
        ),
      );
    } else {
      final error = ref.read(authErrorProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Registration failed. Please try again.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _showLegalModal({required bool isTerms}) {
    HapticFeedback.selectionClick();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _LegalModalSheet(isTerms: isTerms),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _currentStep == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _currentStep > 0) {
          _goToStep(0);
        }
      },
      child: Scaffold(
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
            onPressed: () {
              if (_currentStep > 0) {
                _goToStep(0);
              } else {
                Navigator.of(context).pop();
              }
            },
          ),
          title: Text(
            'Sign Up',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Visual Step Indicator
              _buildStepIndicator(),

              // 2-Step PageView
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildStep1Personal(),
                    _buildStep2Security(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Top Step Progress Indicator
  // ---------------------------------------------------------------------------
  Widget _buildStepIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      child: Column(
        children: [
          Row(
            children: [
              _buildStepNode(
                stepIndex: 0,
                title: 'Personal Info',
                isActive: _currentStep == 0,
                isCompleted: _currentStep > 0,
              ),
              Expanded(
                child: Container(
                  height: 2,
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  color: _currentStep > 0 ? AppColors.primary : AppColors.border,
                ),
              ),
              _buildStepNode(
                stepIndex: 1,
                title: 'Security',
                isActive: _currentStep == 1,
                isCompleted: false,
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Animated Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: _currentStep == 0 ? 0.5 : 1.0,
              minHeight: 4,
              backgroundColor: AppColors.surface,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepNode({
    required int stepIndex,
    required String title,
    required bool isActive,
    required bool isCompleted,
  }) {
    return GestureDetector(
      onTap: () {
        if (stepIndex < _currentStep) {
          _goToStep(stepIndex);
        }
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: isCompleted
                  ? AppColors.primary
                  : (isActive ? AppColors.accentLight : AppColors.surface),
              shape: BoxShape.circle,
              border: Border.all(
                color: (isActive || isCompleted)
                    ? AppColors.primary
                    : AppColors.border,
                width: 1.6,
              ),
            ),
            child: Center(
              child: isCompleted
                  ? const Icon(
                      Icons.check_rounded,
                      size: 16,
                      color: Colors.white,
                    )
                  : Text(
                      '${stepIndex + 1}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        color: isActive
                            ? AppColors.primary
                            : AppColors.textSecondary,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.5,
              fontWeight: (isActive || isCompleted)
                  ? FontWeight.w700
                  : FontWeight.w500,
              color: (isActive || isCompleted)
                  ? AppColors.textPrimary
                  : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // STEP 1: Personal & Contact Information
  // ---------------------------------------------------------------------------
  Widget _buildStep1Personal() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Badge
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
                        'Step 1 of 2 • Basic Information',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    Text(
                      'Create your account',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 27,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.6,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'Join FindBookStay to discover verified rentals, booking stays, and sports turfs with zero broker fee.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textSecondary,
                        height: 1.45,
                      ),
                    ),

                    const SizedBox(height: 28),

                    // 1. Full Name (Required)
                    CustomAuthInput(
                      label: 'Full Name',
                      hint: 'e.g. John Doe or Sarah Jenkins',
                      prefixIcon: Icons.person_outline_rounded,
                      isRequired: true,
                      controller: _nameController,
                      errorMessage: _nameError,
                      onChanged: (_) {
                        if (_nameError != null) setState(() => _nameError = null);
                      },
                    ),

                    const SizedBox(height: 18),

                    // 2. Email Address (Required)
                    CustomAuthInput(
                      label: 'Email Address',
                      hint: 'name@example.com',
                      prefixIcon: Icons.mail_outline_rounded,
                      keyboardType: TextInputType.emailAddress,
                      isRequired: true,
                      controller: _emailController,
                      errorMessage: _emailError,
                      onChanged: (_) {
                        if (_emailError != null) setState(() => _emailError = null);
                      },
                    ),

                    const SizedBox(height: 18),

                    // 3. Phone Number (Optional)
                    CustomAuthInput(
                      label: 'Phone Number (Optional)',
                      hint: '+1 (555) 000-0000 or +880 1712-345678',
                      prefixIcon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      controller: _phoneController,
                    ),

                    const Spacer(),
                    const SizedBox(height: 24),

                    // Step 1 CTA: Next Button
                    CustomAuthButton(
                      text: 'Continue to Step 2',
                      icon: Icons.arrow_forward_rounded,
                      onPressed: _onStep1Continue,
                    ),

                    const SizedBox(height: 16),

                    // Sign In Link
                    Center(
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: RichText(
                          text: TextSpan(
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13.5,
                              color: AppColors.textSecondary,
                            ),
                            children: const [
                              TextSpan(text: 'Already have an account? '),
                              TextSpan(
                                text: 'Sign In',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // STEP 2: Account Security (Password & Terms)
  // ---------------------------------------------------------------------------
  Widget _buildStep2Security() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Badge
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
                        'Step 2 of 2 • Security & Password',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    Text(
                      'Secure your account',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 27,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.6,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'Set a strong password to protect your bookings, listings, and personal information.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textSecondary,
                        height: 1.45,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // User Identity Summary Card
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.account_circle_outlined,
                            size: 22,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _nameController.text.isNotEmpty
                                      ? _nameController.text.trim()
                                      : 'Account Holder',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                Text(
                                  _emailController.text.isNotEmpty
                                      ? _emailController.text.trim()
                                      : 'email@example.com',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: () => _goToStep(0),
                            style: TextButton.styleFrom(
                              visualDensity: VisualDensity.compact,
                              foregroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                            ),
                            child: const Text('Edit'),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Password Input
                    CustomAuthInput(
                      label: 'Password',
                      hint: 'Create password (min. 8 chars, 1 number)',
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

                    // Real-time password strength meter
                    PasswordStrengthMeter(password: _passwordController.text),

                    const SizedBox(height: 16),

                    // Confirm Password Input
                    CustomAuthInput(
                      label: 'Confirm Password',
                      hint: 'Re-enter your password',
                      prefixIcon: Icons.lock_reset_rounded,
                      isPassword: true,
                      isRequired: true,
                      controller: _confirmPasswordController,
                      errorMessage: _confirmPasswordError,
                      onChanged: (_) {
                        if (_confirmPasswordError != null) {
                          setState(() => _confirmPasswordError = null);
                        }
                      },
                    ),

                    const SizedBox(height: 20),

                    // Terms & Policy Checkbox
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _termsAccepted = !_termsAccepted;
                          if (_termsAccepted) _termsError = null;
                        });
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 24,
                            height: 24,
                            child: Checkbox(
                              value: _termsAccepted,
                              activeColor: AppColors.primary,
                              checkColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                              side: BorderSide(
                                color: _termsError != null
                                    ? AppColors.error
                                    : AppColors.border,
                                width: 1.5,
                              ),
                              onChanged: (val) {
                                setState(() {
                                  _termsAccepted = val ?? false;
                                  if (_termsAccepted) _termsError = null;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13,
                                  color: _termsError != null
                                      ? AppColors.error
                                      : AppColors.textSecondary,
                                  height: 1.4,
                                ),
                                children: [
                                  const TextSpan(text: 'I accept the '),
                                  TextSpan(
                                    text: 'Terms of Service',
                                    recognizer: _termsRecognizer,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primary,
                                      decoration: TextDecoration.underline,
                                      decorationColor: AppColors.primary,
                                    ),
                                  ),
                                  const TextSpan(text: ' and acknowledge the '),
                                  TextSpan(
                                    text: 'Privacy Policy',
                                    recognizer: _privacyRecognizer,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primary,
                                      decoration: TextDecoration.underline,
                                      decorationColor: AppColors.primary,
                                    ),
                                  ),
                                  const TextSpan(text: '.'),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    if (_termsError != null) ...[
                      const SizedBox(height: 6),
                      Padding(
                        padding: const EdgeInsets.only(left: 34.0),
                        child: Text(
                          _termsError!,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.error,
                          ),
                        ),
                      ),
                    ],

                    const Spacer(),
                    const SizedBox(height: 24),

                    // Submit CTA Button
                    CustomAuthButton(
                      text: 'Create Account',
                      icon: Icons.check_circle_outline_rounded,
                      isLoading: _isLoading,
                      onPressed: _validateAndSubmit,
                    ),

                    const SizedBox(height: 12),

                    // Back to Step 1 Button
                    Center(
                      child: TextButton.icon(
                        onPressed: () => _goToStep(0),
                        icon: const Icon(Icons.arrow_back_rounded, size: 16),
                        label: const Text('Back to Personal Info'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.textSecondary,
                          textStyle: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Legal Modal Bottom Sheet
// ---------------------------------------------------------------------------

class _LegalModalSheet extends StatelessWidget {
  final bool isTerms;

  const _LegalModalSheet({required this.isTerms});

  @override
  Widget build(BuildContext context) {
    final title = isTerms ? 'Terms of Service' : 'Privacy Policy';
    final sections = isTerms ? _termsSections : _privacySections;

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 4),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 16, 12),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.accentLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        isTerms ? Icons.gavel_rounded : Icons.shield_outlined,
                        size: 20,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        title,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded),
                      color: AppColors.textSecondary,
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.surface,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Divider(
                height: 1,
                color: AppColors.border,
                indent: 24,
                endIndent: 24,
              ),
              Expanded(
                child: ListView.separated(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
                  itemCount: sections.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 20),
                  itemBuilder: (_, index) {
                    final section = sections[index];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          section['heading']!,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          section['body']!,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w400,
                            color: AppColors.textSecondary,
                            height: 1.6,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Got it',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static const List<Map<String, String>> _termsSections = [
    {
      'heading': '1. Acceptance of Terms',
      'body':
          'By registering for or using FindBookStay, you agree to be bound by these Terms of Service. If you do not agree to these terms, please do not use our platform.',
    },
    {
      'heading': '2. Use of the Platform',
      'body':
          'FindBookStay provides a marketplace connecting tenants, guests, players, landlords, hosts, and turf owners. Users are responsible for ensuring all information they provide is accurate and up to date.',
    },
    {
      'heading': '3. User Accounts',
      'body':
          'You must create an account to access most features. You are responsible for maintaining the confidentiality of your credentials and for all activities that occur under your account.',
    },
    {
      'heading': '4. Listings & Bookings',
      'body':
          'Hosts and landlords are solely responsible for the accuracy of their listings. FindBookStay does not guarantee the availability, quality, safety, or legality of any listed property or turf.',
    },
    {
      'heading': '5. Fees & Payments',
      'body':
          'FindBookStay charges zero broker fees. Payment terms between hosts and guests are subject to individual listing conditions. All transactions are processed securely.',
    },
    {
      'heading': '6. Prohibited Conduct',
      'body':
          'Users may not post false listings, engage in fraudulent activity, harass other users, or use the platform for any unlawful purpose.',
    },
    {
      'heading': '7. Changes to Terms',
      'body':
          'We reserve the right to modify these terms at any time. Continued use of the platform after changes constitutes acceptance of the revised terms.',
    },
  ];

  static const List<Map<String, String>> _privacySections = [
    {
      'heading': '1. Information We Collect',
      'body':
          'We collect information you provide directly (name, email, phone), usage data, and device information to deliver and improve our services.',
    },
    {
      'heading': '2. How We Use Your Information',
      'body':
          'Your data is used to operate the platform, process bookings, send confirmation notifications, and personalise your experience. We do not sell your personal data to third parties.',
    },
    {
      'heading': '3. Data Sharing',
      'body':
          'We may share necessary information with hosts, landlords, or turf owners to facilitate bookings. We may also share data with service providers who help us operate FindBookStay under strict confidentiality agreements.',
    },
    {
      'heading': '4. Data Security',
      'body':
          'We implement industry-standard security measures including encryption in transit and at rest to protect your personal information.',
    },
    {
      'heading': '5. Cookies & Analytics',
      'body':
          'We use cookies and analytics tools to understand how users interact with our platform, enabling us to improve features and performance.',
    },
    {
      'heading': '6. Your Rights',
      'body':
          'You have the right to access, correct, or delete your personal data at any time by contacting us at privacy@findbookstay.com.',
    },
    {
      'heading': '7. Contact Us',
      'body':
          'For any privacy-related questions or requests, please reach out to our Data Protection team at privacy@findbookstay.com.',
    },
  ];
}
