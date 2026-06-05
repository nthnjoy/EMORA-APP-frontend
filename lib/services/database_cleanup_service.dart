import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';
import 'laravel_session_service.dart';

/// Service untuk membersihkan data dari database
/// Digunakan untuk testing/maintenance purposes
class DatabaseCleanupService {
  const DatabaseCleanupService._();

  /// Membersihkan semua mood data yang dibuat pada tanggal tertentu
  /// Untuk semua user yang punya data di tanggal tersebut
  static Future<Map<String, dynamic>> clearMoodsForDate(DateTime date) async {
    if (!LaravelSessionService.isAuthenticated) {
      return {
        'success': false,
        'message': 'Tidak ada sesi aktif',
      };
    }

    try {
      // Untuk bersihkan semua user, perlu endpoint khusus di backend
      // Sebagai alternatif, kita bisa bersihkan user saat ini
      final dateStr = date.toIso8601String().split('T')[0];
      
      final response = await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}/api/admin/cleanup-moods-by-date'),
            headers: _adminHeaders(),
            body: jsonEncode({'date': dateStr}),
          )
          .timeout(const Duration(seconds: 30));

      return _parseResponse(response);
    } on TimeoutException {
      return {
        'success': false,
        'message': 'Timeout saat membersihkan data',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: ${e.toString()}',
      };
    }
  }

  /// Membersihkan semua perasaan (feeling) data untuk tanggal tertentu
  static Future<Map<String, dynamic>> clearFeelingsForDate(DateTime date) async {
    if (!LaravelSessionService.isAuthenticated) {
      return {
        'success': false,
        'message': 'Tidak ada sesi aktif',
      };
    }

    try {
      final dateStr = date.toIso8601String().split('T')[0];
      
      final response = await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}/api/admin/cleanup-feelings-by-date'),
            headers: _adminHeaders(),
            body: jsonEncode({'date': dateStr}),
          )
          .timeout(const Duration(seconds: 30));

      return _parseResponse(response);
    } on TimeoutException {
      return {
        'success': false,
        'message': 'Timeout saat membersihkan data',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: ${e.toString()}',
      };
    }
  }

  /// Membersihkan mood dan feeling untuk hari ini untuk user saat ini
  static Future<Map<String, dynamic>> clearCurrentUserTodayData() async {
    if (!LaravelSessionService.isAuthenticated) {
      return {
        'success': false,
        'message': 'Tidak ada sesi aktif',
      };
    }

    try {
      final response = await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}/api/user/cleanup-today'),
            headers: _adminHeaders(),
          )
          .timeout(const Duration(seconds: 30));

      return _parseResponse(response);
    } on TimeoutException {
      return {
        'success': false,
        'message': 'Timeout saat membersihkan data',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: ${e.toString()}',
      };
    }
  }

  static Map<String, String> _adminHeaders() {
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

  static Map<String, dynamic> _parseResponse(http.Response response) {
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
      'message': bodyJson['message'] ?? (success ? 'OK' : 'Gagal'),
      'data': bodyJson['data'],
    };
  }
}
