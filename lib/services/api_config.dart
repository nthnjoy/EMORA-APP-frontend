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
      return 'http://127.0.0.1:8000';
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
      case TargetPlatform.iOS:
        return 'http://10.102.248.162:8000'; // IP laptop kamu saat ini
      default:
        return 'http://10.102.248.162:8000';
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
}
