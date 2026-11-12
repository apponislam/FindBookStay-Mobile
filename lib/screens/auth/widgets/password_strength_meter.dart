import 'package:google_fonts/google_fonts.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/theme/app_colors.dart';

/// 4-segment animated real-time password strength meter.
/// Evaluates length, uppercase, numbers, and symbols (Red -> Amber -> Green).
class PasswordStrengthMeter extends StatelessWidget {
  final String password;

  const PasswordStrengthMeter({super.key, required this.password});

  int get _score {
    if (password.isEmpty) return 0;
    int score = 0;
    if (password.length >= 8) score++;
    if (RegExp(r'[A-Z]').hasMatch(password)) score++;
    if (RegExp(r'[0-9]').hasMatch(password)) score++;
    if (RegExp(r'[^A-Za-z0-9]').hasMatch(password)) score++;
    return score;
  }

  Color _getSegmentColor(int index, int score) {
    if (index >= score) return AppColors.borderSubtle;
    if (score <= 1) return AppColors.error;
    if (score == 2) return AppColors.warning;
    if (score == 3) return const Color(0xFF34D399); // Soft emerald
    return AppColors.accent; // Full mint
  }

  String get _strengthLabel {
    final score = _score;
    if (password.isEmpty) return 'Enter password';
    if (score <= 1) return 'Weak password';
    if (score == 2) return 'Fair password';
    if (score == 3) return 'Good password';
    return 'Strong password';
  }

  Color get _labelColor {
    final score = _score;
    if (password.isEmpty) return AppColors.textMuted;
    if (score <= 1) return AppColors.error;
    if (score == 2) return AppColors.warning;
    return AppColors.accent;
  }

  @override
  Widget build(BuildContext context) {
    final score = _score;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Row(
          children: List.generate(4, (index) {
            return Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 280),
                height: 4,
                margin: EdgeInsets.only(
                  right: index < 3 ? 6.0 : 0.0,
                ),
                decoration: BoxDecoration(
                  color: _getSegmentColor(index, score),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _strengthLabel,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: _labelColor,
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                'Min 8 chars, 1 number',
                textAlign: TextAlign.right,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  color: AppColors.textMuted,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
