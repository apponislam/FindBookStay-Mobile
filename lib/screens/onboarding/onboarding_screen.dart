import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/theme/app_colors.dart';
import '../../models/onboarding_item.dart';
import '../auth/sign_in_screen.dart';
import '../home/home_screen.dart';
import 'widgets/animated_page_indicator.dart';
import 'widgets/onboarding_slide_widget.dart';

/// Production-ready modern Onboarding Screen experience for FindBookStay
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  final List<OnboardingItem> _slides = OnboardingItem.items;
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// Mark onboarding as completed in SharedPreferences and route to HomeScreen
  Future<void> _completeOnboarding() async {
    HapticFeedback.lightImpact();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenOnboarding', true);

    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, _, _) => const HomeScreen(),
          transitionsBuilder: (_, animation, _, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 350),
        ),
      );
    }
  }

  /// Navigate to next slide or complete if on final slide
  void _onNextPressed() {
    HapticFeedback.lightImpact();
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _completeOnboarding();
    }
  }

  /// Navigate directly to Sign In screen
  void _onSignInPressed() {
    HapticFeedback.lightImpact();
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const SignInScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final bool isLastPage = _currentPage == _slides.length - 1;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SizedBox(
              width: double.infinity,
              height: constraints.maxHeight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                // 1. Top Header: Minimalist Logo/Wordmark + Skip Button
                _buildHeader(context),

                // 2. Multi-Step PageView with micro-interaction curves
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _slides.length,
                    physics: const ClampingScrollPhysics(),
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                      HapticFeedback.lightImpact();
                    },
                    itemBuilder: (context, index) {
                      return AnimatedBuilder(
                        animation: _pageController,
                        builder: (context, child) {
                          double value = 1.0;
                          if (_pageController.position.haveDimensions) {
                            value = (_pageController.page ?? 0) - index;
                            value = (1 - (value.abs() * 0.25)).clamp(0.0, 1.0);
                          }
                          return Opacity(opacity: value, child: child);
                        },
                        child: OnboardingSlideWidget(item: _slides[index]),
                      );
                    },
                  ),
                ),

                // 3. Smooth Expanding Pill Page Indicator
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: AnimatedPageIndicator(
                    count: _slides.length,
                    currentIndex: _currentPage,
                    onDotTapped: (index) {
                      HapticFeedback.lightImpact();
                      _pageController.animateToPage(
                        index,
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOutCubic,
                      );
                    },
                  ),
                ),

                // 4. Bottom Action Area (Primary CTA + Secondary Sign In)
                _buildBottomControls(isLastPage),
              ],
            ),
          );
        },
        ),
      ),
    );
  }

  /// Top Header: Centered Logo + Wordmark with Skip button on the right
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      child: SizedBox(
        width: double.infinity,
        height: 44.0,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Center Brand Logo & Wordmark (Dead Middle)
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(9),
                    child: Image.asset(
                      'assets/images/icon.png',
                      width: 30,
                      height: 30,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: const Icon(
                          Icons.maps_home_work_rounded,
                          size: 16,
                          color: AppColors.accent,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  RichText(
                    text: TextSpan(
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                        letterSpacing: -0.3,
                      ),
                      children: const [
                        TextSpan(text: 'FindBookStay'),
                        TextSpan(
                          text: '.',
                          style: TextStyle(
                            color: AppColors.accent,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // "Skip" Button placed on the far right
            Positioned(
              right: 0,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 250),
                opacity: _currentPage == _slides.length - 1 ? 0.0 : 1.0,
                child: TextButton(
                  onPressed: _currentPage == _slides.length - 1
                      ? null
                      : _completeOnboarding,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Skip',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Bottom Controls: Main Rounded CTA + Sign In secondary link
  Widget _buildBottomControls(bool isLastPage) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 24.0,
        right: 24.0,
        bottom: 20.0,
        top: 6.0,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Primary CTA Button
          SizedBox(
            width: double.infinity,
            height: 54.0,
            child: ElevatedButton(
              onPressed: _onNextPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 260),
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.08, 0.0),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: Row(
                  key: ValueKey<bool>(isLastPage),
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      isLastPage ? 'Get Started' : 'Next',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textWhite,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    Icon(
                      isLastPage
                          ? Icons.check_circle_outline_rounded
                          : Icons.arrow_forward_rounded,
                      size: 20.0,
                      color: AppColors.accent,
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 14.0),

          // Secondary "Already have an account? Sign In" Button
          Center(
            child: GestureDetector(
              onTap: _onSignInPressed,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: RichText(
                  textAlign: TextAlign.center,
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
    );
  }
}
