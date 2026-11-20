import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/theme/app_colors.dart';

/// Production-ready Squircle OTP code input with single-field architecture:
/// - Smooth backwards backspace without needing to tap individual boxes
/// - Auto-replace on typing when all digits are full or on error
/// - Native SMS autofill & clipboard paste support
/// - Visual squircle boxes with active glowing focus indicators & error states
class OtpDigitInput extends StatefulWidget {
  final int length;
  final ValueChanged<String> onCompleted;
  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;
  final bool hasError;
  final bool autoFocus;

  const OtpDigitInput({
    super.key,
    this.length = 6,
    required this.onCompleted,
    this.onChanged,
    this.controller,
    this.hasError = false,
    this.autoFocus = true,
  });

  @override
  State<OtpDigitInput> createState() => OtpDigitInputState();
}

class OtpDigitInputState extends State<OtpDigitInput> {
  late TextEditingController _effectiveController;
  late FocusNode _focusNode;
  bool _isInternalController = false;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _effectiveController = widget.controller!;
    } else {
      _effectiveController = TextEditingController();
      _isInternalController = true;
    }
    _focusNode = FocusNode();
    _effectiveController.addListener(_handleTextChange);

    if (widget.autoFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _focusNode.requestFocus();
      });
    }
  }

  @override
  void didUpdateWidget(OtpDigitInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      _effectiveController.removeListener(_handleTextChange);
      if (_isInternalController) {
        _effectiveController.dispose();
      }
      if (widget.controller != null) {
        _effectiveController = widget.controller!;
        _isInternalController = false;
      } else {
        _effectiveController = TextEditingController();
        _isInternalController = true;
      }
      _effectiveController.addListener(_handleTextChange);
    }

    // Auto-select text on error so next keystroke or backspace clears/replaces it immediately
    if (widget.hasError && !oldWidget.hasError && _effectiveController.text.isNotEmpty) {
      _effectiveController.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _effectiveController.text.length,
      );
    }
  }

  @override
  void dispose() {
    _effectiveController.removeListener(_handleTextChange);
    if (_isInternalController) {
      _effectiveController.dispose();
    }
    _focusNode.dispose();
    super.dispose();
  }

  void _handleTextChange() {
    final text = _effectiveController.text;
    widget.onChanged?.call(text);
    if (text.length == widget.length) {
      widget.onCompleted(text);
    }
    if (mounted) {
      setState(() {});
    }
  }

  /// Programmatically clear all digits and focus first box
  void clear() {
    _effectiveController.clear();
    _focusNode.requestFocus();
  }

  /// Programmatically request focus
  void requestFocus() {
    _focusNode.requestFocus();
  }

  /// Programmatically paste code
  void pasteCode(String rawCode) {
    final digits = rawCode.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return;
    HapticFeedback.mediumImpact();
    final capped = digits.length > widget.length ? digits.substring(0, widget.length) : digits;
    _effectiveController.text = capped;
    _effectiveController.selection = TextSelection.collapsed(offset: capped.length);
  }

  void _handleTap() {
    _focusNode.requestFocus();
    if (widget.hasError && _effectiveController.text.isNotEmpty) {
      _effectiveController.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _effectiveController.text.length,
      );
    } else {
      _effectiveController.selection = TextSelection.collapsed(
        offset: _effectiveController.text.length,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: _handleTap,
      behavior: HitTestBehavior.opaque,
      child: Stack(
        children: [
          // ── Visible Squircle Boxes ─────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(widget.length, (index) {
              final text = _effectiveController.text;
              final bool hasDigit = index < text.length;
              final String digit = hasDigit ? text[index] : '';

              // Active focused box is the box awaiting input or the last box if full
              final bool isFocused = _focusNode.hasFocus &&
                  ((index == text.length) ||
                      (index == widget.length - 1 && text.length == widget.length));

              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: index == 0 ? 0 : 3.5,
                    right: index == widget.length - 1 ? 0 : 3.5,
                  ),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOutCubic,
                    height: 56.0,
                    decoration: BoxDecoration(
                      color: widget.hasError
                          ? AppColors.error.withValues(alpha: isDark ? 0.15 : 0.05)
                          : (isFocused
                              ? (isDark ? AppColors.darkSurface : AppColors.background)
                              : (hasDigit
                                  ? (isDark ? AppColors.darkAccentLight : AppColors.accentLight)
                                  : (isDark ? AppColors.darkCard : AppColors.surface))),
                      borderRadius: BorderRadius.circular(15.0),
                      border: Border.all(
                        color: widget.hasError
                            ? AppColors.error
                            : (isFocused
                                ? AppColors.accent
                                : (hasDigit
                                    ? (isDark ? AppColors.accent : AppColors.primary)
                                    : (isDark ? AppColors.darkBorder : AppColors.border))),
                        width: isFocused || widget.hasError ? 2.0 : 1.2,
                      ),
                      boxShadow: isFocused
                          ? [
                              BoxShadow(
                                color: widget.hasError
                                    ? AppColors.error.withValues(alpha: 0.20)
                                    : AppColors.accent.withValues(alpha: isDark ? 0.28 : 0.20),
                                blurRadius: 8.0,
                                offset: const Offset(0, 3),
                              ),
                            ]
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        digit,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 22.0,
                          fontWeight: FontWeight.w800,
                          color: widget.hasError
                              ? AppColors.error
                              : (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),

          // ── Transparent Single Input Layer (Receives typing & backspace) ──
          Positioned.fill(
            child: TextField(
              controller: _effectiveController,
              focusNode: _focusNode,
              keyboardType: TextInputType.number,
              autofillHints: const [AutofillHints.oneTimeCode],
              enableInteractiveSelection: false,
              showCursor: false,
              cursorColor: Colors.transparent,
              style: const TextStyle(
                color: Colors.transparent,
                fontSize: 1,
                height: 1,
              ),
              inputFormatters: [
                _OtpSmartInputFormatter(maxLength: widget.length),
              ],
              decoration: const InputDecoration(
                border: InputBorder.none,
                counterText: '',
                fillColor: Colors.transparent,
                filled: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Smart formatter that supports continuous typing, rapid backspacing,
/// paste distribution, and instant replacement when full.
class _OtpSmartInputFormatter extends TextInputFormatter {
  final int maxLength;

  _OtpSmartInputFormatter({required this.maxLength});

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final cleanDigits = newValue.text.replaceAll(RegExp(r'\D'), '');

    // Case 1: When user types another digit while code is already 6 digits full
    if (cleanDigits.length > maxLength) {
      final addedCount = newValue.text.length - oldValue.text.length;
      if (addedCount >= 4) {
        // Multi-digit paste into full field: replace with first maxLength characters
        final pastePortion = cleanDigits.substring(0, maxLength);
        return TextEditingValue(
          text: pastePortion,
          selection: TextSelection.collapsed(offset: pastePortion.length),
        );
      }

      // Single digit typed into full field: start fresh with the newly typed digit!
      final lastTyped = cleanDigits.substring(cleanDigits.length - 1);
      return TextEditingValue(
        text: lastTyped,
        selection: const TextSelection.collapsed(offset: 1),
      );
    }

    return TextEditingValue(
      text: cleanDigits,
      selection: TextSelection.collapsed(offset: cleanDigits.length),
    );
  }
}
