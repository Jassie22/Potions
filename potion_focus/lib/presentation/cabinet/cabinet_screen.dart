import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:potion_focus/core/theme/app_colors.dart';
import 'package:potion_focus/data/repositories/potion_repository.dart';
import 'package:potion_focus/presentation/cabinet/widgets/potion_grid_item.dart';
import 'package:potion_focus/presentation/cabinet/widgets/potion_detail_modal.dart';

class CabinetScreen extends ConsumerStatefulWidget {
  const CabinetScreen({super.key});

  @override
  ConsumerState<CabinetScreen> createState() => _CabinetScreenState();
}

class _CabinetScreenState extends ConsumerState<CabinetScreen> {
  String? _selectedRarityFilter;

  @override
  Widget build(BuildContext context) {
    final potionsAsync = ref.watch(allPotionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Cabinet',
          style: Theme.of(context).textTheme.displaySmall,
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: potionsAsync.when(
        data: (potions) {
          // Apply filters
          final filteredPotions = _selectedRarityFilter != null
              ? potions.where((p) => p.rarity == _selectedRarityFilter).toList()
              : potions;

          if (potions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Your Collection is Empty',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Complete focus sessions to brew potions',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Stats bar
              Container(
                padding: const EdgeInsets.all(16),
                color: Theme.of(context).cardColor,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStat(
                      context,
                      'Total Potions',
                      potions.length.toString(),
                      Icons.science,
                    ),
                    _buildStat(
                      context,
                      'Total Essence',
                      potions.fold<int>(0, (sum, p) => sum + p.essenceEarned).toString(),
                      Icons.auto_awesome,
                    ),
                  ],
                ),
              ),

              // Filter chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    FilterChip(
                      label: const Text('All'),
                      selected: _selectedRarityFilter == null,
                      onSelected: (selected) {
                        setState(() {
                          _selectedRarityFilter = null;
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                    ..._buildRarityFilters(),
                  ],
                ),
              ),

              // Potion grid
              Expanded(
                child: filteredPotions.isEmpty
                    ? Center(
                        child: Text(
                          'No potions match this filter',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[600],
                              ),
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.8,
                        ),
                        itemCount: filteredPotions.length,
                        itemBuilder: (context, index) {
                          final potion = filteredPotions[index];
                          return PotionGridItem(
                            potion: potion,
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (context) => PotionDetailModal(potion: potion),
                              );
                            },
                          );
                        },
                      ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error loading potions: $error'),
        ),
      ),
    );
  }

  Widget _buildStat(BuildContext context, String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primaryLight),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
        ),
      ],
    );
  }

  List<Widget> _buildRarityFilters() {
    final rarities = ['common', 'uncommon', 'rare', 'epic', 'legendary', 'muddy'];

    return rarities.map((rarity) {
      return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: FilterChip(
          label: Text(rarity[0].toUpperCase() + rarity.substring(1)),
          selected: _selectedRarityFilter == rarity,
          onSelected: (selected) {
            setState(() {
              _selectedRarityFilter = selected ? rarity : null;
            });
          },
          backgroundColor: AppColors.getRarityColor(rarity).withOpacity(0.1),
          selectedColor: AppColors.getRarityColor(rarity).withOpacity(0.3),
        ),
      );
    }).toList();
  }
}

