import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:findbookstay_mobile/main.dart';
import 'package:findbookstay_mobile/screens/onboarding/onboarding_screen.dart';
import 'package:findbookstay_mobile/screens/home/home_screen.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Renders OnboardingScreen when hasSeenOnboarding is false',
      (WidgetTester tester) async {
    // Provide sufficient test screen size to avoid any viewport layout overflow
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const FindBookStayApp(hasSeenOnboarding: false));
    await tester.pumpAndSettle();

    // Verify OnboardingScreen is shown
    expect(find.byType(OnboardingScreen), findsOneWidget);

    // Verify Title of Slide 1
    expect(find.text('Verified Living Spaces'), findsOneWidget);

    // Verify Skip and Next buttons exist
    expect(find.text('Skip'), findsOneWidget);
    expect(find.text('Next'), findsOneWidget);
  });

  testWidgets('Navigates between onboarding slides when tapping Next',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const FindBookStayApp(hasSeenOnboarding: false));
    await tester.pumpAndSettle();

    // Verify Slide 1
    expect(find.text('Verified Living Spaces'), findsOneWidget);

    // Tap Next
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    // Verify Slide 2 is now visible
    expect(find.text('Flexible Bachelor Seats'), findsOneWidget);
  });

  testWidgets('Renders HomeScreen directly when hasSeenOnboarding is true',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const FindBookStayApp(hasSeenOnboarding: true));
    await tester.pumpAndSettle();

    // Verify HomeScreen is rendered and Onboarding is bypassed
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.byType(OnboardingScreen), findsNothing);
  });
}
