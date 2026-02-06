import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:potion_focus/core/theme/app_colors.dart';
import 'package:potion_focus/data/models/shop_item_model.dart';
import 'package:potion_focus/services/subscription_service.dart';
import 'package:potion_focus/services/upgrade_prompt_service.dart';
import 'package:potion_focus/presentation/shared/widgets/upgrade_prompt_modal.dart';
import 'package:potion_focus/presentation/shared/painting/pixel_gradients.dart';
import 'package:potion_focus/presentation/shared/widgets/pixel_button.dart';
import 'package:potion_focus/presentation/shared/painting/bottle_painter.dart';
import 'package:potion_focus/presentation/shared/painting/background_themes.dart';

class ShopItemCard extends ConsumerWidget {
  final ShopItemModel item;
  final VoidCallback onPurchase;

  const ShopItemCard({
    super.key,
    required this.item,
    required this.onPurchase,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPremium = ref.watch(isPremiumProvider);
    final rarityColor = AppColors.getRarityColor(item.rarity);
    final isPurchased = item.purchased;
    final isSubscriberOnly = item.currencyType == 'subscriber_only';
    final isCoins = item.currencyType == 'coins';
    final cost = isCoins ? item.coinCost : item.essenceCost;

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
            baseColor: isSubscriberOnly ? AppColors.legendary : rarityColor,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Item icon with exclusive badge
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        clipBehavior: Clip.hardEdge,
                        decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          color: (isSubscriberOnly
                                  ? AppColors.legendary
                                  : rarityColor)
                              .withOpacity(0.2),
                          border: item.category == 'background'
                              ? Border.all(color: Colors.black54, width: 2)
                              : null,
                        ),
                        child: item.category == 'bottle'
                            ? Center(
                                child: CustomPaint(
                                  size: const Size(50, 55),
                                  painter: BottlePainter(
                                    shapeId: item.assetKey,
                                    fillPercent: 0.6,
                                    liquidColor: rarityColor.withOpacity(0.7),
                                    glassColor: Colors.white.withOpacity(0.8),
                                  ),
                                ),
                              )
                            : item.category == 'background'
                                // Show actual theme preview for backgrounds
                                ? CustomPaint(
                                    size: const Size(60, 60),
                                    painter: BackgroundThemePainter(
                                      themeId: item.assetKey,
                                      animationValue: 0.3, // Static preview frame
                                    ),
                                  )
                                : Icon(
                                    _getCategoryIcon(item.category),
                                    size: 30,
                                    color: isSubscriberOnly
                                        ? AppColors.legendary
                                        : rarityColor,
                                  ),
                      ),
                      // Exclusive star badge
                      if (isSubscriberOnly && !isPurchased)
                        Positioned(
                          top: -6,
                          right: -6,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: AppColors.legendary,
                              borderRadius: BorderRadius.zero,
                              border: Border.all(
                                color: Colors.white,
                                width: 1,
                              ),
                            ),
                            child: const Icon(
                              Icons.star,
                              size: 12,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),

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
                  const SizedBox(height: 2),

                  // Rarity + currency type label
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        item.rarity[0].toUpperCase() + item.rarity.substring(1),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: isSubscriberOnly
                                  ? AppColors.legendary
                                  : rarityColor,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      if (isSubscriberOnly && !isPurchased) ...[
                        const SizedBox(width: 6),
                        Icon(
                          Icons.workspace_premium,
                          size: 12,
                          color: AppColors.legendary.withOpacity(0.8),
                        ),
                      ] else if (!isPurchased && isCoins) ...[
                        const SizedBox(width: 6),
                        Icon(
                          Icons.monetization_on,
                          size: 12,
                          color: Colors.blue.withOpacity(0.7),
                        ),
                      ],
                    ],
                  ),

                  // Description
                  if (item.description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        item.description,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontStyle: FontStyle.italic,
                              color: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.color
                                  ?.withOpacity(0.6),
                              fontSize: 11,
                            ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Purchase button or status
            Padding(
              padding: const EdgeInsets.all(12),
              child: _buildBottomSection(context, ref, isPremium, isPurchased,
                  isSubscriberOnly, isCoins, cost, rarityColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSection(
    BuildContext context,
    WidgetRef ref,
    bool isPremium,
    bool isPurchased,
    bool isSubscriberOnly,
    bool isCoins,
    int cost,
    Color rarityColor,
  ) {
    // Already owned
    if (isPurchased) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.success.withOpacity(0.15),
          borderRadius: BorderRadius.zero,
          border: Border.all(color: AppColors.success.withOpacity(0.5)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, color: AppColors.success, size: 16),
            const SizedBox(width: 6),
            Text(
              'Owned',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      );
    }

    // Subscriber-only item
    if (isSubscriberOnly) {
      if (isPremium) {
        // Premium user can claim for free
        return PixelButton(
          text: 'Claim',
          color: AppColors.legendary,
          width: double.infinity,
          onPressed: onPurchase,
        );
      } else {
        // Non-premium user sees locked state
        return GestureDetector(
          onTap: () {
            showUpgradePromptModal(
              context,
              ref,
              type: UpgradePromptType.exclusiveItem,
              customTitle: 'Exclusive Item',
              customMessage:
                  '${item.name} is exclusive to Potion Master subscribers.',
            );
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.legendary.withOpacity(0.1),
              borderRadius: BorderRadius.zero,
              border: Border.all(color: AppColors.legendary.withOpacity(0.4)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock,
                    color: AppColors.legendary.withOpacity(0.8), size: 16),
                const SizedBox(width: 6),
                Text(
                  'Exclusive',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.legendary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
        );
      }
    }

    // Regular purchase button (coins or essence)
    return PixelButton(
      text: '$cost',
      icon: isCoins ? Icons.monetization_on : Icons.auto_awesome,
      color: isCoins ? Colors.blue[700] : rarityColor,
      width: double.infinity,
      onPressed: onPurchase,
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
