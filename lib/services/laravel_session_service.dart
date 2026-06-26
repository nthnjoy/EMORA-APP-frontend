import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LaravelSessionService {
  LaravelSessionService._();

  static const String _prefsKey = 'laravel_session';

  static String? _accessToken;
  static String? _tokenType;
  static String? _tokenSource;
  static Map<String, dynamic>? _user;

  static Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionData = prefs.getString(_prefsKey);
    if (sessionData != null) {
      try {
        final data = jsonDecode(sessionData) as Map<String, dynamic>;
        _accessToken = data['access_token'] as String?;
        _tokenType = data['token_type'] as String?;
        _tokenSource = data['token_source'] as String?;
        _user = data['user'] as Map<String, dynamic>?;
      } catch (_) {
        
        await _clearPrefs();
      }
    }
  }

  static Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final data = {
      'access_token': _accessToken,
      'token_type': _tokenType,
      'token_source': _tokenSource,
      'user': _user,
    };
    await prefs.setString(_prefsKey, jsonEncode(data));
  }

  static Future<void> _clearPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsKey);
  }

  static Future<void> initialize() async {
    await _loadFromPrefs();
  }

  static Future<void> updateUser(dynamic rawUser) async {
    if (rawUser is Map<String, dynamic>) {
      _user = Map<String, dynamic>.from(rawUser);
    } else if (rawUser is Map) {
      _user = Map<String, dynamic>.from(rawUser);
    } else {
      _user = null;
    }
    await _saveToPrefs();
  }

  static String get activeThemeId => _user?['active_theme']?.toString() ?? 'default';

  static List<String> get purchasedThemeIds {
    final themes = _user?['purchased_themes'];
    if (themes is List) {
      return themes.map((e) => e.toString()).toList();
    }
    return ['default'];
  }

  static String? get gender => _user?['jenis_kelamin']?.toString();
  static bool get hasGender => gender != null && gender!.isNotEmpty && gender != 'null';

  static String? get accessToken => _accessToken;
  static String? get tokenType => _tokenType;
  static String? get tokenSource => _tokenSource;
  static Map<String, dynamic>? get user => _user;

  static bool get isAuthenticated =>
      _accessToken != null && _accessToken!.trim().isNotEmpty;

  static String? get authorizationHeader {
    if (!isAuthenticated) {
      return null;
    }

    final type = (_tokenType == null || _tokenType!.trim().isEmpty)
        ? 'Bearer'
        : _tokenType!.trim();

    return '$type ${_accessToken!.trim()}';
  }

  static String get displayName {
    final candidates = [
      _user?['name'],
      _user?['username'],
      _user?['nim'],
      _user?['email'],
    ];

    for (final candidate in candidates) {
      final value = candidate?.toString().trim();
      if (value != null && value.isNotEmpty) {
        return value;
      }
    }

    return 'User';
  }

  static Future<void> saveFromLoginResult(Map<String, dynamic> loginResult) async {
    _accessToken = loginResult['access_token']?.toString();
    _tokenType = loginResult['token_type']?.toString();
    _tokenSource = loginResult['token_source']?.toString();
    await updateUser(loginResult['user']);
    await _saveToPrefs();
  }

  static Future<void> clear() async {
    _accessToken = null;
    _tokenType = null;
    _tokenSource = null;
    _user = null;
    await _clearPrefs();
  }
}
