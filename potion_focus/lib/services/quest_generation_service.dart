import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:potion_focus/core/config/app_constants.dart';
import 'package:potion_focus/core/utils/helpers.dart';
import 'package:potion_focus/core/utils/extensions.dart';
import 'package:potion_focus/data/local/database.dart';
import 'package:potion_focus/data/local/isar_helpers.dart';
import 'package:potion_focus/data/models/quest_model.dart';
import 'package:potion_focus/data/models/tag_stats_model.dart';
import 'package:potion_focus/services/essence_service.dart';
import 'package:potion_focus/services/coin_service.dart';
import 'dart:math';

class QuestGenerationService {
  final Ref ref;
  QuestGenerationService(this.ref);
  Future<void> generateDailyQuest() async {
    final db = DatabaseHelper.instance;

    // Check if there's already an active daily quest for today
    final today = DateTime.now();
    final allQuests = await db.questModels.getAllItems();
    final existingQuest = allQuests.where((q) => 
        q.timeframe == 'daily' && 
        q.status == 'active' && 
        q.expiresAt.isAfter(today)).firstOrNull;

    if (existingQuest != null) {
      return; // Already have today's quest
    }

    // Get top tag from last 7 days
    final allTags = await db.tagStatsModels.getAllItems();
    allTags.sort((a, b) => b.last7DaysMinutes.compareTo(a.last7DaysMinutes));
    final topTags = allTags.take(1).toList();

    if (topTags.isEmpty) {
      return; // No tags to generate quest from
    }

    final topTag = topTags.first;

    // Get existing active quest types for this timeframe to avoid duplicates
    final existingTypes = allQuests
        .where((q) => q.timeframe == 'daily' && q.status == 'active')
        .map((q) => q.questType)
        .toSet();

    // Filter out already-used quest types
    final availableTypes = ['time_based', 'session_based', 'streak_based']
        .where((t) => !existingTypes.contains(t))
        .toList();

    if (availableTypes.isEmpty) {
      debugPrint('All daily quest types already in use');
      return; // All types used
    }

    // Randomly select from available quest types
    final questType = Helpers.randomElement(availableTypes);

    // Calculate target value based on quest type
    final targetValue = _calculateDailyTarget(topTag, questType);

    // Calculate rewards
    final rewards = _calculateRewards(targetValue, questType, 'daily');

    // Create quest
    final now = DateTime.now();
    final quest = QuestModel(
      questId: Helpers.generateId(),
      tag: topTag.tag,
      questType: questType,
      timeframe: 'daily',
      targetValue: targetValue,
      currentProgress: 0,
      status: 'active',
      essenceReward: rewards.essence,
      coinReward: rewards.coins,
      generatedAt: now,
      expiresAt: now.add(const Duration(days: 1)).endOfDay(),
    );

    await db.writeTxn(() async {
      await db.questModels.put(quest);
    });
  }

  Future<void> generateWeeklyQuests() async {
    final db = DatabaseHelper.instance;

    // Check if there are already active weekly quests for this week
    final allQuests = await db.questModels.getAllItems();
    final existingQuests = allQuests.where((q) => 
        q.timeframe == 'weekly' && q.status == 'active').toList();

    if (existingQuests.length >= 3) {
      return; // Already have weekly quests
    }

    // Get top 3 tags from last 7 days
    final allTags = await db.tagStatsModels.getAllItems();
    allTags.sort((a, b) => b.last7DaysMinutes.compareTo(a.last7DaysMinutes));
    final topTags = allTags.take(3).toList();

    if (topTags.isEmpty) {
      return; // No tags to generate quests from
    }

    // Generate one quest for each top tag
    for (final tagStats in topTags) {
      // Check if quest for this tag already exists
      final allQuests = await db.questModels.getAllItems();
      final existingTagQuest = allQuests.where(
        (q) => q.timeframe == 'weekly' && 
               q.status == 'active' && 
               q.tag == tagStats.tag,
      ).firstOrNull;
      if (existingTagQuest != null) {
        continue; // Skip this tag
      }

      // Weekly quests are always time-based
      final targetValue = _calculateWeeklyTarget(tagStats);

      // Calculate rewards (weekly quests have higher coin chance)
      final rewards = _calculateRewards(targetValue, 'time_based', 'weekly');

      // Create quest
      final now = DateTime.now();
      final quest = QuestModel(
        questId: Helpers.generateId(),
        tag: tagStats.tag,
        questType: 'time_based',
        timeframe: 'weekly',
        targetValue: targetValue,
        currentProgress: 0,
        status: 'active',
        essenceReward: rewards.essence,
        coinReward: rewards.coins,
        generatedAt: now,
        expiresAt: _getEndOfWeek(),
      );

      await db.writeTxn(() async {
        await db.questModels.put(quest);
      });
    }
  }

