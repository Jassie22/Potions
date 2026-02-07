import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:potion_focus/data/local/database.dart';
import 'package:potion_focus/data/local/isar_helpers.dart';
import 'package:potion_focus/data/models/tag_stats_model.dart';

class TagStatsService {
  Future<void> updateTagStats(List<String> tags, int durationMinutes) async {
    final db = DatabaseHelper.instance;

    for (final tag in tags) {
      // Get or create tag stats
      final allTags = await db.tagStatsModels.getAllItems();
      TagStatsModel? tagStats = allTags.where((t) => t.tag == tag).firstOrNull;

      tagStats ??= TagStatsModel(tag: tag);

      // Update totals
      tagStats.totalMinutes += durationMinutes;
      tagStats.totalSessions += 1;

      // Update last 7 days stats (simplified - would need cleanup of old data)
      tagStats.last7DaysMinutes += durationMinutes;
      tagStats.last7DaysSessions += 1;

      // Update streak
      final now = DateTime.now();
      final lastSession = tagStats.lastSessionDate;

      if (lastSession == null) {
        tagStats.currentStreak = 1;
      } else {
        final daysSinceLast = now.difference(lastSession).inDays;
        if (daysSinceLast == 0) {
          // Same day, keep streak
        } else if (daysSinceLast == 1) {
          // Consecutive day
          tagStats.currentStreak += 1;
        } else {
          // Streak broken
          tagStats.currentStreak = 1;
        }
      }

      tagStats.lastSessionDate = now;

      await db.writeTxn(() async {
        await db.tagStatsModels.put(tagStats!);
      });
    }
  }

  Future<List<TagStatsModel>> getTopTags({int limit = 5}) async {
    final db = DatabaseHelper.instance;
    
      final tags = await db.tagStatsModels.getAllItems();
    tags.sort((a, b) => b.last7DaysMinutes.compareTo(a.last7DaysMinutes));
    return tags.take(limit).toList();
  }

  Future<TagStatsModel?> getTagStats(String tag) async {
    final db = DatabaseHelper.instance;
    
    final allTags = await db.tagStatsModels.getAllItems();
    return allTags.where((t) => t.tag == tag).firstOrNull;
  }

  Future<List<TagStatsModel>> getAllTags() async {
    final db = DatabaseHelper.instance;
    
      final tags = await db.tagStatsModels.getAllItems();
    tags.sort((a, b) => b.totalMinutes.compareTo(a.totalMinutes));
    return tags;
  }

  // Cleanup old data from last 7 days calculations
  Future<void> cleanupOldStats() async {
    final db = DatabaseHelper.instance;
    final allTags = await db.tagStatsModels.getAllItems();

    for (final tag in allTags) {
      if (tag.lastSessionDate != null) {
        final daysSinceLast = DateTime.now().difference(tag.lastSessionDate!).inDays;
        
        if (daysSinceLast >= 7) {
          // Reset 7-day stats if no recent activity
          tag.last7DaysMinutes = 0;
          tag.last7DaysSessions = 0;
        }
      }
    }

    await db.writeTxn(() async {
      for (final tag in allTags) {
        await db.tagStatsModels.put(tag);
      }
    });
  }
}

final tagStatsServiceProvider = Provider<TagStatsService>((ref) {
  return TagStatsService();
});

// Provider to watch top tags
final topTagsProvider = FutureProvider<List<TagStatsModel>>((ref) async {
  final service = ref.watch(tagStatsServiceProvider);
  return await service.getTopTags(limit: 5);
});

