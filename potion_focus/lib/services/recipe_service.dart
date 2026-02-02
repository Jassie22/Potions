import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:potion_focus/data/local/database.dart';
import 'package:potion_focus/data/local/isar_helpers.dart';
import 'package:potion_focus/data/models/recipe_model.dart';
import 'package:potion_focus/data/models/potion_model.dart';
import 'package:potion_focus/data/models/session_model.dart';
import 'package:potion_focus/data/models/user_data_model.dart';
import 'dart:convert';

class RecipeService {
  Future<void> checkRecipeUnlocks() async {
    final db = DatabaseHelper.instance;

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
      }
    }
  }

  Future<bool> _checkUnlockCondition(Map<String, dynamic> condition) async {
    final type = condition['type'] as String;
    final db = DatabaseHelper.instance;

    switch (type) {
      case 'potion_count':
        final required = condition['value'] as int;
        final count = await db.potionModels.count();
        return count >= required;

      case 'total_time':
        final required = condition['minutes'] as int;
        final allUserData = await db.userDataModels.getAllItems();
        final userData = allUserData.firstOrNull;
        return userData != null && userData.totalFocusMinutes >= required;

      case 'streak':
        final required = condition['days'] as int;
        final allUserData = await db.userDataModels.getAllItems();
        final userData = allUserData.firstOrNull;
        return userData != null && userData.streakDays >= required;

      case 'rarity_count':
        final rarity = condition['rarity'] as String;
        final required = condition['count'] as int;
        final allPotions = await db.potionModels.getAllItems();
        final count = allPotions.where((p) => p.rarity == rarity).length;
        return count >= required;

      case 'session_duration':
        final required = condition['minutes'] as int;
        final allSessions = await db.sessionModels.getAllItems();
        return allSessions.any(
          (s) => s.completed && s.durationSeconds >= required * 60,
        );

      case 'time_of_day':
        return _checkTimeOfDay(condition, db);

      case 'compound':
        final conditions = condition['conditions'] as List<dynamic>;
        for (final sub in conditions) {
          final met = await _checkUnlockCondition(sub as Map<String, dynamic>);
          if (!met) return false;
        }
        return true;

      default:
        return false;
    }
  }

  Future<bool> _checkTimeOfDay(Map<String, dynamic> condition, dynamic db) async {
    final afterStr = condition['after'] as String;
    final required = condition['sessions'] as int;
    final afterParts = afterStr.split(':');
    final afterHour = int.parse(afterParts[0]);
    final afterMinute = afterParts.length > 1 ? int.parse(afterParts[1]) : 0;

    final allSessions = await db.sessionModels.getAllItems();

    final count = allSessions.where((session) {
      if (!session.completed) return false;
      // Use local time for time_of_day checks
      final localTime = session.startedAt.toLocal();
      final sessionMinutes = localTime.hour * 60 + localTime.minute;
      final afterMinutes = afterHour * 60 + afterMinute;

      if (condition.containsKey('before')) {
        final beforeStr = condition['before'] as String;
        final beforeParts = beforeStr.split(':');
        final beforeHour = int.parse(beforeParts[0]);
        final beforeMinute = beforeParts.length > 1 ? int.parse(beforeParts[1]) : 0;
        final beforeMinutes = beforeHour * 60 + beforeMinute;

        if (afterMinutes < beforeMinutes) {
          // Normal range (e.g., 05:00-07:00)
          return sessionMinutes >= afterMinutes && sessionMinutes < beforeMinutes;
        } else {
          // Overnight range (e.g., 23:00-03:00)
          return sessionMinutes >= afterMinutes || sessionMinutes < beforeMinutes;
        }
      }
      return sessionMinutes >= afterMinutes;
    }).length;

    return count >= required;
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
      case 'streak':
        return 'Maintain a ${condition['days']}-day focus streak';
      case 'rarity_count':
        return 'Brew ${condition['count']} ${condition['rarity']} potions';
      case 'time_of_day':
        final after = condition['after'];
        final sessions = condition['sessions'];
        if (condition.containsKey('before')) {
          return 'Complete $sessions sessions between $after and ${condition['before']}';
        }
        return 'Complete $sessions sessions after $after';
      case 'total_time':
        return 'Accumulate ${condition['minutes']} total focus minutes';
      case 'session_duration':
        return 'Complete a ${condition['minutes']}-minute session';
      case 'compound':
        final conditions = condition['conditions'] as List<dynamic>;
        final hints = conditions.map((c) => getRecipeHint(c as Map<String, dynamic>)).toList();
        return hints.join(' and ');
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
    if (a.unlocked != b.unlocked) return a.unlocked ? -1 : 1;
    return 0;
  });

  return all;
});
