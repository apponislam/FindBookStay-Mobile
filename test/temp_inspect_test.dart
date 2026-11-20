import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:findbookstay/screens/profile/personal_info_screen.dart';
import 'package:findbookstay/core/theme/app_theme.dart';
import 'package:findbookstay/core/theme/theme_controller.dart';
import 'package:findbookstay/features/auth/presentation/providers/auth_providers.dart';
import 'package:findbookstay/features/auth/data/models/user_model.dart';

void main() {
  testWidgets('Test PersonalInfoScreen image source sheet in Light & Dark mode', (tester) async {
    final container = ProviderContainer();

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.light,
          home: const PersonalInfoScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Tap edit button
    final editBtn = find.text('Edit');
    expect(editBtn, findsOneWidget);
    await tester.tap(editBtn);
    await tester.pumpAndSettle();

    // Tap camera icon to open sheet
    final cameraBtn = find.byIcon(Icons.camera_alt_rounded);
    expect(cameraBtn, findsOneWidget);
    await tester.tap(cameraBtn);
    await tester.pumpAndSettle();

    final galleryTextFinder = find.text('Choose from Gallery');
    final cameraTextFinder = find.text('Take a Photo');

    expect(galleryTextFinder, findsOneWidget);
    expect(cameraTextFinder, findsOneWidget);

    final Text galleryText = tester.widget(galleryTextFinder);
    final Text cameraText = tester.widget(cameraTextFinder);

    print('Gallery text style: ${galleryText.style}');
    print('Camera text style: ${cameraText.style}');
  });
}
