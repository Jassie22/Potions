import 'package:flutter/material.dart';
import 'package:potion_focus/core/theme/app_colors.dart';
import 'package:potion_focus/data/models/recipe_model.dart';
import 'package:potion_focus/services/recipe_service.dart';
import 'book_page_background.dart';
import 'recipe_thumbnail.dart';
import 'recipe_detail_modal.dart';

/// A grimoire page displaying a grid of recipe thumbnails.
/// Each page shows recipes of a single rarity tier with adaptive column count.
class RecipeGridPage extends StatelessWidget {
  final String rarity;
  final List<RecipeModel> recipes;
  final int pageIndex; // Which page of this rarity (0-based)
  final int totalPagesForRarity;
  final RecipeService recipeService;
  final int columnCount; // Adaptive column count based on rarity

  const RecipeGridPage({
    super.key,
    required this.rarity,
    required this.recipes,
    required this.pageIndex,
    required this.totalPagesForRarity,
    required this.recipeService,
    this.columnCount = 3, // Default to 3 for backwards compatibility
  });

  @override
  Widget build(BuildContext context) {
    final rarityColor = AppColors.getRarityColor(rarity);
    final rarityLabel = rarity[0].toUpperCase() + rarity.substring(1);

    return BookPageBackground(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            children: [
              // Rarity header with star indicators
              _buildRarityHeader(context, rarityLabel, rarityColor),
              const SizedBox(height: 16),

              // Recipe grid (adaptive column count)
              Expanded(
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columnCount,
                    crossAxisSpacing: columnCount >= 4 ? 6 : 8, // Tighter spacing for more columns
                    mainAxisSpacing: columnCount >= 4 ? 6 : 8,
                    // Adjust aspect ratio based on columns - less columns = larger items
                    childAspectRatio: columnCount <= 2 ? 0.85 : 0.75,
                  ),
                  itemCount: recipes.length,
                  itemBuilder: (context, index) {
                    final recipe = recipes[index];
                    return RecipeThumbnail(
                      recipe: recipe,
                      onTap: () => _showRecipeDetail(context, recipe),
                    );
                  },
                ),
              ),

              // Page indicator for this rarity (if multiple pages)
              if (totalPagesForRarity > 1) ...[
                const SizedBox(height: 12),
                _buildPageDots(context, rarityColor),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRarityHeader(BuildContext context, String label, Color color) {
    final starCount = _getStarCount(rarity);

    return Column(
      children: [
        // Decorative line with stars
        Row(
          children: [
            Expanded(
              child: Container(
                height: 2,
                color: color.withValues(alpha: 0.3),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                  starCount,
                  (i) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Icon(Icons.star, size: 14, color: color),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Container(
                height: 2,
                color: color.withValues(alpha: 0.3),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Rarity title
        Text(
          label.toUpperCase(),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
                letterSpacing: 2.0,
              ),
        ),
        const SizedBox(height: 4),

        // Recipe count
        Text(
          '${recipes.length} ${recipes.length == 1 ? 'Recipe' : 'Recipes'}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: const Color(0xFF5D4E37).withValues(alpha: 0.6),
              ),
        ),
      ],
    );
  }

  Widget _buildPageDots(BuildContext context, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalPagesForRarity, (index) {
        final isActive = index == pageIndex;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: isActive ? 12 : 6,
          height: 6,
          decoration: BoxDecoration(
            color: isActive ? color : color.withValues(alpha: 0.3),
            borderRadius: BorderRadius.zero,
          ),
        );
      }),
    );
  }

  int _getStarCount(String rarity) {
    switch (rarity.toLowerCase()) {
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

  void _showRecipeDetail(BuildContext context, RecipeModel recipe) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => RecipeDetailModal(
        recipe: recipe,
        recipeService: recipeService,
      ),
    );
  }
}
