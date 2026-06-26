import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/login_page.dart';
import 'screens/main_navigation_page.dart';
import 'screens/splash_page.dart';
import 'services/theme_manager.dart';
import 'services/laravel_session_service.dart';

import 'services/notification_service.dart';
import 'services/notification_badge_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LaravelSessionService.initialize();
  await NotificationService().init();
  
  
  await _restoreNotificationSchedule();

  
  NotificationBadgeService().init();
  
  ThemeManager().init();
  runApp(const MyApp());
}

Future<void> _restoreNotificationSchedule() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final isEnabled = prefs.getBool('notifications_enabled') ?? false;
    
    if (isEnabled) {
      final hour = prefs.getInt('notification_hour') ?? 8;
      final minute = prefs.getInt('notification_minute') ?? 30;
      
      final time = TimeOfDay(hour: hour, minute: minute);
      final timeStr = '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
      debugPrint('🔄 Restoring notification schedule: $timeStr');
      await NotificationService().scheduleDailyNotification(time);
      debugPrint('✅ Notification schedule restored!');
    } else {
      debugPrint('⏸️ Notifications disabled, skipping restore');
    }
  } catch (e) {
    debugPrint('❌ Error restoring notification: $e');
  }
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
          title: 'Emolens',
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
          home: const SplashPage(),
        );
      },
    );
  }
}