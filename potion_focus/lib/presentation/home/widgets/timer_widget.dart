import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:potion_focus/core/models/visual_config.dart';
import 'package:potion_focus/core/theme/app_colors.dart';
import 'package:potion_focus/core/utils/extensions.dart';
import 'package:potion_focus/services/timer_service.dart';
import 'package:potion_focus/services/feedback_service.dart';
import 'package:potion_focus/presentation/shared/painting/potion_renderer.dart';
import 'package:potion_focus/presentation/shared/widgets/pixel_dialog.dart';
import 'package:sensors_plus/sensors_plus.dart';

class TimerWidget extends ConsumerStatefulWidget {
  final Duration duration;
  final List<String> selectedTags;
  final String selectedBottle;
  final String selectedLiquid;
  final VoidCallback? onStartPressed;

  const TimerWidget({
    super.key,
    required this.duration,
    required this.selectedTags,
    this.selectedBottle = 'bottle_round',
    this.selectedLiquid = 'liquid_0',
    this.onStartPressed,
  });

  @override
  ConsumerState<TimerWidget> createState() => _TimerWidgetState();
}

class _TimerWidgetState extends ConsumerState<TimerWidget> {
  double _tiltX = 0.0;
  double _tiltY = 0.0;
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;

  @override
  void initState() {
    super.initState();
    _accelerometerSubscription = accelerometerEventStream().listen((event) {
      // event.x is tilt left/right: negative = tilt left, positive = tilt right
      // event.y is tilt forward/back: positive = tilt forward, negative = tilt back
      setState(() {
        // Normalize: typical range is -10 to 10, map to -1 to 1
        _tiltX = (event.x / 5.0).clamp(-1.0, 1.0);
        _tiltY = (event.y / 5.0).clamp(-1.0, 1.0);
      });
    });
  }

  @override
  void dispose() {
    _accelerometerSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final timerState = ref.watch(timerServiceProvider);

    // Derive fill percent from timer progress
    // Show 30% fill in preview so user can see their selected liquid color
    final fillPercent = timerState.isRunning && timerState.totalDuration.inSeconds > 0
        ? 1.0 - (timerState.remainingDuration.inSeconds / timerState.totalDuration.inSeconds)
        : 0.3;

    // Use selected bottle/liquid for the preview, or the timer state's when running
    final bottleForDisplay = timerState.isRunning
        ? timerState.selectedBottle
        : widget.selectedBottle;
    final liquidForDisplay = timerState.isRunning
        ? timerState.selectedLiquid
        : widget.selectedLiquid;

    final config = VisualConfig(
      bottleShape: bottleForDisplay,
      liquid: liquidForDisplay,
      effectType: 'none',
      rarity: 'common',
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Potion bottle with tilt sloshing
        PotionRenderer(
          config: config,
          size: 260,
          fillPercent: fillPercent,
          isBrewing: timerState.isRunning && !timerState.isPaused,
          showGlow: timerState.isRunning,
          tiltX: _tiltX,
          tiltY: _tiltY,
        ),
        const SizedBox(height: 16),

        // Timer countdown text
        Text(
          timerState.isRunning
              ? timerState.remainingDuration.toTimerString()
              : widget.duration.toTimerString(),
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 48,
                color: Colors.white.withOpacity(0.95),
              ),
        ),
        if (timerState.isRunning) ...[
          const SizedBox(height: 4),
          Text(
            timerState.isPaused ? 'Paused' : 'Brewing...',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withOpacity(0.6),
                ),
          ),
        ],
        const SizedBox(height: 24),

        // Control buttons
        if (!timerState.isRunning)
          _buildStartButton(context)
        else
          _buildRunningControls(context, timerState),
      ],
    );
  }

  Widget _buildStartButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: GestureDetector(
        onTap: () {
          ref.read(feedbackServiceProvider).haptic(HapticType.light);
          widget.onStartPressed?.call();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 56, vertical: 18),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            border: Border.all(color: Colors.black87, width: 3),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.play_arrow, color: Colors.white, size: 24),
              const SizedBox(width: 8),
              Text(
                'Start Brewing',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRunningControls(BuildContext context, TimerState timerState) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Pause/Resume button
        GestureDetector(
          onTap: () {
            ref.read(feedbackServiceProvider).haptic(HapticType.light);
            ref.read(timerServiceProvider.notifier).pauseTimer();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              border: Border.all(color: Colors.black87, width: 2),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  timerState.isPaused ? Icons.play_arrow : Icons.pause,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 6),
                Text(
                  timerState.isPaused ? 'Resume' : 'Pause',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),

        // Cancel button
        GestureDetector(
          onTap: () => _handleCancelSession(context, timerState),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.transparent,
              border: Border.all(color: AppColors.error, width: 2),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.stop, color: AppColors.error, size: 20),
                const SizedBox(width: 6),
                Text(
                  'Cancel',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.error,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Handle cancel with confirmation dialog if session > 30 seconds
  Future<void> _handleCancelSession(BuildContext context, TimerState timerState) async {
    final feedbackService = ref.read(feedbackServiceProvider);
    feedbackService.haptic(HapticType.medium);

    // Calculate elapsed time
    final elapsedSeconds = timerState.totalDuration.inSeconds - timerState.remainingDuration.inSeconds;

    // If session is under 30 seconds, cancel directly without confirmation
    if (elapsedSeconds < 30) {
      ref.read(timerServiceProvider.notifier).stopTimer();
      return;
    }

    // Show confirmation dialog for longer sessions
    final elapsedDuration = Duration(seconds: elapsedSeconds);
    final confirmed = await showPixelConfirmDialog(
      context: context,
      title: 'Abandon Session?',
      message:
          "If you stop now, you'll receive a Muddy Brew instead of a completed potion.\n\nTime invested: ${elapsedDuration.toTimerString()}",
      confirmText: 'Abandon',
      cancelText: 'Continue',
      isDangerous: true,
    );

    if (confirmed == true) {
      ref.read(timerServiceProvider.notifier).stopTimer();
    }
  }
}
