import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:findbookstay_mobile/main.dart';
import 'package:findbookstay_mobile/screens/splash/splash_screen.dart';
import 'package:findbookstay_mobile/screens/onboarding/onboarding_screen.dart';
import 'package:findbookstay_mobile/screens/home/home_screen.dart';

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

  testWidgets('SplashScreen routes directly to HomeScreen when already onboarded', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({'hasSeenOnboarding': true});

    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const FindBookStayApp());
    await tester.pump(); // Splash screen appears
    expect(find.byType(SplashScreen), findsOneWidget);

    // Let splash finish
    await tester.pumpAndSettle(const Duration(milliseconds: 2500));
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.byType(OnboardingScreen), findsNothing);
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
}
