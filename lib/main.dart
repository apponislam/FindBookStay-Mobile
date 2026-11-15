import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_ui/material_ui.dart';

import 'core/config/env_config.dart';
import 'core/services/auth_service.dart';
import 'core/theme/app_colors.dart';
import 'screens/splash/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await EnvConfig.init();
  } catch (e) {
    debugPrint('EnvConfig init failed: $e');
  }

  try {
    await AuthService.instance.init();
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

  runApp(
    const ProviderScope(
      child: FindBookStayApp(),
    ),
  );
}

class FindBookStayApp extends StatelessWidget {
  const FindBookStayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FindBookStay',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          secondary: AppColors.accent,
          surface: AppColors.surface,
        ),
        fontFamily: GoogleFonts.plusJakartaSans().fontFamily,
      ),
      home: const SplashScreen(),
    );
  }
}
