import 'package:material_ui/material_ui.dart';

import '../../../core/theme/app_colors.dart';

/// Smooth expanding pill page indicator
/// Active page is an emerald pill (width 28px), inactive pages are 8px subtle circles.
class AnimatedPageIndicator extends StatelessWidget {
  final int count;
  final int currentIndex;
  final ValueChanged<int>? onDotTapped;

  const AnimatedPageIndicator({
    super.key,
    required this.count,
    required this.currentIndex,
    this.onDotTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final bool isActive = index == currentIndex;

        return GestureDetector(
          onTap: onDotTapped != null ? () => onDotTapped!(index) : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 320),
            curve: Curves.easeInOutCubic,
            margin: const EdgeInsets.symmetric(horizontal: 4.0),
            height: 8.0,
            width: isActive ? 28.0 : 8.0,
            decoration: BoxDecoration(
              color: isActive ? AppColors.accent : AppColors.border,
              borderRadius: BorderRadius.circular(4.0),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: AppColors.accent.withOpacity(0.35),
                        blurRadius: 8.0,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
          ),
        );
      }),
    );
  }
}
