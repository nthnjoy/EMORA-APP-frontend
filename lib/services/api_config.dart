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
        return 'http://10.0.2.2:8000';
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
}
