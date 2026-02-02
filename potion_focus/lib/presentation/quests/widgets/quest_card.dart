import 'package:flutter/material.dart';
import 'package:potion_focus/core/theme/app_colors.dart';
import 'package:potion_focus/core/utils/extensions.dart';
import 'package:potion_focus/data/models/quest_model.dart';

class QuestCard extends StatelessWidget {
  final QuestModel quest;

  const QuestCard({
    super.key,
    required this.quest,
  });

  @override
  Widget build(BuildContext context) {
    final isCompleted = quest.status == 'completed';
    final progressPercentage = quest.progressPercentage;

    return Card(
      elevation: isCompleted ? 1 : 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isCompleted
            ? BorderSide(color: Colors.green.withOpacity(0.5), width: 2)
            : BorderSide.none,
      ),
      child: Container(
        decoration: isCompleted
            ? BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [
                    Colors.green.withOpacity(0.1),
                    Colors.green.withOpacity(0.05),
                  ],
                ),
              )
            : null,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                // Quest type icon
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getQuestColor().withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getQuestIcon(),
                    color: _getQuestColor(),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),

                // Quest title
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getQuestTitle(),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '#${quest.tag}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: _getQuestColor(),
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                ),

                // Completion checkmark or reward
                if (isCompleted)
                  const Icon(Icons.check_circle, color: Colors.green, size: 32)
                else
                  Column(
                    children: [
                      const Icon(Icons.auto_awesome, color: Colors.amber, size: 20),
                      Text(
                        '+${quest.essenceReward}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Progress bar
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _getProgressText(),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Text(
                      '${(progressPercentage * 100).toInt()}%',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progressPercentage,
                    minHeight: 8,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isCompleted ? Colors.green : _getQuestColor(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Expiration info
            if (!isCompleted)
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 14,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Expires: ${quest.expiresAt.toFormattedDate()}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
              )
            else
              Row(
                children: [
                  Icon(
                    Icons.celebration,
                    size: 14,
                    color: Colors.green[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Completed! +${quest.essenceReward} essence earned',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.green[600],
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  String _getQuestTitle() {
    switch (quest.questType) {
      case 'time_based':
        return 'Focus with ${quest.tag}';
      case 'session_based':
        return 'Complete sessions with ${quest.tag}';
      case 'streak_based':
        return 'Continue your ${quest.tag} streak';
      default:
        return 'Quest';
    }
  }

  String _getProgressText() {
    switch (quest.questType) {
      case 'time_based':
        return '${quest.currentProgress} / ${quest.targetValue} minutes';
      case 'session_based':
        return '${quest.currentProgress} / ${quest.targetValue} sessions';
      case 'streak_based':
        return quest.currentProgress >= 1 ? 'Completed today!' : 'Not completed yet';
      default:
        return '${quest.currentProgress} / ${quest.targetValue}';
    }
  }

  IconData _getQuestIcon() {
    switch (quest.questType) {
      case 'time_based':
        return Icons.timer;
      case 'session_based':
        return Icons.repeat;
      case 'streak_based':
        return Icons.local_fire_department;
      default:
        return Icons.flag;
    }
  }

  Color _getQuestColor() {
    switch (quest.questType) {
      case 'time_based':
        return AppColors.primaryLight;
      case 'session_based':
        return AppColors.secondaryLight;
      case 'streak_based':
        return Colors.orange;
      default:
        return AppColors.primaryLight;
    }
  }
}



