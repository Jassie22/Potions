import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:potion_focus/core/theme/app_colors.dart';
import 'package:potion_focus/data/models/recipe_model.dart';
import 'package:potion_focus/services/recipe_service.dart';
import 'package:potion_focus/presentation/shared/widgets/empty_state_art.dart';
import 'package:potion_focus/presentation/shared/widgets/pixel_loading.dart';
import 'widgets/recipe_grid_page.dart';
import 'widgets/book_page_background.dart';

/// Book-style grimoire with grid pages.
/// Each page displays 9-12 recipes in a 3-column grid, grouped by rarity.
class GrimoireBookScreen extends ConsumerStatefulWidget {
  const GrimoireBookScreen({super.key});

  @override
  ConsumerState<GrimoireBookScreen> createState() => _GrimoireBookScreenState();
}

class _GrimoireBookScreenState extends ConsumerState<GrimoireBookScreen> {
  late PageController _pageController;
  double _currentPage = 0;

  /// Get recipes per page based on rarity - more for common, fewer for rare
  int _getRecipesPerPage(String rarity) => switch (rarity) {
        'common' || 'uncommon' => 12, // 4x3 grid
        'rare' => 9, // 3x3 grid
        'epic' || 'legendary' => 6, // 3x2 or 2x3 grid
        _ => 9,
      };

  /// Get column count based on rarity
  int _getColumnCount(String rarity) => switch (rarity) {
        'common' || 'uncommon' => 4,
        'rare' => 3,
        'epic' || 'legendary' => 2,
        _ => 3,
      };

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page ?? 0;
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final recipesAsync = ref.watch(recipesByRarityProvider);
    final recipeService = ref.read(recipeServiceProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF3D2B1F),
      body: SafeArea(
        child: recipesAsync.when(
          data: (recipes) {
            final pageData = _buildGridPages(recipes, recipeService);
            final totalPages = pageData.length;

            if (totalPages == 0) {
              return _buildEmptyState(context);
            }

            return Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Grimoire',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: const Color(0xFFF5E6C8),
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        '${_currentPage.round() + 1} / $totalPages',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: const Color(0xFFF5E6C8).withOpacity(0.6),
                            ),
                      ),
                    ],
                  ),
                ),

                // Book pages
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.zero,
                      border: Border.all(color: Colors.black, width: 2),
                    ),
                    clipBehavior: Clip.hardEdge,
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: totalPages,
                      itemBuilder: (context, index) {
                        return _buildPageWithTransform(pageData[index], index);
                      },
                    ),
                  ),
                ),

                // Page indicator dots (colored by rarity)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: _buildPageIndicator(pageData, totalPages),
                ),
              ],
            );
          },
          loading: () => const PixelLoadingIndicator(
            message: 'Opening grimoire...',
            color: Color(0xFFF5E6C8),
          ),
          error: (error, stack) => Center(
            child: Text('Error: $error', style: const TextStyle(color: Colors.white)),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return const BookPageBackground(
      child: Center(
        child: PixelEmptyState(
          type: EmptyStateType.grimoire,
          message: 'The pages are blank...\nDiscover recipes by completing focus sessions!',
        ),
      ),
    );
  }

  /// Build grid pages with recipes grouped by rarity.
  /// Each page holds a variable number of recipes based on rarity.
  /// Filters out bottle-reward recipes (bottles belong in the shop).
  List<RecipeGridPage> _buildGridPages(List<RecipeModel> recipes, RecipeService service) {
    final pages = <RecipeGridPage>[];
    final potionRecipes = recipes.where((r) => r.rewardType != 'bottle').toList();

    // Group recipes by rarity
    final rarityGroups = <String, List<RecipeModel>>{};
    for (final recipe in potionRecipes) {
      rarityGroups.putIfAbsent(recipe.rarity, () => []).add(recipe);
    }

    const rarityOrder = ['common', 'uncommon', 'rare', 'epic', 'legendary'];

    for (final rarity in rarityOrder) {
      final group = rarityGroups[rarity];
      if (group == null || group.isEmpty) continue;

      // Get adaptive page size for this rarity
      final recipesPerPage = _getRecipesPerPage(rarity);
      final columnCount = _getColumnCount(rarity);

      // Calculate number of pages needed for this rarity
      final totalPagesForRarity = (group.length / recipesPerPage).ceil();

      // Create pages for this rarity
      for (int pageIndex = 0; pageIndex < totalPagesForRarity; pageIndex++) {
        final startIndex = pageIndex * recipesPerPage;
        final endIndex = math.min(startIndex + recipesPerPage, group.length);
        final pageRecipes = group.sublist(startIndex, endIndex);

        pages.add(RecipeGridPage(
          rarity: rarity,
          recipes: pageRecipes,
          pageIndex: pageIndex,
          totalPagesForRarity: totalPagesForRarity,
          recipeService: service,
          columnCount: columnCount,
        ));
      }
    }

    return pages;
  }

  /// Apply a subtle 3D page-turn effect.
  Widget _buildPageWithTransform(Widget page, int index) {
    final delta = _currentPage - index;
    // Slight perspective rotation
    final angle = delta.clamp(-1.0, 1.0) * 0.05 * math.pi;

    return Transform(
      alignment: delta > 0 ? Alignment.centerRight : Alignment.centerLeft,
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.001) // perspective
        ..rotateY(angle),
      child: page,
    );
  }

  /// Compact dot indicator, colored by the rarity of each grid page.
  Widget _buildPageIndicator(List<RecipeGridPage> pages, int totalPages) {
    if (totalPages <= 1) return const SizedBox();

    // Limit displayed dots if too many pages
    final maxDots = 12;
    final showDots = totalPages <= maxDots;

    if (!showDots) {
      // Show compact rarity indicators instead
      return _buildCompactIndicator(pages);
    }

    return SizedBox(
      height: 8,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(totalPages, (index) {
          final isActive = index == _currentPage.round();
          final dotColor = AppColors.getRarityColor(pages[index].rarity);

          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 2),
            width: isActive ? 16 : 6,
            height: 6,
            decoration: BoxDecoration(
              color: isActive ? dotColor : dotColor.withOpacity(0.3),
              borderRadius: BorderRadius.zero,
            ),
          );
        }),
      ),
    );
  }

  /// Compact indicator for when there are many pages.
  /// Shows rarity sections with their page counts.
  Widget _buildCompactIndicator(List<RecipeGridPage> pages) {
    // Group pages by rarity and count
    final rarityCounts = <String, int>{};
    for (final page in pages) {
      rarityCounts[page.rarity] = (rarityCounts[page.rarity] ?? 0) + 1;
    }

    // Find current rarity
    final currentIndex = _currentPage.round().clamp(0, pages.length - 1);
    final currentRarity = pages[currentIndex].rarity;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: rarityCounts.entries.map((entry) {
        final rarity = entry.key;
        final count = entry.value;
        final color = AppColors.getRarityColor(rarity);
        final isActive = rarity == currentRarity;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isActive ? color.withOpacity(0.3) : Colors.transparent,
            border: Border.all(
              color: isActive ? color : color.withOpacity(0.3),
              width: isActive ? 2 : 1,
            ),
          ),
          child: Text(
            '$count',
            style: TextStyle(
              color: isActive ? color : color.withOpacity(0.5),
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      }).toList(),
    );
  }
}
