import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:potion_focus/services/recipe_service.dart';
import 'package:potion_focus/presentation/grimoire/widgets/recipe_card.dart';

class GrimoireScreen extends ConsumerWidget {
  const GrimoireScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unlockedRecipesAsync = ref.watch(unlockedRecipesProvider);
    final lockedRecipesAsync = ref.watch(lockedRecipesProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Grimoire',
            style: Theme.of(context).textTheme.displaySmall,
          ),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Discovered', icon: Icon(Icons.auto_stories)),
              Tab(text: 'Hidden', icon: Icon(Icons.help_outline)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Discovered Recipes
            unlockedRecipesAsync.when(
              data: (recipes) {
                if (recipes.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.menu_book_outlined,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No Recipes Discovered Yet',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Complete focus sessions to unlock recipes',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[600],
                              ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: recipes.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: RecipeCard(
                        recipe: recipes[index],
                        isUnlocked: true,
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('Error: $error')),
            ),

            // Locked Recipes
            lockedRecipesAsync.when(
              data: (recipes) {
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: recipes.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: RecipeCard(
                        recipe: recipes[index],
                        isUnlocked: false,
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('Error: $error')),
            ),
          ],
        ),
      ),
    );
  }
}

