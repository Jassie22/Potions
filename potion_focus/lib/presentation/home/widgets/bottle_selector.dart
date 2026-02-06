import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:potion_focus/core/theme/app_colors.dart';
import 'package:potion_focus/data/local/database.dart';
import 'package:potion_focus/data/local/isar_helpers.dart';
import 'package:potion_focus/data/models/shop_item_model.dart';
import 'package:potion_focus/presentation/shared/painting/bottle_painter.dart';

/// Provides the list of owned bottle shape IDs (free defaults + purchased).
final ownedBottlesProvider = FutureProvider<List<String>>((ref) async {
  final db = DatabaseHelper.instance;
  final allShopItems = await db.shopItemModels.getAllItems();
  final purchased = allShopItems
      .where((item) => item.category == 'bottle' && item.purchased)
      .map((item) => item.assetKey)
      .toList();

  // Free defaults always available
  return [
    'bottle_round',
    'bottle_tall',
    ...purchased.where((b) => b != 'bottle_round' && b != 'bottle_tall'),
  ];
});

class BottleSelector extends ConsumerWidget {
  final String selectedBottle;
  final ValueChanged<String> onBottleChanged;

  const BottleSelector({
    super.key,
    required this.selectedBottle,
    required this.onBottleChanged,
  });

  static const _bottleNames = {
    'bottle_round': 'Round',
    'bottle_tall': 'Tall',
    'bottle_flask': 'Flask',
    'bottle_potion': 'Potion',
    'bottle_heart': 'Heart',
    'bottle_diamond': 'Diamond',
    'bottle_gourd': 'Gourd',
    'bottle_legendary': 'Ornate',
    'bottle_celestial': 'Celestial',
    'bottle_starforged': 'Starforged',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ownedBottles = ref.watch(ownedBottlesProvider);

    return ownedBottles.when(
      data: (bottles) {
        return SizedBox(
          height: 88,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: bottles.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final bottleId = bottles[index];
              final isSelected = bottleId == selectedBottle;
              return GestureDetector(
                onTap: () => onBottleChanged(bottleId),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 68,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
                        : Theme.of(context).colorScheme.surface.withOpacity(0.6),
                    borderRadius: BorderRadius.zero,
                    border: isSelected
                        ? Border.all(
                            color: Theme.of(context).colorScheme.primary,
                            width: 2,
                          )
                        : Border.all(
                            color: AppColors.mysticalGold.withOpacity(0.2),
                            width: 1,
                          ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 36,
                        height: 44,
                        child: CustomPaint(
                          painter: BottlePainter(
                            shapeId: bottleId,
                            fillPercent: 0.0,
                            liquidColor: Colors.transparent,
                            glassColor: isSelected
                                ? Colors.white
                                : Colors.white.withOpacity(0.6),
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _bottleNames[bottleId] ?? bottleId,
                        style: TextStyle(
                          fontSize: 9,
                          color: isSelected
                              ? Colors.white
                              : Colors.white.withOpacity(0.5),
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
      loading: () => const SizedBox(height: 88),
      error: (_, __) => const SizedBox(height: 88),
    );
  }
}
