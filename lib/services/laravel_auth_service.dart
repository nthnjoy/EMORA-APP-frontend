import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class LaravelAuthService {
  const LaravelAuthService._();

  static Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    final uri = Uri.parse(ApiConfig.loginUrl);

    try {
      final response = await http.post(
        uri,
        headers: {'Accept': 'application/json'},
        body: {'username': username, 'password': password},
      );

      Map<String, dynamic> bodyJson = {};
      if (response.body.isNotEmpty) {
        try {
          bodyJson = jsonDecode(response.body) as Map<String, dynamic>;
        } catch (_) {
          bodyJson = {};
        }
      }

      final bool success =
          response.statusCode == 200 && bodyJson['success'] == true;

      return {
        'success': success,
        'status_code': response.statusCode,
        'message': (bodyJson['message'] ?? 'Login gagal').toString(),
        'access_token': bodyJson['access_token'],
        'token_type': bodyJson['token_type'],
        'token_source': bodyJson['token_source'],
        'user': bodyJson['user'],
        'raw': bodyJson,
      };
    } catch (_) {
      return {
        'success': false,
        'status_code': 0,
        'message':
            'Tidak dapat terhubung ke backend Laravel. Periksa API_BASE_URL.',
      };
    }
  }
}
