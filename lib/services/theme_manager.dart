import 'package:flutter/material.dart';
import '../services/laravel_session_service.dart';
import '../utils/theme_colors.dart';

class ThemeManager with ChangeNotifier {
  static final ThemeManager _instance = ThemeManager._internal();
  factory ThemeManager() => _instance;
  ThemeManager._internal();

  String _currentThemeId = 'default';
  String _genderBasedTheme = 'default';

  String get currentThemeId => _currentThemeId;
  
  Color get primaryColor => ThemeColors.getColor(_currentThemeId);
  Color get secondaryColor => primaryColor.withOpacity(0.7);
  Color get backgroundColor => _currentThemeId == 'default' 
      ? const Color(0xFFE7EBE2) 
      : Color.lerp(Colors.white, primaryColor, 0.15) ?? Colors.white;
  Color get surfaceColor => _currentThemeId == 'default' 
      ? const Color(0xFFF1F4EE) 
      : Color.lerp(Colors.white, primaryColor, 0.25) ?? Colors.white;

  void init() {
    final user = LaravelSessionService.user;
    
    // Set gender-based theme
    _setGenderBasedTheme();
    
    // Jika user sudah memilih tema, gunakan tema yang dipilih
    if (user != null && user['active_theme'] != null) {
      _currentThemeId = user['active_theme'].toString();
    } else {
      // Jika belum memilih, gunakan tema berdasarkan gender
      _currentThemeId = _genderBasedTheme;
    }
    
    notifyListeners();
  }

  /// Mengatur tema berdasarkan jenis kelamin user
  void _setGenderBasedTheme() {
    final user = LaravelSessionService.user;
    final gender = user?['jenis_kelamin']?.toString().toLowerCase() ?? '';
    
    if (gender.contains('perempuan') || gender == 'perempuan') {
      _genderBasedTheme = 'pink'; // Soft Pink untuk perempuan
    } else {
      _genderBasedTheme = 'default'; // Green default untuk laki-laki atau belum pilih
    }
  }

  void updateTheme(String themeId) {
    _currentThemeId = themeId;
    notifyListeners();
  }

  /// Dipanggil ketika user mengubah gender
  void updateGenderAndTheme() {
    _setGenderBasedTheme();
    init(); // Re-initialize dengan gender baru
  }
}
