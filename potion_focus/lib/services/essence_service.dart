import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:potion_focus/data/local/database.dart';
import 'package:potion_focus/data/local/isar_helpers.dart';
import 'package:potion_focus/data/models/user_data_model.dart';

class EssenceService {
  Future<int> getEssenceBalance() async {
    final db = DatabaseHelper.instance;
    final allUserData = await db.userDataModels.getAllItems();
    final userData = allUserData.firstOrNull;
    return userData?.essenceBalance ?? 0;
  }

  Future<void> addEssence(int amount) async {
    final db = DatabaseHelper.instance;
    final allUserData = await db.userDataModels.getAllItems();
    final userData = allUserData.firstOrNull ?? UserDataModel();

    userData.essenceBalance += amount;

    await db.writeTxn(() async {
      await db.userDataModels.put(userData);
    });
  }

  Future<bool> spendEssence(int amount) async {
    final db = DatabaseHelper.instance;

    // Atomic check-and-deduct inside a single transaction (bug 1.5)
    return await db.writeTxn(() async {
      final allUserData = await db.userDataModels.where().findAll();
      final userData = allUserData.firstOrNull ?? UserDataModel();

      if (userData.essenceBalance < amount) {
        return false; // Not enough essence
      }

      userData.essenceBalance -= amount;
      await db.userDataModels.put(userData);
      return true;
    });
  }

  Future<UserDataModel> getUserData() async {
    final db = DatabaseHelper.instance;
    final allUserData = await db.userDataModels.getAllItems();
    return allUserData.firstOrNull ?? UserDataModel();
  }

  Future<void> updateStreak() async {
    final db = DatabaseHelper.instance;
    final allUserData = await db.userDataModels.getAllItems();
    final userData = allUserData.firstOrNull ?? UserDataModel();

    final now = DateTime.now();
    final lastFocus = userData.lastFocusDate;

    if (lastFocus == null) {
      // First session ever
      userData.streakDays = 1;
    } else {
      final daysSinceLastFocus = now.difference(lastFocus).inDays;

      if (daysSinceLastFocus == 0) {
        // Same day, don't change streak
      } else if (daysSinceLastFocus == 1) {
        // Consecutive day, increment streak
        userData.streakDays += 1;
      } else {
        // Streak broken, reset to 1
        userData.streakDays = 1;
      }
    }

    userData.lastFocusDate = now;

    await db.writeTxn(() async {
      await db.userDataModels.put(userData);
    });
  }

  Future<void> incrementPotionCount() async {
    final db = DatabaseHelper.instance;
    final allUserData = await db.userDataModels.getAllItems();
    final userData = allUserData.firstOrNull ?? UserDataModel();

    userData.totalPotions += 1;

    await db.writeTxn(() async {
      await db.userDataModels.put(userData);
    });
  }

  Future<void> addFocusMinutes(int minutes) async {
    final db = DatabaseHelper.instance;
    final allUserData = await db.userDataModels.getAllItems();
    final userData = allUserData.firstOrNull ?? UserDataModel();

    userData.totalFocusMinutes += minutes;

    await db.writeTxn(() async {
      await db.userDataModels.put(userData);
    });
  }
}

final essenceServiceProvider = Provider<EssenceService>((ref) {
  return EssenceService();
});

// Provider to watch essence balance
final essenceBalanceProvider = StreamProvider<int>((ref) async* {
  final service = ref.watch(essenceServiceProvider);
  
  // Initial value
  yield await service.getEssenceBalance();
  
  // TODO: In the future, add stream listener for database changes
  // For now, this will update when the provider is refreshed
});

