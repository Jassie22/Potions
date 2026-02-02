import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:potion_focus/core/utils/helpers.dart';
import 'package:potion_focus/core/theme/app_colors.dart';
import 'package:potion_focus/data/local/database.dart';
import 'package:potion_focus/data/local/isar_helpers.dart';
import 'package:potion_focus/data/models/potion_model.dart';
import 'package:potion_focus/data/models/user_data_model.dart';

class PotionCreationService {
  Future<PotionModel> createPotion(
    String sessionId,
    int durationMinutes,
    List<String> tags,
  ) async {
    final db = DatabaseHelper.instance;

    // Get user data for streak calculation
    final allUserData = await db.userDataModels.getAllItems();
    final userData = allUserData.firstOrNull ?? UserDataModel();

    // Calculate rarity
    final rarity = Helpers.calculateRarity(
      durationMinutes: durationMinutes,
      streakDays: userData.streakDays,
    );

    // Calculate essence
    final rarityMultiplier = _getRarityMultiplier(rarity);
    final essenceEarned = Helpers.calculateEssence(
      durationMinutes: durationMinutes,
      rarityMultiplier: rarityMultiplier,
      streakBonus: userData.streakDays,
    );

    // Generate visual config
    final visualConfig = _generateVisualConfig(rarity, tags);

    // Create potion
    final now = DateTime.now();
    final potion = PotionModel(
      potionId: Helpers.generateId(),
      sessionId: sessionId,
      rarity: rarity,
      essenceEarned: essenceEarned,
      visualConfig: jsonEncode(visualConfig),
      createdAt: now,
    );

    await db.writeTxn(() async {
      await db.potionModels.put(potion);
    });

    return potion;
  }

  Future<PotionModel> createMuddyBrew(String sessionId) async {
    final db = DatabaseHelper.instance;

    // Muddy Brew has fixed low essence
    final visualConfig = {
      'bottle': 'bottle_round',
      'liquid': 'muddy_brown',
      'effect': 'none',
      'rarity': 'muddy',
    };

    final now = DateTime.now();
    final potion = PotionModel(
      potionId: Helpers.generateId(),
      sessionId: sessionId,
      rarity: 'muddy',
      essenceEarned: 1, // Minimal essence for cancelled sessions
      visualConfig: jsonEncode(visualConfig),
      createdAt: now,
    );

    await db.writeTxn(() async {
      await db.potionModels.put(potion);
    });

    return potion;
  }

  int _getRarityMultiplier(String rarity) {
    switch (rarity) {
      case 'legendary':
        return 5;
      case 'epic':
        return 4;
      case 'rare':
        return 3;
      case 'uncommon':
        return 2;
      default:
        return 1;
    }
  }

  Map<String, dynamic> _generateVisualConfig(String rarity, List<String> tags) {
    // Select bottle based on rarity
    final bottle = _selectBottle(rarity);

    // Select liquid color (could be influenced by tags in the future)
    final liquid = _selectLiquid(rarity);

    // Select effect based on rarity
    final effect = _selectEffect(rarity);

    return {
      'bottle': bottle,
      'liquid': liquid,
      'effect': effect,
      'rarity': rarity,
    };
  }

  String _selectBottle(String rarity) {
    // For now, use default bottles. In Phase 2, check purchased bottles
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

  String _selectLiquid(String rarity) {
    // Select from available liquid colors
    final colorIndex = Helpers.randomInt(0, AppColors.potionLiquids.length - 1);
    return 'liquid_$colorIndex';
  }

  String _selectEffect(String rarity) {
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

final potionCreationServiceProvider = Provider<PotionCreationService>((ref) {
  return PotionCreationService();
});

