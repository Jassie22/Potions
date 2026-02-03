import 'package:isar/isar.dart';

part 'tag_stats_model.g.dart';

@collection
class TagStatsModel {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String tag;

  late int totalMinutes;
  late int totalSessions;
  late int last7DaysMinutes;
  late int last7DaysSessions;
  late int currentStreak;
  DateTime? lastSessionDate;

  /// Color index for the tag (0-11, maps to AppColors.tagColors)
  int colorIndex;

  TagStatsModel({
    this.tag = '',
    this.totalMinutes = 0,
    this.totalSessions = 0,
    this.last7DaysMinutes = 0,
    this.last7DaysSessions = 0,
    this.currentStreak = 0,
    this.lastSessionDate,
    this.colorIndex = 0,
  });
}



