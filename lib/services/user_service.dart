import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'api_config.dart';
import 'laravel_session_service.dart';
import 'theme_manager.dart';

class UserService {
  const UserService._();

  static Map<String, String> _headers() {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': LaravelSessionService.authorizationHeader ?? '',
    };
  }

  static Future<Map<String, dynamic>> fetchCurrentUser() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.meUrl),
        headers: _headers(),
      ).timeout(const Duration(seconds: 10));

      final result = jsonDecode(response.body);
      if (response.statusCode == 200 && result['success'] == true) {
        await LaravelSessionService.updateUser(result['user']);
        return {'success': true, 'data': result['user']};
      }
      return {'success': false, 'message': result['message'] ?? 'Gagal memuat profil'};
    } catch (e) {
      return {'success': false, 'message': 'Kesalahan koneksi'};
    }
  }

  static Future<Map<String, dynamic>> logout() async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.logoutUrl),
        headers: _headers(),
      ).timeout(const Duration(seconds: 10));

      final result = jsonDecode(response.body);
      return {'success': response.statusCode == 200, 'message': result['message']};
    } catch (e) {
      return {'success': false, 'message': 'Kesalahan koneksi'};
    }
  }

  static Future<Map<String, dynamic>> updateUserPoints(int points, {String? moduleId}) async {
    try {
      final body = <String, dynamic>{'points': points};
      if (moduleId != null) {
        body['completed_module_id'] = moduleId;
      }
      
      final response = await http.post(
        Uri.parse(ApiConfig.updatePointsUrl),
        headers: _headers(),
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 10));

      final result = jsonDecode(response.body);
      if (response.statusCode == 200 && result['success'] == true) {
        await LaravelSessionService.updateUser(result['user']);
        return {'success': true, 'data': result['user']};
      }
      return {'success': false, 'message': result['message'] ?? 'Gagal update poin'};
    } catch (e) {
      return {'success': false, 'message': 'Kesalahan koneksi'};
    }
  }

  static Future<Map<String, dynamic>> buyTheme(String themeId, int price) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.buyThemeUrl),
        headers: _headers(),
        body: jsonEncode({'theme_id': themeId, 'cost': price}),
      ).timeout(const Duration(seconds: 10));

      final result = jsonDecode(response.body);
      if (response.statusCode == 200 && result['success'] == true) {
        await LaravelSessionService.updateUser(result['user']);
        return {'success': true, 'data': result['user']};
      }
      return {'success': false, 'message': result['message'] ?? 'Gagal beli tema'};
    } catch (e) {
      return {'success': false, 'message': 'Kesalahan koneksi'};
    }
  }

  static Future<Map<String, dynamic>> setActiveTheme(String themeId) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.setActiveThemeUrl),
        headers: _headers(),
        body: jsonEncode({'theme_id': themeId}),
      ).timeout(const Duration(seconds: 10));

      final result = jsonDecode(response.body);
      
      try {
        debugPrint('[UserService.setActiveTheme] status=${response.statusCode} body=${response.body}');
      } catch (_) {}
      if (response.statusCode == 200 && result['success'] == true) {
        
        final userResult = await fetchCurrentUser();
        if (userResult['success']) {
          return {'success': true, 'data': userResult['data']};
        }
        return {'success': true, 'data': result['user']};
      }
      return {'success': false, 'message': result['message'] ?? 'Gagal ganti tema'};
    } catch (e) {
      debugPrint('[UserService.setActiveTheme] exception: ${e.toString()}');
      return {'success': false, 'message': 'Kesalahan koneksi: ${e.toString()}'};
    }
  }

  static Future<Map<String, dynamic>> updateGender(String gender) async {
    
    final attempts = <Map<String, dynamic>>[
      {'contentType': 'application/json', 'body': jsonEncode({'jenis_kelamin': gender})},
      {'contentType': 'application/json', 'body': jsonEncode({'jenis_kelamin': _capitalize(gender)})},
      {'contentType': 'application/x-www-form-urlencoded', 'body': 'jenis_kelamin=${Uri.encodeComponent(gender)}'},
      {'contentType': 'application/x-www-form-urlencoded', 'body': 'jenis_kelamin=${Uri.encodeComponent(_capitalize(gender))}'},
    ];

    for (final attempt in attempts) {
      try {
        final headers = attempt['contentType'] == 'application/json'
            ? _headers()
            : {
                'Content-Type': attempt['contentType'] as String,
                'Accept': 'application/json',
                'Authorization': LaravelSessionService.authorizationHeader ?? '',
              };

        debugPrint('[UserService.updateGender] trying contentType=${attempt['contentType']} body=${attempt['body']}');

        final response = await http
            .post(
          Uri.parse(ApiConfig.updateGenderUrl),
          headers: headers,
          body: attempt['body'] as String,
        )
            .timeout(const Duration(seconds: 10));

        debugPrint('[UserService.updateGender] status=${response.statusCode} body=${response.body}');

        final result = jsonDecode(response.body);
        if (response.statusCode == 200 && result['success'] == true) {
          if (result['user'] != null) {
            await LaravelSessionService.updateUser(result['user']);
          } else {
            await fetchCurrentUser();
          }
          return {'success': true, 'message': 'Berhasil memperbarui jenis kelamin'};
        }
        
      } catch (e) {
        debugPrint('[UserService.updateGender] attempt exception: ${e.toString()}');
        
      }
    }

    return {'success': false, 'message': 'Gagal memperbarui jenis kelamin setelah beberapa percobaan'};
  }

  static Future<Map<String, dynamic>> fetchModules() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.modulesUrl),
        headers: _headers(),
      ).timeout(const Duration(seconds: 10));

      final result = jsonDecode(response.body);
      if (response.statusCode == 200 && result['success'] == true) {
        return {'success': true, 'data': result['data']};
      }
      return {'success': false, 'message': result['message'] ?? 'Gagal memuat modul'};
    } catch (e) {
      return {'success': false, 'message': 'Kesalahan koneksi'};
    }
  }

  static String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1).toLowerCase();
  }
}
