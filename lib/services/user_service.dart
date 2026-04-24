import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';
import 'laravel_session_service.dart';

class UserService {
  const UserService._();

  static Future<Map<String, dynamic>> fetchCurrentUser() async {
    if (!LaravelSessionService.isAuthenticated) {
      return {
        'success': false,
        'status_code': 401,
        'message': 'Sesi login tidak ditemukan. Silakan login ulang.',
      };
    }

    try {
      final response = await http
          .get(
            Uri.parse(ApiConfig.meUrl),
            headers: _headers(),
          )
          .timeout(const Duration(seconds: 20));

      final parsed = _parseResponse(
        response,
        defaultErrorMessage: 'Gagal mengambil data profil.',
      );

      if (parsed['success'] == true) {
        await LaravelSessionService.updateUser(parsed['user']);
      }

      return parsed;
    } on TimeoutException {
      return {
        'success': false,
        'status_code': 0,
        'message': 'Timeout saat mengambil profil.',
      };
    } catch (_) {
      return {
        'success': false,
        'status_code': 0,
        'message': 'Tidak dapat terhubung ke backend Laravel.',
      };
    }
  }

  static Future<Map<String, dynamic>> logout() async {
    if (!LaravelSessionService.isAuthenticated) {
      return {
        'success': true,
        'status_code': 200,
        'message': 'Sesi sudah berakhir.',
      };
    }

    try {
      final response = await http
          .post(
            Uri.parse(ApiConfig.logoutUrl),
            headers: _headers(),
          )
          .timeout(const Duration(seconds: 20));

      return _parseResponse(
        response,
        defaultErrorMessage: 'Gagal logout dari server.',
      );
    } on TimeoutException {
      return {
        'success': false,
        'status_code': 0,
        'message': 'Timeout saat logout.',
      };
    } catch (_) {
      return {
        'success': false,
        'status_code': 0,
        'message': 'Tidak dapat terhubung ke backend Laravel.',
      };
    }
  }

  static Map<String, String> _headers() {
    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };

    final authHeader = LaravelSessionService.authorizationHeader;
    if (authHeader != null) {
      headers['Authorization'] = authHeader;
    }

    return headers;
  }

  static Map<String, dynamic> _parseResponse(
    http.Response response, {
    required String defaultErrorMessage,
  }) {
    Map<String, dynamic> bodyJson = {};
    if (response.body.isNotEmpty) {
      try {
        bodyJson = jsonDecode(response.body) as Map<String, dynamic>;
      } catch (_) {
        bodyJson = {};
      }
    }

    final isHttpOk = response.statusCode >= 200 && response.statusCode < 300;
    final success = isHttpOk && bodyJson['success'] == true;

    return {
      'success': success,
      'status_code': response.statusCode,
      'message':
          (bodyJson['message'] ?? (success ? 'OK' : defaultErrorMessage))
              .toString(),
      'user': bodyJson['user'],
      'raw': bodyJson,
    };
  }
}
