import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:potion_focus/core/theme/app_colors.dart';
import 'package:potion_focus/data/models/potion_model.dart';
import 'package:potion_focus/data/repositories/potion_repository.dart';
import 'package:potion_focus/presentation/cabinet/widgets/potion_detail_modal.dart';
import 'package:potion_focus/presentation/cabinet/widgets/shelf_row.dart';
import 'package:potion_focus/presentation/cabinet/widgets/statistics_screen.dart';
import 'package:potion_focus/presentation/shared/widgets/empty_state_art.dart';
import 'package:potion_focus/presentation/shared/widgets/pixel_loading.dart';

class CabinetScreen extends ConsumerStatefulWidget {
  const CabinetScreen({super.key});

  @override
  ConsumerState<CabinetScreen> createState() => _CabinetScreenState();
}

class _CabinetScreenState extends ConsumerState<CabinetScreen> {
  @override
  Widget build(BuildContext context) {
    final potionsAsync = ref.watch(allPotionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Your Cabinet',
          style: Theme.of(context).textTheme.displaySmall,
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart_rounded),
            tooltip: 'Focus Journey',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const StatisticsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: potionsAsync.when(
        data: (potions) {
          if (potions.isEmpty) {
            return _buildEmptyState(context);
          }

          // Group potions by rarity
          final groupedPotions = _groupByRarity(potions);

          return Column(
            children: [
              // Stats bar
              _buildStatsBar(context, potions),

              // Shelves by rarity
              Expanded(
                child: ListView(
                  children: [
                    // Display shelves in order: legendary -> epic -> rare -> uncommon -> common -> muddy
                    if (groupedPotions['legendary']?.isNotEmpty ?? false)
                      ShelfRow(
                        rarity: 'legendary',
                        potions: groupedPotions['legendary']!,
                        onPotionTap: (potion) => _showPotionDetail(context, potion),
                      ),
                    if (groupedPotions['epic']?.isNotEmpty ?? false)
                      ShelfRow(
                        rarity: 'epic',
                        potions: groupedPotions['epic']!,
                        onPotionTap: (potion) => _showPotionDetail(context, potion),
                      ),
                    if (groupedPotions['rare']?.isNotEmpty ?? false)
                      ShelfRow(
                        rarity: 'rare',
                        potions: groupedPotions['rare']!,
                        onPotionTap: (potion) => _showPotionDetail(context, potion),
                      ),
                    if (groupedPotions['uncommon']?.isNotEmpty ?? false)
                      ShelfRow(
                        rarity: 'uncommon',
                        potions: groupedPotions['uncommon']!,
                        onPotionTap: (potion) => _showPotionDetail(context, potion),
                      ),
                    if (groupedPotions['common']?.isNotEmpty ?? false)
                      ShelfRow(
                        rarity: 'common',
                        potions: groupedPotions['common']!,
                        onPotionTap: (potion) => _showPotionDetail(context, potion),
                      ),
                    if (groupedPotions['muddy']?.isNotEmpty ?? false)
                      ShelfRow(
                        rarity: 'muddy',
                        potions: groupedPotions['muddy']!,
                        onPotionTap: (potion) => _showPotionDetail(context, potion),
                      ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          );
        },
        loading: () => const PixelLoadingIndicator(message: 'Loading collection...'),
        error: (error, stack) => Center(
          child: Text('Error loading potions: $error'),
        ),
      ),
    );
  }

  Map<String, List<PotionModel>> _groupByRarity(List<PotionModel> potions) {
    final grouped = <String, List<PotionModel>>{};
    for (final potion in potions) {
      final rarity = potion.rarity.toLowerCase();
      grouped.putIfAbsent(rarity, () => []);
      grouped[rarity]!.add(potion);
    }

    // Sort each group by creation date (newest first)
    for (final list in grouped.values) {
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }

    return grouped;
  }

  void _showPotionDetail(BuildContext context, PotionModel potion) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PotionDetailModal(potion: potion),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return const Center(
      child: PixelEmptyState(
        type: EmptyStateType.cabinet,
        message: 'Your cabinet awaits its first potion.\nComplete a focus session to start brewing!',
      ),
    );
  }

  Widget _buildStatsBar(BuildContext context, List<PotionModel> potions) {
    final totalEssence = potions.fold<int>(0, (sum, p) => sum + p.essenceEarned);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border.all(color: Colors.black54, width: 2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem(
            context,
            Icons.science,
            potions.length.toString(),
            'Potions',
            AppColors.primaryLight,
          ),
          Container(
            width: 2,
            height: 40,
            color: Colors.black26,
          ),
          _buildStatItem(
            context,
            Icons.auto_awesome,
            totalEssence.toString(),
            'Essence',
            AppColors.mysticalGold,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    IconData icon,
    String value,
    String label,
    Color color,
  ) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
      ],
    );
  }
}
