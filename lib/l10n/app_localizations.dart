import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_bn.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('bn'),
    Locale('en'),
  ];

  /// Application brand name
  ///
  /// In en, this message translates to:
  /// **'FindBookStay'**
  String get appName;

  /// Application tagline
  ///
  /// In en, this message translates to:
  /// **'Find, Book & Stay Anywhere'**
  String get appTagline;

  /// Bottom nav explore tab label
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get navExplore;

  /// Bottom nav bookings tab label
  ///
  /// In en, this message translates to:
  /// **'Bookings'**
  String get navBookings;

  /// Bottom nav saved tab label
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get navSaved;

  /// Bottom nav inbox tab label
  ///
  /// In en, this message translates to:
  /// **'Inbox'**
  String get navInbox;

  /// Bottom nav profile tab label
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// Search label
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// Search input placeholder
  ///
  /// In en, this message translates to:
  /// **'Search destinations, properties...'**
  String get searchPlaceholder;

  /// Filter label
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// Cancel button label
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Save button label
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Save changes button label
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// Saving in-progress label
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get saving;

  /// Edit button label
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// Delete button label
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Confirm button label
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// Back button label
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// Next button label
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// Done button label
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// Retry button label
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// View all action label
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// See all action label
  ///
  /// In en, this message translates to:
  /// **'See All'**
  String get seeAll;

  /// See more action label
  ///
  /// In en, this message translates to:
  /// **'See More'**
  String get seeMore;

  /// See less action label
  ///
  /// In en, this message translates to:
  /// **'See Less'**
  String get seeLess;

  /// Loading state label
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// Sign in button label
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// Sign up button label
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// Sign out button label
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// Register button label
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// Create an account button label
  ///
  /// In en, this message translates to:
  /// **'Create an Account'**
  String get createAnAccount;

  /// Guest mode badge text
  ///
  /// In en, this message translates to:
  /// **'Guest Mode'**
  String get guestMode;

  /// Guest user label
  ///
  /// In en, this message translates to:
  /// **'Guest User'**
  String get guestUser;

  /// Sign in callout for guest users
  ///
  /// In en, this message translates to:
  /// **'Sign in to access your full profile, saved wishlists, and bookings.'**
  String get signInToContinue;

  /// Don't have an account question
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get dontHaveAccount;

  /// Already have an account question
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get alreadyHaveAccount;

  /// Got it confirmation button label
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get gotIt;

  /// Guest hero banner title
  ///
  /// In en, this message translates to:
  /// **'Join FindBookStay'**
  String get joinFindBookStay;

  /// Guest hero banner subtitle
  ///
  /// In en, this message translates to:
  /// **'Sign in or create an account to book stays, rent flats, and reserve sports turfs with zero broker fees.'**
  String get guestHeroSubtitle;

  /// Brand pill badge text
  ///
  /// In en, this message translates to:
  /// **'FIND · BOOK · STAY'**
  String get findBookStayBadge;

  /// Account settings section title
  ///
  /// In en, this message translates to:
  /// **'Account Settings'**
  String get accountSettings;

  /// Preferences section title
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get preferences;

  /// Personal information menu title
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get personalInfo;

  /// Personal information menu subtitle
  ///
  /// In en, this message translates to:
  /// **'Name, phone, address, and profile details'**
  String get personalInfoSubtitle;

  /// Payment methods menu title
  ///
  /// In en, this message translates to:
  /// **'Payment Methods & Invoices'**
  String get paymentMethods;

  /// Payment methods menu subtitle
  ///
  /// In en, this message translates to:
  /// **'Cards, bKash, transaction history'**
  String get paymentMethodsSubtitle;

  /// Notifications menu title
  ///
  /// In en, this message translates to:
  /// **'Notification Preferences'**
  String get notifications;

  /// Notifications menu subtitle
  ///
  /// In en, this message translates to:
  /// **'Booking alerts, owner messages'**
  String get notificationsSubtitle;

  /// Language and currency menu label
  ///
  /// In en, this message translates to:
  /// **'Language & Currency'**
  String get languageAndCurrency;

  /// Select language modal title
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// English language name
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// Bangla language name
  ///
  /// In en, this message translates to:
  /// **'বাংলা'**
  String get bangla;

  /// Theme mode label
  ///
  /// In en, this message translates to:
  /// **'Theme Mode'**
  String get themeMode;

  /// Dark mode active state
  ///
  /// In en, this message translates to:
  /// **'Dark Mode (Active)'**
  String get activeDarkMode;

  /// Light mode active state
  ///
  /// In en, this message translates to:
  /// **'Light Mode (Active)'**
  String get activeLightMode;

  /// Light mode label
  ///
  /// In en, this message translates to:
  /// **'Light Mode'**
  String get lightMode;

  /// Dark mode label
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// System default theme label
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get systemDefault;

  /// Legal and support section title
  ///
  /// In en, this message translates to:
  /// **'Legal & Support'**
  String get legalAndSupport;

  /// Terms of service label
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// Terms of service subtitle
  ///
  /// In en, this message translates to:
  /// **'Platform rules and direct booking terms'**
  String get termsOfServiceSubtitle;

  /// Privacy policy label
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// Privacy policy subtitle
  ///
  /// In en, this message translates to:
  /// **'How FindBookStay protects your data'**
  String get privacyPolicySubtitle;

  /// Help center label
  ///
  /// In en, this message translates to:
  /// **'Help Center & 24/7 Support'**
  String get helpCenter;

  /// Help center subtitle
  ///
  /// In en, this message translates to:
  /// **'FAQs, contact agent, safety center'**
  String get helpCenterSubtitle;

  /// Sign out confirmation dialog title
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOutConfirmTitle;

  /// Sign out confirmation dialog message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out? You can sign back in at any time.'**
  String get signOutConfirmMessage;

  /// Signed out success snackbar
  ///
  /// In en, this message translates to:
  /// **'Signed out successfully. Switched to Guest mode.'**
  String get signedOutSuccess;

  /// Footer app version text
  ///
  /// In en, this message translates to:
  /// **'FindBookStay v1.0.0 (Build 1) · 0% Broker Fees'**
  String get appVersionInfo;

  /// Profile tab title when signed in
  ///
  /// In en, this message translates to:
  /// **'Account Profile'**
  String get accountProfile;

  /// Greeting user header
  ///
  /// In en, this message translates to:
  /// **'Hi, {name}'**
  String userGreeting(String name);

  /// Explore search card title
  ///
  /// In en, this message translates to:
  /// **'Where to stay or play?'**
  String get whereToStayOrPlay;

  /// Explore search card subtitle
  ///
  /// In en, this message translates to:
  /// **'Flats · Bachelor seats · Hotels · Sports turfs'**
  String get exploreSearchSubtext;

  /// Explore category all spaces
  ///
  /// In en, this message translates to:
  /// **'All Spaces'**
  String get categoryAllSpaces;

  /// Explore category rent flats
  ///
  /// In en, this message translates to:
  /// **'Rent Flats'**
  String get categoryRentFlats;

  /// Explore category hotel stays
  ///
  /// In en, this message translates to:
  /// **'Hotel Stays'**
  String get categoryHotelStays;

  /// Explore category sports turfs
  ///
  /// In en, this message translates to:
  /// **'Sports Turfs'**
  String get categorySportsTurfs;

  /// Explore category buy property
  ///
  /// In en, this message translates to:
  /// **'Buy Property'**
  String get categoryBuyProperty;

  /// 100% direct badge
  ///
  /// In en, this message translates to:
  /// **'100% DIRECT'**
  String get badgeDirect;

  /// Zero broker fees banner title
  ///
  /// In en, this message translates to:
  /// **'Zero Broker Fees Guaranteed'**
  String get zeroBrokerFeesTitle;

  /// Zero broker fees banner subtitle
  ///
  /// In en, this message translates to:
  /// **'Rent family apartments or reserve turfs directly with owners.'**
  String get zeroBrokerFeesSubtitle;

  /// Featured listings section title
  ///
  /// In en, this message translates to:
  /// **'Featured Across Spaces'**
  String get featuredAcrossSpaces;

  /// No listings empty state title
  ///
  /// In en, this message translates to:
  /// **'No listings available yet'**
  String get noListingsAvailable;

  /// No listings empty state description
  ///
  /// In en, this message translates to:
  /// **'Check back shortly as verified property owners add new listings.'**
  String get noListingsDesc;

  /// Bookings tab title
  ///
  /// In en, this message translates to:
  /// **'My Bookings & Stays'**
  String get myBookingsAndStays;

  /// Bookings guest auth gate title
  ///
  /// In en, this message translates to:
  /// **'Manage your reservations'**
  String get manageReservations;

  /// Bookings guest auth gate subtitle
  ///
  /// In en, this message translates to:
  /// **'Sign in to view your upcoming sports turf slots, hotel reservations, and rental viewing appointments in one place.'**
  String get manageReservationsSubtitle;

  /// Bookings guest auth gate CTA button
  ///
  /// In en, this message translates to:
  /// **'Sign In to View Bookings'**
  String get signInToViewBookings;

  /// Bookings filter upcoming
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get filterUpcoming;

  /// Bookings filter completed
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get filterCompleted;

  /// Bookings filter cancelled
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get filterCancelled;

  /// Bookings empty state title
  ///
  /// In en, this message translates to:
  /// **'No reservations found'**
  String get noBookingsFound;

  /// Bookings empty state description
  ///
  /// In en, this message translates to:
  /// **'When you book turf slots, resort suites, or schedule rental viewings, your bookings will be shown here.'**
  String get noBookingsDesc;

  /// Saved tab title
  ///
  /// In en, this message translates to:
  /// **'Saved Wishlist'**
  String get savedWishlist;

  /// Saved tab guest auth gate title
  ///
  /// In en, this message translates to:
  /// **'Save your favorite spots'**
  String get saveFavoriteSpots;

  /// Saved tab guest auth gate subtitle
  ///
  /// In en, this message translates to:
  /// **'Sign in to keep track of family flats, hotel getaways, and sports turfs you love across all your devices.'**
  String get saveFavoriteSpotsSubtitle;

  /// Saved tab guest auth gate CTA button
  ///
  /// In en, this message translates to:
  /// **'Sign In to View Wishlist'**
  String get signInToViewWishlist;

  /// Wishlist sync snackbar
  ///
  /// In en, this message translates to:
  /// **'Wishlist synced with your account'**
  String get wishlistSynced;

  /// Wishlist empty state title
  ///
  /// In en, this message translates to:
  /// **'Your wishlist is empty'**
  String get wishlistEmpty;

  /// Wishlist empty state description
  ///
  /// In en, this message translates to:
  /// **'Tap the heart icon on any flat, hotel, or turf to save it to your wishlist.'**
  String get wishlistEmptyDesc;

  /// Inbox tab title
  ///
  /// In en, this message translates to:
  /// **'Inbox & Inquiries'**
  String get inboxAndInquiries;

  /// Inbox guest auth gate title
  ///
  /// In en, this message translates to:
  /// **'Chat directly with owners'**
  String get chatDirectlyOwners;

  /// Inbox guest auth gate subtitle
  ///
  /// In en, this message translates to:
  /// **'Sign in to message verified property landlords, inquire about bachelor seats, and confirm turf reservations in real-time.'**
  String get chatDirectlyOwnersSubtitle;

  /// Inbox guest auth gate CTA button
  ///
  /// In en, this message translates to:
  /// **'Sign In to Access Messages'**
  String get signInToAccessMessages;

  /// Inbox empty state title
  ///
  /// In en, this message translates to:
  /// **'No conversations yet'**
  String get noMessages;

  /// Inbox empty state description
  ///
  /// In en, this message translates to:
  /// **'When you message property owners, landlord representatives, or turf managers, your chats will appear here.'**
  String get noMessagesDesc;

  /// Edit profile title
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// Basic information section title
  ///
  /// In en, this message translates to:
  /// **'Basic Information'**
  String get basicInformation;

  /// Full name field label
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// Phone number field label
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phone;

  /// Email address field label
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get emailAddress;

  /// Verified status badge
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get verified;

  /// Unverified status badge
  ///
  /// In en, this message translates to:
  /// **'Unverified'**
  String get unverified;

  /// Present address section title
  ///
  /// In en, this message translates to:
  /// **'Present Address'**
  String get presentAddress;

  /// Permanent address section title
  ///
  /// In en, this message translates to:
  /// **'Permanent Address'**
  String get permanentAddress;

  /// Same address checkbox label
  ///
  /// In en, this message translates to:
  /// **'Permanent address is same as present'**
  String get sameAsPresent;

  /// Street address field label
  ///
  /// In en, this message translates to:
  /// **'Street Address'**
  String get street;

  /// City field label
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get city;

  /// State field label
  ///
  /// In en, this message translates to:
  /// **'State / Division'**
  String get state;

  /// Postal code field label
  ///
  /// In en, this message translates to:
  /// **'Postal / Zip Code'**
  String get zipCode;

  /// Change profile photo title
  ///
  /// In en, this message translates to:
  /// **'Change Profile Photo'**
  String get changeProfilePhoto;

  /// Choose photo from gallery option
  ///
  /// In en, this message translates to:
  /// **'Choose from Gallery'**
  String get chooseFromGallery;

  /// Take photo with camera option
  ///
  /// In en, this message translates to:
  /// **'Take a Photo'**
  String get takePhoto;

  /// Remove selected photo option
  ///
  /// In en, this message translates to:
  /// **'Remove Selected Photo'**
  String get removePhoto;

  /// Profile updated success message
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully!'**
  String get profileUpdatedSuccess;

  /// Name validation error message
  ///
  /// In en, this message translates to:
  /// **'Please enter your full name'**
  String get pleaseEnterFullName;

  /// Sign in screen main heading
  ///
  /// In en, this message translates to:
  /// **'Sign In to Account'**
  String get signInToAccount;

  /// Sign in screen description
  ///
  /// In en, this message translates to:
  /// **'Sign in to access your verified rentals, boutique stays, turf slots, and account preferences.'**
  String get signInDescription;

  /// Email required validation message
  ///
  /// In en, this message translates to:
  /// **'Email address is required'**
  String get emailAddressRequired;

  /// Valid email required validation message
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get validEmailRequired;

  /// Password field label
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// Password required validation message
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get passwordRequired;

  /// Password min length validation message
  ///
  /// In en, this message translates to:
  /// **'Min. 6 characters required'**
  String get passwordMinLength;

  /// Forgot password link label
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// Reset password label
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPassword;

  /// Verify OTP label
  ///
  /// In en, this message translates to:
  /// **'Verify OTP'**
  String get verifyOtp;

  /// Welcome back badge title
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get welcomeBack;

  /// Security label
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get security;

  /// Skip onboarding label
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// Get started button label
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// Onboarding rent slide title
  ///
  /// In en, this message translates to:
  /// **'Rent Verified Spaces'**
  String get onboardingRentTitle;

  /// Onboarding rent slide subtitle
  ///
  /// In en, this message translates to:
  /// **'Rent family apartments, furnished flats, and flexible bachelor seats directly from verified owners with zero broker fees.'**
  String get onboardingRentSubtitle;

  /// Onboarding rent slide tag
  ///
  /// In en, this message translates to:
  /// **'01 / RENT'**
  String get onboardingRentTag;

  /// Onboarding book slide title
  ///
  /// In en, this message translates to:
  /// **'Book Stays & Getaways'**
  String get onboardingBookTitle;

  /// Onboarding book slide subtitle
  ///
  /// In en, this message translates to:
  /// **'Discover and book boutique hotels, vacation resorts, and short stays with transparent pricing and instant confirmations.'**
  String get onboardingBookSubtitle;

  /// Onboarding book slide tag
  ///
  /// In en, this message translates to:
  /// **'02 / BOOK'**
  String get onboardingBookTag;

  /// Onboarding sports slide title
  ///
  /// In en, this message translates to:
  /// **'Reserve Sports Turfs'**
  String get onboardingSportsTitle;

  /// Onboarding sports slide subtitle
  ///
  /// In en, this message translates to:
  /// **'Book football pitches, cricket nets, and sports arenas by the hour with real-time slot availability.'**
  String get onboardingSportsSubtitle;

  /// Onboarding sports slide tag
  ///
  /// In en, this message translates to:
  /// **'03 / SPORTS'**
  String get onboardingSportsTag;

  /// Onboarding buy slide title
  ///
  /// In en, this message translates to:
  /// **'Buy Verified Properties'**
  String get onboardingBuyTitle;

  /// Onboarding buy slide subtitle
  ///
  /// In en, this message translates to:
  /// **'Explore premium residential apartments, luxury villas, and verified plots with direct developer & owner connections.'**
  String get onboardingBuySubtitle;

  /// Onboarding buy slide tag
  ///
  /// In en, this message translates to:
  /// **'04 / BUY'**
  String get onboardingBuyTag;

  /// Step 1 of 2 tag
  ///
  /// In en, this message translates to:
  /// **'Step 1 of 2'**
  String get step1Of2;

  /// Role selection screen title
  ///
  /// In en, this message translates to:
  /// **'Select your role'**
  String get selectYourRole;

  /// Role selection screen subtitle
  ///
  /// In en, this message translates to:
  /// **'Choose how you want to use FindBookStay. You can always switch or manage both from account settings.'**
  String get selectYourRoleSubtitle;

  /// Tenant role title
  ///
  /// In en, this message translates to:
  /// **'Tenant, Guest or Player'**
  String get roleTenantTitle;

  /// Tenant role description
  ///
  /// In en, this message translates to:
  /// **'Rent family apartments, bachelor seats, book hotel stays, or reserve sports turfs.'**
  String get roleTenantDesc;

  /// Host role title
  ///
  /// In en, this message translates to:
  /// **'Host, Landlord or Turf Owner'**
  String get roleHostTitle;

  /// Host role description
  ///
  /// In en, this message translates to:
  /// **'List residential properties, rent shared seats, or manage sports turf reservations.'**
  String get roleHostDesc;

  /// Continue to sign up button
  ///
  /// In en, this message translates to:
  /// **'Continue to Sign Up'**
  String get continueToSignUp;

  /// Create account screen title
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// Registration step 1 title
  ///
  /// In en, this message translates to:
  /// **'Personal Details'**
  String get step1Title;

  /// Registration step 1 subtitle
  ///
  /// In en, this message translates to:
  /// **'Enter your name, contact information, and upload an optional profile photo.'**
  String get step1Subtitle;

  /// Registration step 2 title
  ///
  /// In en, this message translates to:
  /// **'Addresses & Referral'**
  String get step2Title;

  /// Registration step 2 subtitle
  ///
  /// In en, this message translates to:
  /// **'Provide your present address and permanent residence details for verified booking records.'**
  String get step2Subtitle;

  /// Registration step 3 title
  ///
  /// In en, this message translates to:
  /// **'Account Security'**
  String get step3Title;

  /// Registration step 3 subtitle
  ///
  /// In en, this message translates to:
  /// **'Create a strong password and accept our terms to safeguard your account.'**
  String get step3Subtitle;

  /// Step progress indicator
  ///
  /// In en, this message translates to:
  /// **'Step {current} of {total}'**
  String stepCountOf(int current, int total);

  /// Next step button
  ///
  /// In en, this message translates to:
  /// **'Next Step'**
  String get nextStep;

  /// Previous step button
  ///
  /// In en, this message translates to:
  /// **'Previous Step'**
  String get previousStep;

  /// Complete registration button
  ///
  /// In en, this message translates to:
  /// **'Complete Registration'**
  String get completeRegistration;

  /// Take photo with camera
  ///
  /// In en, this message translates to:
  /// **'Take Photo with Camera'**
  String get takePhotoWithCamera;

  /// Profile photo modal title
  ///
  /// In en, this message translates to:
  /// **'Profile Photo'**
  String get profilePhoto;

  /// Full name required message
  ///
  /// In en, this message translates to:
  /// **'Full name is required'**
  String get fullNameRequired;

  /// Confirm password label
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// Confirm password required message
  ///
  /// In en, this message translates to:
  /// **'Confirm password is required'**
  String get confirmPasswordRequired;

  /// Passwords do not match error
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// Passwords match success
  ///
  /// In en, this message translates to:
  /// **'Passwords match'**
  String get passwordsMatch;

  /// Referral code field
  ///
  /// In en, this message translates to:
  /// **'Referral Code (Optional)'**
  String get referralCodeOptional;

  /// Terms agreement checkbox text
  ///
  /// In en, this message translates to:
  /// **'I agree to the Terms of Service and Privacy Policy'**
  String get termsAgreementText;

  /// Please accept terms validation message
  ///
  /// In en, this message translates to:
  /// **'Please accept Terms of Service & Privacy Policy to continue'**
  String get pleaseAcceptTerms;

  /// Account recovery badge
  ///
  /// In en, this message translates to:
  /// **'Account Recovery'**
  String get accountRecovery;

  /// Forgot password screen heading
  ///
  /// In en, this message translates to:
  /// **'Forgot your password?'**
  String get forgotYourPassword;

  /// Forgot password screen subtitle
  ///
  /// In en, this message translates to:
  /// **'Enter your registered email address and we will send you a 6-digit code to reset your password.'**
  String get forgotPasswordSubtitle;

  /// Send reset code button label
  ///
  /// In en, this message translates to:
  /// **'Send Reset Code'**
  String get sendResetCode;

  /// Remember password question
  ///
  /// In en, this message translates to:
  /// **'Remember your password? '**
  String get rememberPasswordQuestion;

  /// Verification badge
  ///
  /// In en, this message translates to:
  /// **'Verification'**
  String get verification;

  /// Verify email heading
  ///
  /// In en, this message translates to:
  /// **'Verify your email'**
  String get verifyYourEmail;

  /// OTP screen subtitle
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit verification code sent to {email}'**
  String otpSubtitle(String email);

  /// Verify code button
  ///
  /// In en, this message translates to:
  /// **'Verify Code'**
  String get verifyCode;

  /// Resend code timer
  ///
  /// In en, this message translates to:
  /// **'Resend Code in {seconds}s'**
  String resendCodeIn(int seconds);

  /// Resend code button
  ///
  /// In en, this message translates to:
  /// **'Resend Code'**
  String get resendCode;

  /// Didn't receive code prompt
  ///
  /// In en, this message translates to:
  /// **'Didn\'t receive code? '**
  String get didntReceiveCode;

  /// Clear code button
  ///
  /// In en, this message translates to:
  /// **'Clear Code'**
  String get clearCode;

  /// OTP required validation message
  ///
  /// In en, this message translates to:
  /// **'Please enter the 6-digit OTP code'**
  String get otpRequired;

  /// New credentials badge
  ///
  /// In en, this message translates to:
  /// **'New Credentials'**
  String get newCredentials;

  /// Reset password screen heading
  ///
  /// In en, this message translates to:
  /// **'Reset your password'**
  String get resetYourPassword;

  /// Reset password screen subtitle
  ///
  /// In en, this message translates to:
  /// **'Create a strong new password with at least 8 characters and 1 number.'**
  String get resetPasswordSubtitle;

  /// New password label
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// Password must contain number validation
  ///
  /// In en, this message translates to:
  /// **'Must contain at least 1 number'**
  String get passwordMustContainNumber;

  /// Password min 8 characters validation
  ///
  /// In en, this message translates to:
  /// **'Min. 8 characters required'**
  String get passwordMin8Characters;

  /// Reset password button
  ///
  /// In en, this message translates to:
  /// **'Reset Password & Sign In'**
  String get resetPasswordAndSignIn;

  /// Password reset success title
  ///
  /// In en, this message translates to:
  /// **'Password Reset Successful'**
  String get passwordResetSuccessTitle;

  /// Password reset success description
  ///
  /// In en, this message translates to:
  /// **'Your password has been updated. You can now sign in with your new credentials.'**
  String get passwordResetSuccessDesc;

  /// Go to sign in button
  ///
  /// In en, this message translates to:
  /// **'Go to Sign In'**
  String get goToSignIn;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['bn', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'bn':
      return AppLocalizationsBn();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
