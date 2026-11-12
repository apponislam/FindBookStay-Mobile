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

  /// Factory list containing the 4 required onboarding slides for FindBookStay
  static List<OnboardingItem> get items => [
        const OnboardingItem(
          tag: '01 / APARTMENTS',
          title: 'Verified Living Spaces',
          subtitle:
              'Find and rent furnished family apartments and flats directly from verified owners with zero broker commissions.',
          primaryIcon: Icons.apartment_rounded,
          imageAssetPath: 'assets/images/onboarding_apartments.png',
          highlights: ['0% Broker Fee', '100% Verified Owners', 'Furnished Flats'],
          metricValue: '0%',
          metricLabel: 'Broker Fees',
        ),
        const OnboardingItem(
          tag: '02 / CO-LIVING',
          title: 'Flexible Bachelor Seats',
          subtitle:
              'Discover transparent, affordable shared rooms and bachelor seats with verified roommates in prime locations.',
          primaryIcon: Icons.people_alt_rounded,
          imageAssetPath: 'assets/images/onboarding_bachelor.png',
          highlights: ['Verified Roommates', 'All-Inclusive Bills', 'Month-to-Month'],
          metricValue: '5,000+',
          metricLabel: 'Active Seats',
        ),
        const OnboardingItem(
          tag: '03 / HOTELS',
          title: 'Boutique Hotel Stays',
          subtitle:
              'Book weekend getaways, city stays, and holiday rooms with instant booking confirmation.',
          primaryIcon: Icons.hotel_rounded,
          imageAssetPath: 'assets/images/onboarding_hotels.png',
          highlights: ['Instant Confirmation', 'Best Rates Guaranteed', 'Curated Stays'],
          metricValue: '4.9â˜…',
          metricLabel: 'Guest Rating',
        ),
        const OnboardingItem(
          tag: '04 / SPORTS TURFS',
          title: 'Reserve Sports Turfs',
          subtitle:
              'Book cricket nets, football turfs, and sports venues by the hour with real-time slot availability.',
          primaryIcon: Icons.sports_soccer_rounded,
          imageAssetPath: 'assets/images/onboarding_turfs.png',
          highlights: ['Real-Time Slot Booking', 'Cricket & Football', 'Hourly Pricing'],
          metricValue: '60s',
          metricLabel: 'Instant Booking',
        ),
      ];
}

