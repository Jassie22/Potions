import 'package:flutter/material.dart';
import 'package:potion_focus/core/models/visual_config.dart';
import 'package:potion_focus/core/theme/app_colors.dart';
import 'package:potion_focus/data/models/recipe_model.dart';
import 'package:potion_focus/presentation/shared/painting/potion_renderer.dart';

/// A compact thumbnail for displaying a recipe in a grid.
/// Shows a small potion preview (80px), recipe name, and lock icon if not unlocked.
class RecipeThumbnail extends StatelessWidget {
  final RecipeModel recipe;
  final VoidCallback onTap;

  const RecipeThumbnail({
    super.key,
    required this.recipe,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isUnlocked = recipe.unlocked;
    final rarityColor = AppColors.getRarityColor(recipe.rarity);
    final config = _getRecipeVisualConfig();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: rarityColor.withValues(alpha: isUnlocked ? 0.08 : 0.04),
          border: Border.all(
            color: rarityColor.withValues(alpha: isUnlocked ? 0.3 : 0.15),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Potion bottle (or locked silhouette)
            Stack(
              alignment: Alignment.center,
              children: [
                isUnlocked
                    ? PotionRenderer(
                        config: config,
                        size: 70,
                        fillPercent: 1.0,
                        showGlow: false,
                      )
                    : Opacity(
                        opacity: 0.3,
                        child: PotionRenderer(
                          config: config,
                          size: 70,
                          fillPercent: 0.6,
                          showGlow: false,
                        ),
                      ),
                // Lock icon overlay for locked recipes
                if (!isUnlocked)
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      border: Border.all(color: Colors.black54, width: 1),
                    ),
                    child: const Icon(
                      Icons.lock,
                      color: Colors.white70,
                      size: 16,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),

            // Recipe name (or "???")
            Text(
              isUnlocked ? _truncateName(recipe.name) : '???',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: isUnlocked
                        ? const Color(0xFF3D2B1F)
                        : const Color(0xFF3D2B1F).withValues(alpha: 0.4),
                    fontWeight: FontWeight.w600,
                    fontSize: 9,
                  ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  VisualConfig _getRecipeVisualConfig() {
    // Build a visual config from the recipe's reward to show as illustration
    final bottleShape = recipe.rewardType == 'bottle'
        ? recipe.rewardAssetKey
        : VisualConfig.defaultForRarity(recipe.rarity).bottleShape;
    final liquid = recipe.rewardType == 'liquid'
        ? recipe.rewardAssetKey
        : VisualConfig.defaultForRarity(recipe.rarity).liquid;
    final effect = recipe.rewardType == 'effect'
        ? recipe.rewardAssetKey
        : VisualConfig.defaultForRarity(recipe.rarity).effectType;

    return VisualConfig(
      bottleShape: bottleShape,
      liquid: liquid,
      effectType: effect,
      rarity: recipe.rarity,
    );
  }

  String _truncateName(String name) {
    // Truncate long names for compact display
    if (name.length <= 14) return name;
    return '${name.substring(0, 12)}...';
  }
}
