import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:potion_focus/data/local/database.dart';
import 'package:potion_focus/data/local/isar_helpers.dart';
import 'package:potion_focus/data/models/user_data_model.dart';

class CoinService {
  Future<int> getCoinBalance() async {
    final db = DatabaseHelper.instance;
    final allUserData = await db.userDataModels.getAllItems();
    final userData = allUserData.firstOrNull;
    return userData?.coinBalance ?? 0;
  }

  Future<void> addCoins(int amount) async {
    final db = DatabaseHelper.instance;
    final allUserData = await db.userDataModels.getAllItems();
    final userData = allUserData.firstOrNull ?? UserDataModel();

    userData.coinBalance += amount;

    await db.writeTxn(() async {
      await db.userDataModels.put(userData);
    });
  }

  Future<bool> spendCoins(int amount) async {
    final db = DatabaseHelper.instance;

    // Atomic check-and-deduct inside a single transaction (bug 1.5)
    return await db.writeTxn(() async {
      final allUserData = await db.userDataModels.where().findAll();
      final userData = allUserData.firstOrNull ?? UserDataModel();

      if (userData.coinBalance < amount) return false;

      userData.coinBalance -= amount;
      await db.userDataModels.put(userData);
      return true;
    });
  }
}

final coinServiceProvider = Provider<CoinService>((ref) {
  return CoinService();
});

final coinBalanceProvider = FutureProvider<int>((ref) async {
  final service = ref.watch(coinServiceProvider);
  return await service.getCoinBalance();
});
