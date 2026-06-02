import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/login_page.dart';
import 'screens/main_navigation_page.dart';
import 'services/theme_manager.dart';
import 'services/laravel_session_service.dart';

import 'services/notification_service.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LaravelSessionService.initialize();
  await NotificationService().init();
  ThemeManager().init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeManager(),
      builder: (context, _) {
        final primaryColor = ThemeManager().primaryColor;
        final backgroundColor = ThemeManager().backgroundColor;
        
        return MaterialApp(
          navigatorKey: navigatorKey,
          debugShowCheckedModeBanner: false,
          title: 'Emora App',
          themeMode: ThemeMode.light,
          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.light,
            primaryColor: primaryColor,
            scaffoldBackgroundColor: backgroundColor,
            colorScheme: ColorScheme.fromSeed(
              seedColor: primaryColor,
              primary: primaryColor,
              surface: ThemeManager().surfaceColor,
              onSurface: Colors.black87,
              background: backgroundColor,
              brightness: Brightness.light,
            ),
            textTheme: GoogleFonts.plusJakartaSansTextTheme(),
          ),
          home: LaravelSessionService.isAuthenticated
              ? const MainNavigationPage()
              : const LoginPage(),
        );
      },
    );
  }
}