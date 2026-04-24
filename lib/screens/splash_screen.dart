import 'package:flutter/material.dart';
import 'dart:async';
import 'login_page.dart';
import 'main_navigation_page.dart';
import '../services/laravel_session_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      final targetPage = LaravelSessionService.isAuthenticated
          ? const MainNavigationPage()
          : const LoginPage();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => targetPage),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: const Color(0xFFDCE8F4),
        child: Center(
          child: Image.asset(
            'assets/image/emolens_logo.jpeg',
            width: 150,
          ),
        ),
      ),
    );
  }
}