import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:potion_focus/core/models/liquid_presets.dart';
import 'package:potion_focus/data/local/database.dart';
import 'package:potion_focus/data/local/isar_helpers.dart';
import 'package:potion_focus/data/models/recipe_model.dart';

/// Provides the list of unlocked liquid IDs from grimoire recipes.
final unlockedLiquidsProvider = FutureProvider<List<String>>((ref) async {
  final db = DatabaseHelper.instance;
  final allRecipes = await db.recipeModels.getAllItems();
  final unlocked = allRecipes
      .where((r) => r.rewardType == 'liquid' && r.unlocked)
      .map((r) => r.rewardAssetKey)
      .toList();

  // Always include liquid_0 as the starter liquid
  if (!unlocked.contains('liquid_0')) {
    unlocked.insert(0, 'liquid_0');
  }

  // Sort by liquid index for consistent ordering
  unlocked.sort((a, b) {
    final aIndex = int.tryParse(a.replaceFirst('liquid_', '')) ?? 0;
    final bIndex = int.tryParse(b.replaceFirst('liquid_', '')) ?? 0;
    return aIndex.compareTo(bIndex);
  });

  return unlocked;
});

class LiquidSelector extends ConsumerWidget {
  final String selectedLiquid;
  final ValueChanged<String> onLiquidChanged;

  const LiquidSelector({
    super.key,
    required this.selectedLiquid,
    required this.onLiquidChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unlockedLiquids = ref.watch(unlockedLiquidsProvider);

    return unlockedLiquids.when(
      data: (liquids) {
        return SizedBox(
          height: 80,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: liquids.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final liquidId = liquids[index];
              final preset = LiquidPreset.getPreset(liquidId);
              final isSelected = liquidId == selectedLiquid;
              return GestureDetector(
                onTap: () => onLiquidChanged(liquidId),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 60,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? preset.primaryColor.withOpacity(0.3)
                        : Theme.of(context).colorScheme.surface.withOpacity(0.6),
                    borderRadius: BorderRadius.zero,
                    border: isSelected
                        ? Border.all(
                            color: preset.primaryColor,
                            width: 2,
                          )
                        : Border.all(
                            color: Colors.white.withOpacity(0.15),
                            width: 1,
                          ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Color swatch
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: preset.primaryColor,
                          borderRadius: BorderRadius.zero,
                          border: Border.all(
                            color: Colors.black.withOpacity(0.6),
                            width: 2,
                          ),
                        ),
                        child: preset.secondaryColor != null
                            ? CustomPaint(
                                painter: _LiquidSwatchPainter(
                                  primary: preset.primaryColor,
                                  secondary: preset.secondaryColor!,
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        preset.name.length > 8
                            ? '${preset.name.substring(0, 7)}.'
                            : preset.name,
                        style: TextStyle(
                          fontSize: 8,
                          color: isSelected
                              ? Colors.white
                              : Colors.white.withOpacity(0.5),
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
      loading: () => const SizedBox(height: 80),
      error: (_, __) => const SizedBox(height: 80),
    );
  }
}

/// Paints a diagonal split swatch showing primary and secondary colors.
class _LiquidSwatchPainter extends CustomPainter {
  final Color primary;
  final Color secondary;

  _LiquidSwatchPainter({required this.primary, required this.secondary});

  @override
  void paint(Canvas canvas, Size size) {
    final primaryPaint = Paint()
      ..color = primary
      ..style = PaintingStyle.fill
      ..isAntiAlias = false;
    final secondaryPaint = Paint()
      ..color = secondary
      ..style = PaintingStyle.fill
      ..isAntiAlias = false;

    // Top-left triangle: primary
    final topLeft = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(topLeft, primaryPaint);

    // Bottom-right triangle: secondary
    final bottomRight = Path()
      ..moveTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(bottomRight, secondaryPaint);
  }

  @override
  bool shouldRepaint(_LiquidSwatchPainter oldDelegate) {
    return oldDelegate.primary != primary || oldDelegate.secondary != secondary;
  }
}
