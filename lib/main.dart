import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'core/config/env_config.dart';
import 'core/services/auth_service.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';
import 'screens/splash/splash_screen.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase (reads google-services.json on Android)
  try {
    await Firebase.initializeApp().timeout(const Duration(seconds: 4));
    NotificationService.instance.init().catchError((e) {
      debugPrint('NotificationService init failed: $e');
    });
  } catch (e) {
    debugPrint('Firebase/NotificationService init failed: $e');
  }

  try {
    await EnvConfig.init().timeout(const Duration(seconds: 2));
  } catch (e) {
    debugPrint('EnvConfig init failed: $e');
  }

  try {
    await AuthService.instance.init().timeout(const Duration(seconds: 2));
  } catch (e) {
    debugPrint('AuthService init failed: $e');
  }

  // Set system navigation bar & status bar colors for a seamless experience
  try {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: AppColors.background,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
  } catch (_) {}

  runApp(const ProviderScope(child: FindBookStayApp()));
}

class FindBookStayApp extends ConsumerWidget {
  const FindBookStayApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'FindBookStay',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: const SplashScreen(),
    );
  }
}
