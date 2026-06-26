import 'dart:convert';
import 'package:http/http.dart' as http;

class CisService {
  static Future<Map<String, dynamic>?> login(String username) async {
    final url = Uri.parse(
      "https://cis-dev.del.ac.id/api/library-api/mahasiswa?username=$username&status=Aktif&limit=1",
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data['data'] != null && data['data'].length > 0) {
        return data['data'][0];
      }
    }

    return null;
  }
}
