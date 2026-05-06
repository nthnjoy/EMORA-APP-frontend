import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';
import 'laravel_session_service.dart';

class AiService {
  /// Mengirim pesan chat ke AI melalui Laravel backend.
  static Future<Map<String, dynamic>> sendChat(String message, {String? emotion}) async {
    try {
      final token = LaravelSessionService.accessToken;
      if (token == null) {
        return {'success': false, 'message': 'User tidak terautentikasi.'};
      }

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/ai/chat'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'message': message,
          'emotion': emotion,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Gagal menghubungi AI.',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Kesalahan koneksi: $e'};
    }
  }

  /// Mengecek status AI Engine.
  static Future<bool> checkAiStatus() async {
    try {
      final token = LaravelSessionService.accessToken;
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/ai/status'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['ai_engine_online'] ?? false;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Mengambil rekomendasi quote dari AI.
  static Future<Map<String, dynamic>> getRecommendation({String? mood, String? feeling}) async {
    try {
      final token = LaravelSessionService.accessToken;
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/ai/recommend?mood=$mood&feeling=$feeling'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return {'status': 'error', 'message': 'Gagal mengambil rekomendasi'};
    } catch (e) {
      return {'status': 'error', 'message': 'Kesalahan koneksi: $e'};
    }
  }
}
