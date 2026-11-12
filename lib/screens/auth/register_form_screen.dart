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

  @override
  void initState() {
    super.initState();
    _currentRole = widget.initialRole;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
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
                                    children: const [
                                      TextSpan(text: 'I accept the '),
                                      TextSpan(
                                        text: 'Terms of Service',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.primary,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                      TextSpan(text: ' and acknowledge the '),
                                      TextSpan(
                                        text: 'Privacy Policy',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.primary,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                      TextSpan(text: '.'),
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
