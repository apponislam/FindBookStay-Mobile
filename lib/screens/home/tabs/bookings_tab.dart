import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/services/auth_service.dart';
import '../../../core/theme/app_colors.dart';
import '../widgets/guest_auth_gate_card.dart';

/// Bookings / Reservations Tab:
/// Shows active & upcoming bookings when signed in, or auth gate when guest.
class BookingsTab extends StatefulWidget {
  const BookingsTab({super.key});

  @override
  State<BookingsTab> createState() => _BookingsTabState();
}

class _BookingsTabState extends State<BookingsTab> {
  int _activeFilter = 0;

  final List<Map<String, dynamic>> _bookings = const [
    {
      'title': 'Green Arena 7v7 Football Turf',
      'slot': 'Tomorrow · 06:00 PM - 07:00 PM',
      'pitch': 'Pitch #1 (Floodlit)',
      'status': 'Confirmed',
      'bookingId': 'FBS-TRF-9021',
      'icon': Icons.sports_soccer_rounded,
      'accentColor': AppColors.accent,
    },
    {
      'title': 'Ocean Breeze Resort Suite',
      'slot': 'Dec 15 - Dec 18 · 3 Nights',
      'pitch': 'Deluxe Sea View (Room 402)',
      'status': 'Upcoming',
      'bookingId': 'FBS-HTL-4810',
      'icon': Icons.hotel_rounded,
      'accentColor': Color(0xFF0284C7),
    },
    {
      'title': 'Bachelor Studio Seat Visit',
      'slot': 'Dec 22 · 03:30 PM Viewing',
      'pitch': 'Flat 4B, Dhanmondi 27',
      'status': 'Scheduled',
      'bookingId': 'FBS-RNT-1102',
      'icon': Icons.home_work_rounded,
      'accentColor': AppColors.primary,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AuthService.instance,
      builder: (context, _) {
        final isLoggedIn = AuthService.instance.isLoggedIn;

        if (!isLoggedIn) {
          return const Scaffold(
            backgroundColor: AppColors.background,
            body: SafeArea(
              child: GuestAuthGateCard(
                icon: Icons.calendar_month_rounded,
                title: 'Manage your reservations',
                subtitle:
                    'Sign in to view your upcoming sports turf slots, hotel reservations, and rental viewing appointments in one place.',
                ctaText: 'Sign In to View Bookings',
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.background,
            elevation: 0,
            title: Text(
              'My Bookings & Stays',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          body: SafeArea(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
              children: [
                // Filter Segment Pills
                Row(
                  children: [
                    _buildFilterChip('Upcoming (${_bookings.length})', 0),
                    const SizedBox(width: 8),
                    _buildFilterChip('Completed (4)', 1),
                    const SizedBox(width: 8),
                    _buildFilterChip('Cancelled (0)', 2),
                  ],
                ),

                const SizedBox(height: 18),

                // Booking Cards
                ..._bookings.map((booking) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: AppColors.border),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: (booking['accentColor'] as Color)
                                    .withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                booking['icon'] as IconData,
                                color: booking['accentColor'] as Color,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    booking['title'] as String,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    booking['pitch'] as String,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.accentLight,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                booking['status'] as String,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Divider(height: 1, color: AppColors.border),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(
                              Icons.schedule_rounded,
                              size: 15,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                booking['slot'] as String,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              booking['bookingId'] as String,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFilterChip(String label, int index) {
    final isSelected = _activeFilter == index;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _activeFilter = index);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
