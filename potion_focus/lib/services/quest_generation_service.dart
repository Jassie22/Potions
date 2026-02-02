import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:potion_focus/core/config/app_constants.dart';
import 'package:potion_focus/core/utils/helpers.dart';
import 'package:potion_focus/core/utils/extensions.dart';
import 'package:potion_focus/data/local/database.dart';
import 'package:potion_focus/data/local/isar_helpers.dart';
import 'package:potion_focus/data/models/quest_model.dart';
import 'package:potion_focus/data/models/tag_stats_model.dart';

class QuestGenerationService {
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

    // Randomly select quest type based on weights
    final questType = Helpers.weightedRandom(AppConstants.questTypeWeights);

    // Calculate target value based on quest type
    final targetValue = _calculateDailyTarget(topTag, questType);

    // Calculate essence reward
    final essenceReward = _calculateEssenceReward(
      targetValue,
      AppConstants.dailyQuestEssenceBonus,
      questType,
    );

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
      essenceReward: essenceReward,
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

      // Calculate essence reward
      final essenceReward = _calculateEssenceReward(
        targetValue,
        AppConstants.weeklyQuestEssenceBonus,
        'time_based',
      );

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
        essenceReward: essenceReward,
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

      // Check if quest is complete
      if (quest.currentProgress >= quest.targetValue) {
        quest.status = 'completed';
        quest.completedAt = DateTime.now();
      }

      await db.writeTxn(() async {
        await db.questModels.put(quest);
      });
    }
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

  int _calculateEssenceReward(int targetValue, double bonusMultiplier, String questType) {
    int baseReward;

    switch (questType) {
      case 'time_based':
        baseReward = (targetValue / 5).round(); // 1 essence per 5 minutes
        break;
      case 'session_based':
        baseReward = targetValue * 10; // 10 essence per session
        break;
      case 'streak_based':
        baseReward = 20; // Fixed reward
        break;
      default:
        baseReward = 10;
    }

    return (baseReward * bonusMultiplier).round();
  }

  DateTime _getEndOfWeek() {
    final now = DateTime.now();
    // Calculate days until Sunday (assuming week ends on Sunday)
    final daysUntilSunday = 7 - now.weekday;
    return now.add(Duration(days: daysUntilSunday)).endOfDay();
  }
}

final questGenerationServiceProvider = Provider<QuestGenerationService>((ref) {
  return QuestGenerationService();
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

