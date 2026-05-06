import 'package:flutter/material.dart';
import '../services/laravel_session_service.dart';
import '../utils/theme_colors.dart';

class ThemeManager with ChangeNotifier {
  static final ThemeManager _instance = ThemeManager._internal();
  factory ThemeManager() => _instance;
  ThemeManager._internal();

  String _currentThemeId = 'default';

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
    if (user != null && user['active_theme'] != null) {
      _currentThemeId = user['active_theme'].toString();
      notifyListeners();
    }
  }

  void updateTheme(String themeId) {
    _currentThemeId = themeId;
    notifyListeners();
  }
}
