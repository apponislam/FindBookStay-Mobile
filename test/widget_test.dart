import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:findbookstay_mobile/main.dart';
import 'package:findbookstay_mobile/screens/splash/splash_screen.dart';
import 'package:findbookstay_mobile/screens/onboarding/onboarding_screen.dart';
import 'package:findbookstay_mobile/screens/auth/register_role_screen.dart';
import 'package:findbookstay_mobile/screens/auth/register_form_screen.dart';
import 'package:findbookstay_mobile/screens/auth/forgot_password_screen.dart';
import 'package:findbookstay_mobile/screens/auth/otp_verification_screen.dart';
import 'package:findbookstay_mobile/screens/auth/reset_password_screen.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('App starts with SplashScreen showing logo and tagline', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const FindBookStayApp());
    await tester.pump(); // Initial frame

    // Verify SplashScreen is loaded
    expect(find.byType(SplashScreen), findsOneWidget);
    expect(find.text('0% Broker Fee | Stays, Rentals & Turfs'), findsOneWidget);
    expect(find.text('FINDBOOKSTAY'), findsOneWidget);

    // Let the splash timer finish (2.1s) and transition to Onboarding
    await tester.pumpAndSettle(const Duration(milliseconds: 2500));
    expect(find.byType(OnboardingScreen), findsOneWidget);
    expect(find.text('Rent Verified Spaces'), findsOneWidget);
  });

  testWidgets('Navigates across exact onboarding slide sequence (RENT -> BOOK -> SPORTS -> BUY)', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const MaterialApp(home: OnboardingScreen()));
    await tester.pumpAndSettle();

    // 01 / RENT
    expect(find.text('01 / RENT'), findsOneWidget);
    expect(find.text('Rent Verified Spaces'), findsOneWidget);

    // Tap Next -> 02 / BOOK
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('02 / BOOK'), findsOneWidget);
    expect(find.text('Book Stays & Getaways'), findsOneWidget);

    // Tap Next -> 03 / SPORTS
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('03 / SPORTS'), findsOneWidget);
    expect(find.text('Reserve Sports Turfs'), findsOneWidget);

    // Tap Next -> 04 / BUY
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('04 / BUY'), findsOneWidget);
    expect(find.text('Buy Verified Properties'), findsOneWidget);
    expect(find.text('Get Started'), findsOneWidget);
  });

  testWidgets('Role Selection Screen allows choosing between Tenant and Host', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const MaterialApp(home: RegisterRoleScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Step 1 of 2'), findsOneWidget);
    expect(find.text('Select your role'), findsOneWidget);
    expect(find.text('Tenant, Guest or Player'), findsOneWidget);
    expect(find.text('Host, Landlord or Turf Owner'), findsOneWidget);

    // Tap Host role card
    await tester.tap(find.text('Host, Landlord or Turf Owner'));
    await tester.pumpAndSettle();

    // Tap Continue
    await tester.tap(find.text('Continue to Sign Up'));
    await tester.pumpAndSettle();

    // Verifies transition to Step 2 with Host account title
    expect(find.byType(RegisterFormScreen), findsOneWidget);
    expect(find.text('Create Host Account'), findsOneWidget);
  });

  testWidgets('Register Form validates required fields and terms checkbox', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const MaterialApp(
        home: RegisterFormScreen(initialRole: UserRole.tenant),
      ),
    );
    await tester.pumpAndSettle();

    // Tap Create Account without input
    await tester.tap(find.text('Create Tenant Account'));
    await tester.pumpAndSettle();

    // Verify error badges appear on upper side
    expect(find.text('Full name is required'), findsOneWidget);
    expect(find.text('Email address is required'), findsOneWidget);
    expect(find.text('Password is required'), findsOneWidget);
    expect(find.text('Please accept the Terms to continue'), findsOneWidget);
  });

  testWidgets('Forgot Password and OTP Verification flow', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const MaterialApp(home: ForgotPasswordScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Account Recovery'), findsOneWidget);
    expect(find.text('Forgot your password?'), findsOneWidget);

    // Enter email
    await tester.enterText(
      find.byType(TextField),
      'test@findbookstay.com',
    );
    await tester.pumpAndSettle();

    // Tap Send Reset Code
    await tester.tap(find.text('Send Reset Code'));
    await tester.pump(); // Start loading
    await tester.pump(const Duration(milliseconds: 1200));
    await tester.pumpAndSettle();

    // Navigates to OTP Verification
    expect(find.byType(OtpVerificationScreen), findsOneWidget);
    expect(find.text('Enter 6-Digit Code'), findsOneWidget);
    expect(find.textContaining('test@findbookstay.com'), findsOneWidget);
  });

  testWidgets('Reset Password Screen verifies real-time match indicator', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const MaterialApp(
        home: ResetPasswordScreen(email: 'user@example.com'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Create New Password'), findsOneWidget);

    final textFields = find.byType(TextField);
    expect(textFields, findsNWidgets(2));

    // Enter matching passwords
    await tester.enterText(textFields.at(0), 'Secret123');
    await tester.enterText(textFields.at(1), 'Secret123');
    await tester.pumpAndSettle();

    // Verify real-time match indicator
    expect(find.text('Passwords match perfectly'), findsOneWidget);

    // Tap Reset Password
    await tester.tap(find.text('Reset Password & Sign In'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1400));
    await tester.pumpAndSettle();

    // Verify Success Dialog
    expect(find.text('Password Updated!'), findsOneWidget);
    expect(find.text('Sign In Now'), findsOneWidget);
  });
}
