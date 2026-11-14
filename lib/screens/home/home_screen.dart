import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/services/auth_service.dart';
import '../../core/theme/app_colors.dart';
import 'tabs/bookings_tab.dart';
import 'tabs/explore_tab.dart';
import 'tabs/inbox_tab.dart';
import 'tabs/profile_tab.dart';
import 'tabs/saved_tab.dart';

/// Main destination screen featuring an elevated, smoothly animated bottom navigation bar.
/// Dynamically adapts tabs, badges, and capabilities for Signed-In vs Guest users.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _tabs = const [
    ExploreTab(),
    SavedTab(),
    BookingsTab(),
    InboxTab(),
    ProfileTab(),
  ];

  void _onTabSelected(int index) {
    if (_currentIndex == index) return;
    HapticFeedback.selectionClick();
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AuthService.instance,
      builder: (context, _) {
        final isLoggedIn = AuthService.instance.isLoggedIn;

        return Scaffold(
          backgroundColor: AppColors.background,
          body: IndexedStack(
            index: _currentIndex,
            children: _tabs,
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(
                  color: AppColors.border,
                  width: 1.0,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryDark.withValues(alpha: 0.08),
                  blurRadius: 16,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: SizedBox(
                height: 64,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildNavItem(
                      index: 0,
                      label: 'Explore',
                      activeIcon: Icons.explore_rounded,
                      inactiveIcon: Icons.explore_outlined,
                    ),
                    _buildNavItem(
                      index: 1,
                      label: 'Saved',
                      activeIcon: Icons.favorite_rounded,
                      inactiveIcon: Icons.favorite_outline_rounded,
                    ),
                    _buildNavItem(
                      index: 2,
                      label: 'Bookings',
                      activeIcon: Icons.calendar_month_rounded,
                      inactiveIcon: Icons.calendar_month_outlined,
                    ),
                    _buildNavItem(
                      index: 3,
                      label: 'Inbox',
                      activeIcon: Icons.chat_bubble_rounded,
                      inactiveIcon: Icons.chat_bubble_outline_rounded,
                      badgeCount: isLoggedIn ? 2 : 0,
                    ),
                    _buildNavItem(
                      index: 4,
                      label: isLoggedIn ? 'Profile' : 'Account',
                      activeIcon: Icons.person_rounded,
                      inactiveIcon: Icons.person_outline_rounded,
                      isUserAvatar: isLoggedIn,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNavItem({
    required int index,
    required String label,
    required IconData activeIcon,
    required IconData inactiveIcon,
    int badgeCount = 0,
    bool isUserAvatar = false,
  }) {
    final bool isSelected = _currentIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => _onTabSelected(index),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Floating Animated Icon Container (Moves Up and Gets Bigger on Select)
            AnimatedContainer(
              duration: const Duration(milliseconds: 240),
              curve: Curves.easeOutCubic,
              transform: Matrix4.translationValues(
                0,
                isSelected ? -6.0 : 0.0,
                0,
              ),
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 240),
                    curve: Curves.easeOutCubic,
                    width: isSelected ? 40 : 34,
                    height: isSelected ? 40 : 34,
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        isSelected ? activeIcon : inactiveIcon,
                        size: isSelected ? 23 : 21,
                        color: isSelected
                            ? Colors.white
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),

                  // Notification Badge (for Inbox or notifications)
                  if (badgeCount > 0)
                    Positioned(
                      top: isSelected ? -2 : -2,
                      right: isSelected ? -2 : -4,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.accent : AppColors.primary,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 1.5,
                          ),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Center(
                          child: Text(
                            '$badgeCount',
                            style: GoogleFonts.plusJakartaSans(
                              color: isSelected ? AppColors.primaryDark : Colors.white,
                              fontSize: 9.0,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 1),

            // Animated Label
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              style: GoogleFonts.plusJakartaSans(
                fontSize: isSelected ? 11.5 : 10.5,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                letterSpacing: isSelected ? 0.2 : 0.0,
              ),
              child: Text(label),
            ),

            const SizedBox(height: 2),

            // Animated Mint Active Dot Indicator
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              width: isSelected ? 12.0 : 0.0,
              height: 2.5,
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
