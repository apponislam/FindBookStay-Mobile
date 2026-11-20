import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/services/auth_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/theme_controller.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';
import 'tabs/bookings_tab.dart';
import 'tabs/explore_tab.dart';
import 'tabs/inbox_tab.dart';
import 'tabs/profile_tab.dart';
import 'tabs/saved_tab.dart';

/// Main destination screen featuring an elevated, smoothly animated bottom navigation bar.
/// Dynamically adapts tabs, badges, and capabilities for Signed-In vs Guest users.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
      }
    });
  }

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
    final riverpodAuth = ref.watch(isAuthenticatedProvider);
    ref.watch(themeModeProvider);

    return ListenableBuilder(
      listenable: AuthService.instance,
      builder: (context, _) {
        final isLoggedIn = riverpodAuth || AuthService.instance.isLoggedIn;

        return Scaffold(
          backgroundColor: AppColors.background,
          body: IndexedStack(
            index: _currentIndex,
            children: _tabs,
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              border: Border(
                top: BorderSide(
                  color: AppColors.border,
                  width: 1.0,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryDark.withValues(alpha: 0.08),
                  blurRadius: 18,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: SizedBox(
                height: 70,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _NavBarItem(
                      index: 0,
                      label: 'Explore',
                      activeIcon: Icons.explore_rounded,
                      inactiveIcon: Icons.explore_outlined,
                      isSelected: _currentIndex == 0,
                      onTap: () => _onTabSelected(0),
                    ),
                    _NavBarItem(
                      index: 1,
                      label: 'Saved',
                      activeIcon: Icons.favorite_rounded,
                      inactiveIcon: Icons.favorite_outline_rounded,
                      isSelected: _currentIndex == 1,
                      onTap: () => _onTabSelected(1),
                    ),
                    _NavBarItem(
                      index: 2,
                      label: 'Bookings',
                      activeIcon: Icons.calendar_month_rounded,
                      inactiveIcon: Icons.calendar_month_outlined,
                      isSelected: _currentIndex == 2,
                      onTap: () => _onTabSelected(2),
                    ),
                    _NavBarItem(
                      index: 3,
                      label: 'Inbox',
                      activeIcon: Icons.chat_bubble_rounded,
                      inactiveIcon: Icons.chat_bubble_outline_rounded,
                      badgeCount: isLoggedIn ? 2 : 0,
                      isSelected: _currentIndex == 3,
                      onTap: () => _onTabSelected(3),
                    ),
                    _NavBarItem(
                      index: 4,
                      label: isLoggedIn ? 'Profile' : 'Account',
                      activeIcon: Icons.person_rounded,
                      inactiveIcon: Icons.person_outline_rounded,
                      isSelected: _currentIndex == 4,
                      onTap: () => _onTabSelected(4),
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
}

// ---------------------------------------------------------------------------
// Enhanced Interactive & Animated Bottom Navigation Item
// ---------------------------------------------------------------------------

class _NavBarItem extends StatefulWidget {
  final int index;
  final String label;
  final IconData activeIcon;
  final IconData inactiveIcon;
  final int badgeCount;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.index,
    required this.label,
    required this.activeIcon,
    required this.inactiveIcon,
    required this.isSelected,
    required this.onTap,
    this.badgeCount = 0,
  });

  @override
  State<_NavBarItem> createState() => _NavBarItemState();
}

class _NavBarItemState extends State<_NavBarItem> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final bool isSelected = widget.isSelected;

    return Expanded(
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) => setState(() => _isPressed = false),
          onTapCancel: () => setState(() => _isPressed = false),
          onTap: widget.onTap,
          behavior: HitTestBehavior.opaque,
          child: AnimatedScale(
            scale: _isPressed ? 0.92 : (_isHovered && !isSelected ? 1.06 : 1.0),
            duration: const Duration(milliseconds: 120),
            curve: Curves.easeOutCubic,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Floating Active Pod (Moves Up & Scales smoothly on Select)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 240),
                  curve: Curves.easeOutCubic,
                  transform: Matrix4.translationValues(
                    0,
                    isSelected ? -5.0 : 0.0,
                    0,
                  ),
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: [
                      // Smooth Drop Shadow for Active Pod (Faded via AnimatedOpacity to prevent BoxShadow.lerp assertion)
                      Positioned.fill(
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 240),
                          opacity: isSelected ? 1.0 : 0.0,
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.28),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Circular Pod with Accent Ring
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 240),
                        curve: Curves.easeOutCubic,
                        width: isSelected ? 42 : 36,
                        height: isSelected ? 42 : 36,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary
                              : (_isHovered
                                  ? AppColors.accentLight.withValues(alpha: 0.6)
                                  : Colors.transparent),
                          shape: BoxShape.circle,
                          border: isSelected
                              ? Border.all(
                                  color: AppColors.accent,
                                  width: 1.5,
                                )
                              : (_isHovered
                                  ? Border.all(
                                      color: AppColors.accent.withValues(alpha: 0.3),
                                      width: 1.0,
                                    )
                                  : null),
                        ),
                        child: Center(
                          child: Icon(
                            isSelected ? widget.activeIcon : widget.inactiveIcon,
                            size: isSelected ? 22 : 21,
                            color: isSelected
                                ? Colors.white
                                : (_isHovered
                                    ? AppColors.primary
                                    : AppColors.textSecondary),
                          ),
                        ),
                      ),

                      // Notification Badge
                      if (widget.badgeCount > 0)
                        Positioned(
                          top: isSelected ? -3 : -2,
                          right: isSelected ? -3 : -4,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.accent,
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
                                '${widget.badgeCount}',
                                style: GoogleFonts.plusJakartaSans(
                                  color: AppColors.primaryDark,
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

                const SizedBox(height: 2),

                // Animated Label with Text Scaler Protection
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: isSelected ? 11.5 : 10.5,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                      color: isSelected
                          ? AppColors.primary
                          : (_isHovered
                              ? AppColors.textPrimary
                              : AppColors.textSecondary),
                      letterSpacing: isSelected ? 0.2 : 0.0,
                    ),
                    child: Text(
                      widget.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),

                const SizedBox(height: 2),

                // Active Mint Indicator Pill
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOutCubic,
                  width: isSelected ? 14.0 : 0.0,
                  height: 2.5,
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
