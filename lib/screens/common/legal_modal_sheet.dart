import 'package:google_fonts/google_fonts.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/theme/app_colors.dart';

/// Shows a polished bottom-sheet modal for Terms of Service or Privacy Policy.
void showLegalModalSheet(BuildContext context, {required bool isTerms}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => LegalModalSheet(isTerms: isTerms),
  );
}

/// Polished bottom-sheet modal that displays Terms of Service or Privacy Policy content.
class LegalModalSheet extends StatelessWidget {
  final bool isTerms;

  const LegalModalSheet({super.key, required this.isTerms});

  @override
  Widget build(BuildContext context) {
    final title = isTerms ? 'Terms of Service' : 'Privacy Policy';
    final sections = isTerms ? _termsSections : _privacySections;

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              // Drag handle
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 4),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 16, 12),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.accentLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        isTerms
                            ? Icons.gavel_rounded
                            : Icons.shield_outlined,
                        size: 20,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        title,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded),
                      color: AppColors.textSecondary,
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.surface,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Divider(
                height: 1,
                color: AppColors.border,
                indent: 24,
                endIndent: 24,
              ),

              // Scrollable content
              Expanded(
                child: ListView.separated(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
                  itemCount: sections.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 20),
                  itemBuilder: (_, index) {
                    final section = sections[index];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          section['heading']!,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          section['body']!,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w400,
                            color: AppColors.textSecondary,
                            height: 1.6,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

              // Accept button
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Got it',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static const List<Map<String, String>> _termsSections = [
    {
      'heading': '1. Acceptance of Terms',
      'body':
          'By registering for or using FindBookStay, you agree to be bound by these Terms of Service. If you do not agree to these terms, please do not use our platform.',
    },
    {
      'heading': '2. Use of the Platform',
      'body':
          'FindBookStay provides a marketplace connecting tenants, guests, players, landlords, hosts, and turf owners. Users are responsible for ensuring all information they provide is accurate and up to date.',
    },
    {
      'heading': '3. User Accounts',
      'body':
          'You must create an account to access most features. You are responsible for maintaining the confidentiality of your credentials and for all activities that occur under your account.',
    },
    {
      'heading': '4. Listings & Bookings',
      'body':
          'Hosts and landlords are solely responsible for the accuracy of their listings. FindBookStay does not guarantee the availability, quality, safety, or legality of any listed property or turf.',
    },
    {
      'heading': '5. Fees & Payments',
      'body':
          'FindBookStay charges zero broker fees. Payment terms between hosts and guests are subject to individual listing conditions. All transactions are processed securely.',
    },
    {
      'heading': '6. Prohibited Conduct',
      'body':
          'Users may not post false listings, engage in fraudulent activity, harass other users, or use the platform for any unlawful purpose.',
    },
    {
      'heading': '7. Changes to Terms',
      'body':
          'We reserve the right to modify these terms at any time. Continued use of the platform after changes constitutes acceptance of the revised terms.',
    },
  ];

  static const List<Map<String, String>> _privacySections = [
    {
      'heading': '1. Information We Collect',
      'body':
          'We collect information you provide directly (name, email, phone), usage data, and device information to deliver and improve our services.',
    },
    {
      'heading': '2. How We Use Your Information',
      'body':
          'Your data is used to operate the platform, process bookings, send confirmation notifications, and personalise your experience. We do not sell your personal data to third parties.',
    },
    {
      'heading': '3. Data Sharing',
      'body':
          'We may share necessary information with hosts, landlords, or turf owners to facilitate bookings. We may also share data with service providers who help us operate FindBookStay under strict confidentiality agreements.',
    },
    {
      'heading': '4. Data Security',
      'body':
          'We implement industry-standard security measures including encryption in transit and at rest to protect your personal information.',
    },
    {
      'heading': '5. Cookies & Analytics',
      'body':
          'We use cookies and analytics tools to understand how users interact with our platform, enabling us to improve features and performance.',
    },
    {
      'heading': '6. Your Rights',
      'body':
          'You have the right to access, correct, or delete your personal data at any time by contacting us at privacy@findbookstay.com.',
    },
    {
      'heading': '7. Contact Us',
      'body':
          'For any privacy-related questions or requests, please reach out to our Data Protection team at privacy@findbookstay.com.',
    },
  ];
}

