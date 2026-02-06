import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:potion_focus/data/local/database.dart';
import 'package:potion_focus/data/local/isar_helpers.dart';
import 'package:potion_focus/data/models/user_data_model.dart';
import 'package:potion_focus/services/subscription_service.dart';

/// Types of upgrade prompts
enum UpgradePromptType {
  postSession, // After completing a focus session
  weeklyReminder, // Weekly reminder on app launch
  exclusiveItem, // When tapping an exclusive item in shop
}

/// Manages when and how often to show upgrade prompts to non-subscribers.
///
/// Prompt rules:
/// - Post-session: Show every 3rd completed session
/// - Weekly reminder: Show once per week max on app launch
/// - Exclusive item: Always show when tapping exclusive items
class UpgradePromptService {
  final Ref _ref;

  UpgradePromptService(this._ref);

  /// Show post-session prompt every N sessions
  static const int sessionsBetweenPrompts = 5;

  /// Minimum days between weekly reminders
  static const int daysBetweenWeeklyReminders = 7;

  /// Check if post-session upgrade prompt should be shown.
  ///
  /// Returns true every 3rd completed session for non-subscribers.
  Future<bool> shouldShowPostSessionPrompt() async {
    final isPremium = _ref.read(subscriptionServiceProvider).isPremium;
    if (isPremium) return false;

    final db = DatabaseHelper.instance;
    final allUserData = await db.userDataModels.getAllItems();
    final userData = allUserData.firstOrNull ?? UserDataModel();

    // Show every Nth session (1st session = index 0, show on 3, 6, 9, etc.)
    return (userData.completedSessionCount % sessionsBetweenPrompts) == 0 &&
        userData.completedSessionCount > 0;
  }

  /// Check if weekly reminder should be shown on app launch.
  ///
  /// Returns true if non-subscriber and >7 days since last reminder.
  Future<bool> shouldShowWeeklyReminder() async {
    final isPremium = _ref.read(subscriptionServiceProvider).isPremium;
    if (isPremium) return false;

    final db = DatabaseHelper.instance;
    final allUserData = await db.userDataModels.getAllItems();
    final userData = allUserData.firstOrNull;

    // If never shown, show it
    if (userData?.lastUpgradePromptDate == null) return true;

    final lastPrompt = userData!.lastUpgradePromptDate!;
    final now = DateTime.now().toUtc();

    final daysSinceLastPrompt = now.difference(lastPrompt).inDays;
    return daysSinceLastPrompt >= daysBetweenWeeklyReminders;
  }

  /// Record that a prompt was shown.
  ///
  /// Updates the last prompt date for weekly reminder tracking.
  Future<void> recordPromptShown(UpgradePromptType type) async {
    if (type == UpgradePromptType.weeklyReminder ||
        type == UpgradePromptType.postSession) {
      final db = DatabaseHelper.instance;
      final allUserData = await db.userDataModels.getAllItems();
      final userData = allUserData.firstOrNull ?? UserDataModel();

      userData.lastUpgradePromptDate = DateTime.now().toUtc();

      await db.writeTxn(() async {
        await db.userDataModels.put(userData);
      });
    }
  }

  /// Increment the completed session counter.
  ///
  /// Called after each successful session completion.
  Future<void> incrementSessionCount() async {
    final db = DatabaseHelper.instance;
    final allUserData = await db.userDataModels.getAllItems();
    final userData = allUserData.firstOrNull ?? UserDataModel();

    userData.completedSessionCount++;

    await db.writeTxn(() async {
      await db.userDataModels.put(userData);
    });
  }

  /// Get the current completed session count.
  Future<int> getSessionCount() async {
    final db = DatabaseHelper.instance;
    final allUserData = await db.userDataModels.getAllItems();
    return allUserData.firstOrNull?.completedSessionCount ?? 0;
  }
}

final upgradePromptServiceProvider = Provider<UpgradePromptService>((ref) {
  return UpgradePromptService(ref);
});
