import 'package:findbookstay/core/localization/locale_controller.dart';
import 'package:findbookstay/core/utils/app_formatters.dart';
import 'package:findbookstay/l10n/app_localizations.dart';
import 'package:findbookstay/screens/home/tabs/profile_tab.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LocaleController & localeProvider Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('Initializes with English (en) by default', () {
      final container = ProviderContainer();
      final locale = container.read(localeProvider);
      expect(locale.languageCode, equals('en'));
    });

    test('Switches locale to Bangla (bn) and persists', () async {
      final container = ProviderContainer();
      expect(container.read(localeProvider).languageCode, equals('en'));

      await container.read(localeProvider.notifier).setLocale(AppLocales.bangla);
      expect(container.read(localeProvider).languageCode, equals('bn'));
      expect(container.read(localeProvider.notifier).isBengali, isTrue);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('app_locale_code'), equals('bn'));
    });

    test('Toggles locale between English and Bangla', () async {
      final container = ProviderContainer();
      expect(container.read(localeProvider).languageCode, equals('en'));

      await container.read(localeProvider.notifier).toggleLocale();
      expect(container.read(localeProvider).languageCode, equals('bn'));

      await container.read(localeProvider.notifier).toggleLocale();
      expect(container.read(localeProvider).languageCode, equals('en'));
    });

    test('Loads saved locale from SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({'app_locale_code': 'bn'});
      final container = ProviderContainer();
      await container.read(localeProvider.notifier).loadSavedLocale();

      final locale = container.read(localeProvider);
      expect(locale.languageCode, equals('bn'));
    });
  });

  group('AppFormatters Currency & Date Tests', () {
    test('Formats currency with BDT (৳) in English and Bengali', () {
      final enCurrency = AppFormatters.formatCurrency(1500, locale: 'en');
      expect(enCurrency, contains('1,500'));
      expect(enCurrency, contains('৳'));

      final bnCurrency = AppFormatters.formatCurrency(1500, locale: 'bn');
      expect(bnCurrency, contains('১,৫০০'));
      expect(bnCurrency, contains('৳'));
    });

    test('Formats numbers in Bengali digits', () {
      final bnNumber = AppFormatters.formatNumber(1250, locale: 'bn');
      expect(bnNumber, equals('১,২৫০'));

      final enNumber = AppFormatters.formatNumber(1250, locale: 'en');
      expect(enNumber, equals('1,250'));
    });

    test('Formats dates cleanly according to pattern', () {
      final date = DateTime(2026, 11, 20);
      final formatted = AppFormatters.formatDate(date, locale: 'en', pattern: 'yyyy-MM-dd');
      expect(formatted, equals('2026-11-20'));
    });
  });

  group('AppLocalizations Translations Coverage Tests', () {
    test('English translations have expected strings', () async {
      final l10n = await AppLocalizations.delegate.load(const Locale('en'));
      expect(l10n.appName, equals('FindBookStay'));
      expect(l10n.navExplore, equals('Explore'));
      expect(l10n.navBookings, equals('Bookings'));
      expect(l10n.navSaved, equals('Saved'));
      expect(l10n.navInbox, equals('Inbox'));
      expect(l10n.navProfile, equals('Profile'));
      expect(l10n.personalInfo, equals('Personal Information'));
      expect(l10n.editProfile, equals('Edit Profile'));
      expect(l10n.saveChanges, equals('Save Changes'));
      expect(l10n.languageAndCurrency, equals('Language & Currency'));
      expect(l10n.english, equals('English'));
      expect(l10n.bangla, equals('বাংলা'));
      expect(l10n.joinFindBookStay, equals('Join FindBookStay'));
      expect(l10n.whereToStayOrPlay, equals('Where to stay or play?'));
      expect(l10n.categoryAllSpaces, equals('All Spaces'));
      expect(l10n.myBookingsAndStays, equals('My Bookings & Stays'));
      expect(l10n.savedWishlist, equals('Saved Wishlist'));
      expect(l10n.inboxAndInquiries, equals('Inbox & Inquiries'));
      expect(l10n.guestMode, equals('Guest Mode'));
      expect(l10n.signInToAccount, equals('Sign In to Account'));
    });

    test('Bangla translations have expected strings', () async {
      final l10n = await AppLocalizations.delegate.load(const Locale('bn'));
      expect(l10n.appName, equals('ফাইন্ডবুকস্টে'));
      expect(l10n.navExplore, equals('এক্সপ্লোর'));
      expect(l10n.navBookings, equals('বুকিং'));
      expect(l10n.navSaved, equals('সংরক্ষিত'));
      expect(l10n.navInbox, equals('ইনবক্স'));
      expect(l10n.navProfile, equals('প্রোফাইল'));
      expect(l10n.personalInfo, equals('ব্যক্তিগত তথ্য'));
      expect(l10n.editProfile, equals('প্রোফাইল এডিট'));
      expect(l10n.saveChanges, equals('পরিবর্তন সংরক্ষণ করুন'));
      expect(l10n.languageAndCurrency, equals('ভাষা ও মুদ্রা'));
      expect(l10n.english, equals('English'));
      expect(l10n.bangla, equals('বাংলা'));
      expect(l10n.joinFindBookStay, equals('ফাইন্ডবুকস্টে-তে যোগ দিন'));
      expect(l10n.whereToStayOrPlay, equals('কোথায় থাকতে বা খেলতে চান?'));
      expect(l10n.categoryAllSpaces, equals('সব স্পেস'));
      expect(l10n.myBookingsAndStays, equals('আমার বুকিং ও স্টে'));
      expect(l10n.savedWishlist, equals('সংরক্ষিত উইশলিস্ট'));
      expect(l10n.inboxAndInquiries, equals('ইনবক্স ও অনুসন্ধান'));
      expect(l10n.guestMode, equals('গেস্ট মোড'));
      expect(l10n.signInToAccount, equals('অ্যাকাউন্টে সাইন ইন করুন'));

      // Test loading GlobalMaterialLocalizations in material_ui
      final matLoc = await GlobalMaterialLocalizations.delegate.load(const Locale('bn'));
      expect(matLoc, isNotNull);
      expect(matLoc.okButtonLabel, isNotEmpty);
    });

    testWidgets('MaterialApp renders with Bangla locale without MaterialLocalizations error', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            locale: const Locale('bn'),
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: [
              AppLocalizations.delegate,
              ...GlobalMaterialLocalizations.delegates,
              ...AppLocalizations.localizationsDelegates,
            ],
            home: Scaffold(
              appBar: AppBar(title: const Text('Test Bangla')),
              body: const Text('স্বাগতম'),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Test Bangla'), findsOneWidget);
      expect(find.text('স্বাগতম'), findsOneWidget);
    });

    testWidgets('ProfileTab renders guest hero and theme mode in Bangla', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            locale: const Locale('bn'),
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: [
              AppLocalizations.delegate,
              ...GlobalMaterialLocalizations.delegates,
              ...AppLocalizations.localizationsDelegates,
            ],
            home: const ProfileTab(),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('ফাইন্ডবুকস্টে-তে যোগ দিন'), findsOneWidget);
      expect(find.text('থিম মোড'), findsOneWidget);
      expect(find.text('পছন্দসমূহ'), findsOneWidget);
    });
  });
}