  Future<void> updateQuestProgress(List<String> tags, int durationMinutes) async {
    final db = DatabaseHelper.instance;

    // Get all active quests
    final allQuests = await db.questModels.getAllItems();
    final activeQuests = allQuests.where((q) => q.status == 'active').toList();

    for (final quest in activeQuests) {
      if (!tags.contains(quest.tag)) {
        continue; // This quest's tag wasn't in the session
      }

      // Update progress based on quest type
      switch (quest.questType) {
        case 'time_based':
          quest.currentProgress += durationMinutes;
          break;
        case 'session_based':
          quest.currentProgress += 1;
          break;
        case 'streak_based':
          // Check if this is a new day for the tag
          final allTags = await db.tagStatsModels.getAllItems();
          final tagStats = allTags.where((t) => t.tag == quest.tag).firstOrNull;

          if (tagStats != null) {
            final lastSession = tagStats.lastSessionDate;
            if (lastSession == null ||
                !DateTime.now().isSameDay(lastSession)) {
              quest.currentProgress = 1; // Completed today's part
            }
          }
          break;
      }

      // Check if quest is complete (only award once, when status changes)
      if (quest.currentProgress >= quest.targetValue && quest.status != 'completed') {
        quest.status = 'completed';
        quest.completedAt = DateTime.now();

        // Save completed status FIRST to prevent double-award on crash (bug 1.4)
        await db.writeTxn(() async {
          await db.questModels.put(quest);
        });

        // THEN award essence and coins using ref.read() (not new instances)
        try {
          await ref.read(essenceServiceProvider).addEssence(quest.essenceReward);
          debugPrint('Quest completed! Awarded ${quest.essenceReward} essence for quest: ${quest.questType}');

          if (quest.coinReward > 0) {
            await ref.read(coinServiceProvider).addCoins(quest.coinReward);
            debugPrint('Quest bonus! Awarded ${quest.coinReward} coins');
          }
        } catch (e) {
          debugPrint('Failed to award rewards for quest ${quest.questId}: $e');
        }
      } else {
        // Save progress update
        await db.writeTxn(() async {
          await db.questModels.put(quest);
        });
      }
    }
  }

  Future<void> createCustomQuest({
    required String tag,
    required String questType,
    required int targetValue,
    required String timeframe,
  }) async {
    final db = DatabaseHelper.instance;
    final now = DateTime.now();

    final expiresAt = timeframe == 'daily'
        ? now.add(const Duration(days: 1)).endOfDay()
        : _getEndOfWeek();

    final rewards = _calculateRewards(targetValue, questType, timeframe);

    final quest = QuestModel(
      questId: Helpers.generateId(),
      tag: tag,
      questType: questType,
      timeframe: timeframe,
      targetValue: targetValue,
      currentProgress: 0,
      status: 'active',
      essenceReward: rewards.essence,
      coinReward: rewards.coins,
      isCustom: true,
      generatedAt: now,
      expiresAt: expiresAt,
    );

    await db.writeTxn(() async {
      await db.questModels.put(quest);
    });
  }

