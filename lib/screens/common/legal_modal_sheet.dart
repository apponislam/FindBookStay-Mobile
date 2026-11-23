import 'package:google_fonts/google_fonts.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/theme/app_colors.dart';
import '../../l10n/app_localizations.dart';

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    final isBn = l10n?.localeName.startsWith('bn') ?? false;
    final title = isTerms
        ? (l10n?.termsOfService ?? 'Terms of Service')
        : (l10n?.privacyPolicy ?? 'Privacy Policy');
    final sections = isTerms
        ? (isBn ? _termsSectionsBn : _termsSections)
        : (isBn ? _privacySectionsBn : _privacySections);

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              // Drag handle
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 4),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkBorder : AppColors.border,
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
                        color: isDark ? const Color(0xFF132F28) : AppColors.accentLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        isTerms
                            ? Icons.gavel_rounded
                            : Icons.shield_outlined,
                        size: 20,
                        color: isDark ? AppColors.accent : AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        title,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded),
                      color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                      style: IconButton.styleFrom(
                        backgroundColor: isDark ? AppColors.darkSurface : AppColors.surface,
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
                color: isDark ? AppColors.darkBorder : AppColors.border,
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
                            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          section['body']!,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w400,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
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
                        backgroundColor: isDark ? AppColors.accent : AppColors.primary,
                        foregroundColor: isDark ? AppColors.primaryDark : Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        l10n?.gotIt ?? 'Got it',
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

  static const List<Map<String, String>> _termsSectionsBn = [
    {
      'heading': '১. শর্তাবলীর স্বীকৃতি',
      'body':
          'ফাইন্ডবুকস্টে-তে নিবন্ধন বা ব্যবহার করার মাধ্যমে, আপনি আমাদের সেবার শর্তাবলীতে সম্মত হচ্ছেন। আপনি এই শর্তাবলীতে সম্মত না হলে দয়া করে আমাদের প্ল্যাটফর্ম ব্যবহার করবেন না।',
    },
    {
      'heading': '২. প্ল্যাটফর্মের ব্যবহার',
      'body':
          'ফাইন্ডবুকস্টে ভাড়াটিয়া, অতিথি, খেলোয়াড়, বাড়িওয়ালা, হোস্ট এবং টার্ফ মালিকদের সংযুক্ত করার একটি মার্কেটপ্লেস প্রদান করে। ব্যবহারকারীরা তাদের প্রদত্ত সমস্ত তথ্যের নির্ভুলতা ও নির্ভরযোগ্যতা নিশ্চিত করার জন্য দায়বদ্ধ।',
    },
    {
      'heading': '৩. ব্যবহারকারী অ্যাকাউন্ট',
      'body':
          'অধিকাংশ সুবিধা উপভোগ করতে আপনাকে একটি অ্যাকাউন্ট তৈরি করতে হবে। আপনার অ্যাকাউন্টের তথ্যের গোপনীয়তা রক্ষা এবং অ্যাকাউন্টের আওতাধীন সমস্ত কার্যক্রমের জন্য আপনি দায়ী।',
    },
    {
      'heading': '৪. লিস্টিং ও বুকিং',
      'body':
          'হোস্ট এবং বাড়িওয়ালাগণ তাদের লিস্টিংয়ের নির্ভুলতার জন্য এককভাবে দায়ী। ফাইন্ডবুকস্টে কোনো তালিকাভুক্ত প্রপার্টি বা টার্ফের প্রাপ্যতা, মান, নিরাপত্তা বা বৈধতার নিশ্চয়তা দেয় না।',
    },
    {
      'heading': '৫. ফি ও পেমেন্ট',
      'body':
          'ফাইন্ডবুকস্টে কোনো ব্রোকার ফি চার্জ করে না। হোস্ট ও মেহমানদের মধ্যকার পেমেন্টের শর্তাবলী সংশ্লিষ্ট লিস্টিংয়ের উপর প্রযোজ্য। সমস্ত লেনদেন নিরাপদে সম্পন্ন হয়।',
    },
    {
      'heading': '৬. নিষিদ্ধ আচরণ',
      'body':
          'ব্যবহারকারীরা মিথ্যা লিস্টিং পোস্ট করতে পারবেন না, কোনো প্রতারণামূলক কার্যকলাপে যুক্ত হতে পারবেন না, অন্যান্য ব্যবহারকারীদের হয়রানি করতে পারবেন না এবং কোনো বেআইনি উদ্দেশ্যে প্ল্যাটফর্ম ব্যবহার করতে পারবেন না।',
    },
    {
      'heading': '৭. শর্তাবলীর পরিবর্তন',
      'body':
          'আমরা যেকোনো সময় এই শর্তাবলী সংশোধন করার অধিকার সংরক্ষণ করি। সংশোধনের পরেও প্ল্যাটফর্মের অব্যাহত ব্যবহার নতুন শর্তাবলীর গ্রহণযোগ্যতা হিসেবে গণ্য হবে।',
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

  static const List<Map<String, String>> _privacySectionsBn = [
    {
      'heading': '১. সংগৃহীত তথ্য',
      'body':
          'আমরা আপনার সরাসরি প্রদত্ত তথ্য (নাম, ইমেল, ফোন নম্বর), প্ল্যাটফর্ম ব্যবহারের ডেটা এবং ডিভাইস সম্পর্কিত তথ্য সংগ্রহ করি যাতে সেবা উন্নত করা সম্ভব হয়।',
    },
    {
      'heading': '২. তথ্যের ব্যবহার',
      'body':
          'আপনার তথ্য প্ল্যাটফর্ম পরিচালনা, বুকিং প্রক্রিয়া সম্পন্নকরণ, নিশ্চিতকরণ নোটিফিকেশন প্রেরণ এবং আপনার অভিজ্ঞতা ব্যক্তিগতকৃত করতে ব্যবহৃত হয়। আমরা কখনোই আপনার তথ্য তৃতীয় পক্ষের কাছে বিক্রি করি না।',
    },
    {
      'heading': '৩. তথ্য শেয়ারিং',
      'body':
          'বুকিং সম্পন্ন করার স্বার্থে আমরা প্রয়োজনীয় তথ্য হোস্ট, বাড়িওয়ালা বা টার্ফ মালিকদের সাথে শেয়ার করতে পারি। এছাড়াও নির্ভরযোগ্য সার্ভিস প্রোভাইডারদের সাথে কঠোর গোপনীয়তা চুক্তির অধীনে তথ্য শেয়ার করা হতে পারে।',
    },
    {
      'heading': '৪. তথ্য নিরাপত্তা',
      'body':
          'আপনার ব্যক্তিগত তথ্যের পূর্ণ সুরক্ষা নিশ্চিত করতে আমরা ট্রান্সফার ও স্টোরেজে সর্বোচ্চ মানের এনক্রিপশন ও নিরাপত্তা ব্যবস্থা প্রয়োগ করি।',
    },
    {
      'heading': '৫. কুকিজ ও অ্যানালিটিক্স',
      'body':
          'প্ল্যাটফর্মের ফিচার ও পারফরম্যান্স উন্নয়নে ব্যবহারকারীরা কীভাবে ইন্টারঅ্যাক্ট করেন তা বুঝতে আমরা কুকিজ ও অ্যানালিটিক্স প্রযুক্তি ব্যবহার করি।',
    },
    {
      'heading': '৬. আপনার অধিকার',
      'body':
          'যেকোনো সময় আপনার ব্যক্তিগত তথ্য দেখা, সংশোধন বা মুছে ফেলার অনুরোধ জানানোর পূর্ণ অধিকার আপনার রয়েছে। এর জন্য যোগাযোগ করুন privacy@findbookstay.com ঠিকানায়।',
    },
    {
      'heading': '৭. যোগাযোগ',
      'body':
          'গোপনীয়তা সংক্রান্ত যেকোনো প্রশ্ন বা অনুসন্ধানের জন্য নির্দ্বিধায় আমাদের ডেটা প্রোটেকশন টিমের সাথে যোগাযোগ করুন: privacy@findbookstay.com।',
    },
  ];
}

