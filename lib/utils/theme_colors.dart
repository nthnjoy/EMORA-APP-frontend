import 'package:flutter/material.dart';

class ThemeColorItem {
  final String id;
  final String name;
  final Color color;
  final int price;

  const ThemeColorItem({
    required this.id,
    required this.name,
    required this.color,
    required this.price,
  });
}

class ThemeColors {
  static const List<ThemeColorItem> allThemes = [
    ThemeColorItem(id: 'default', name: 'Original Green', color: Color(0xFF9BAA7F), price: 0),
    ThemeColorItem(id: 'red', name: 'Rose Red', color: Color(0xFFD32F2F), price: 1000),
    ThemeColorItem(id: 'pink', name: 'Soft Pink', color: Color(0xFFC2185B), price: 1000),
    ThemeColorItem(id: 'purple', name: 'Deep Purple', color: Color(0xFF7B1FA2), price: 1000),
    ThemeColorItem(id: 'indigo', name: 'Indigo Night', color: Color(0xFF303F9F), price: 1000),
    ThemeColorItem(id: 'blue', name: 'Ocean Blue', color: Color(0xFF1976D2), price: 1000),
    ThemeColorItem(id: 'light_blue', name: 'Sky Blue', color: Color(0xFF0288D1), price: 1000),
    ThemeColorItem(id: 'cyan', name: 'Teal Cyan', color: Color(0xFF0097A7), price: 1000),
    ThemeColorItem(id: 'teal', name: 'Fresh Teal', color: Color(0xFF00796B), price: 1000),
    ThemeColorItem(id: 'green', name: 'Emerald Green', color: Color(0xFF388E3C), price: 1000),
    ThemeColorItem(id: 'light_green', name: 'Lime Green', color: Color(0xFF689F38), price: 1000),
    ThemeColorItem(id: 'lime', name: 'Citrus Lime', color: Color(0xFFAFB42B), price: 1000),
    ThemeColorItem(id: 'yellow', name: 'Amber Yellow', color: Color(0xFFFBC02D), price: 1000),
    ThemeColorItem(id: 'orange', name: 'Sunset Orange', color: Color(0xFFF57C00), price: 1000),
    ThemeColorItem(id: 'deep_orange', name: 'Flame Orange', color: Color(0xFFE64A19), price: 1000),
    ThemeColorItem(id: 'brown', name: 'Earth Brown', color: Color(0xFF5D4037), price: 1000),
    ThemeColorItem(id: 'grey', name: 'Slate Grey', color: Color(0xFF616161), price: 1000),
    ThemeColorItem(id: 'blue_grey', name: 'Cool Grey', color: Color(0xFF455A64), price: 1000),
    ThemeColorItem(id: 'black', name: 'Solid Black', color: Color(0xFF212121), price: 1000),
    ThemeColorItem(id: 'gold', name: 'Luxury Gold', color: Color(0xFFD4AF37), price: 1000),
  ];

  static Color getColor(String id) {
    return allThemes.firstWhere((t) => t.id == id, orElse: () => allThemes[0]).color;
  }
}
