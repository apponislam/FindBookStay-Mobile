import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/theme/app_colors.dart';

/// 6-digit squircle OTP code input with auto-advance, backspace, and full paste support.
class OtpDigitInput extends StatefulWidget {
  final int length;
  final ValueChanged<String> onCompleted;
  final ValueChanged<String>? onChanged;

  const OtpDigitInput({
    super.key,
    this.length = 6,
    required this.onCompleted,
    this.onChanged,
  });

  @override
  State<OtpDigitInput> createState() => OtpDigitInputState();
}

class OtpDigitInputState extends State<OtpDigitInput> {
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(widget.length, (_) => TextEditingController());
    _focusNodes = List.generate(widget.length, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  /// Programmatically paste or fill code across all boxes
  void pasteCode(String rawCode) {
    _fillDigits(rawCode);
  }

  void _fillDigits(String rawDigits) {
    final digits = rawDigits.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return;

    HapticFeedback.mediumImpact();

    // Distribute digits into all boxes
    for (int i = 0; i < widget.length; i++) {
      if (i < digits.length) {
        _controllers[i].text = digits[i];
      } else {
        _controllers[i].clear();
      }
    }

    final filledCount = digits.length.clamp(0, widget.length);
    if (filledCount == widget.length) {
      _focusNodes.last.unfocus();
    } else {
      _focusNodes[filledCount].requestFocus();
    }

    final fullCode = _controllers.map((c) => c.text).join();
    widget.onChanged?.call(fullCode);
    if (fullCode.length == widget.length) {
      widget.onCompleted(fullCode);
    }
  }

  void _onDigitChanged(int index, String value) {
    final digits = value.replaceAll(RegExp(r'\D'), '');

    // Case 1: Multi-digit paste detected (pasting 6-digit OTP into any box)
    if (digits.length >= 4 || digits.length >= widget.length) {
      _fillDigits(digits);
      return;
    }

    // Case 2: User typed over an existing digit (value has 2 digits)
    if (digits.length > 1) {
      HapticFeedback.lightImpact();
      final newChar = digits.substring(digits.length - 1);
      _controllers[index].text = newChar;
      if (index < widget.length - 1) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
      }
    } else if (digits.length == 1) {
      // Case 3: Single digit typed
      HapticFeedback.lightImpact();
      _controllers[index].text = digits;
      if (index < widget.length - 1) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
      }
    } else {
      // Case 4: Cleared
      _controllers[index].clear();
    }

    final fullCode = _controllers.map((c) => c.text).join();
    widget.onChanged?.call(fullCode);
    if (fullCode.length == widget.length) {
      widget.onCompleted(fullCode);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(widget.length, (index) {
        final controller = _controllers[index];
        final focusNode = _focusNodes[index];

        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              left: index == 0 ? 0 : 3.5,
              right: index == widget.length - 1 ? 0 : 3.5,
            ),
            child: Focus(
              onKeyEvent: (node, event) {
                if (event is KeyDownEvent &&
                    event.logicalKey == LogicalKeyboardKey.backspace &&
                    controller.text.isEmpty &&
                    index > 0) {
                  _focusNodes[index - 1].requestFocus();
                  _controllers[index - 1].selection = TextSelection.fromPosition(
                    TextPosition(offset: _controllers[index - 1].text.length),
                  );
                }
                return KeyEventResult.ignored;
              },
              child: AnimatedBuilder(
                animation: Listenable.merge([focusNode, controller]),
                builder: (context, _) {
                  final bool isFocused = focusNode.hasFocus;
                  final bool hasValue = controller.text.isNotEmpty;

                  return Container(
                    height: 56.0,
                    decoration: BoxDecoration(
                      color: isFocused
                          ? AppColors.background
                          : (hasValue ? AppColors.accentLight : AppColors.surface),
                      borderRadius: BorderRadius.circular(15.0),
                      border: Border.all(
                        color: isFocused
                            ? AppColors.accent
                            : (hasValue ? AppColors.primary : AppColors.border),
                        width: isFocused ? 2.0 : 1.2,
                      ),
                      boxShadow: isFocused
                          ? [
                              BoxShadow(
                                color: AppColors.accent.withValues(alpha: 0.18),
                                blurRadius: 8.0,
                                offset: const Offset(0, 3),
                              ),
                            ]
                          : null,
                    ),
                    child: Center(
                      child: TextField(
                        controller: controller,
                        focusNode: focusNode,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        enableInteractiveSelection: true,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        onChanged: (val) => _onDigitChanged(index, val),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 22.0,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                        decoration: const InputDecoration(
                          counterText: '',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      }),
    );
  }
}
