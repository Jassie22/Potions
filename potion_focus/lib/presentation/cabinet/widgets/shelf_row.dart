import 'package:flutter/material.dart';
import 'package:potion_focus/core/theme/app_colors.dart';
import 'package:potion_focus/data/models/potion_model.dart';
import 'package:potion_focus/presentation/shared/painting/potion_renderer.dart';
import 'package:potion_focus/presentation/shared/painting/wood_texture_painter.dart';
import 'package:potion_focus/core/models/visual_config.dart';

/// A horizontal row of potions displayed on a wooden shelf.
class ShelfRow extends StatelessWidget {
  final String rarity;
  final List<PotionModel> potions;
  final void Function(PotionModel potion) onPotionTap;

  const ShelfRow({
    super.key,
    required this.rarity,
    required this.potions,
    required this.onPotionTap,
  });

  @override
  Widget build(BuildContext context) {
    final rarityColor = AppColors.getRarityColor(rarity);
    final rarityLabel = rarity[0].toUpperCase() + rarity.substring(1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Rarity header
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            children: [
              // Star indicator based on rarity
              ...List.generate(
                _getStarCount(rarity),
                (i) => Icon(Icons.star, size: 12, color: rarityColor),
              ),
              const SizedBox(width: 6),
              Text(
                rarityLabel.toUpperCase(),
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: rarityColor,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
              ),
              const SizedBox(width: 8),
              Text(
                '(${potions.length})',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: rarityColor.withValues(alpha: 0.7),
                    ),
              ),
            ],
          ),
        ),

        // Shelf with potions
        Container(
          height: 110,
          margin: const EdgeInsets.symmetric(horizontal: 8),
          child: Stack(
            children: [
              // Wood background
              Positioned.fill(
                child: CustomPaint(
                  painter: WoodTexturePainter(),
                ),
              ),

              // Potions row
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                bottom: 20, // Leave room for shelf edge
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  itemCount: potions.length,
                  itemBuilder: (context, index) {
                    final potion = potions[index];
                    return _ShelfPotionItem(
                      potion: potion,
                      onTap: () => onPotionTap(potion),
                    );
                  },
                ),
              ),

              // Shelf edge (front lip)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: 16,
                child: CustomPaint(
                  painter: WoodTexturePainter(isShelfEdge: true),
                ),
              ),
            ],
          ),
        ),

        // Shadow under shelf
        Container(
          height: 12,
          margin: const EdgeInsets.symmetric(horizontal: 8),
          child: CustomPaint(
            painter: ShelfShadowPainter(),
          ),
        ),
      ],
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
}

/// Individual potion item displayed on the shelf
class _ShelfPotionItem extends StatelessWidget {
  final PotionModel potion;
  final VoidCallback onTap;

  const _ShelfPotionItem({
    required this.potion,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final config = VisualConfig.fromJson(potion.visualConfig);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 65,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Potion bottle
            PotionRenderer(
              config: config,
              size: 60,
              fillPercent: 1.0,
              showGlow: false,
            ),
            const SizedBox(height: 2),
            // Essence value
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black45,
                border: Border.all(color: Colors.black54, width: 1),
              ),
              child: Text(
                '${potion.essenceEarned}',
                style: const TextStyle(
                  fontSize: 8,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
