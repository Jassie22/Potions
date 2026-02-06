import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:potion_focus/data/local/database.dart';
import 'package:potion_focus/data/local/isar_helpers.dart';
import 'package:potion_focus/data/models/user_data_model.dart';
import 'package:potion_focus/services/coin_service.dart';
import 'package:potion_focus/services/subscription_service.dart';

/// Handles daily coin bonus for premium subscribers.
///
/// Premium users receive 10 coins once per day. The bonus can be claimed
/// automatically on session completion or manually from the subscription screen.
class DailyBonusService {
  final Ref _ref;

  DailyBonusService(this._ref);

  /// Daily coin bonus amount for premium subscribers
  static const int dailyCoinBonus = 10;

  /// Check if bonus can be claimed today and grant it if so.
  ///
  /// Returns true if bonus was granted, false if already claimed or not premium.
  Future<bool> checkAndGrantDailyBonus() async {
    final isPremium = _ref.read(subscriptionServiceProvider).isPremium;
    if (!isPremium) return false;

    final canClaim = await canClaimToday();
    if (!canClaim) return false;

    // Grant the bonus
    await _ref.read(coinServiceProvider).addCoins(dailyCoinBonus);

    // Update last grant date
    final db = DatabaseHelper.instance;
    final allUserData = await db.userDataModels.getAllItems();
    final userData = allUserData.firstOrNull ?? UserDataModel();

    userData.lastDailyBonusDate = DateTime.now().toUtc();

    await db.writeTxn(() async {
      await db.userDataModels.put(userData);
    });

    // Invalidate coin balance provider to refresh UI
    _ref.invalidate(coinBalanceProvider);

    return true;
  }

  /// Check if the daily bonus can be claimed today.
  ///
  /// Returns true if user is premium and hasn't claimed today.
  Future<bool> canClaimToday() async {
    final isPremium = _ref.read(subscriptionServiceProvider).isPremium;
    if (!isPremium) return false;

    final db = DatabaseHelper.instance;
    final allUserData = await db.userDataModels.getAllItems();
    final userData = allUserData.firstOrNull;

    // If never claimed, can claim
    if (userData?.lastDailyBonusDate == null) return true;

    final lastGrant = userData!.lastDailyBonusDate!;
    final now = DateTime.now().toUtc();

    // Compare dates in UTC to avoid timezone issues
    final lastGrantDay =
        DateTime.utc(lastGrant.year, lastGrant.month, lastGrant.day);
    final today = DateTime.utc(now.year, now.month, now.day);

    // Can claim if today is after the last grant day
    return today.isAfter(lastGrantDay);
  }

  /// Get the last date when bonus was claimed.
  Future<DateTime?> getLastBonusDate() async {
    final db = DatabaseHelper.instance;
    final allUserData = await db.userDataModels.getAllItems();
    return allUserData.firstOrNull?.lastDailyBonusDate;
  }
}

final dailyBonusServiceProvider = Provider<DailyBonusService>((ref) {
  return DailyBonusService(ref);
});

/// Provider for checking if daily bonus can be claimed
final canClaimDailyBonusProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(dailyBonusServiceProvider);
  return await service.canClaimToday();
});
