import 'package:flutter/material.dart';

class AppColors {
  // Light Theme Colors — vivid pixel-game palette
  static const Color primaryLight = Color(0xFF8B2FC9); // Vivid purple
  static const Color secondaryLight = Color(0xFFCC8800); // Rich amber/gold
  static const Color backgroundLight = Color(0xFFE8D8B4); // Warm parchment
  static const Color surfaceLight = Color(0xFFF2E6C9); // Light parchment
  static const Color textLight = Color(0xFF1A1A2E); // Deep navy black

  // Dark Theme Colors — warm candlelit darks
  static const Color primaryDark = Color(0xFFE8A835); // Warm amber gold
  static const Color secondaryDark = Color(0xFFFF8C42); // Warm orange
  static const Color backgroundDark = Color(0xFF130E08); // Deep warm brown-black
  static const Color surfaceDark = Color(0xFF1F1610); // Dark walnut
  static const Color textDark = Color(0xFFF0E0C8); // Warm cream

  // Accent Colors
  static const Color mysticalGold = Color(0xFFD4A34A);
  static const Color mysticalAmber = Color(0xFFB87333);
  static const Color parchment = Color(0xFFE8D8B4);

  // Rarity Colors — saturated game colors
  static const Color common = Color(0xFF888888); // Gray
  static const Color uncommon = Color(0xFF33CC33); // Bright green
  static const Color rare = Color(0xFF3399FF); // Bright blue
  static const Color epic = Color(0xFFAA33CC); // Bright purple
  static const Color legendary = Color(0xFFFFAA00); // Bright orange/gold

  // Functional Colors
  static const Color success = Color(0xFF33CC33);
  static const Color warning = Color(0xFFFFAA00);
  static const Color error = Color(0xFFFF3333);
  static const Color info = Color(0xFF3399FF);

  // Tag Colors — 12 preset colors for custom tag personalization
  static const List<Color> tagColors = [
    Color(0xFFFF6B6B), // 0  Coral Red
    Color(0xFFFF9F43), // 1  Orange
    Color(0xFFFECA57), // 2  Yellow
    Color(0xFF1DD1A1), // 3  Mint Green
    Color(0xFF54A0FF), // 4  Sky Blue
    Color(0xFF5F27CD), // 5  Purple
    Color(0xFFFF6B81), // 6  Pink
    Color(0xFF00D2D3), // 7  Cyan
    Color(0xFF10AC84), // 8  Forest Green
    Color(0xFFC8D6E5), // 9  Silver
    Color(0xFFFFFFFF), // 10 White
    Color(0xFF576574), // 11 Slate
  ];

  /// Get tag color by index (wraps around if out of bounds)
  static Color getTagColor(int index) {
    return tagColors[index % tagColors.length];
  }

  // Potion Liquid Colors — primary color for each of the 21 liquids.
  // For full preset data (name, secondary color, style), see LiquidPreset.
  static const List<Color> potionLiquids = [
    // Common (0-3)
    Color(0xFFAA00CC), // 0  Twilight Essence
    Color(0xFF3366FF), // 1  Azure Depths
    Color(0xFF00CCAA), // 2  Emerald Tide
    Color(0xFF55CC00), // 3  Hearthglow
    // Uncommon (4-8)
    Color(0xFFFF4422), // 4  Crimson Ember
    Color(0xFFFFBB00), // 5  Liquid Sunlight
    Color(0xFFAA77DD), // 6  Lavender Mist
    Color(0xFFCC8800), // 7  Amber Dew
    Color(0xFF228844), // 8  Jade Whisper
    // Rare (9-13)
    Color(0xFFFF44AA), // 9  Roseveil Draught
    Color(0xFF6644FF), // 10 Midnight Oil
    Color(0xFF44DD88), // 11 Frostbloom Nectar
    Color(0xFF2244AA), // 12 Ocean's Memory
    Color(0xFFDD6600), // 13 Autumn Blaze
    // Epic (14-17)
    Color(0xFFDD4455), // 14 Dragon's Blood
    Color(0xFF3322AA), // 15 Starweaver's Ink
    Color(0xFF99AABB), // 16 Phantom Mist
    Color(0xFFFF8800), // 17 Molten Core
    // Legendary (18-20)
    Color(0xFFFFCC22), // 18 Phoenix Tears
    Color(0xFF220044), // 19 Void Ichor
    Color(0xFFFFEECC), // 20 Celestial Ambrosia
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
