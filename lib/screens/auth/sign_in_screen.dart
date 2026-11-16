import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/theme/app_colors.dart';
import '../../features/auth/domain/auth_state.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';
import '../home/home_screen.dart';
import 'forgot_password_screen.dart';
import 'register_form_screen.dart';
import 'widgets/custom_auth_input.dart';

/// Production-ready Sign In Screen powered by Riverpod and Dio.
class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  late final AnimationController _glowController;
  late final Animation<double> _glowAnimation;

  String? _emailError;
  String? _passwordError;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _glowAnimation = Tween<double>(begin: 0.25, end: 0.65).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _glowController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onSignIn() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    setState(() {
      if (email.isEmpty) {
        _emailError = 'Email address is required';
      } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
        _emailError = 'Please enter a valid email';
      } else {
        _emailError = null;
      }

      if (password.isEmpty) {
        _passwordError = 'Password is required';
      } else if (password.length < 6) {
        _passwordError = 'Min. 6 characters required';
      } else {
        _passwordError = null;
      }
    });

    if (_emailError != null || _passwordError != null) {
      HapticFeedback.mediumImpact();
      return;
    }

    final success = await ref.read(authControllerProvider.notifier).login(
      email: email,
      password: password,
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenOnboarding', true);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).clearSnackBars();
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    } else {
      final error = ref.read(authErrorProvider);
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Invalid email or password.'),
          backgroundColor: AppColors.error,
          duration: const Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Interactive Glowing "Welcome Back" Badge
  // ---------------------------------------------------------------------------
  Widget _buildGlowingWelcomeBadge() {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, _) {
        return InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 14.0,
              vertical: 6.5,
            ),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFE8F8F3), Color(0xFFD6F3EA)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.accent.withValues(alpha: 0.45),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accent.withValues(alpha: _glowAnimation.value * 0.7),
                  blurRadius: 12 + (_glowAnimation.value * 6),
                  spreadRadius: 1.5,
                ),
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.06),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 7.5,
                  height: 7.5,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.accent,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accent.withValues(alpha: _glowAnimation.value),
                        blurRadius: 6,
                        spreadRadius: 1.2,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Welcome Back',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                    letterSpacing: 0.4,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Modern Glowing Sign In CTA Button
  // ---------------------------------------------------------------------------
  Widget _buildGlowingSignInButton({required bool isLoading}) {
    return Container(
      height: 54,
      width: double.infinity,
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
            color: AppColors.accent.withValues(alpha: 0.16),
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
                  _onSignIn();
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
                        'Sign In',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        size: 20,
                        color: AppColors.accent,
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authStatusProvider) == AuthStatus.loading;
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
        child: Stack(
          children: [
            // Ambient glowing gradient orb (top-right)
            Positioned(
              top: -40,
              right: -40,
              child: IgnorePointer(
                child: Container(
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.accent.withValues(alpha: 0.14),
                        AppColors.accentLight.withValues(alpha: 0.05),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.55, 1.0],
                    ),
                  ),
                ),
              ),
            ),

            // Ambient glowing soft accent (bottom-left)
            Positioned(
              bottom: -50,
              left: -50,
              child: IgnorePointer(
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.primary.withValues(alpha: 0.04),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Main scrollable content
            LayoutBuilder(
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
                            // Interactive Glowing Welcome Back Badge
                            _buildGlowingWelcomeBadge(),

                            const SizedBox(height: 16),

                            Text(
                              'Sign In to Account',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 29,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                                letterSpacing: -0.7,
                              ),
                            ),

                            const SizedBox(height: 8),

                            Text(
                              'Sign in to access your verified rentals, boutique stays, turf slots, and account preferences.',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w400,
                                color: AppColors.textSecondary,
                                height: 1.45,
                              ),
                            ),

                            const SizedBox(height: 32),

                            // Email Input (Required)
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

                            // Password Input (Required)
                            CustomAuthInput(
                              label: 'Password',
                              hint: '••••••••',
                              prefixIcon: Icons.lock_outline_rounded,
                              isPassword: true,
                              isRequired: true,
                              controller: _passwordController,
                              errorMessage: _passwordError,
                              onChanged: (_) {
                                if (_passwordError != null) {
                                  setState(() => _passwordError = null);
                                }
                              },
                            ),

                            const SizedBox(height: 12),

                            // Forgot Password link
                            Align(
                              alignment: Alignment.centerRight,
                              child: GestureDetector(
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => const ForgotPasswordScreen(),
                                    ),
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                                  child: Text(
                                    'Forgot password?',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 32),

                            // Glowing Sign In CTA
                            _buildGlowingSignInButton(isLoading: isLoading),

                            const SizedBox(height: 24),

                            // Don't have an account? Sign Up link
                            Center(
                              child: GestureDetector(
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => const RegisterFormScreen(),
                                    ),
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                                  child: RichText(
                                    text: TextSpan(
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 13.5,
                                        color: AppColors.textSecondary,
                                      ),
                                      children: const [
                                        TextSpan(text: "Don't have an account? "),
                                        TextSpan(
                                          text: 'Sign Up',
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
          ],
        ),
      ),
    );
  }
}
