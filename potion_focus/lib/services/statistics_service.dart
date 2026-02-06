import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:potion_focus/data/local/database.dart';
import 'package:potion_focus/data/local/isar_helpers.dart';
import 'package:potion_focus/data/models/session_model.dart';
import 'package:potion_focus/data/models/potion_model.dart';
import 'package:potion_focus/data/models/tag_stats_model.dart';
import 'package:potion_focus/data/models/user_data_model.dart';

class StatisticsService {
  /// Minutes focused each day for the last 7 days (index 0 = 6 days ago, 6 = today).
  Future<List<int>> getWeeklyMinutes() async {
    final db = DatabaseHelper.instance;
    final allSessions = await db.sessionModels.getAllItems();
    final now = DateTime.now();
    final result = List.filled(7, 0);

    for (final session in allSessions) {
      if (!session.completed) continue;
      final dayDiff = now.difference(session.startedAt).inDays;
      if (dayDiff >= 0 && dayDiff < 7) {
        result[6 - dayDiff] += session.durationSeconds ~/ 60;
      }
    }
    return result;
  }

  /// Minutes focused each week for the last 4 weeks (index 0 = oldest).
  Future<List<int>> getMonthlyMinutes() async {
    final db = DatabaseHelper.instance;
    final allSessions = await db.sessionModels.getAllItems();
    final now = DateTime.now();
    final result = List.filled(4, 0);

    for (final session in allSessions) {
      if (!session.completed) continue;
      final dayDiff = now.difference(session.startedAt).inDays;
      final weekIndex = dayDiff ~/ 7;
      if (weekIndex >= 0 && weekIndex < 4) {
        result[3 - weekIndex] += session.durationSeconds ~/ 60;
      }
    }
    return result;
  }

  /// Top N tags sorted by total minutes.
  Future<List<TagStat>> getTopTags(int limit) async {
    final db = DatabaseHelper.instance;
    final allTags = await db.tagStatsModels.getAllItems();
    allTags.sort((a, b) => b.totalMinutes.compareTo(a.totalMinutes));
    return allTags
        .take(limit)
        .map((t) => TagStat(tag: t.tag, minutes: t.totalMinutes))
        .toList();
  }

  /// Potion count per rarity.
  Future<Map<String, int>> getRarityDistribution() async {
    final db = DatabaseHelper.instance;
    final allPotions = await db.potionModels.getAllItems();
    final dist = <String, int>{};
    for (final p in allPotions) {
      dist[p.rarity] = (dist[p.rarity] ?? 0) + 1;
    }
    return dist;
  }

  /// Overview stats.
  Future<OverviewStats> getOverview() async {
    final db = DatabaseHelper.instance;
    final allUserData = await db.userDataModels.getAllItems();
    final userData = allUserData.firstOrNull;
    final allPotions = await db.potionModels.getAllItems();

    return OverviewStats(
      totalHours: (userData?.totalFocusMinutes ?? 0) / 60.0,
      currentStreak: userData?.streakDays ?? 0,
      totalPotions: allPotions.length,
    );
  }
}

class TagStat {
  final String tag;
  final int minutes;
  const TagStat({required this.tag, required this.minutes});
}

class OverviewStats {
  final double totalHours;
  final int currentStreak;
  final int totalPotions;
  const OverviewStats({
    required this.totalHours,
    required this.currentStreak,
    required this.totalPotions,
  });
}

final statisticsServiceProvider = Provider<StatisticsService>((ref) {
  return StatisticsService();
});

final overviewStatsProvider = FutureProvider<OverviewStats>((ref) async {
  return ref.watch(statisticsServiceProvider).getOverview();
});

final weeklyMinutesProvider = FutureProvider<List<int>>((ref) async {
  return ref.watch(statisticsServiceProvider).getWeeklyMinutes();
});

final monthlyMinutesProvider = FutureProvider<List<int>>((ref) async {
  return ref.watch(statisticsServiceProvider).getMonthlyMinutes();
});

final topTagsProvider = FutureProvider<List<TagStat>>((ref) async {
  return ref.watch(statisticsServiceProvider).getTopTags(5);
});

final rarityDistributionProvider = FutureProvider<Map<String, int>>((ref) async {
  return ref.watch(statisticsServiceProvider).getRarityDistribution();
});
