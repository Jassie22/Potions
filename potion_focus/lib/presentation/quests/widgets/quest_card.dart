import 'package:flutter/material.dart';
import 'package:potion_focus/core/theme/app_colors.dart';
import 'package:potion_focus/core/utils/extensions.dart';
import 'package:potion_focus/data/models/quest_model.dart';
import 'package:potion_focus/presentation/shared/painting/pixel_gradients.dart';

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
    final questColor = _getQuestColor();

    return Card(
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
        side: BorderSide(
          color: Colors.black87,
          width: 2,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.zero,
          gradient: PixelGradients.twoBand(
            baseColor: isCompleted ? Colors.green : questColor,
            topOpacity: isCompleted ? 0.12 : 0.08,
            bottomOpacity: isCompleted ? 0.04 : 0.02,
          ),
        ),
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
                    color: _getQuestColor().withValues(alpha: 0.2),
                    borderRadius: BorderRadius.zero,
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
                // Custom pixel-style animated progress bar
                LayoutBuilder(
                  builder: (context, constraints) {
                    final barColor = isCompleted ? Colors.green : _getQuestColor();
                    return Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        border: Border.all(color: Colors.black38, width: 1),
                      ),
                      child: Stack(
                        children: [
                          // Animated fill
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeOutCubic,
                            width: constraints.maxWidth * progressPercentage,
                            height: 8,
                            color: barColor,
                          ),
                          // Pixel highlight at top (adds depth)
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeOutCubic,
                            width: constraints.maxWidth * progressPercentage,
                            height: 2,
                            color: barColor.withValues(alpha: 0.3),
                          ),
                        ],
                      ),
                    );
                  },
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



