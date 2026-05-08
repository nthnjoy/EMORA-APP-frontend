import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';
import 'laravel_session_service.dart';

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

  static Future<Map<String, dynamic>> updateUserPoints(int points) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.updatePointsUrl),
        headers: _headers(),
        body: jsonEncode({'points': points}),
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
      if (response.statusCode == 200 && result['success'] == true) {
        await LaravelSessionService.updateUser(result['user']);
        return {'success': true, 'data': result['user']};
      }
      return {'success': false, 'message': result['message'] ?? 'Gagal ganti tema'};
    } catch (e) {
      return {'success': false, 'message': 'Kesalahan koneksi'};
    }
  }

  static Future<Map<String, dynamic>> updateGender(String gender) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/api/user/update-gender');
    
    try {
      final response = await http.post(
        url,
        headers: _headers(),
        body: jsonEncode({
          'jenis_kelamin': gender,
        }),
      ).timeout(const Duration(seconds: 10));

      final result = jsonDecode(response.body);
      if (response.statusCode == 200 && result['success'] == true) {
        await LaravelSessionService.updateUser(result['user']);
        return {'success': true, 'message': 'Berhasil memperbarui jenis kelamin'};
      } else {
        return {'success': false, 'message': result['message'] ?? 'Gagal memperbarui jenis kelamin'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan koneksi'};
    }
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
}
