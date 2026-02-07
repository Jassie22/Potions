import 'package:flutter/material.dart';
import 'package:potion_focus/core/theme/app_colors.dart';
import 'book_page_background.dart';

/// A decorative divider page between rarity sections in the grimoire.
class SectionDividerPage extends StatelessWidget {
  final String rarity;
  final int recipeCount;

  const SectionDividerPage({
    super.key,
    required this.rarity,
    required this.recipeCount,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppColors.getRarityColor(rarity);
    final rarityName = rarity[0].toUpperCase() + rarity.substring(1);

    return BookPageBackground(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 48),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Decorative line
              Row(
                children: [
                  Expanded(child: Divider(color: color.withValues(alpha: 0.4), thickness: 1)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Icon(Icons.auto_awesome, color: color.withValues(alpha: 0.5), size: 20),
                  ),
                  Expanded(child: Divider(color: color.withValues(alpha: 0.4), thickness: 1)),
                ],
              ),
              const SizedBox(height: 20),

              // Rarity title
              Text(
                rarityName,
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: color,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.0,
                    ),
              ),
              const SizedBox(height: 8),

              Text(
                '$recipeCount ${recipeCount == 1 ? 'Recipe' : 'Recipes'}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF5D4E37).withValues(alpha: 0.6),
                    ),
              ),
              const SizedBox(height: 20),

              // Decorative line
              Row(
                children: [
                  Expanded(child: Divider(color: color.withValues(alpha: 0.4), thickness: 1)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Icon(Icons.auto_awesome, color: color.withValues(alpha: 0.5), size: 20),
                  ),
                  Expanded(child: Divider(color: color.withValues(alpha: 0.4), thickness: 1)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
