import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:potion_focus/core/models/visual_config.dart';
import 'package:potion_focus/core/theme/app_colors.dart';
import 'package:potion_focus/core/utils/extensions.dart';
import 'package:potion_focus/data/models/recipe_model.dart';
import 'package:potion_focus/services/recipe_service.dart';
import 'package:potion_focus/presentation/shared/painting/potion_renderer.dart';
import 'book_page_background.dart';

/// A single grimoire page for one recipe.
/// Shows the potion illustration (or silhouette if locked), name, lore,
/// unlock status/hint, and reward info.
class RecipePage extends StatelessWidget {
  final RecipeModel recipe;
  final RecipeService recipeService;

  const RecipePage({
    super.key,
    required this.recipe,
    required this.recipeService,
  });

  @override
  Widget build(BuildContext context) {
    final rarityColor = AppColors.getRarityColor(recipe.rarity);
    final isUnlocked = recipe.unlocked;

    return BookPageBackground(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: Column(
            children: [
              const SizedBox(height: 16),

              // Recipe name
              Text(
                isUnlocked ? recipe.name : '???',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isUnlocked ? const Color(0xFF3D2B1F) : Colors.grey[500],
                      letterSpacing: 0.5,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),

              // Rarity label
              Text(
                recipe.rarity[0].toUpperCase() + recipe.rarity.substring(1),
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: rarityColor,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.0,
                    ),
              ),
              const SizedBox(height: 24),

              // Potion illustration (or silhouette)
              Expanded(
                child: Center(
                  child: isUnlocked
                      ? PotionRenderer(
                          config: _getRecipeVisualConfig(),
                          size: 180,
                          fillPercent: 1.0,
                        )
                      : Opacity(
                          opacity: 0.15,
                          child: PotionRenderer(
                            config: _getRecipeVisualConfig(),
                            size: 180,
                            fillPercent: 0.7,
                            showGlow: false,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),

              // Lore text (only if unlocked)
              if (isUnlocked) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B7355).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    recipe.lore,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontStyle: FontStyle.italic,
                          color: const Color(0xFF5D4E37),
                          height: 1.5,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],

              // Unlock hint (if locked)
              if (!isUnlocked) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B7355).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.lock_outline, size: 18, color: Colors.grey[500]),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          _getHint(),
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[600],
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 12),

              // Reward info
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _getRewardIcon(),
                    size: 16,
                    color: rarityColor.withOpacity(0.7),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Reward: ${_getRewardLabel()}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: const Color(0xFF5D4E37).withOpacity(0.7),
                        ),
                  ),
                ],
              ),

              // Unlock date
              if (isUnlocked && recipe.unlockedAt != null) ...[
                const SizedBox(height: 4),
                Text(
                  'Discovered ${recipe.unlockedAt!.toFormattedDate()}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF5D4E37).withOpacity(0.5),
                        fontSize: 11,
                      ),
                ),
              ],
              const SizedBox(height: 16),
            ],
          ),
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

  String _getHint() {
    try {
      final condition = jsonDecode(recipe.unlockCondition) as Map<String, dynamic>;
      return recipeService.getRecipeHint(condition);
    } catch (_) {
      return 'Complete a special challenge';
    }
  }

  IconData _getRewardIcon() {
    switch (recipe.rewardType) {
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

  String _getRewardLabel() {
    switch (recipe.rewardType) {
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
