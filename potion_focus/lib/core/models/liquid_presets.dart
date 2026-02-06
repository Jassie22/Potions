import 'package:flutter/material.dart';

/// Defines a liquid's visual properties: name, colors, rendering style, and rarity.
///
/// Liquid styles by rarity:
///   - common: `flat` — single solid color
///   - uncommon: `sheen` — base color + drifting highlight column
///   - rare: `gradient` — two-tone stepped pixel gradient
///   - epic: `sparkle` — gradient + twinkling bright pixels
///   - legendary: `luminous` — color-shifting gradient + sparkle + pulse
class LiquidPreset {
  final String id;
  final String name;
  final Color primaryColor;
  final Color? secondaryColor;
  final String style; // flat, sheen, gradient, sparkle, luminous
  final String rarity;

  const LiquidPreset({
    required this.id,
    required this.name,
    required this.primaryColor,
    this.secondaryColor,
    required this.style,
    required this.rarity,
  });

  /// Look up a preset by liquid ID. Falls back to liquid_0.
  static LiquidPreset getPreset(String liquidId) {
    return all.firstWhere(
      (p) => p.id == liquidId,
      orElse: () => all[0],
    );
  }

  static const List<LiquidPreset> all = [
    // ═══ COMMON (flat) ═══
    LiquidPreset(
      id: 'liquid_0',
      name: 'Twilight Essence',
      primaryColor: Color(0xFFAA00CC),
      style: 'flat',
      rarity: 'common',
    ),
    LiquidPreset(
      id: 'liquid_1',
      name: 'Azure Depths',
      primaryColor: Color(0xFF3366FF),
      style: 'flat',
      rarity: 'common',
    ),
    LiquidPreset(
      id: 'liquid_2',
      name: 'Emerald Tide',
      primaryColor: Color(0xFF00CCAA),
      style: 'flat',
      rarity: 'common',
    ),
    LiquidPreset(
      id: 'liquid_3',
      name: 'Hearthglow',
      primaryColor: Color(0xFF55CC00),
      style: 'flat',
      rarity: 'common',
    ),

    // ═══ UNCOMMON (sheen) ═══
    LiquidPreset(
      id: 'liquid_4',
      name: 'Crimson Ember',
      primaryColor: Color(0xFFFF4422),
      secondaryColor: Color(0xFFFF8844),
      style: 'sheen',
      rarity: 'uncommon',
    ),
    LiquidPreset(
      id: 'liquid_5',
      name: 'Liquid Sunlight',
      primaryColor: Color(0xFFFFBB00),
      secondaryColor: Color(0xFFFFEE88),
      style: 'sheen',
      rarity: 'uncommon',
    ),
    LiquidPreset(
      id: 'liquid_6',
      name: 'Lavender Mist',
      primaryColor: Color(0xFFAA77DD),
      secondaryColor: Color(0xFFDDBBFF),
      style: 'sheen',
      rarity: 'uncommon',
    ),
    LiquidPreset(
      id: 'liquid_7',
      name: 'Amber Dew',
      primaryColor: Color(0xFFCC8800),
      secondaryColor: Color(0xFFFFCC44),
      style: 'sheen',
      rarity: 'uncommon',
    ),
    LiquidPreset(
      id: 'liquid_8',
      name: 'Jade Whisper',
      primaryColor: Color(0xFF228844),
      secondaryColor: Color(0xFF66DD66),
      style: 'sheen',
      rarity: 'uncommon',
    ),

    // ═══ RARE (gradient) ═══
    LiquidPreset(
      id: 'liquid_9',
      name: 'Roseveil Draught',
      primaryColor: Color(0xFFFF44AA),
      secondaryColor: Color(0xFFFFAACC),
      style: 'gradient',
      rarity: 'rare',
    ),
    LiquidPreset(
      id: 'liquid_10',
      name: 'Midnight Oil',
      primaryColor: Color(0xFF6644FF),
      secondaryColor: Color(0xFF4488FF),
      style: 'gradient',
      rarity: 'rare',
    ),
    LiquidPreset(
      id: 'liquid_11',
      name: 'Frostbloom Nectar',
      primaryColor: Color(0xFF44DD88),
      secondaryColor: Color(0xFF008877),
      style: 'gradient',
      rarity: 'rare',
    ),
    LiquidPreset(
      id: 'liquid_12',
      name: "Ocean's Memory",
      primaryColor: Color(0xFF2244AA),
      secondaryColor: Color(0xFF44CCDD),
      style: 'gradient',
      rarity: 'rare',
    ),
    LiquidPreset(
      id: 'liquid_13',
      name: 'Autumn Blaze',
      primaryColor: Color(0xFFDD6600),
      secondaryColor: Color(0xFFCC2222),
      style: 'gradient',
      rarity: 'rare',
    ),

    // ═══ EPIC (sparkle) ═══
    LiquidPreset(
      id: 'liquid_14',
      name: "Dragon's Blood",
      primaryColor: Color(0xFFDD4455),
      secondaryColor: Color(0xFF881122),
      style: 'sparkle',
      rarity: 'epic',
    ),
    LiquidPreset(
      id: 'liquid_15',
      name: "Starweaver's Ink",
      primaryColor: Color(0xFF3322AA),
      secondaryColor: Color(0xFFDDAA22),
      style: 'sparkle',
      rarity: 'epic',
    ),
    LiquidPreset(
      id: 'liquid_16',
      name: 'Phantom Mist',
      primaryColor: Color(0xFF99AABB),
      secondaryColor: Color(0xFFDDEEFF),
      style: 'sparkle',
      rarity: 'epic',
    ),
    LiquidPreset(
      id: 'liquid_17',
      name: 'Molten Core',
      primaryColor: Color(0xFFFF8800),
      secondaryColor: Color(0xFFFFDD44),
      style: 'sparkle',
      rarity: 'epic',
    ),

    // ═══ LEGENDARY (luminous) ═══
    LiquidPreset(
      id: 'liquid_18',
      name: 'Phoenix Tears',
      primaryColor: Color(0xFFFFCC22),
      secondaryColor: Color(0xFFDD7700),
      style: 'luminous',
      rarity: 'legendary',
    ),
    LiquidPreset(
      id: 'liquid_19',
      name: 'Void Ichor',
      primaryColor: Color(0xFF220044),
      secondaryColor: Color(0xFF4422AA),
      style: 'luminous',
      rarity: 'legendary',
    ),
    LiquidPreset(
      id: 'liquid_20',
      name: 'Celestial Ambrosia',
      primaryColor: Color(0xFFFFEECC),
      secondaryColor: Color(0xFFAABBFF),
      style: 'luminous',
      rarity: 'legendary',
    ),
  ];
}
