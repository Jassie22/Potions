import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:potion_focus/core/errors/app_error.dart';
import 'package:potion_focus/core/theme/app_colors.dart';
import 'package:potion_focus/data/repositories/shop_repository.dart';
import 'package:potion_focus/services/essence_service.dart';
import 'package:potion_focus/services/coin_service.dart';
import 'package:potion_focus/services/feedback_service.dart';
import 'package:potion_focus/presentation/shared/widgets/error_snackbar.dart';
import 'package:potion_focus/presentation/shared/widgets/pixel_loading.dart';
import 'package:potion_focus/presentation/shop/widgets/shop_item_card.dart';
import 'package:potion_focus/presentation/home/widgets/bottle_selector.dart';

class ShopScreen extends ConsumerStatefulWidget {
  const ShopScreen({super.key});

  @override
  ConsumerState<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends ConsumerState<ShopScreen> {
  String _selectedCategory = 'all';

  @override
  Widget build(BuildContext context) {
    final shopItemsAsync = ref.watch(shopItemsProvider);
    final essenceBalanceAsync = ref.watch(essenceBalanceProvider);
    final coinBalanceAsync = ref.watch(coinBalanceProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Shop',
          style: Theme.of(context).textTheme.displaySmall,
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          // Coin balance
          Padding(
            padding: const EdgeInsets.only(right: 4.0, top: 8.0, bottom: 8.0),
            child: coinBalanceAsync.when(
              data: (balance) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.15),
                  borderRadius: BorderRadius.zero,
                  border: Border.all(color: Colors.blue.withOpacity(0.5)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.monetization_on, color: Colors.blue, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      '$balance',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ),
              loading: () => const SizedBox(),
              error: (_, __) => const SizedBox(),
            ),
          ),
          // Essence balance
          Padding(
            padding: const EdgeInsets.only(right: 16.0, top: 8.0, bottom: 8.0),
            child: essenceBalanceAsync.when(
              data: (balance) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.15),
                  borderRadius: BorderRadius.zero,
                  border: Border.all(color: Colors.amber.withOpacity(0.5)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.auto_awesome, color: Colors.amber, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      '$balance',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ),
              loading: () => const SizedBox(),
              error: (_, __) => const SizedBox(),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Category filters
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                _buildCategoryChip(context, 'all', 'All Items'),
                const SizedBox(width: 8),
                _buildCategoryChip(context, 'bottle', 'Bottles'),
                const SizedBox(width: 8),
                _buildCategoryChip(context, 'background', 'Themes'),
              ],
            ),
          ),

          // Shop items
          Expanded(
            child: shopItemsAsync.when(
              data: (items) {
                final filteredItems = _selectedCategory == 'all'
                    ? items
                    : items.where((item) => item.category == _selectedCategory).toList();

                if (filteredItems.isEmpty) {
                  return Center(
                    child: Text(
                      'No items in this category',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.62,
                  ),
                  itemCount: filteredItems.length,
                  itemBuilder: (context, index) {
                    final item = filteredItems[index];
                    return ShopItemCard(
                      item: item,
                      onPurchase: () => _handlePurchase(item.itemId),
                    );
                  },
                );
              },
              loading: () => const PixelLoadingIndicator(message: 'Loading shop...'),
              error: (error, stack) => Center(child: Text('Error: $error')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(BuildContext context, String category, String label) {
    final isSelected = _selectedCategory == category;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = category;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryLight.withOpacity(0.3) : Colors.transparent,
          border: Border.all(
            color: isSelected ? AppColors.primaryLight : Colors.black54,
            width: 2,
          ),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? AppColors.primaryLight : null,
              ),
        ),
      ),
    );
  }

  Future<void> _handlePurchase(String itemId) async {
    final repository = ref.read(shopRepositoryProvider);
    final essenceService = ref.read(essenceServiceProvider);
    final coinService = ref.read(coinServiceProvider);
    final feedbackService = ref.read(feedbackServiceProvider);

    // Get item details to determine specific error
    final items = await repository.getAllItems();
    final item = items.where((i) => i.itemId == itemId).firstOrNull;

    if (item == null) {
      feedbackService.feedback(sound: SoundType.error, haptic: HapticType.error);
      if (mounted) showErrorSnackbar(context, AppErrors.itemNotFound);
      return;
    }

    if (item.purchased) {
      feedbackService.feedback(sound: SoundType.error, haptic: HapticType.error);
      if (mounted) showErrorSnackbar(context, AppErrors.itemAlreadyOwned);
      return;
    }

    // Check balance before purchase for specific error message
    if (item.currencyType == 'coins') {
      final balance = await coinService.getCoinBalance();
      if (balance < item.coinCost) {
        feedbackService.feedback(sound: SoundType.error, haptic: HapticType.error);
        if (mounted) {
          showErrorSnackbar(context, AppErrors.insufficientCoins(item.coinCost, balance));
        }
        return;
      }
    } else {
      final balance = await essenceService.getEssenceBalance();
      if (balance < item.essenceCost) {
        feedbackService.feedback(sound: SoundType.error, haptic: HapticType.error);
        if (mounted) {
          showErrorSnackbar(context, AppErrors.insufficientEssence(item.essenceCost, balance));
        }
        return;
      }
    }

    // Attempt purchase
    final success = await repository.purchaseItem(itemId, essenceService, coinService);

    if (success) {
      feedbackService.feedback(
        sound: SoundType.purchase,
        haptic: HapticType.success,
      );

      ref.invalidate(shopItemsProvider);
      ref.invalidate(essenceBalanceProvider);
      ref.invalidate(coinBalanceProvider);
      ref.invalidate(ownedBottlesProvider); // Refresh bottle selector

      if (mounted) {
        showSuccessSnackbar(context, 'Purchase successful!');
      }
    } else {
      // Fallback for unexpected failures
      feedbackService.feedback(sound: SoundType.error, haptic: HapticType.error);
      if (mounted) showErrorSnackbar(context, AppErrors.unknownError);
    }
  }
}
