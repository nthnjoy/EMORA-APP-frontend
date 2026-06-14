import 'package:flutter/foundation.dart';

class ApiConfig {
  const ApiConfig._();

  static const String _envBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );

  static String get baseUrl {
    if (_envBaseUrl.trim().isNotEmpty) {
      return _envBaseUrl.trim();
    }

    if (kIsWeb) {
      // Browser berjalan di laptop yang sama → langsung ke localhost, tanpa ngrok
      return 'http://127.0.0.1:8000';
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
      case TargetPlatform.iOS:
        // Perangkat mobile fisik → butuh ngrok agar bisa reach laptop
        return 'https://dollar-fiftieth-appease.ngrok-free.dev';
      default:
        return 'http://127.0.0.1:8000';
    }
  }

  static String get loginUrl => '$baseUrl/api/login';
  static String get logoutUrl => '$baseUrl/api/logout';
  static String get pingUrl => '$baseUrl/api/ping';
  static String get testDbUrl => '$baseUrl/api/test-db';
  static String get meUrl => '$baseUrl/api/me';
  static String get moodsUrl => '$baseUrl/api/moods';
  static String moodByIdUrl(String id) => '$baseUrl/api/moods/$id';
  static String get storiesUrl => '$baseUrl/api/stories';
  static String get updatePointsUrl => '$baseUrl/api/user/update-points';
  static String get buyThemeUrl => '$baseUrl/api/user/buy-theme';
  static String get setActiveThemeUrl => '$baseUrl/api/user/set-active-theme';
  static String get updateGenderUrl => '$baseUrl/api/user/update-gender';
  static String get modulesUrl => '$baseUrl/api/modules';

  // Counselor notifications endpoints
  static String get notificationsUrl => '$baseUrl/api/counselor/notifications';
  static String markNotificationReadUrl(String id) => '$baseUrl/api/counselor/notifications/$id/read';
}