  Future<void> expireOldQuests() async {
    final db = DatabaseHelper.instance;
    final now = DateTime.now();

    final allQuests = await db.questModels.getAllItems();
    final expiredQuests = allQuests.where((q) => 
        q.status == 'active' && q.expiresAt.isBefore(now)).toList();

    for (final quest in expiredQuests) {
      quest.status = 'expired';

      await db.writeTxn(() async {
        await db.questModels.put(quest);
      });
    }
  }

  int _calculateDailyTarget(TagStatsModel tagStats, String questType) {
    switch (questType) {
      case 'time_based':
        // 80% of daily average from last 7 days
        final avgDaily = tagStats.last7DaysMinutes / 7;
        final target = (avgDaily * AppConstants.dailyQuestDifficultyFactor).round();
        return Helpers.clamp(target, 15, 120); // Between 15 and 120 minutes

      case 'session_based':
        // Average sessions per day
        final avgSessions = tagStats.last7DaysSessions / 7;
        final target = avgSessions.round();
        return Helpers.clamp(target, 1, 5); // Between 1 and 5 sessions

      case 'streak_based':
        return 1; // Just complete one session today

      default:
        return 30; // Fallback
    }
  }

  int _calculateWeeklyTarget(TagStatsModel tagStats) {
    // 110% of last week's minutes
    final target = (tagStats.last7DaysMinutes * AppConstants.weeklyQuestDifficultyFactor).round();
    return Helpers.clamp(target, 60, 600); // Between 1 and 10 hours
  }

  /// Calculate both essence and coin rewards based on quest parameters.
  /// Coin rewards are rare - only for challenging quests with some randomness.
  ({int essence, int coins}) _calculateRewards(int targetValue, String questType, String timeframe) {
    int baseEssence;
    int coins = 0;

    switch (questType) {
      case 'time_based':
        // 1 essence per 2 minutes (increased from 1 per 5)
        baseEssence = (targetValue / 2).round();
        // Coin bonus for challenging weekly time quests (180+ min = 3 hours)
        if (timeframe == 'weekly' && targetValue >= 180) {
          coins = Random().nextInt(100) < 30 ? 3 : 0; // 30% chance for 3 coins
        }
        break;
      case 'session_based':
        // 15 essence per session (increased from 10)
        baseEssence = targetValue * 15;
        // Coins for weekly multi-session quests (5+ sessions)
        if (timeframe == 'weekly' && targetValue >= 5) {
          coins = Random().nextInt(100) < 25 ? 5 : 0; // 25% chance for 5 coins
        }
        break;
      case 'streak_based':
        baseEssence = 25; // Increased from 20
        // Small chance for coins on streak quests
        if (timeframe == 'weekly') {
          coins = Random().nextInt(100) < 20 ? 2 : 0; // 20% chance for 2 coins
        }
        break;
      default:
        baseEssence = 10;
    }

    // Apply timeframe multiplier to essence
    final essenceMultiplier = timeframe == 'weekly' ? 2.0 : 1.5;
    final finalEssence = (baseEssence * essenceMultiplier).round();

    return (essence: finalEssence, coins: coins);
  }

  DateTime _getEndOfWeek() {
    final now = DateTime.now();
    // Calculate days until Sunday (assuming week ends on Sunday)
    final daysUntilSunday = 7 - now.weekday;
    return now.add(Duration(days: daysUntilSunday)).endOfDay();
  }
}

final questGenerationServiceProvider = Provider<QuestGenerationService>((ref) {
  return QuestGenerationService(ref);
});

// Provider for active quests
final activeQuestsProvider = StreamProvider<List<QuestModel>>((ref) async* {
  final db = DatabaseHelper.instance;
  
  // Expire old quests first
  await ref.read(questGenerationServiceProvider).expireOldQuests();
  
  // Get active quests
  final allQuests = await db.questModels.getAllItems();
  final quests = allQuests.where((q) => q.status == 'active').toList();
  quests.sort((a, b) => b.generatedAt.compareTo(a.generatedAt));

  yield quests;
  
  // TODO: In the future, add stream listener for real-time updates
});

