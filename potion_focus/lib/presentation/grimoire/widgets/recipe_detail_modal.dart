import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:potion_focus/core/models/visual_config.dart';
import 'package:potion_focus/core/theme/app_colors.dart';
import 'package:potion_focus/core/utils/extensions.dart';
import 'package:potion_focus/data/models/recipe_model.dart';
import 'package:potion_focus/services/recipe_service.dart';
import 'package:potion_focus/presentation/shared/painting/potion_renderer.dart';

/// A modal bottom sheet displaying full recipe details.
/// Shows potion illustration, name, lore, unlock status, and reward info.
class RecipeDetailModal extends StatelessWidget {
  final RecipeModel recipe;
  final RecipeService recipeService;

  const RecipeDetailModal({
    super.key,
    required this.recipe,
    required this.recipeService,
  });

  @override
  Widget build(BuildContext context) {
    final rarityColor = AppColors.getRarityColor(recipe.rarity);
    final isUnlocked = recipe.unlocked;
    final config = _getRecipeVisualConfig();

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFFF5E6C8), // Parchment color
        border: Border(
          top: BorderSide(color: Color(0xFF3D2B1F), width: 3),
          left: BorderSide(color: Color(0xFF3D2B1F), width: 3),
          right: BorderSide(color: Color(0xFF3D2B1F), width: 3),
        ),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFF8B7355).withValues(alpha: 0.5),
                  borderRadius: BorderRadius.zero,
                ),
              ),
              const SizedBox(height: 20),

              // Recipe name
              Text(
                isUnlocked ? recipe.name : '???',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isUnlocked
                          ? const Color(0xFF3D2B1F)
                          : Colors.grey[500],
                      letterSpacing: 0.5,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),

              // Rarity label with stars
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ...List.generate(
                    _getStarCount(),
                    (i) => Icon(Icons.star, size: 14, color: rarityColor),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    recipe.rarity[0].toUpperCase() + recipe.rarity.substring(1),
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: rarityColor,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.0,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Potion illustration
              Stack(
                alignment: Alignment.center,
                children: [
                  // Colored glow behind potion
                  Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      gradient: RadialGradient(
                        colors: [
                          isUnlocked
                              ? config.liquidColor.withValues(alpha: 0.12)
                              : config.liquidColor.withValues(alpha: 0.05),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                  // Potion bottle
                  isUnlocked
                      ? PotionRenderer(
                          config: config,
                          size: 160,
                          fillPercent: 1.0,
                        )
                      : Opacity(
                          opacity: 0.25,
                          child: PotionRenderer(
                            config: config,
                            size: 160,
                            fillPercent: 0.7,
                            showGlow: false,
                          ),
                        ),
                ],
              ),
              const SizedBox(height: 20),

              // Lore text (only if unlocked)
              if (isUnlocked) ...[
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B7355).withValues(alpha: 0.08),
                    border: Border.all(
                      color: const Color(0xFF8B7355).withValues(alpha: 0.2),
                      width: 1,
                    ),
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
                const SizedBox(height: 16),
              ],

              // Unlock hint (if locked)
              if (!isUnlocked) ...[
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B7355).withValues(alpha: 0.08),
                    border: Border.all(
                      color: const Color(0xFF8B7355).withValues(alpha: 0.2),
                      width: 1,
                    ),
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
                const SizedBox(height: 16),
              ],

              // Reward info
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: rarityColor.withValues(alpha: 0.1),
                  border: Border.all(
                    color: rarityColor.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getRewardIcon(),
                      size: 18,
                      color: rarityColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Reward: ${_getRewardLabel()}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF3D2B1F),
                          ),
                    ),
                  ],
                ),
              ),

              // Unlock date (if unlocked)
              if (isUnlocked && recipe.unlockedAt != null) ...[
                const SizedBox(height: 12),
                Text(
                  'Discovered ${recipe.unlockedAt!.toFormattedDate()}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF5D4E37).withValues(alpha: 0.5),
                        fontSize: 11,
                      ),
                ),
              ],

              const SizedBox(height: 16),

              // Close button
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3D2B1F),
                    border: Border.all(color: Colors.black87, width: 2),
                  ),
                  child: Text(
                    'Close',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFFF5E6C8),
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  VisualConfig _getRecipeVisualConfig() {
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

  int _getStarCount() {
    switch (recipe.rarity.toLowerCase()) {
      case 'legendary':
        return 5;
      case 'epic':
        return 4;
      case 'rare':
        return 3;
      case 'uncommon':
        return 2;
      default:
        return 1;
    }
  }

  String _getHint() {
    try {
      final condition =
          jsonDecode(recipe.unlockCondition) as Map<String, dynamic>;
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
