import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';
import 'laravel_session_service.dart';

class MoodService {
  const MoodService._();

  static Future<Map<String, Object?>> fetchMoods() async {
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
            Uri.parse(ApiConfig.moodsUrl),
            headers: _headers(),
          )
          .timeout(const Duration(seconds: 20));

      final parsed = _parseResponse(
        response,
        defaultErrorMessage: 'Gagal mengambil data mood.',
      );

      final rawData = parsed['data'];
      final data = rawData is List
          ? rawData
              .whereType<Map>()
              .map((item) => Map<String, Object?>.from(item))
              .toList()
          : <Map<String, Object?>>[];

      return {
        ...parsed,
        'data': data,
      };
    } on TimeoutException {
      return {
        'success': false,
        'status_code': 0,
        'message': 'Timeout saat mengambil data mood.',
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

  static Future<Map<String, dynamic>> createMood({
    required String moodLabel,
    required String feeling,
    required int emotionCode,
    DateTime? recordedAt,
  }) async {
    if (!LaravelSessionService.isAuthenticated) {
      return {
        'success': false,
        'status_code': 401,
        'message': 'Sesi login tidak ditemukan. Silakan login ulang.',
      };
    }

    final payload = <String, dynamic>{
      'mood_label': moodLabel,
      'perasaan': feeling,
      'emosi_kode': emotionCode,
      'recorded_at': (recordedAt ?? DateTime.now().toUtc()).toIso8601String(),
    };

    try {
      final response = await http
          .post(
            Uri.parse(ApiConfig.moodsUrl),
            headers: _headers(),
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 20));

      return _parseResponse(
        response,
        defaultErrorMessage: 'Gagal menyimpan mood.',
      );
    } on TimeoutException {
      return {
        'success': false,
        'status_code': 0,
        'message': 'Timeout saat menyimpan mood.',
      };
    } catch (_) {
      return {
        'success': false,
        'status_code': 0,
        'message': 'Tidak dapat terhubung ke backend Laravel.',
      };
    }
  }

  static Future<Map<String, dynamic>> deleteMood(String moodId) async {
    if (!LaravelSessionService.isAuthenticated) {
      return {
        'success': false,
        'status_code': 401,
        'message': 'Sesi login tidak ditemukan. Silakan login ulang.',
      };
    }

    try {
      final response = await http
          .delete(
            Uri.parse(ApiConfig.moodByIdUrl(moodId)),
            headers: _headers(),
          )
          .timeout(const Duration(seconds: 20));

      return _parseResponse(
        response,
        defaultErrorMessage: 'Gagal menghapus mood.',
      );
    } on TimeoutException {
      return {
        'success': false,
        'status_code': 0,
        'message': 'Timeout saat menghapus mood.',
      };
    } catch (_) {
      return {
        'success': false,
        'status_code': 0,
        'message': 'Tidak dapat terhubung ke backend Laravel.',
      };
    }
  }

  static Future<Map<String, dynamic>> clearMoodsForToday() async {
    if (!LaravelSessionService.isAuthenticated) {
      return {
        'success': false,
        'status_code': 401,
        'message': 'Sesi login tidak ditemukan. Silakan login ulang.',
      };
    }

    try {
      final moods = await fetchMoods();
      if (moods['success'] != true) {
        return moods;
      }

      final moodsList = moods['data'] as List? ?? [];
      final today = DateTime.now();
      final todayStart = DateTime(today.year, today.month, today.day);
      final todayEnd = todayStart.add(const Duration(days: 1));

      int deletedCount = 0;
      for (final mood in moodsList.whereType<Map<String, dynamic>>()) {
        final createdAt = mood['created_at'];
        if (createdAt != null) {
          try {
            final recordDate = DateTime.parse(createdAt.toString()).toLocal();
            if (recordDate.isAfter(todayStart) && recordDate.isBefore(todayEnd)) {
              final moodId = mood['id']?.toString();
              if (moodId != null) {
                await deleteMood(moodId);
                deletedCount++;
              }
            }
          } catch (_) {
            
          }
        }
      }

      return {
        'success': true,
        'status_code': 200,
        'message': 'Berhasil menghapus $deletedCount mood dari hari ini.',
        'deleted_count': deletedCount,
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
      'ai_feedback': bodyJson['ai_feedback'],
      'ai_level': bodyJson['ai_level'] ?? 0,
      'data': bodyJson['data'],
      'raw': bodyJson,
    };
  }
}
