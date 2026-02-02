import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:potion_focus/data/local/database.dart';
import 'package:potion_focus/data/local/isar_helpers.dart';
import 'package:potion_focus/data/models/recipe_model.dart';
import 'package:potion_focus/data/models/potion_model.dart';
import 'package:potion_focus/data/models/session_model.dart';
import 'package:potion_focus/data/models/tag_stats_model.dart';
import 'package:potion_focus/data/models/user_data_model.dart';
import 'dart:convert';

class RecipeService {
  Future<void> checkRecipeUnlocks() async {
    final db = DatabaseHelper.instance;

    // Get all locked recipes
    final allRecipes = await db.recipeModels.getAllItems();
    final lockedRecipes = allRecipes.where((r) => !r.unlocked).toList();

    for (final recipe in lockedRecipes) {
      final unlockCondition = jsonDecode(recipe.unlockCondition);
      final isUnlocked = await _checkUnlockCondition(unlockCondition);

      if (isUnlocked) {
        recipe.unlocked = true;
        recipe.unlockedAt = DateTime.now();

        await db.writeTxn(() async {
          await db.recipeModels.put(recipe);
        });

        // TODO: Show unlock celebration notification
      }
    }
  }

  Future<bool> _checkUnlockCondition(Map<String, dynamic> condition) async {
    final type = condition['type'] as String;

    switch (type) {
      case 'potion_count':
        return await _checkPotionCount(condition['value'] as int);

      case 'tag_time':
        return await _checkTagTime(
          condition['tag'] as String,
          condition['minutes'] as int,
        );

      case 'streak':
        return await _checkStreak(condition['days'] as int);

      case 'rarity_count':
        return await _checkRarityCount(
          condition['rarity'] as String,
          condition['count'] as int,
        );

      case 'time_of_day':
        return await _checkTimeOfDay(
          condition['after'] as String,
          condition['sessions'] as int,
        );

      case 'total_time':
        return await _checkTotalTime(condition['minutes'] as int);

      default:
        return false;
    }
  }

  Future<bool> _checkPotionCount(int required) async {
    final db = DatabaseHelper.instance;
    final count = await db.potionModels.count();
    return count >= required;
  }

  Future<bool> _checkTagTime(String tag, int requiredMinutes) async {
    final db = DatabaseHelper.instance;
    final allTags = await db.tagStatsModels.getAllItems();
    final tagStats = allTags.where((t) => t.tag == tag).firstOrNull;

    return tagStats != null && tagStats.totalMinutes >= requiredMinutes;
  }

  Future<bool> _checkStreak(int requiredDays) async {
    final db = DatabaseHelper.instance;
    final allUserData = await db.userDataModels.getAllItems();
    final userData = allUserData.firstOrNull;

    return userData != null && userData.streakDays >= requiredDays;
  }

  Future<bool> _checkRarityCount(String rarity, int required) async {
    final db = DatabaseHelper.instance;
    final allPotions = await db.potionModels.getAllItems();
    final matchingPotions = allPotions.where((p) => p.rarity == rarity).toList();
    final count = matchingPotions.length;

    return count >= required;
  }

  Future<bool> _checkTimeOfDay(String afterTime, int requiredSessions) async {
    final db = DatabaseHelper.instance;
    
    // Parse time (e.g., "22:00")
    final timeParts = afterTime.split(':');
    final hour = int.parse(timeParts[0]);

    // Count sessions started after this time
    final allSessions = await db.sessionModels.getAllItems();
    final nightSessions = allSessions.where((session) {
      return session.startedAt.hour >= hour && session.completed;
    }).length;

    return nightSessions >= requiredSessions;
  }

  Future<bool> _checkTotalTime(int requiredMinutes) async {
    final db = DatabaseHelper.instance;
    final allUserData = await db.userDataModels.getAllItems();
    final userData = allUserData.firstOrNull;

    return userData != null && userData.totalFocusMinutes >= requiredMinutes;
  }

  Future<List<RecipeModel>> getAllRecipes() async {
    final db = DatabaseHelper.instance;
    return await db.recipeModels.getAllItems();
  }

  Future<List<RecipeModel>> getUnlockedRecipes() async {
    final db = DatabaseHelper.instance;
    final allRecipes = await db.recipeModels.getAllItems();
    return allRecipes.where((r) => r.unlocked).toList();
  }

  Future<List<RecipeModel>> getLockedRecipes() async {
    final db = DatabaseHelper.instance;
    final allRecipes = await db.recipeModels.getAllItems();
    return allRecipes.where((r) => !r.unlocked).toList();
  }

  String getRecipeHint(Map<String, dynamic> condition) {
    final type = condition['type'] as String;

    switch (type) {
      case 'potion_count':
        return 'Brew ${condition['value']} potions';
      case 'tag_time':
        return 'Focus ${condition['minutes']} minutes with #${condition['tag']}';
      case 'streak':
        return 'Maintain a ${condition['days']} day focus streak';
      case 'rarity_count':
        return 'Brew ${condition['count']} ${condition['rarity']} potions';
      case 'time_of_day':
        return 'Complete ${condition['sessions']} sessions after ${condition['after']}';
      case 'total_time':
        return 'Accumulate ${condition['minutes']} total focus minutes';
      default:
        return 'Complete a special challenge';
    }
  }
}

final recipeServiceProvider = Provider<RecipeService>((ref) {
  return RecipeService();
});

final allRecipesProvider = FutureProvider<List<RecipeModel>>((ref) async {
  final service = ref.watch(recipeServiceProvider);
  return await service.getAllRecipes();
});

final unlockedRecipesProvider = FutureProvider<List<RecipeModel>>((ref) async {
  final service = ref.watch(recipeServiceProvider);
  return await service.getUnlockedRecipes();
});

final lockedRecipesProvider = FutureProvider<List<RecipeModel>>((ref) async {
  final service = ref.watch(recipeServiceProvider);
  return await service.getLockedRecipes();
});

/// All recipes sorted by rarity (Common first, Legendary last),
/// with unlocked recipes before locked within each rarity group.
final recipesByRarityProvider = FutureProvider<List<RecipeModel>>((ref) async {
  final service = ref.watch(recipeServiceProvider);
  final all = await service.getAllRecipes();

  const rarityOrder = ['common', 'uncommon', 'rare', 'epic', 'legendary'];

  all.sort((a, b) {
    final rarityA = rarityOrder.indexOf(a.rarity);
    final rarityB = rarityOrder.indexOf(b.rarity);
    if (rarityA != rarityB) return rarityA.compareTo(rarityB);
    // Unlocked first within same rarity
    if (a.unlocked != b.unlocked) return a.unlocked ? -1 : 1;
    return 0;
  });

  return all;
});

