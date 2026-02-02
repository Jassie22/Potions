import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:potion_focus/core/models/visual_config.dart';
import 'package:potion_focus/core/theme/app_colors.dart';
import 'package:potion_focus/core/utils/extensions.dart';
import 'package:potion_focus/services/timer_service.dart';
import 'package:potion_focus/presentation/shared/painting/potion_renderer.dart';

class TimerWidget extends ConsumerWidget {
  final Duration duration;
  final List<String> selectedTags;

  const TimerWidget({
    super.key,
    required this.duration,
    required this.selectedTags,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerState = ref.watch(timerServiceProvider);

    // Derive fill percent from timer progress
    final fillPercent = timerState.isRunning && timerState.totalDuration.inSeconds > 0
        ? 1.0 - (timerState.remainingDuration.inSeconds / timerState.totalDuration.inSeconds)
        : 0.0;

    return Column(
      children: [
        // Timer display with brewing potion animation
        Stack(
          alignment: Alignment.center,
          children: [
            // Potion bottle -- always visible
            PotionRenderer(
              config: timerState.isRunning
                  ? VisualConfig.defaultForRarity('common')
                  : VisualConfig.defaultForRarity('common'),
              size: 220,
              fillPercent: fillPercent,
              isBrewing: timerState.isRunning && !timerState.isPaused,
              showGlow: timerState.isRunning,
            ),
            // Timer text overlay
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  timerState.isRunning
                      ? timerState.remainingDuration.toTimerString()
                      : duration.toTimerString(),
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 48,
                        color: timerState.isRunning
                            ? Colors.white.withOpacity(0.9)
                            : null,
                        shadows: timerState.isRunning
                            ? [
                                Shadow(
                                  color: Colors.black.withOpacity(0.5),
                                  blurRadius: 4,
                                ),
                              ]
                            : null,
                      ),
                ),
                if (timerState.isRunning) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Brewing...',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withOpacity(0.7),
                          fontStyle: FontStyle.italic,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.5),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                  ),
                ],
              ],
            ),
          ],
        ),
        const SizedBox(height: 32),

        // Control buttons
        if (!timerState.isRunning)
          ElevatedButton.icon(
            onPressed: selectedTags.isEmpty
                ? null
                : () {
                    ref.read(timerServiceProvider.notifier).startTimer(
                          duration,
                          selectedTags,
                        );
                  },
            icon: const Icon(Icons.play_arrow),
            label: const Text('Start Brewing'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 48,
                vertical: 20,
              ),
            ),
          )
        else
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  ref.read(timerServiceProvider.notifier).pauseTimer();
                },
                icon: Icon(
                  timerState.isPaused ? Icons.play_arrow : Icons.pause,
                ),
                label: Text(timerState.isPaused ? 'Resume' : 'Pause'),
              ),
              const SizedBox(width: 16),
              OutlinedButton.icon(
                onPressed: () {
                  ref.read(timerServiceProvider.notifier).stopTimer();
                },
                icon: const Icon(Icons.stop),
                label: const Text('Cancel'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                ),
              ),
            ],
          ),

        // Tags display when running
        if (timerState.isRunning && timerState.tags.isNotEmpty) ...[
          const SizedBox(height: 24),
          Wrap(
            spacing: 8,
            children: timerState.tags
                .map((tag) => Chip(
                      label: Text('#$tag'),
                      backgroundColor:
                          AppColors.primaryLight.withOpacity(0.2),
                    ))
                .toList(),
          ),
        ],

        // Reminder about tags
        if (!timerState.isRunning && selectedTags.isEmpty) ...[
          const SizedBox(height: 16),
          Text(
            'Select at least one tag to start',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
        ],
      ],
    );
  }
}
