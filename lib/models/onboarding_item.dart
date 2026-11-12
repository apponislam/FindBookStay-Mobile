import 'package:material_ui/material_ui.dart';

/// Data model representing a single onboarding slide.
class OnboardingItem {
  final String tag;
  final String title;
  final String subtitle;
  final IconData primaryIcon;
  final String? imageAssetPath;
  final List<String> highlights;
  final String metricValue;
  final String metricLabel;

  const OnboardingItem({
    required this.tag,
    required this.title,
    required this.subtitle,
    required this.primaryIcon,
    this.imageAssetPath,
    required this.highlights,
    required this.metricValue,
    required this.metricLabel,
  });

  /// 4 Onboarding Slides in exact order: 01 RENT -> 02 BOOK -> 03 SPORTS -> 04 BUY
  static List<OnboardingItem> get items => [
        const OnboardingItem(
          tag: '01 / RENT',
          title: 'Rent Verified Spaces',
          subtitle:
              'Rent family apartments, furnished flats, and flexible bachelor seats directly from verified owners with zero broker fees.',
          primaryIcon: Icons.home_work_rounded,
          imageAssetPath: 'assets/images/onboarding_rent.png',
          highlights: ['0% Broker Fee', 'Family Apartments', 'Bachelor Seats'],
          metricValue: '0%',
          metricLabel: 'Broker Fees',
        ),
        const OnboardingItem(
          tag: '02 / BOOK',
          title: 'Book Stays & Getaways',
          subtitle:
              'Discover and book boutique hotels, vacation resorts, and short stays with transparent pricing and instant confirmations.',
          primaryIcon: Icons.hotel_rounded,
          imageAssetPath: 'assets/images/onboarding_book.png',
          highlights: ['Instant Booking', 'Boutique Resorts', 'Best Rates'],
          metricValue: '4.9/5',
          metricLabel: 'Top Stays',
        ),
        const OnboardingItem(
          tag: '03 / SPORTS',
          title: 'Reserve Sports Turfs',
          subtitle:
              'Book football pitches, cricket nets, and sports arenas by the hour with real-time slot availability.',
          primaryIcon: Icons.sports_soccer_rounded,
          imageAssetPath: 'assets/images/onboarding_sports.png',
          highlights: ['Real-Time Slots', 'Football & Cricket', 'Hourly Booking'],
          metricValue: '60s',
          metricLabel: 'Quick Reserve',
        ),
        const OnboardingItem(
          tag: '04 / BUY',
          title: 'Buy Verified Properties',
          subtitle:
              'Explore premium residential apartments, luxury villas, and verified plots with direct developer & owner connections.',
          primaryIcon: Icons.real_estate_agent_rounded,
          imageAssetPath: 'assets/images/onboarding_buy.png',
          highlights: ['Verified Titles', 'Direct Owners', 'Zero Hidden Fees'],
          metricValue: '100%',
          metricLabel: 'Verified Deals',
        ),
      ];
}
