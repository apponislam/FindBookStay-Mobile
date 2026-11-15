import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/theme/app_colors.dart';

/// Production-ready custom authentication input field.
/// Features a 52px height container, rounded corners (16px), smooth focus ring,
/// animated password visibility toggle, and an upper-side custom error badge with a downward triangle pointer.
class CustomAuthInput extends StatefulWidget {
  final String label;
  final String? hint;
  final IconData prefixIcon;
  final TextEditingController? controller;
  final bool isPassword;
  final bool isRequired;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? errorMessage;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onEditingComplete;
  final FocusNode? focusNode;

  const CustomAuthInput({
    super.key,
    required this.label,
    this.hint,
    required this.prefixIcon,
    this.controller,
    this.isPassword = false,
    this.isRequired = false,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.errorMessage,
    this.onChanged,
    this.onEditingComplete,
    this.focusNode,
  });

  @override
  State<CustomAuthInput> createState() => _CustomAuthInputState();
}

class _CustomAuthInputState extends State<CustomAuthInput> {
  late bool _obscureText;
  late FocusNode _internalFocusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
    _internalFocusNode = widget.focusNode ?? FocusNode();
    _internalFocusNode.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    setState(() {
      _isFocused = _internalFocusNode.hasFocus;
    });
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _internalFocusNode.dispose();
    } else {
      _internalFocusNode.removeListener(_handleFocusChange);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool hasError = widget.errorMessage != null && widget.errorMessage!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label Row with Upper-Side Warning Badge
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Label with optional asterisk
            Flexible(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      widget.label,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: hasError ? AppColors.error : AppColors.textPrimary,
                        letterSpacing: 0.1,
                      ),
                    ),
                  ),
                  if (widget.isRequired)
                    Padding(
                      padding: const EdgeInsets.only(left: 3.0),
                      child: Text(
                        '*',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppColors.error,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Animated Warning Badge with Downward Pointer
            AnimatedSize(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              child: hasError
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 3.5,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.error,
                            borderRadius: BorderRadius.circular(6),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.error.withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.warning_amber_rounded,
                                size: 12,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                widget.errorMessage!,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Downward pointing arrow triangle directly into the red border
                        Padding(
                          padding: const EdgeInsets.only(right: 14.0),
                          child: CustomPaint(
                            size: const Size(8, 5),
                            painter: _TrianglePainter(color: AppColors.error),
                          ),
                        ),
                      ],
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),

        const SizedBox(height: 5),

        // 52px Rounded Input Container with Red Warning Border on Error
        AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          height: 52.0,
          decoration: BoxDecoration(
            color: _isFocused ? AppColors.background : AppColors.surface,
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(
              color: hasError
                  ? AppColors.error
                  : (_isFocused ? AppColors.accent : AppColors.border),
              width: hasError ? 1.8 : (_isFocused ? 1.6 : 1.0),
            ),
            boxShadow: hasError
                ? [
                    BoxShadow(
                      color: AppColors.error.withValues(alpha: 0.12),
                      blurRadius: 10.0,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : (_isFocused
                    ? [
                        BoxShadow(
                          color: AppColors.accent.withValues(alpha: 0.12),
                          blurRadius: 8.0,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null),
          ),
          child: Center(
            child: TextField(
              controller: widget.controller,
              focusNode: _internalFocusNode,
              obscureText: _obscureText,
              keyboardType: widget.keyboardType,
              inputFormatters: widget.inputFormatters,
              onChanged: widget.onChanged,
              onEditingComplete: widget.onEditingComplete,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14.5,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: widget.hint,
                hintStyle: GoogleFonts.plusJakartaSans(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textMuted,
                ),
                prefixIcon: Icon(
                  widget.prefixIcon,
                  size: 20,
                  color: hasError
                      ? AppColors.error
                      : (_isFocused ? AppColors.accent : AppColors.textSecondary),
                ),
                suffixIcon: widget.isPassword
                    ? IconButton(
                        splashRadius: 20,
                        icon: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 240),
                          transitionBuilder: (child, animation) {
                            return RotationTransition(
                              turns: Tween<double>(begin: 0.85, end: 1.0).animate(animation),
                              child: FadeTransition(opacity: animation, child: child),
                            );
                          },
                          child: Icon(
                            _obscureText
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            key: ValueKey<bool>(_obscureText),
                            size: 20,
                            color: hasError
                                ? AppColors.error
                                : (_isFocused ? AppColors.primary : AppColors.textSecondary),
                          ),
                        ),
                        onPressed: () {
                          HapticFeedback.selectionClick();
                          setState(() {
                            _obscureText = !_obscureText;
                          });
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Draws downward pointer triangle for the warning badge
class _TrianglePainter extends CustomPainter {
  final Color color;

  const _TrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _TrianglePainter oldDelegate) =>
      oldDelegate.color != color;
}
