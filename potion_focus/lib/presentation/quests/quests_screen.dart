import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:potion_focus/services/quest_generation_service.dart';
import 'package:potion_focus/presentation/quests/widgets/quest_card.dart';
import 'package:potion_focus/presentation/quests/widgets/create_quest_dialog.dart';
import 'package:potion_focus/presentation/cabinet/widgets/statistics_screen.dart';
import 'package:potion_focus/presentation/shared/widgets/empty_state_art.dart';
import 'package:potion_focus/presentation/shared/widgets/pixel_button.dart';
import 'package:potion_focus/presentation/shared/widgets/pixel_loading.dart';

class QuestsScreen extends ConsumerStatefulWidget {
  const QuestsScreen({super.key});

  @override
  ConsumerState<QuestsScreen> createState() => _QuestsScreenState();
}

class _QuestsScreenState extends ConsumerState<QuestsScreen> {
  @override
  void initState() {
    super.initState();
    // Generate quests on first load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _generateQuests();
    });
  }

  Future<void> _generateQuests() async {
    final service = ref.read(questGenerationServiceProvider);
    await service.expireOldQuests();
    await service.generateDailyQuest();
    await service.generateWeeklyQuests();
    ref.invalidate(activeQuestsProvider);
  }

  @override
  Widget build(BuildContext context) {
    final questsAsync = ref.watch(activeQuestsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Focus Threads',
          style: Theme.of(context).textTheme.displaySmall,
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _generateQuests,
            tooltip: 'Refresh quests',
          ),
        ],
      ),
      floatingActionButton: PixelIconButton(
        icon: Icons.add,
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => const CreateQuestDialog(),
          );
        },
        color: Theme.of(context).colorScheme.primary,
        size: 56,
      ),
      body: questsAsync.when(
        data: (quests) {
          if (quests.isEmpty) {
            return Center(
              child: PixelEmptyState(
                type: EmptyStateType.quests,
                message: 'Your quests are resting...\nComplete focus sessions to awaken them!',
                actionLabel: 'Generate Quests',
                onAction: _generateQuests,
              ),
            );
          }

          // Separate daily, weekly, and custom quests
          final dailyQuests = quests.where((q) => q.timeframe == 'daily' && !q.isCustom).toList();
          final weeklyQuests = quests.where((q) => q.timeframe == 'weekly' && !q.isCustom).toList();
          final customQuests = quests.where((q) => q.isCustom).toList();

          return RefreshIndicator(
            onRefresh: _generateQuests,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Header
                Text(
                  'Your Focus Threads',
                  style: Theme.of(context).textTheme.displaySmall,
                ),
                const SizedBox(height: 8),
                Text(
                  'Personalized goals based on your focus patterns',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                const SizedBox(height: 16),

                // Focus Journey card - pixel style
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const StatisticsScreen()),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      border: Border.all(
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.6),
                        width: 3,
                      ),
                    ),
                    child: Row(
                      children: [
                        // Pixel icon container
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                            border: Border.all(
                              color: Theme.of(context).colorScheme.primary,
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            Icons.bar_chart,
                            color: Theme.of(context).colorScheme.primary,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Focus Journey',
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'View your stats and progress',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                                    ),
                              ),
                            ],
                          ),
                        ),
                        // Pixel arrow
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.4),
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            Icons.chevron_right,
                            color: Theme.of(context).colorScheme.primary,
                            size: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Daily Quest Section
                if (dailyQuests.isNotEmpty) ...[
                  Row(
                    children: [
                      Icon(Icons.today, color: Theme.of(context).primaryColor),
                      const SizedBox(width: 8),
                      Text(
                        "Today's Quest",
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...dailyQuests.map((quest) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: QuestCard(quest: quest),
                      )),
                  const SizedBox(height: 24),
                ],

                // Weekly Quests Section
                if (weeklyQuests.isNotEmpty) ...[
                  Row(
                    children: [
                      Icon(Icons.event, color: Theme.of(context).primaryColor),
                      const SizedBox(width: 8),
                      Text(
                        'Weekly Quests',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...weeklyQuests.map((quest) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: QuestCard(quest: quest),
                      )),
                ],

                // Custom Quests Section
                if (customQuests.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Icon(Icons.auto_fix_high, color: Theme.of(context).primaryColor),
                      const SizedBox(width: 8),
                      Text(
                        'Custom Quests',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...customQuests.map((quest) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: QuestCard(quest: quest),
                      )),
                ],
              ],
            ),
          );
        },
        loading: () => const PixelLoadingIndicator(message: 'Loading quests...'),
        error: (error, stack) => Center(
          child: Text('Error loading quests: $error'),
        ),
      ),
    );
  }
}

