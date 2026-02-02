import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:potion_focus/data/local/database.dart';
import 'package:potion_focus/data/local/isar_helpers.dart';
import 'package:potion_focus/data/models/potion_model.dart';

class PotionRepository {
  Future<List<PotionModel>> getAllPotions() async {
    final db = DatabaseHelper.instance;
    final allPotions = await db.potionModels.getAllItems();
    allPotions.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return allPotions;
  }

  Future<List<PotionModel>> getPotionsByRarity(String rarity) async {
    final db = DatabaseHelper.instance;
    final allPotions = await db.potionModels.getAllItems();
    final potions = allPotions.where((p) => p.rarity == rarity).toList();
    potions.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return potions;
  }

  Future<List<PotionModel>> getPotionsByDateRange(DateTime start, DateTime end) async {
    final db = DatabaseHelper.instance;
    final allPotions = await db.potionModels.getAllItems();
    final potions = allPotions.where((p) => 
        p.createdAt.isAfter(start.subtract(const Duration(seconds: 1))) && 
        p.createdAt.isBefore(end.add(const Duration(seconds: 1)))).toList();
    potions.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return potions;
  }

  Future<int> getPotionCount() async {
    final db = DatabaseHelper.instance;
    return await db.potionModels.count();
  }

  Future<PotionModel?> getPotionBySessionId(String sessionId) async {
    final db = DatabaseHelper.instance;
    final allPotions = await db.potionModels.getAllItems();
    return allPotions.where((p) => p.sessionId == sessionId).firstOrNull;
  }

  Future<Map<String, int>> getRarityDistribution() async {
    final db = DatabaseHelper.instance;
    final allPotions = await db.potionModels.getAllItems();

    final distribution = <String, int>{
      'common': 0,
      'uncommon': 0,
      'rare': 0,
      'epic': 0,
      'legendary': 0,
      'muddy': 0,
    };

    for (final potion in allPotions) {
      distribution[potion.rarity] = (distribution[potion.rarity] ?? 0) + 1;
    }

    return distribution;
  }
}

final potionRepositoryProvider = Provider<PotionRepository>((ref) {
  return PotionRepository();
});

final allPotionsProvider = FutureProvider<List<PotionModel>>((ref) async {
  final repository = ref.watch(potionRepositoryProvider);
  return await repository.getAllPotions();
});

