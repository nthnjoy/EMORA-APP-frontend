import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';
import 'laravel_session_service.dart';

class StoryService {
  const StoryService._();

  static Future<Map<String, dynamic>> createStory({
    required String content,
  }) async {
    if (!LaravelSessionService.isAuthenticated) {
      return {
        'success': false,
        'status_code': 401,
        'message': 'Sesi login tidak ditemukan. Silakan login ulang.',
      };
    }

    final payload = <String, dynamic>{
      'content': content,
    };

    try {
      final response = await http
          .post(
            Uri.parse(ApiConfig.storiesUrl),
            headers: _headers(),
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 20));

      return _parseResponse(
        response,
        defaultErrorMessage: 'Gagal menyimpan cerita.',
      );
    } on TimeoutException {
      return {
        'success': false,
        'status_code': 0,
        'message': 'Timeout saat menyimpan cerita.',
      };
    } catch (_) {
      return {
        'success': false,
        'status_code': 0,
        'message': 'Tidak dapat terhubung ke backend Laravel.',
      };
    }
  }

  static Future<Map<String, Object?>> fetchStories() async {
    if (!LaravelSessionService.isAuthenticated) {
      return {
        'success': false,
        'status_code': 401,
        'message': 'Sesi login tidak ditemukan. Silakan login ulang.',
        'data': <Map<String, Object?>>[],
      };
    }

    try {
      final response = await http
          .get(
            Uri.parse(ApiConfig.storiesUrl),
            headers: _headers(),
          )
          .timeout(const Duration(seconds: 20));

      return _parseResponse(
        response,
        defaultErrorMessage: 'Gagal mengambil data cerita.',
      );
    } on TimeoutException {
      return {
        'success': false,
        'status_code': 0,
        'message': 'Timeout saat mengambil cerita.',
        'data': <Map<String, Object?>>[],
      };
    } catch (_) {
      return {
        'success': false,
        'status_code': 0,
        'message': 'Tidak dapat terhubung ke backend Laravel.',
        'data': <Map<String, Object?>>[],
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
      'data': bodyJson['data'],
      'raw': bodyJson,
    };
  }
}
