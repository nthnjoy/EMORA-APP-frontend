import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class SystemService {
  const SystemService._();

  static Future<Map<String, dynamic>> ping() async {
    return _get(ApiConfig.pingUrl, fallbackMessage: 'Backend tidak merespons.');
  }

  static Future<Map<String, dynamic>> testDb() async {
    return _get(
      ApiConfig.testDbUrl,
      fallbackMessage: 'Gagal menguji koneksi MongoDB.',
    );
  }

  static Future<Map<String, dynamic>> _get(
    String url, {
    required String fallbackMessage,
  }) async {
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 20));

      Map<String, dynamic> bodyJson = {};
      if (response.body.isNotEmpty) {
        try {
          bodyJson = jsonDecode(response.body) as Map<String, dynamic>;
        } catch (_) {
          bodyJson = {};
        }
      }

      final bool success = response.statusCode >= 200 &&
          response.statusCode < 300 &&
          bodyJson['success'] == true;

      return {
        'success': success,
        'status_code': response.statusCode,
        'message':
            (bodyJson['message'] ?? (success ? 'OK' : fallbackMessage))
                .toString(),
        'data': bodyJson,
      };
    } on TimeoutException {
      return {
        'success': false,
        'status_code': 0,
        'message': 'Timeout saat menghubungi backend.',
      };
    } catch (_) {
      return {
        'success': false,
        'status_code': 0,
        'message': 'Tidak dapat terhubung ke backend Laravel.',
      };
    }
  }
}
