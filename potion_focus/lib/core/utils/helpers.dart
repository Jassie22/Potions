import 'dart:math';
import 'package:uuid/uuid.dart';

class Helpers {
  static final _uuid = Uuid();
  static final _random = Random();

  // Generate unique ID
  static String generateId() {
    return _uuid.v4();
  }

  // Random number between min and max (inclusive)
  static int randomInt(int min, int max) {
    return min + _random.nextInt(max - min + 1);
  }

  // Random element from list
  static T randomElement<T>(List<T> list) {
    return list[_random.nextInt(list.length)];
  }

  // Weighted random selection
  static String weightedRandom(Map<String, double> weights) {
    final totalWeight = weights.values.reduce((a, b) => a + b);
    final randomValue = _random.nextDouble() * totalWeight;

    double cumulativeWeight = 0.0;
    for (final entry in weights.entries) {
      cumulativeWeight += entry.value;
      if (randomValue <= cumulativeWeight) {
        return entry.key;
      }
    }

    return weights.keys.first;
  }

  // Calculate essence based on duration and multipliers
  static int calculateEssence({
    required int durationMinutes,
    required int rarityMultiplier,
    required int streakBonus,
  }) {
    final base = durationMinutes ~/ 5; // 5 minutes = 1 essence
    return (base * rarityMultiplier) + streakBonus;
  }

  // Calculate rarity based on various factors
  static String calculateRarity({
    required int durationMinutes,
    required int streakDays,
    bool hasActiveRecipe = false,
  }) {
    final baseChance = durationMinutes / 60.0;
    final streakBonus = streakDays * 0.05;
    final recipeBonus = hasActiveRecipe ? 0.2 : 0.0;

    final totalChance = baseChance + streakBonus + recipeBonus;
    final roll = _random.nextInt(100);

    if (roll < totalChance * 2) return 'legendary'; // ~2%
    if (roll < totalChance * 8) return 'epic'; // ~6%
    if (roll < totalChance * 20) return 'rare'; // ~12%
    if (roll < totalChance * 50) return 'uncommon'; // ~30%
    return 'common'; // ~50%
  }

  // Format large numbers (e.g., 1000 -> 1K)
  static String formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  // Clamp value between min and max
  static T clamp<T extends num>(T value, T min, T max) {
    if (value < min) return min;
    if (value > max) return max;
    return value;
  }
}



