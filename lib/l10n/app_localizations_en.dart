// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'FindBookStay';

  @override
  String get appTagline => 'Find, Book & Stay Anywhere';

  @override
  String get navExplore => 'Explore';

  @override
  String get navBookings => 'Bookings';

  @override
  String get navSaved => 'Saved';

  @override
  String get navInbox => 'Inbox';

  @override
  String get navProfile => 'Profile';

  @override
  String get search => 'Search';

  @override
  String get searchPlaceholder => 'Search destinations, properties...';

  @override
  String get filter => 'Filter';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get saving => 'Saving...';

  @override
  String get edit => 'Edit';

  @override
  String get delete => 'Delete';

  @override
  String get confirm => 'Confirm';

  @override
  String get back => 'Back';

  @override
  String get next => 'Next';

  @override
  String get done => 'Done';

  @override
  String get retry => 'Retry';

  @override
  String get viewAll => 'View All';

  @override
  String get seeAll => 'See All';

  @override
  String get seeMore => 'See More';

  @override
  String get seeLess => 'See Less';

  @override
  String get loading => 'Loading...';

  @override
  String get signIn => 'Sign In';

  @override
  String get signUp => 'Sign Up';

  @override
  String get signOut => 'Sign Out';

  @override
  String get register => 'Register';

  @override
  String get createAnAccount => 'Create an Account';

  @override
  String get guestMode => 'Guest Mode';

  @override
  String get guestUser => 'Guest User';

  @override
  String get signInToContinue =>
      'Sign in to access your full profile, saved wishlists, and bookings.';

  @override
  String get dontHaveAccount => 'Don\'t have an account? ';

  @override
  String get alreadyHaveAccount => 'Already have an account? ';

  @override
  String get gotIt => 'Got it';

  @override
  String get joinFindBookStay => 'Join FindBookStay';

  @override
  String get guestHeroSubtitle =>
      'Sign in or create an account to book stays, rent flats, and reserve sports turfs with zero broker fees.';

  @override
  String get findBookStayBadge => 'FIND · BOOK · STAY';

  @override
  String get accountSettings => 'Account Settings';

  @override
  String get preferences => 'Preferences';

  @override
  String get personalInfo => 'Personal Information';

  @override
  String get personalInfoSubtitle =>
      'Name, phone, address, and profile details';

  @override
  String get paymentMethods => 'Payment Methods & Invoices';

  @override
  String get paymentMethodsSubtitle => 'Cards, bKash, transaction history';

  @override
  String get notifications => 'Notification Preferences';

  @override
  String get notificationsSubtitle => 'Booking alerts, owner messages';

  @override
  String get languageAndCurrency => 'Language & Currency';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get english => 'English';

  @override
  String get bangla => 'বাংলা';

  @override
  String get themeMode => 'Theme Mode';

  @override
  String get activeDarkMode => 'Dark Mode (Active)';

  @override
  String get activeLightMode => 'Light Mode (Active)';

  @override
  String get lightMode => 'Light Mode';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get systemDefault => 'System Default';

  @override
  String get legalAndSupport => 'Legal & Support';

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String get termsOfServiceSubtitle =>
      'Platform rules and direct booking terms';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get privacyPolicySubtitle => 'How FindBookStay protects your data';

  @override
  String get helpCenter => 'Help Center & 24/7 Support';

  @override
  String get helpCenterSubtitle => 'FAQs, contact agent, safety center';

  @override
  String get signOutConfirmTitle => 'Sign Out';

  @override
  String get signOutConfirmMessage =>
      'Are you sure you want to sign out? You can sign back in at any time.';

  @override
  String get signedOutSuccess =>
      'Signed out successfully. Switched to Guest mode.';

  @override
  String get appVersionInfo => 'FindBookStay v1.0.0 (Build 1) · 0% Broker Fees';

  @override
  String get accountProfile => 'Account Profile';

  @override
  String userGreeting(String name) {
    return 'Hi, $name';
  }

  @override
  String get whereToStayOrPlay => 'Where to stay or play?';

  @override
  String get exploreSearchSubtext =>
      'Flats · Bachelor seats · Hotels · Sports turfs';

  @override
  String get categoryAllSpaces => 'All Spaces';

  @override
  String get categoryRentFlats => 'Rent Flats';

  @override
  String get categoryHotelStays => 'Hotel Stays';

  @override
  String get categorySportsTurfs => 'Sports Turfs';

  @override
  String get categoryBuyProperty => 'Buy Property';

  @override
  String get badgeDirect => '100% DIRECT';

  @override
  String get zeroBrokerFeesTitle => 'Zero Broker Fees Guaranteed';

  @override
  String get zeroBrokerFeesSubtitle =>
      'Rent family apartments or reserve turfs directly with owners.';

  @override
  String get featuredAcrossSpaces => 'Featured Across Spaces';

  @override
  String get noListingsAvailable => 'No listings available yet';

  @override
  String get noListingsDesc =>
      'Check back shortly as verified property owners add new listings.';

  @override
  String get myBookingsAndStays => 'My Bookings & Stays';

  @override
  String get manageReservations => 'Manage your reservations';

  @override
  String get manageReservationsSubtitle =>
      'Sign in to view your upcoming sports turf slots, hotel reservations, and rental viewing appointments in one place.';

  @override
  String get signInToViewBookings => 'Sign In to View Bookings';

  @override
  String get filterUpcoming => 'Upcoming';

  @override
  String get filterCompleted => 'Completed';

  @override
  String get filterCancelled => 'Cancelled';

  @override
  String get noBookingsFound => 'No reservations found';

  @override
  String get noBookingsDesc =>
      'When you book turf slots, resort suites, or schedule rental viewings, your bookings will be shown here.';

  @override
  String get savedWishlist => 'Saved Wishlist';

  @override
  String get saveFavoriteSpots => 'Save your favorite spots';

  @override
  String get saveFavoriteSpotsSubtitle =>
      'Sign in to keep track of family flats, hotel getaways, and sports turfs you love across all your devices.';

  @override
  String get signInToViewWishlist => 'Sign In to View Wishlist';

  @override
  String get wishlistSynced => 'Wishlist synced with your account';

  @override
  String get wishlistEmpty => 'Your wishlist is empty';

  @override
  String get wishlistEmptyDesc =>
      'Tap the heart icon on any flat, hotel, or turf to save it to your wishlist.';

  @override
  String get inboxAndInquiries => 'Inbox & Inquiries';

  @override
  String get chatDirectlyOwners => 'Chat directly with owners';

  @override
  String get chatDirectlyOwnersSubtitle =>
      'Sign in to message verified property landlords, inquire about bachelor seats, and confirm turf reservations in real-time.';

  @override
  String get signInToAccessMessages => 'Sign In to Access Messages';

  @override
  String get noMessages => 'No conversations yet';

  @override
  String get noMessagesDesc =>
      'When you message property owners, landlord representatives, or turf managers, your chats will appear here.';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get basicInformation => 'Basic Information';

  @override
  String get fullName => 'Full Name';

  @override
  String get phone => 'Phone Number';

  @override
  String get emailAddress => 'Email Address';

  @override
  String get verified => 'Verified';

  @override
  String get unverified => 'Unverified';

  @override
  String get presentAddress => 'Present Address';

  @override
  String get permanentAddress => 'Permanent Address';

  @override
  String get sameAsPresent => 'Permanent address is same as present';

  @override
  String get street => 'Street Address';

  @override
  String get city => 'City';

  @override
  String get state => 'State / Division';

  @override
  String get zipCode => 'Postal / Zip Code';

  @override
  String get changeProfilePhoto => 'Change Profile Photo';

  @override
  String get chooseFromGallery => 'Choose from Gallery';

  @override
  String get takePhoto => 'Take a Photo';

  @override
  String get removePhoto => 'Remove Selected Photo';

  @override
  String get profileUpdatedSuccess => 'Profile updated successfully!';

  @override
  String get pleaseEnterFullName => 'Please enter your full name';

  @override
  String get signInToAccount => 'Sign In to Account';

  @override
  String get signInDescription =>
      'Sign in to access your verified rentals, boutique stays, turf slots, and account preferences.';

  @override
  String get emailAddressRequired => 'Email address is required';

  @override
  String get validEmailRequired => 'Please enter a valid email';

  @override
  String get password => 'Password';

  @override
  String get passwordRequired => 'Password is required';

  @override
  String get passwordMinLength => 'Min. 6 characters required';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get resetPassword => 'Reset Password';

  @override
  String get verifyOtp => 'Verify OTP';

  @override
  String get welcomeBack => 'Welcome Back';

  @override
  String get security => 'Security';

  @override
  String get skip => 'Skip';

  @override
  String get getStarted => 'Get Started';

  @override
  String get onboardingRentTitle => 'Rent Verified Spaces';

  @override
  String get onboardingRentSubtitle =>
      'Rent family apartments, furnished flats, and flexible bachelor seats directly from verified owners with zero broker fees.';

  @override
  String get onboardingRentTag => '01 / RENT';

  @override
  String get onboardingBookTitle => 'Book Stays & Getaways';

  @override
  String get onboardingBookSubtitle =>
      'Discover and book boutique hotels, vacation resorts, and short stays with transparent pricing and instant confirmations.';

  @override
  String get onboardingBookTag => '02 / BOOK';

  @override
  String get onboardingSportsTitle => 'Reserve Sports Turfs';

  @override
  String get onboardingSportsSubtitle =>
      'Book football pitches, cricket nets, and sports arenas by the hour with real-time slot availability.';

  @override
  String get onboardingSportsTag => '03 / SPORTS';

  @override
  String get onboardingBuyTitle => 'Buy Verified Properties';

  @override
  String get onboardingBuySubtitle =>
      'Explore premium residential apartments, luxury villas, and verified plots with direct developer & owner connections.';

  @override
  String get onboardingBuyTag => '04 / BUY';

  @override
  String get step1Of2 => 'Step 1 of 2';

  @override
  String get selectYourRole => 'Select your role';

  @override
  String get selectYourRoleSubtitle =>
      'Choose how you want to use FindBookStay. You can always switch or manage both from account settings.';

  @override
  String get roleTenantTitle => 'Tenant, Guest or Player';

  @override
  String get roleTenantDesc =>
      'Rent family apartments, bachelor seats, book hotel stays, or reserve sports turfs.';

  @override
  String get roleHostTitle => 'Host, Landlord or Turf Owner';

  @override
  String get roleHostDesc =>
      'List residential properties, rent shared seats, or manage sports turf reservations.';

  @override
  String get continueToSignUp => 'Continue to Sign Up';

  @override
  String get createAccount => 'Create Account';

  @override
  String get step1Title => 'Personal Details';

  @override
  String get step1Subtitle =>
      'Enter your name, contact information, and upload an optional profile photo.';

  @override
  String get step2Title => 'Addresses & Referral';

  @override
  String get step2Subtitle =>
      'Provide your present address and permanent residence details for verified booking records.';

  @override
  String get step3Title => 'Account Security';

  @override
  String get step3Subtitle =>
      'Create a strong password and accept our terms to safeguard your account.';

  @override
  String stepCountOf(int current, int total) {
    return 'Step $current of $total';
  }

  @override
  String get nextStep => 'Next Step';

  @override
  String get previousStep => 'Previous Step';

  @override
  String get completeRegistration => 'Complete Registration';

  @override
  String get takePhotoWithCamera => 'Take Photo with Camera';

  @override
  String get profilePhoto => 'Profile Photo';

  @override
  String get fullNameRequired => 'Full name is required';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get confirmPasswordRequired => 'Confirm password is required';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get passwordsMatch => 'Passwords match';

  @override
  String get referralCodeOptional => 'Referral Code (Optional)';

  @override
  String get termsAgreementText =>
      'I agree to the Terms of Service and Privacy Policy';

  @override
  String get pleaseAcceptTerms =>
      'Please accept Terms of Service & Privacy Policy to continue';

  @override
  String get accountRecovery => 'Account Recovery';

  @override
  String get forgotYourPassword => 'Forgot your password?';

  @override
  String get forgotPasswordSubtitle =>
      'Enter your registered email address and we will send you a 6-digit code to reset your password.';

  @override
  String get sendResetCode => 'Send Reset Code';

  @override
  String get rememberPasswordQuestion => 'Remember your password? ';

  @override
  String get verification => 'Verification';

  @override
  String get verifyYourEmail => 'Verify your email';

  @override
  String otpSubtitle(String email) {
    return 'Enter the 6-digit verification code sent to $email';
  }

  @override
  String get verifyCode => 'Verify Code';

  @override
  String resendCodeIn(int seconds) {
    return 'Resend Code in ${seconds}s';
  }

  @override
  String get resendCode => 'Resend Code';

  @override
  String get didntReceiveCode => 'Didn\'t receive code? ';

  @override
  String get clearCode => 'Clear Code';

  @override
  String get otpRequired => 'Please enter the 6-digit OTP code';

  @override
  String get newCredentials => 'New Credentials';

  @override
  String get resetYourPassword => 'Reset your password';

  @override
  String get resetPasswordSubtitle =>
      'Create a strong new password with at least 8 characters and 1 number.';

  @override
  String get newPassword => 'New Password';

  @override
  String get passwordMustContainNumber => 'Must contain at least 1 number';

  @override
  String get passwordMin8Characters => 'Min. 8 characters required';

  @override
  String get resetPasswordAndSignIn => 'Reset Password & Sign In';

  @override
  String get passwordResetSuccessTitle => 'Password Reset Successful';

  @override
  String get passwordResetSuccessDesc =>
      'Your password has been updated. You can now sign in with your new credentials.';

  @override
  String get goToSignIn => 'Go to Sign In';
}
