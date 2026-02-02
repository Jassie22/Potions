import 'package:flutter/material.dart';
import 'package:potion_focus/core/theme/app_colors.dart';
import 'package:potion_focus/data/models/shop_item_model.dart';

class ShopItemCard extends StatelessWidget {
  final ShopItemModel item;
  final VoidCallback onPurchase;

  const ShopItemCard({
    super.key,
    required this.item,
    required this.onPurchase,
  });

  @override
  Widget build(BuildContext context) {
    final rarityColor = AppColors.getRarityColor(item.rarity);
    final isPurchased = item.purchased;
    final isCoins = item.currencyType == 'coins';
    final cost = isCoins ? item.coinCost : item.essenceCost;
    final isFree = cost == 0 && isPurchased;

    return Card(
      elevation: isPurchased ? 1 : 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: rarityColor.withOpacity(0.5),
          width: 2,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              rarityColor.withOpacity(0.1),
              rarityColor.withOpacity(0.05),
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Item icon
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: rarityColor.withOpacity(0.2),
                    ),
                    child: Icon(
                      _getCategoryIcon(item.category),
                      size: 40,
                      color: rarityColor,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Item name
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      item.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Rarity + currency type label
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        item.rarity[0].toUpperCase() + item.rarity.substring(1),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: rarityColor,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      if (!isPurchased && isCoins) ...[
                        const SizedBox(width: 6),
                        Icon(
                          Icons.monetization_on,
                          size: 12,
                          color: Colors.blue.withOpacity(0.7),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            // Purchase button or owned badge
            Padding(
              padding: const EdgeInsets.all(12),
              child: isPurchased
                  ? Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green.withOpacity(0.5)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.check_circle, color: Colors.green, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            'Owned',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.green,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                    )
                  : ElevatedButton(
                      onPressed: onPurchase,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 40),
                        backgroundColor: isCoins ? Colors.blue[700] : rarityColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isCoins ? Icons.monetization_on : Icons.auto_awesome,
                            size: 18,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '$cost',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'bottle':
        return Icons.local_drink;
      case 'liquid':
        return Icons.water_drop;
      case 'effect':
        return Icons.auto_awesome;
      case 'background':
        return Icons.wallpaper;
      case 'sound':
        return Icons.music_note;
      default:
        return Icons.shopping_bag;
    }
  }
}
