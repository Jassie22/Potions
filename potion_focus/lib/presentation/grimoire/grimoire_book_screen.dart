import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:potion_focus/core/theme/app_colors.dart';
import 'package:potion_focus/data/models/recipe_model.dart';
import 'package:potion_focus/services/recipe_service.dart';
import 'widgets/recipe_page.dart';
import 'widgets/section_divider_page.dart';
import 'widgets/book_page_background.dart';

/// Book-style grimoire. Each recipe is a page you swipe through.
/// Recipes are grouped by rarity with section divider pages.
class GrimoireBookScreen extends ConsumerStatefulWidget {
  const GrimoireBookScreen({super.key});

  @override
  ConsumerState<GrimoireBookScreen> createState() => _GrimoireBookScreenState();
}

class _GrimoireBookScreenState extends ConsumerState<GrimoireBookScreen> {
  late PageController _pageController;
  double _currentPage = 0;

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
            final pages = _buildPageList(recipes, recipeService);
            final totalPages = pages.length;

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
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.4),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: totalPages,
                      itemBuilder: (context, index) {
                        return _buildPageWithTransform(pages[index], index);
                      },
                    ),
                  ),
                ),

                // Page indicator dots (grouped by rarity)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: _buildPageIndicator(pages, totalPages),
                ),
              ],
            );
          },
          loading: () => const Center(
            child: CircularProgressIndicator(color: Color(0xFFF5E6C8)),
          ),
          error: (error, stack) => Center(
            child: Text('Error: $error', style: const TextStyle(color: Colors.white)),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return BookPageBackground(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.menu_book_outlined, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Your Grimoire Awaits',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: const Color(0xFF3D2B1F),
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Complete focus sessions to discover recipes',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF5D4E37),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build the list of pages: section dividers + recipe pages.
  List<Widget> _buildPageList(List<RecipeModel> recipes, RecipeService service) {
    final pages = <Widget>[];

    // Group recipes by rarity
    final rarityGroups = <String, List<RecipeModel>>{};
    for (final recipe in recipes) {
      rarityGroups.putIfAbsent(recipe.rarity, () => []).add(recipe);
    }

    const rarityOrder = ['common', 'uncommon', 'rare', 'epic', 'legendary'];

    for (final rarity in rarityOrder) {
      final group = rarityGroups[rarity];
      if (group == null || group.isEmpty) continue;

      // Section divider
      pages.add(SectionDividerPage(
        rarity: rarity,
        recipeCount: group.length,
      ));

      // Recipe pages
      for (final recipe in group) {
        pages.add(RecipePage(
          recipe: recipe,
          recipeService: service,
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

  /// Compact dot indicator, colored by the rarity of each page's section.
  Widget _buildPageIndicator(List<Widget> pages, int totalPages) {
    if (totalPages <= 1) return const SizedBox();

    return SizedBox(
      height: 8,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(totalPages, (index) {
          final isActive = index == _currentPage.round();
          // Determine rarity color for this page
          final page = pages[index];
          Color dotColor = Colors.grey;
          if (page is SectionDividerPage) {
            dotColor = AppColors.getRarityColor(page.rarity);
          } else if (page is RecipePage) {
            dotColor = AppColors.getRarityColor(page.recipe.rarity);
          }

          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 2),
            width: isActive ? 16 : 6,
            height: 6,
            decoration: BoxDecoration(
              color: isActive ? dotColor : dotColor.withOpacity(0.3),
              borderRadius: BorderRadius.circular(3),
            ),
          );
        }),
      ),
    );
  }
}
