import 'dart:convert';
import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/theme/app_colors.dart';
import '../../features/auth/data/models/register_request.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';
import 'otp_verification_screen.dart';
import 'register_role_screen.dart';
import 'widgets/country_code_selector.dart';
import 'widgets/custom_auth_input.dart';
import 'widgets/password_strength_meter.dart';

/// Complete, Production-Ready 3-Step Registration Flow for FindBookStay.
///
/// Steps:
/// - Step 1: Personal Details (Profile Photo, Full Name, Email Address, Phone Number).
/// - Step 2: Addresses & Referral (Present Address, Permanent Address with "Same as Present" toggle, Optional Referral Code).
/// - Step 3: Account Security (Password, Strength Meter, Confirm Password, Terms & Privacy Agreement).
class RegisterFormScreen extends ConsumerStatefulWidget {
  final UserRole initialRole;

  const RegisterFormScreen({
    super.key,
    this.initialRole = UserRole.tenant,
  });

  @override
  ConsumerState<RegisterFormScreen> createState() => _RegisterFormScreenState();
}

class _RegisterFormScreenState extends ConsumerState<RegisterFormScreen>
    with SingleTickerProviderStateMixin {
  int _currentStep = 0;
  late final PageController _pageController;
  late final AnimationController _glowController;
  late final Animation<double> _glowAnimation;

  // Profile Photo
  XFile? _profilePhoto;
  final ImagePicker _imagePicker = ImagePicker();

  // Step 1 Controllers: Personal Details
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  String _selectedDialCode = '+880';

  // Step 2 Controllers: Present Address
  final TextEditingController _presentStreetController = TextEditingController();
  final TextEditingController _presentCityController = TextEditingController();
  final TextEditingController _presentStateController = TextEditingController();
  final TextEditingController _presentZipController = TextEditingController();

  // Step 2 Controllers: Permanent Address & Referral
  bool _sameAsPresent = false;
  final TextEditingController _permanentStreetController = TextEditingController();
  final TextEditingController _permanentCityController = TextEditingController();
  final TextEditingController _permanentStateController = TextEditingController();
  final TextEditingController _permanentZipController = TextEditingController();
  final TextEditingController _referralCodeController = TextEditingController();

  // Step 3 Controllers: Security & Password
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  // Validation Errors
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
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _glowAnimation = Tween<double>(begin: 0.25, end: 0.65).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
    _termsRecognizer = TapGestureRecognizer()
      ..onTap = () => _showLegalModal(isTerms: true);
    _privacyRecognizer = TapGestureRecognizer()
      ..onTap = () => _showLegalModal(isTerms: false);
  }

  @override
  void dispose() {
    _glowController.dispose();
    _pageController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _presentStreetController.dispose();
    _presentCityController.dispose();
    _presentStateController.dispose();
    _presentZipController.dispose();
    _permanentStreetController.dispose();
    _permanentCityController.dispose();
    _permanentStateController.dispose();
    _permanentZipController.dispose();
    _referralCodeController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _termsRecognizer.dispose();
    _privacyRecognizer.dispose();
    super.dispose();
  }

  void _goToStep(int step) {
    HapticFeedback.lightImpact();
    setState(() {
      _currentStep = step;
    });
    _pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 380),
      curve: Curves.fastOutSlowIn,
    );
  }

  // ---------------------------------------------------------------------------
  // Profile Photo Upload (Camera / Gallery)
  // ---------------------------------------------------------------------------
  void _showPhotoOptions() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    HapticFeedback.selectionClick();
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkBorder : AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Profile Photo',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 18),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF132F28) : AppColors.accentLight,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.camera_alt_rounded,
                    color: isDark ? AppColors.accent : AppColors.primary,
                  ),
                ),
                title: Text(
                  'Take Photo with Camera',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                  ),
                ),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _pickPhoto(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF132F28) : AppColors.accentLight,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.photo_library_rounded,
                    color: isDark ? AppColors.accent : AppColors.primary,
                  ),
                ),
                title: Text(
                  'Choose from Gallery',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                  ),
                ),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _pickPhoto(ImageSource.gallery);
                },
              ),
              if (_profilePhoto != null)
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
                  ),
                  title: Text(
                    'Remove Photo',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.error,
                    ),
                  ),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    setState(() => _profilePhoto = null);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickPhoto(ImageSource source) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 75,
      );
      if (image != null) {
        setState(() {
          _profilePhoto = image;
        });
      }
    } catch (e) {
      debugPrint('Failed to pick profile image: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // Validation Handlers
  // ---------------------------------------------------------------------------
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

  void _onStep2Continue() {
    _goToStep(2);
  }

  void _validateAndSubmit() async {
    if (!_validateStep1()) {
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
    final rawPhone = _phoneController.text.trim();
    String? fullPhone;
    if (rawPhone.isNotEmpty) {
      final cleanDigits = rawPhone.replaceAll(RegExp(r'[\s-]'), '');
      if (cleanDigits.startsWith('+')) {
        fullPhone = cleanDigits;
      } else {
        final normalizedDigits =
            cleanDigits.startsWith('0') ? cleanDigits.substring(1) : cleanDigits;
        fullPhone = '$_selectedDialCode$normalizedDigits';
      }
    }

    // Step 2: Present Address
    final presentStreet = _presentStreetController.text.trim();
    final presentCity = _presentCityController.text.trim();
    final presentState = _presentStateController.text.trim();
    final presentZip = _presentZipController.text.trim();

    AddressModel? presentAddress;
    if (presentStreet.isNotEmpty || presentCity.isNotEmpty || presentState.isNotEmpty || presentZip.isNotEmpty) {
      presentAddress = AddressModel(
        street: presentStreet.isNotEmpty ? presentStreet : null,
        city: presentCity.isNotEmpty ? presentCity : null,
        state: presentState.isNotEmpty ? presentState : null,
        zipCode: presentZip.isNotEmpty ? presentZip : null,
      );
    }

    // Step 2: Permanent Address
    AddressModel? permanentAddress;
    if (_sameAsPresent) {
      permanentAddress = presentAddress;
    } else {
      final permStreet = _permanentStreetController.text.trim();
      final permCity = _permanentCityController.text.trim();
      final permState = _permanentStateController.text.trim();
      final permZip = _permanentZipController.text.trim();
      if (permStreet.isNotEmpty || permCity.isNotEmpty || permState.isNotEmpty || permZip.isNotEmpty) {
        permanentAddress = AddressModel(
          street: permStreet.isNotEmpty ? permStreet : null,
          city: permCity.isNotEmpty ? permCity : null,
          state: permState.isNotEmpty ? permState : null,
          zipCode: permZip.isNotEmpty ? permZip : null,
        );
      }
    }

    // Step 2: Referral Code
    final referralCode = _referralCodeController.text.trim();

    // Profile photo conversion
    String? profileImageBase64;
    if (_profilePhoto != null) {
      try {
        final bytes = await _profilePhoto!.readAsBytes();
        final ext = _profilePhoto!.name.split('.').last.toLowerCase();
        final mime = (ext == 'png') ? 'image/png' : 'image/jpeg';
        profileImageBase64 = 'data:$mime;base64,${base64Encode(bytes)}';
      } catch (_) {
        profileImageBase64 = _profilePhoto!.path;
      }
    }

    final success = await ref.read(authControllerProvider.notifier).register(
      name: name,
      email: email,
      password: password,
      phone: fullPhone,
      role: 'USER',
      profileImage: profileImageBase64,
      presentAddress: (presentAddress != null && !presentAddress.isEmpty) ? presentAddress : null,
      permanentAddress: (permanentAddress != null && !permanentAddress.isEmpty) ? permanentAddress : null,
      referredBy: referralCode.isNotEmpty ? referralCode : null,
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (success) {
      ScaffoldMessenger.of(context).clearSnackBars();
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
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error ?? 'Registration failed. Please check your data and try again.',
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 4),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return PopScope(
      canPop: _currentStep == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _currentStep > 0) {
          _goToStep(_currentStep - 1);
        }
      },
      child: Scaffold(
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
            onPressed: () {
              if (_currentStep > 0) {
                _goToStep(_currentStep - 1);
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
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            ),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // Top Step Progress Indicator (Round & Stationary)
              _buildModernRoundStepper(),

              // 3-Step PageView (Only middle form moves!)
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildStep1Personal(),
                    _buildStep2AddressAndReferral(),
                    _buildStep3Security(),
                  ],
                ),
              ),

              // Stationary Bottom Action Bar (Fixed, never slides with form)
              _buildFixedBottomBar(),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Top Step Progress Indicator (Modern Round Nodes with Glowing Pulse)
  // ---------------------------------------------------------------------------
  Widget _buildModernRoundStepper() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.fromLTRB(28, 10, 28, 14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBackground : AppColors.background,
        border: Border(
          bottom: BorderSide(
            color: (isDark ? AppColors.darkBorder : AppColors.border).withValues(alpha: 0.6),
            width: 1,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepNode(
            stepIndex: 0,
            label: 'Personal',
            icon: Icons.person_rounded,
          ),
          Expanded(child: _buildConnectingLine(0)),
          _buildStepNode(
            stepIndex: 1,
            label: 'Address',
            icon: Icons.location_on_rounded,
          ),
          Expanded(child: _buildConnectingLine(1)),
          _buildStepNode(
            stepIndex: 2,
            label: 'Security',
            icon: Icons.shield_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildStepNode({
    required int stepIndex,
    required String label,
    required IconData icon,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isActive = _currentStep == stepIndex;
    final isCompleted = _currentStep > stepIndex;

    return GestureDetector(
      onTap: () {
        if (stepIndex < _currentStep) {
          _goToStep(stepIndex);
        }
      },
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _glowAnimation,
            builder: (context, _) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isActive
                      ? AppColors.primary
                      : (isCompleted
                          ? AppColors.primary
                          : (isDark ? AppColors.darkCard : AppColors.surface)),
                  border: Border.all(
                    color: isActive
                        ? AppColors.accent
                        : (isCompleted
                            ? AppColors.primary
                            : (isDark ? AppColors.darkBorder : AppColors.border)),
                    width: isActive ? 2.2 : (isCompleted ? 2.0 : 1.5),
                  ),
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: AppColors.accent.withValues(alpha: _glowAnimation.value),
                            blurRadius: 14 + (_glowAnimation.value * 6),
                            spreadRadius: 2.0,
                          ),
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.35),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : (isCompleted
                          ? [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.18),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null),
                ),
                child: Center(
                  child: isCompleted
                      ? const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 20,
                        )
                      : Text(
                          '${stepIndex + 1}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                            color: isActive
                                ? Colors.white
                                : (isDark ? AppColors.darkTextMuted : AppColors.textMuted),
                          ),
                        ),
                ),
              );
            },
          ),
          const SizedBox(height: 6),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 250),
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: isActive ? FontWeight.w800 : (isCompleted ? FontWeight.w700 : FontWeight.w500),
              color: isActive
                  ? (isDark ? AppColors.accent : AppColors.primary)
                  : (isCompleted
                      ? (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary)
                      : (isDark ? AppColors.darkTextMuted : AppColors.textMuted)),
              letterSpacing: -0.1,
            ),
            child: Text(label),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectingLine(int fromIndex) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isCompleted = _currentStep > fromIndex;
    return Container(
      margin: const EdgeInsets.only(top: 19.5, left: 8, right: 8),
      height: 3,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              Container(
                width: constraints.maxWidth,
                height: 3,
                decoration: BoxDecoration(
                  color: (isDark ? AppColors.darkBorder : AppColors.border).withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 380),
                curve: Curves.easeInOutCubic,
                width: isCompleted ? constraints.maxWidth : 0,
                height: 3,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.accent],
                  ),
                  borderRadius: BorderRadius.circular(3),
                  boxShadow: isCompleted
                      ? [
                          BoxShadow(
                            color: AppColors.accent.withValues(alpha: 0.4),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ]
                      : null,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Stationary Bottom Action Bar (Fixed, never slides with form)
  // ---------------------------------------------------------------------------
  Widget _buildFixedBottomBar() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        border: Border(
          top: BorderSide(
            color: (isDark ? AppColors.darkBorder : AppColors.border).withValues(alpha: 0.7),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
            offset: const Offset(0, -3),
            blurRadius: 12,
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 260),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (child, animation) {
            return FadeTransition(opacity: animation, child: child);
          },
          child: _currentStep == 0
              ? KeyedSubtree(
                  key: const ValueKey('step_0_actions'),
                  child: _buildModernPrimaryButton(
                    text: 'Continue',
                    icon: Icons.arrow_forward_rounded,
                    onPressed: _onStep1Continue,
                  ),
                )
              : _currentStep == 1
                  ? KeyedSubtree(
                      key: const ValueKey('step_1_actions'),
                      child: Row(
                        children: [
                          _buildModernBackButton(
                            onPressed: () => _goToStep(0),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildModernPrimaryButton(
                              text: 'Continue',
                              icon: Icons.arrow_forward_rounded,
                              onPressed: _onStep2Continue,
                            ),
                          ),
                        ],
                      ),
                    )
                  : KeyedSubtree(
                      key: const ValueKey('step_2_actions'),
                      child: Row(
                        children: [
                          _buildModernBackButton(
                            onPressed: () => _goToStep(1),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildModernPrimaryButton(
                              text: 'Create Account',
                              icon: Icons.check_circle_rounded,
                              isLoading: _isLoading,
                              onPressed: _validateAndSubmit,
                            ),
                          ),
                        ],
                      ),
                    ),
        ),
      ),
    );
  }

  Widget _buildModernPrimaryButton({
    required String text,
    required VoidCallback? onPressed,
    IconData? icon,
    bool isLoading = false,
  }) {
    return Container(
      height: 54,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xFF073B35), Color(0xFF0E544B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.38),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
          BoxShadow(
            color: AppColors.accent.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading
              ? null
              : () {
                  HapticFeedback.lightImpact();
                  onPressed?.call();
                },
          borderRadius: BorderRadius.circular(16),
          splashColor: Colors.white.withValues(alpha: 0.12),
          highlightColor: Colors.white.withValues(alpha: 0.06),
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        text,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.2,
                        ),
                      ),
                      if (icon != null) ...[
                        const SizedBox(width: 8),
                        Icon(icon, size: 20, color: AppColors.accent),
                      ],
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernBackButton({required VoidCallback onPressed}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.border,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            onPressed();
          },
          borderRadius: BorderRadius.circular(16),
          splashColor: AppColors.primary.withValues(alpha: 0.08),
          highlightColor: AppColors.primary.withValues(alpha: 0.04),
          child: Center(
            child: Icon(
              Icons.arrow_back_rounded,
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              size: 22,
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // STEP 1: Personal Details (Profile Photo, Name, Email, Phone)
  // ---------------------------------------------------------------------------
  Widget _buildStep1Personal() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Create your account',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 27,
                  fontWeight: FontWeight.w800,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                  letterSpacing: -0.6,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                'Join FindBookStay with 0% broker fee across stays, rentals, and sports turfs.',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w400,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 24),

              // Photo Upload Avatar Component
              Center(
                child: Stack(
                  children: [
                    GestureDetector(
                      onTap: _showPhotoOptions,
                      child: Container(
                        width: 94,
                        height: 94,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDark ? AppColors.darkSurface : AppColors.surface,
                          border: Border.all(
                            color: _profilePhoto != null
                                ? AppColors.primary
                                : (isDark ? AppColors.darkBorder : AppColors.border),
                            width: 2.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: _profilePhoto != null
                                ? Image.file(
                                  File(_profilePhoto!.path),
                                  fit: BoxFit.cover,
                                  width: 94,
                                  height: 94,
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.person_rounded,
                                      size: 44,
                                      color: (isDark ? AppColors.darkTextMuted : AppColors.textMuted).withValues(alpha: 0.6),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _showPhotoOptions,
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            border: Border.all(color: isDark ? AppColors.darkCard : Colors.white, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.35),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.camera_alt_rounded,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),
              Center(
                child: Text(
                  _profilePhoto != null ? 'Tap to change photo' : 'Add Profile Photo (Optional)',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Full Name
              CustomAuthInput(
                label: 'Full Name',
                hint: 'John Doe',
                prefixIcon: Icons.person_outline_rounded,
                isRequired: true,
                controller: _nameController,
                errorMessage: _nameError,
                onChanged: (_) {
                  if (_nameError != null) setState(() => _nameError = null);
                },
              ),

              const SizedBox(height: 16),

              // Email Address
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

              const SizedBox(height: 16),

              // Phone Number with Country Code Picker (Bangladesh +880 default)
              CustomAuthInput(
                label: 'Phone Number (Optional)',
                hint: '1712-345678',
                prefixWidget: CountryCodeSelector(
                  initialCountryCode: 'BD',
                  onChanged: (country) {
                    setState(() {
                      _selectedDialCode = country['dial_code'] ?? '+880';
                    });
                  },
                ),
                keyboardType: TextInputType.phone,
                controller: _phoneController,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9\s-]')),
                ],
              ),

              const SizedBox(height: 24),

              // Sign In Link
              Center(
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: RichText(
                    text: TextSpan(
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13.5,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                      ),
                      children: [
                        const TextSpan(text: 'Already have an account? '),
                        TextSpan(
                          text: 'Sign In',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppColors.accent : AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // STEP 2: Addresses & Referral (Present, Permanent, Referral Code)
  // ---------------------------------------------------------------------------
  Widget _buildStep2AddressAndReferral() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Where are you located?',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 27,
                  fontWeight: FontWeight.w800,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                  letterSpacing: -0.6,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                'Add your present and permanent address details to streamline your stay and booking verifications.',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w400,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 24),

              // ---------------------------------------------------------------
              // Present Address
              // ---------------------------------------------------------------
              Row(
                children: [
                  Icon(Icons.location_on_rounded, size: 20, color: isDark ? AppColors.accent : AppColors.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Present Address',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              CustomAuthInput(
                label: 'Street Address',
                hint: '123 Main St, Apt 4B',
                prefixIcon: Icons.home_outlined,
                controller: _presentStreetController,
              ),

              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: CustomAuthInput(
                      label: 'City',
                      hint: 'City',
                      prefixIcon: Icons.location_city_outlined,
                      controller: _presentCityController,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomAuthInput(
                      label: 'State / Region',
                      hint: 'State',
                      prefixIcon: Icons.map_outlined,
                      controller: _presentStateController,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              CustomAuthInput(
                label: 'Postal / Zip Code',
                hint: '10001',
                prefixIcon: Icons.markunread_mailbox_outlined,
                controller: _presentZipController,
              ),

              const SizedBox(height: 24),

              // ---------------------------------------------------------------
              // Permanent Address Toggle ("Same as Present")
              // ---------------------------------------------------------------
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: Checkbox(
                        value: _sameAsPresent,
                        activeColor: isDark ? AppColors.accent : AppColors.primary,
                        checkColor: isDark ? AppColors.primaryDark : Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        onChanged: (val) {
                          setState(() {
                            _sameAsPresent = val ?? false;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() => _sameAsPresent = !_sameAsPresent);
                        },
                        child: Text(
                          'Permanent address is the same as present',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // ---------------------------------------------------------------
              // Permanent Address Inputs (if not same)
              // ---------------------------------------------------------------
              if (!_sameAsPresent) ...[
                Row(
                  children: [
                    Icon(Icons.home_work_rounded, size: 20, color: isDark ? AppColors.accent : AppColors.primary),
                    const SizedBox(width: 8),
                    Text(
                      'Permanent Address',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                CustomAuthInput(
                  label: 'Permanent Street Address',
                  hint: 'Village/Road, House No.',
                  prefixIcon: Icons.home_outlined,
                  controller: _permanentStreetController,
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: CustomAuthInput(
                        label: 'Permanent City',
                        hint: 'City',
                        prefixIcon: Icons.location_city_outlined,
                        controller: _permanentCityController,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomAuthInput(
                        label: 'Permanent State',
                        hint: 'State / Region',
                        prefixIcon: Icons.map_outlined,
                        controller: _permanentStateController,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                CustomAuthInput(
                  label: 'Permanent Postal / Zip Code',
                  hint: 'Postal Code',
                  prefixIcon: Icons.markunread_mailbox_outlined,
                  controller: _permanentZipController,
                ),
                const SizedBox(height: 24),
              ],

              // ---------------------------------------------------------------
              // Optional Referral Code
              // ---------------------------------------------------------------
              Row(
                children: [
                  Icon(Icons.card_giftcard_rounded, size: 20, color: isDark ? AppColors.accent : AppColors.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Referral Code (Optional)',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Have a friend on FindBookStay? Enter their referral code for signup rewards.',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.5,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 14),
              CustomAuthInput(
                label: 'Referral Code',
                hint: 'e.g. F7GC1YX7',
                prefixIcon: Icons.confirmation_number_outlined,
                controller: _referralCodeController,
              ),

              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // STEP 3: Security & Password (Password, Strength, Confirm, Terms)
  // ---------------------------------------------------------------------------
  Widget _buildStep3Security() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Secure your account',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 27,
                  fontWeight: FontWeight.w800,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                  letterSpacing: -0.6,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                'Set a strong password to protect your bookings, listings, and personal information.',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w400,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 20),

              // Password Input
              CustomAuthInput(
                label: 'Password',
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

              // Real-time password strength meter
              PasswordStrengthMeter(password: _passwordController.text),

              const SizedBox(height: 16),

              // Confirm Password Input
              CustomAuthInput(
                label: 'Confirm Password',
                hint: '••••••••',
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
                        activeColor: isDark ? AppColors.accent : AppColors.primary,
                        checkColor: isDark ? AppColors.primaryDark : Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        side: BorderSide(
                          color: _termsError != null
                              ? AppColors.error
                              : (isDark ? AppColors.darkBorder : AppColors.border),
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
                                : (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
                            height: 1.4,
                          ),
                          children: [
                            const TextSpan(text: 'I accept the '),
                            TextSpan(
                              text: 'Terms of Service',
                              recognizer: _termsRecognizer,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: isDark ? AppColors.accent : AppColors.primary,
                                decoration: TextDecoration.underline,
                                decorationColor: isDark ? AppColors.accent : AppColors.primary,
                              ),
                            ),
                            const TextSpan(text: ' and acknowledge the '),
                            TextSpan(
                              text: 'Privacy Policy',
                              recognizer: _privacyRecognizer,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: isDark ? AppColors.accent : AppColors.primary,
                                decoration: TextDecoration.underline,
                                decorationColor: isDark ? AppColors.accent : AppColors.primary,
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

              const SizedBox(height: 24),
            ],
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final title = isTerms ? 'Terms of Service' : 'Privacy Policy';
    final sections = isTerms ? _termsSections : _privacySections;

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 4),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkBorder : AppColors.border,
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
                        color: isDark ? const Color(0xFF132F28) : AppColors.accentLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        isTerms ? Icons.gavel_rounded : Icons.shield_outlined,
                        size: 20,
                        color: isDark ? AppColors.accent : AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        title,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded),
                      color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                      style: IconButton.styleFrom(
                        backgroundColor: isDark ? AppColors.darkSurface : AppColors.surface,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Divider(height: 1, color: isDark ? AppColors.darkBorder : AppColors.border),
              Expanded(
                child: ListView.separated(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(24, 18, 24, 32),
                  itemCount: sections.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 18),
                  itemBuilder: (ctx, i) {
                    final item = sections[i];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          item.body,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                            height: 1.5,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _LegalSection {
  final String title;
  final String body;

  const _LegalSection(this.title, this.body);
}

const List<_LegalSection> _termsSections = [
  _LegalSection(
    '1. Agreement to Terms',
    'By registering for, accessing, or using the FindBookStay platform, you agree to be bound by these Terms of Service. If you do not agree with any part, please refrain from creating an account.',
  ),
  _LegalSection(
    '2. 0% Broker Fee Policy',
    'FindBookStay operates on a strictly zero-percent broker commission model for standard rentals, stays, and sports turfs. Any attempt by hosts or users to solicit offline broker commissions violates our Community Standards.',
  ),
  _LegalSection(
    '3. Account Accuracy',
    'You represent and warrant that the name, email, phone number, and address provided are accurate and belong to you. Providing fraudulent or stolen credentials will lead to immediate suspension.',
  ),
  _LegalSection(
    '4. Booking & Cancellation Policies',
    'Bookings made on FindBookStay are subject to the specific cancellation window defined on the property or turf listing at checkout time.',
  ),
];

const List<_LegalSection> _privacySections = [
  _LegalSection(
    '1. Information We Collect',
    'We collect details you provide during registration including full name, email address, phone number, physical address details, and profile photos to facilitate seamless booking experiences.',
  ),
  _LegalSection(
    '2. How We Protect Your Data',
    'Passwords and sensitive security credentials are encrypted using industry-standard hashing before storage. We will never sell your personal information to third parties.',
  ),
  _LegalSection(
    '3. Location & Address Usage',
    'Your address details are utilized exclusively to match nearby verified properties, turfs, and stays, and to verify account authenticity.',
  ),
];
