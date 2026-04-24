import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'services/laravel_session_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LaravelSessionService.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'IT Del Emolens',
      home: const SplashScreen(),
    );
  }
}