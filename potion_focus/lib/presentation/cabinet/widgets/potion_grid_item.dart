import 'package:flutter/material.dart';
import 'package:potion_focus/core/models/visual_config.dart';
import 'package:potion_focus/core/theme/app_colors.dart';
import 'package:potion_focus/core/utils/extensions.dart';
import 'package:potion_focus/data/models/potion_model.dart';
import 'package:potion_focus/presentation/shared/painting/potion_renderer.dart';
import 'package:potion_focus/presentation/shared/painting/pixel_gradients.dart';

class PotionGridItem extends StatelessWidget {
  final PotionModel potion;
  final VoidCallback onTap;

  const PotionGridItem({
    super.key,
    required this.potion,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final rarityColor = AppColors.getRarityColor(potion.rarity);

    return GestureDetector(
      onTap: onTap,
      child: Card(
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
            gradient: PixelGradients.twoBand(baseColor: rarityColor),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Potion visual
              PotionRenderer(
                config: VisualConfig.fromJson(potion.visualConfig),
                size: 80,
              ),
              const SizedBox(height: 12),

              // Rarity
              Text(
                potion.rarity[0].toUpperCase() + potion.rarity.substring(1),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: rarityColor,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 4),

              // Essence
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.auto_awesome,
                    size: 14,
                    color: Colors.amber,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${potion.essenceEarned}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: 4),

              // Date
              Text(
                potion.createdAt.toFormattedDate(),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

