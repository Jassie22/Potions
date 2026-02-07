import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:potion_focus/core/theme/app_colors.dart';
import 'package:potion_focus/core/utils/extensions.dart';
import 'package:potion_focus/data/models/recipe_model.dart';
import 'package:potion_focus/presentation/shared/painting/pixel_gradients.dart';
import 'package:potion_focus/services/recipe_service.dart';

class RecipeCard extends ConsumerWidget {
  final RecipeModel recipe;
  final bool isUnlocked;

  const RecipeCard({
    super.key,
    required this.recipe,
    required this.isUnlocked,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rarityColor = AppColors.getRarityColor(recipe.rarity);

    return Card(
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
        side: BorderSide(
          color: Colors.black87,
          width: 2,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.zero,
          gradient: PixelGradients.twoBand(
            baseColor: rarityColor,
            topOpacity: isUnlocked ? 0.12 : 0.06,
            bottomOpacity: isUnlocked ? 0.04 : 0.02,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                // Recipe icon
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: rarityColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.zero,
                  ),
                  child: Icon(
                    _getRewardIcon(recipe.rewardType),
                    color: rarityColor,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),

                // Recipe name and rarity
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recipe.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        recipe.rarity[0].toUpperCase() + recipe.rarity.substring(1),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: rarityColor,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                ),

                // Unlock status
                if (isUnlocked)
                  const Icon(Icons.check_circle, color: Colors.green, size: 28)
                else
                  Icon(Icons.lock, color: Colors.grey[400], size: 28),
              ],
            ),
            const SizedBox(height: 16),

            // Lore (only for unlocked)
            if (isUnlocked) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.zero,
                ),
                child: Text(
                  recipe.lore,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontStyle: FontStyle.italic,
                        color: Colors.grey[600],
                      ),
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Unlock condition / hint
            Row(
              children: [
                Icon(
                  isUnlocked ? Icons.celebration : Icons.help_outline,
                  size: 16,
                  color: isUnlocked ? Colors.green : Colors.grey[600],
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isUnlocked
                        ? 'Unlocked ${recipe.unlockedAt?.toFormattedDate() ?? ""}'
                        : _getUnlockHint(),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isUnlocked ? Colors.green : Colors.grey[600],
                        ),
                  ),
                ),
              ],
            ),

            // Reward info
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: rarityColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.zero,
                border: Border.all(
                  color: rarityColor.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.card_giftcard,
                    size: 18,
                    color: rarityColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Reward: ${_getRewardTypeLabel(recipe.rewardType)}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getUnlockHint() {
    final recipeService = RecipeService();
    final condition = jsonDecode(recipe.unlockCondition);
    return recipeService.getRecipeHint(condition);
  }

  IconData _getRewardIcon(String rewardType) {
    switch (rewardType) {
      case 'bottle':
        return Icons.local_drink;
      case 'liquid':
        return Icons.water_drop;
      case 'effect':
        return Icons.auto_awesome;
      case 'background':
        return Icons.wallpaper;
      default:
        return Icons.card_giftcard;
    }
  }

  String _getRewardTypeLabel(String rewardType) {
    switch (rewardType) {
      case 'bottle':
        return 'New Bottle Design';
      case 'liquid':
        return 'New Liquid Color';
      case 'effect':
        return 'New Visual Effect';
      case 'background':
        return 'New Background';
      default:
        return 'Special Reward';
    }
  }
}



