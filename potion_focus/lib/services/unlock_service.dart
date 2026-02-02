import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:potion_focus/data/local/database.dart';
import 'package:potion_focus/data/local/isar_helpers.dart';
import 'package:potion_focus/data/models/potion_model.dart';
import 'package:potion_focus/data/models/session_model.dart';
import 'package:potion_focus/data/models/unlockable_model.dart';
import 'package:potion_focus/data/models/user_data_model.dart';

/// Checks unlock conditions for potion styles after each session.
/// Condition types: potion_count, total_time, streak, rarity_collection,
/// session_duration, time_of_day, compound.
class UnlockService {
  /// Check all locked unlockables and unlock any whose conditions are met.
  /// Returns the list of newly unlocked items (for UI notifications).
  Future<List<UnlockableModel>> checkUnlocks() async {
    final db = DatabaseHelper.instance;
    final all = await db.unlockableModels.getAllItems();
    final locked = all.where((u) => !u.unlocked).toList();
    final newlyUnlocked = <UnlockableModel>[];

    for (final item in locked) {
      try {
        final condition = jsonDecode(item.unlockCondition) as Map<String, dynamic>;
        final met = await _checkCondition(condition);

        if (met) {
          item.unlocked = true;
          item.unlockedAt = DateTime.now();

          await db.writeTxn(() async {
            await db.unlockableModels.put(item);
          });

          newlyUnlocked.add(item);
        }
      } catch (_) {
        // Skip malformed conditions
      }
    }

    return newlyUnlocked;
  }

  Future<bool> _checkCondition(Map<String, dynamic> condition) async {
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

      case 'rarity_collection':
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
          final met = await _checkCondition(sub as Map<String, dynamic>);
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

  Future<List<UnlockableModel>> getUnlockedStyles() async {
    final db = DatabaseHelper.instance;
    final all = await db.unlockableModels.getAllItems();
    return all.where((u) => u.unlocked).toList();
  }

  Future<List<UnlockableModel>> getLockedStyles() async {
    final db = DatabaseHelper.instance;
    final all = await db.unlockableModels.getAllItems();
    return all.where((u) => !u.unlocked).toList();
  }

  Future<List<UnlockableModel>> getAllStyles() async {
    final db = DatabaseHelper.instance;
    return await db.unlockableModels.getAllItems();
  }
}

final unlockServiceProvider = Provider<UnlockService>((ref) {
  return UnlockService();
});

final unlockedStylesProvider = FutureProvider<List<UnlockableModel>>((ref) async {
  final service = ref.watch(unlockServiceProvider);
  return await service.getUnlockedStyles();
});
