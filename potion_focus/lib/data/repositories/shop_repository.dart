import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:potion_focus/data/local/database.dart';
import 'package:potion_focus/data/local/isar_helpers.dart';
import 'package:potion_focus/data/models/shop_item_model.dart';
import 'package:potion_focus/services/essence_service.dart';
import 'package:potion_focus/services/coin_service.dart';

class ShopRepository {
  Future<List<ShopItemModel>> getAllItems() async {
    final db = DatabaseHelper.instance;
    return await db.shopItemModels.getAllItems();
  }

  Future<List<ShopItemModel>> getItemsByCategory(String category) async {
    final db = DatabaseHelper.instance;
    final allItems = await db.shopItemModels.getAllItems();
    final items = allItems.where((item) => item.category == category).toList();
    items.sort((a, b) {
      // Sort by: purchased first, then by cost
      if (a.purchased != b.purchased) return a.purchased ? 1 : -1;
      final costA = a.currencyType == 'coins' ? a.coinCost : a.essenceCost;
      final costB = b.currencyType == 'coins' ? b.coinCost : b.essenceCost;
      return costA.compareTo(costB);
    });
    return items;
  }

  Future<List<ShopItemModel>> getPurchasedItems() async {
    final db = DatabaseHelper.instance;
    final allItems = await db.shopItemModels.getAllItems();
    return allItems.where((item) => item.purchased).toList();
  }

  Future<List<ShopItemModel>> getUnpurchasedItems() async {
    final db = DatabaseHelper.instance;
    final allItems = await db.shopItemModels.getAllItems();
    return allItems.where((item) => !item.purchased).toList();
  }

  /// Purchase an item using the correct currency.
  Future<bool> purchaseItem(
    String itemId,
    EssenceService essenceService,
    CoinService coinService,
  ) async {
    final db = DatabaseHelper.instance;

    final allItems = await db.shopItemModels.getAllItems();
    final item = allItems.where((i) => i.itemId == itemId).firstOrNull;

    if (item == null || item.purchased) return false;

    // Spend the correct currency
    bool success;
    if (item.currencyType == 'coins') {
      success = await coinService.spendCoins(item.coinCost);
    } else {
      success = await essenceService.spendEssence(item.essenceCost);
    }

    if (!success) return false;

    item.purchased = true;
    item.purchasedAt = DateTime.now();

    await db.writeTxn(() async {
      await db.shopItemModels.put(item);
    });

    return true;
  }
}

final shopRepositoryProvider = Provider<ShopRepository>((ref) {
  return ShopRepository();
});

final shopItemsProvider = FutureProvider<List<ShopItemModel>>((ref) async {
  final repository = ref.watch(shopRepositoryProvider);
  return await repository.getAllItems();
});

final shopItemsByCategoryProvider = FutureProvider.family<List<ShopItemModel>, String>(
  (ref, category) async {
    final repository = ref.watch(shopRepositoryProvider);
    return await repository.getItemsByCategory(category);
  },
);
