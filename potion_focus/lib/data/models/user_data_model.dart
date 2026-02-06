import 'package:isar/isar.dart';

part 'user_data_model.g.dart';

@collection
class UserDataModel {
  Id id = Isar.autoIncrement;

  late int essenceBalance;
  late int totalFocusMinutes;
  late int totalPotions;
  late int streakDays;
  DateTime? lastFocusDate;
  late int coinBalance;
  late String activeThemeId;

  // Subscription-related tracking
  DateTime? lastDailyBonusDate;
  late int completedSessionCount;
  DateTime? lastUpgradePromptDate;

  UserDataModel({
    this.essenceBalance = 0,
    this.totalFocusMinutes = 0,
    this.totalPotions = 0,
    this.streakDays = 0,
    this.lastFocusDate,
    this.coinBalance = 0,
    this.activeThemeId = 'theme_default',
    this.lastDailyBonusDate,
    this.completedSessionCount = 0,
    this.lastUpgradePromptDate,
  });
}
