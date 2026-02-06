import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:potion_focus/core/theme/app_colors.dart';
import 'package:potion_focus/data/local/database.dart';
import 'package:potion_focus/data/local/isar_helpers.dart';
import 'package:potion_focus/data/models/tag_stats_model.dart';
import 'package:potion_focus/services/quest_generation_service.dart';

/// Simplified quest creation dialog - only allows tag selection.
/// Quest type (always time_based) and target are auto-calculated from user's stats.
class CreateQuestDialog extends ConsumerStatefulWidget {
  const CreateQuestDialog({super.key});

  @override
  ConsumerState<CreateQuestDialog> createState() => _CreateQuestDialogState();
}

class _CreateQuestDialogState extends ConsumerState<CreateQuestDialog> {
  String? _selectedTag;
  List<TagStatsModel> _tagStats = [];
  bool _isCreating = false;

  @override
  void initState() {
    super.initState();
    _loadTags();
  }

  Future<void> _loadTags() async {
    final db = DatabaseHelper.instance;
    final allTags = await db.tagStatsModels.getAllItems();
    // Sort by most used
    allTags.sort((a, b) => b.last7DaysMinutes.compareTo(a.last7DaysMinutes));
    setState(() {
      _tagStats = allTags;
      if (_tagStats.isNotEmpty) {
        _selectedTag = _tagStats.first.tag;
      }
    });
  }

  /// Calculate suggested target based on user's stats for the tag
  int _calculateTargetMinutes(TagStatsModel stats) {
    // 80% of their daily average, clamped to reasonable range
    final avgDailyMinutes = stats.last7DaysMinutes / 7;
    final target = (avgDailyMinutes * 0.8).round();
    return target.clamp(15, 60); // Between 15 and 60 minutes
  }

  /// Get the stats for the selected tag
  TagStatsModel? get _selectedTagStats {
    if (_selectedTag == null) return null;
    return _tagStats.where((t) => t.tag == _selectedTag).firstOrNull;
  }

  @override
  Widget build(BuildContext context) {
    final selectedStats = _selectedTagStats;
    final targetMinutes = selectedStats != null
        ? _calculateTargetMinutes(selectedStats)
        : 25;

    return Dialog(
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.add_task,
                  color: Theme.of(context).primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Personal Quest',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Create a focused challenge for a specific area',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                  ),
            ),
            const SizedBox(height: 24),

            // Tag selection
            Text(
              'What do you want to focus on?',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            if (_tagStats.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  border: Border.all(color: Colors.grey.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    Icon(Icons.info_outline, color: Colors.grey[600], size: 32),
                    const SizedBox(height: 8),
                    Text(
                      'Complete a focus session first to unlock custom quests',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _tagStats.map((stats) {
                  final isSelected = stats.tag == _selectedTag;
                  return GestureDetector(
                    onTap: () {
                      setState(() => _selectedTag = stats.tag);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Theme.of(context).primaryColor
                            : Theme.of(context).colorScheme.surface,
                        border: Border.all(
                          color: isSelected
                              ? Theme.of(context).primaryColor
                              : Colors.grey.withOpacity(0.3),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '#${stats.tag}',
                            style: TextStyle(
                              color: isSelected ? Colors.white : null,
                              fontWeight: isSelected ? FontWeight.bold : null,
                            ),
                          ),
                          if (stats.last7DaysMinutes > 0) ...[
                            const SizedBox(width: 6),
                            Text(
                              '${stats.last7DaysMinutes}m',
                              style: TextStyle(
                                fontSize: 10,
                                color: isSelected
                                    ? Colors.white.withOpacity(0.8)
                                    : Colors.grey,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            const SizedBox(height: 24),

            // Quest preview (auto-calculated)
            if (_selectedTag != null && selectedStats != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  border: Border.all(
                    color: Theme.of(context).primaryColor.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.timer,
                          size: 18,
                          color: Theme.of(context).primaryColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Quest Preview',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Focus $targetMinutes minutes on #$_selectedTag today',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Based on your recent focus patterns',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6),
                            fontStyle: FontStyle.italic,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _selectedTag == null || _isCreating
                        ? null
                        : () async {
                            setState(() => _isCreating = true);
                            try {
                              final service = ref.read(questGenerationServiceProvider);
                              await service.createCustomQuest(
                                tag: _selectedTag!,
                                questType: 'time_based', // Always time-based for simplicity
                                targetValue: targetMinutes,
                                timeframe: 'daily', // Always daily for custom quests
                              );
                              ref.invalidate(activeQuestsProvider);
                              if (context.mounted) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Quest created: Focus $targetMinutes min on #$_selectedTag'),
                                  ),
                                );
                              }
                            } finally {
                              if (mounted) {
                                setState(() => _isCreating = false);
                              }
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                    ),
                    child: _isCreating
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Create Quest'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
