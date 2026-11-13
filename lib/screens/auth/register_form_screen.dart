import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/theme/app_colors.dart';
import 'otp_verification_screen.dart';
import 'register_role_screen.dart';
import 'widgets/custom_auth_button.dart';
import 'widgets/custom_auth_input.dart';
import 'widgets/password_strength_meter.dart';

/// Step 2 of Registration Flow: Dynamic Form with Role Switcher & Real-time Validation.
/// Features top-bottom centering, clean placeholders, eye toggle animation, and required field warning badges.
class RegisterFormScreen extends StatefulWidget {
  final UserRole initialRole;

  const RegisterFormScreen({super.key, required this.initialRole});

  @override
  State<RegisterFormScreen> createState() => _RegisterFormScreenState();
}

class _RegisterFormScreenState extends State<RegisterFormScreen> {
  late UserRole _currentRole;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String? _nameError;
  String? _emailError;
  String? _passwordError;
  bool _termsAccepted = false;
  String? _termsError;
  bool _isLoading = false;

  // TapGestureRecognizers for legal links — must be disposed to avoid memory leaks
  late final TapGestureRecognizer _termsRecognizer;
  late final TapGestureRecognizer _privacyRecognizer;

  @override
  void initState() {
    super.initState();
    _currentRole = widget.initialRole;
    _termsRecognizer = TapGestureRecognizer()
      ..onTap = () => _showLegalModal(isTerms: true);
    _privacyRecognizer = TapGestureRecognizer()
      ..onTap = () => _showLegalModal(isTerms: false);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _termsRecognizer.dispose();
    _privacyRecognizer.dispose();
    super.dispose();
  }

  void _validateAndSubmit() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    setState(() {
      _nameError = name.isEmpty ? 'Full name is required' : null;

      if (email.isEmpty) {
        _emailError = 'Email address is required';
      } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
        _emailError = 'Please enter a valid email';
      } else {
        _emailError = null;
      }

      if (password.isEmpty) {
        _passwordError = 'Password is required';
      } else if (password.length < 8) {
        _passwordError = 'Min. 8 characters required';
      } else if (!RegExp(r'[0-9]').hasMatch(password)) {
        _passwordError = 'Include at least 1 number';
      } else {
        _passwordError = null;
      }

      if (!_termsAccepted) {
        _termsError = 'Please accept the Terms to continue';
      } else {
        _termsError = null;
      }
    });

    if (_nameError != null ||
        _emailError != null ||
        _passwordError != null ||
        _termsError != null) {
      HapticFeedback.mediumImpact();
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Simulate secure network registration request
    await Future.delayed(const Duration(milliseconds: 1200));

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    // Navigate to OTP verification for account activation
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => OtpVerificationScreen(
          email: _emailController.text.trim(),
          isRegistrationFlow: true,
        ),
      ),
    );
  }

  /// Shows a beautiful bottom-sheet modal for Terms of Service or Privacy Policy.
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
    final bool isHost = _currentRole == UserRole.host;

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
        actions: [
          // 1-Click Role Switcher Pill in Top Bar
          Padding(
            padding: const EdgeInsets.only(right: 18.0),
            child: Center(
              child: Container(
                height: 36,
                padding: const EdgeInsets.all(3.0),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildRoleToggleOption(
                      title: 'Tenant',
                      role: UserRole.tenant,
                    ),
                    _buildRoleToggleOption(
                      title: 'Host',
                      role: UserRole.host,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
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
                        // Step Tag
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
                            'Step 2 of 2 \u2022 ${isHost ? "Host Account" : "Tenant Account"}',
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
                          isHost
                              ? 'List apartments, shared rooms, and sports turfs to verified guests with zero broker fee.'
                              : 'Rent spaces, discover bachelor seats, book hotel stays, and reserve sports turfs.',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: AppColors.textSecondary,
                            height: 1.45,
                          ),
                        ),

                        const SizedBox(height: 26),

                        // 1. Full Name (Required)
                        CustomAuthInput(
                          label: isHost ? 'Legal Name / Agency' : 'Full Name',
                          hint: isHost
                              ? 'e.g. Skyline Living or Alex Miller'
                              : 'e.g. John Doe or Sarah Jenkins',
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

                        const SizedBox(height: 18),

                        // 4. Password (Required)
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

                        const SizedBox(height: 20),

                        // 5. Terms Checkbox with Error Indication
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

                        const SizedBox(height: 28),

                        // Submit CTA Button
                        CustomAuthButton(
                          text: 'Create ${isHost ? "Host" : "Tenant"} Account',
                          icon: Icons.arrow_forward_rounded,
                          isLoading: _isLoading,
                          onPressed: _validateAndSubmit,
                        ),

                        const SizedBox(height: 16),
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

  Widget _buildRoleToggleOption({
    required String title,
    required UserRole role,
  }) {
    final bool isSelected = _currentRole == role;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() {
          _currentRole = role;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 5.0),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12.5,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Legal Modal Bottom Sheet
// ---------------------------------------------------------------------------

/// A polished bottom-sheet modal that displays Terms of Service or Privacy Policy content.
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
              // Drag handle
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 4),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
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
                        isTerms
                            ? Icons.gavel_rounded
                            : Icons.shield_outlined,
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

              // Scrollable content
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

              // Accept button
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
