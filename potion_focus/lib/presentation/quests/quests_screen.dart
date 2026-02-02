import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:potion_focus/services/quest_generation_service.dart';
import 'package:potion_focus/presentation/quests/widgets/quest_card.dart';

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
      body: questsAsync.when(
        data: (quests) {
          if (quests.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.flag_outlined,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Active Quests',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Complete focus sessions to generate personalized quests',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _generateQuests,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Generate Quests'),
                  ),
                ],
              ),
            );
          }

          // Separate daily and weekly quests
          final dailyQuests = quests.where((q) => q.timeframe == 'daily').toList();
          final weeklyQuests = quests.where((q) => q.timeframe == 'weekly').toList();

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
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error loading quests: $error'),
        ),
      ),
    );
  }
}

