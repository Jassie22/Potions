import 'package:flutter/material.dart';

class AppColors {
  // Light Theme Colors
  static const Color primaryLight = Color(0xFF6B4E71); // Muted purple
  static const Color secondaryLight = Color(0xFF8B7355); // Warm brown
  static const Color backgroundLight = Color(0xFFF5F1ED); // Soft cream
  static const Color surfaceLight = Color(0xFFFFFFFF); // White
  static const Color textLight = Color(0xFF2D2D2D); // Dark gray
  
  // Dark Theme Colors
  static const Color primaryDark = Color(0xFF9B7FA5); // Lighter purple
  static const Color secondaryDark = Color(0xFFB8956B); // Lighter brown
  static const Color backgroundDark = Color(0xFF1A1A1A); // Very dark gray
  static const Color surfaceDark = Color(0xFF2D2D2D); // Dark gray
  static const Color textDark = Color(0xFFE8E8E8); // Light gray
  
  // Rarity Colors
  static const Color common = Color(0xFF9E9E9E); // Gray
  static const Color uncommon = Color(0xFF4CAF50); // Green
  static const Color rare = Color(0xFF2196F3); // Blue
  static const Color epic = Color(0xFF9C27B0); // Purple
  static const Color legendary = Color(0xFFFF9800); // Orange/Gold
  
  // Functional Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);
  
  // Potion Liquid Colors (for visual system)
  static const List<Color> potionLiquids = [
    Color(0xFF8B4789), // Purple
    Color(0xFF4A7BA7), // Blue
    Color(0xFF45B69C), // Teal
    Color(0xFF73A24E), // Green
    Color(0xFFE07A5F), // Coral
    Color(0xFFD4A574), // Gold
    Color(0xFFC76B98), // Pink
    Color(0xFF6A5ACD), // Slate blue
    Color(0xFF8FBC8F), // Sea green
    Color(0xFFBC8F8F), // Rosy brown
  ];
  
  // Get rarity color
  static Color getRarityColor(String rarity) {
    switch (rarity.toLowerCase()) {
      case 'uncommon':
        return uncommon;
      case 'rare':
        return rare;
      case 'epic':
        return epic;
      case 'legendary':
        return legendary;
      default:
        return common;
    }
  }
}



