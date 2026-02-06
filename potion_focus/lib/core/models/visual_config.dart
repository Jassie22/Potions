import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:potion_focus/core/theme/app_colors.dart';
import 'package:potion_focus/core/models/liquid_presets.dart';

/// Typed wrapper around the visualConfig JSON stored on each PotionModel.
class VisualConfig {
  final String bottleShape;
  final String liquid;
  final String effectType;
  final String rarity;

  const VisualConfig({
    required this.bottleShape,
    required this.liquid,
    required this.effectType,
    required this.rarity,
  });

  /// Default config for a given rarity (used as fallback).
  factory VisualConfig.defaultForRarity(String rarity) {
    return VisualConfig(
      bottleShape: _defaultBottle(rarity),
      liquid: 'liquid_0',
      effectType: _defaultEffect(rarity),
      rarity: rarity,
    );
  }

  factory VisualConfig.fromJson(String jsonString) {
    try {
      final map = jsonDecode(jsonString) as Map<String, dynamic>;
      return VisualConfig(
        bottleShape: map['bottle'] as String? ?? 'bottle_round',
        liquid: map['liquid'] as String? ?? 'liquid_0',
        effectType: map['effect'] as String? ?? 'none',
        rarity: map['rarity'] as String? ?? 'common',
      );
    } catch (_) {
      return const VisualConfig(
        bottleShape: 'bottle_round',
        liquid: 'liquid_0',
        effectType: 'none',
        rarity: 'common',
      );
    }
  }

  String toJson() {
    return jsonEncode({
      'bottle': bottleShape,
      'liquid': liquid,
      'effect': effectType,
      'rarity': rarity,
    });
  }

  /// Get the full liquid preset (name, colors, style, rarity).
  LiquidPreset get liquidPreset => LiquidPreset.getPreset(liquid);

  /// Resolve the liquid field to its primary color.
  Color get liquidColor {
    if (liquid == 'muddy_brown') {
      return const Color(0xFF6D4C2A);
    }
    return liquidPreset.primaryColor;
  }

  /// Resolve the rarity to its glow/accent color.
  Color get rarityColor => AppColors.getRarityColor(rarity);

  static String _defaultBottle(String rarity) {
    switch (rarity) {
      case 'legendary':
        return 'bottle_legendary';
      case 'epic':
        return 'bottle_potion';
      case 'rare':
        return 'bottle_flask';
      case 'uncommon':
        return 'bottle_tall';
      default:
        return 'bottle_round';
    }
  }

  static String _defaultEffect(String rarity) {
    switch (rarity) {
      case 'legendary':
        return 'effect_legendary_glow';
      case 'epic':
        return 'effect_smoke';
      case 'rare':
        return 'effect_sparkles';
      case 'uncommon':
        return 'effect_glow';
      default:
        return 'none';
    }
  }
}
