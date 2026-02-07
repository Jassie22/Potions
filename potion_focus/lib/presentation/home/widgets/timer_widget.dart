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
      setState(() {
        // X tilt (left/right) - normalize to -1 to 1
        _tiltX = (event.x / 5.0).clamp(-1.0, 1.0);

        // Y tilt - handle both upright and inverted positions
        // Upright: Y ~ +9.8 (gravity pulling down on bottom of phone)
        // Inverted: Y ~ -9.8 (gravity pulling down on top of phone)
        // Tilted forward/back: |Y| < 9.8

        // Calculate how upright the phone is (0 when flat, ~9.8 when upright/inverted)
        final uprightness = event.y.abs();

        // The deviation from fully upright (9.8) tells us the forward/back tilt
        final tiltFromUpright = (uprightness - 9.8) / 5.0;

        // When phone is inverted (Y negative), flip the tilt direction
        // so liquid still responds correctly to forward/back tilts
        if (event.y >= 0) {
          _tiltY = tiltFromUpright.clamp(-1.0, 1.0);
        } else {
          _tiltY = (-tiltFromUpright).clamp(-1.0, 1.0);
        }
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

    // Use the fillPercent getter from TimerState (handles both modes)
    // Show 30% fill in preview so user can see their selected liquid color
    final fillPercent = timerState.isRunning ? timerState.fillPercent : 0.3;

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

    // Determine timer display text based on mode
    String timerText;
    if (!timerState.isRunning) {
      timerText = widget.duration.toTimerString();
    } else if (timerState.isFreeForm) {
      // Free-form: show elapsed time counting UP
      timerText = timerState.elapsedDuration.toTimerString();
    } else {
      // Preset: show remaining time counting DOWN
      timerText = timerState.remainingDuration.toTimerString();
    }

    // Determine status text based on mode
    String statusText;
    if (timerState.isPaused) {
      statusText = 'Paused';
    } else if (timerState.isFreeForm) {
      statusText = 'Free-Form Brewing...';
    } else {
      statusText = 'Brewing...';
    }

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

        // Timer text
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            timerText,
            maxLines: 1,
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 48,
                  color: Colors.white.withValues(alpha: 0.95),
                ),
          ),
        ),
        if (timerState.isRunning) ...[
          const SizedBox(height: 4),
          Text(
            statusText,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.6),
                ),
          ),
          // Show max time hint for free-form
          if (timerState.isFreeForm) ...[
            const SizedBox(height: 2),
            Text(
              '(up to 2 hours)',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.4),
                    fontSize: 10,
                  ),
            ),
          ],
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
    // Determine if free-form session has enough time for a valid potion
    final canEndWithPotion = timerState.isFreeForm &&
        timerState.elapsedDuration.inMinutes >= freeFormMinMinutes;

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

        // End Session / Cancel button
        if (timerState.isFreeForm)
          // Free-form: End Session button (positive action if >= 10 min)
          GestureDetector(
            onTap: () => _handleEndFreeFormSession(context, timerState),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              decoration: BoxDecoration(
                color: canEndWithPotion ? AppColors.success : Colors.transparent,
                border: Border.all(
                  color: canEndWithPotion ? Colors.black87 : AppColors.warning,
                  width: 2,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    canEndWithPotion ? Icons.check : Icons.stop,
                    color: canEndWithPotion ? Colors.white : AppColors.warning,
                    size: 20,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'End Session',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: canEndWithPotion ? Colors.white : AppColors.warning,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            ),
          )
        else
          // Preset: Cancel button (negative action)
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
                  const Icon(Icons.stop, color: AppColors.error, size: 20),
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

  /// Handle ending a free-form session
  Future<void> _handleEndFreeFormSession(BuildContext context, TimerState timerState) async {
    final feedbackService = ref.read(feedbackServiceProvider);
    feedbackService.haptic(HapticType.medium);

    final elapsedMinutes = timerState.elapsedDuration.inMinutes;

    if (elapsedMinutes < freeFormMinMinutes) {
      // Not enough time - warn and ask for confirmation
      final confirmed = await showPixelConfirmDialog(
        context: context,
        title: 'End Early?',
        message:
            "You've only focused for ${timerState.elapsedDuration.toTimerString()}.\n\nMinimum $freeFormMinMinutes minutes needed for a valid potion. Ending now will create a Muddy Brew.",
        confirmText: 'End Anyway',
        cancelText: 'Keep Going',
        isDangerous: true,
      );

      if (confirmed == true) {
        ref.read(timerServiceProvider.notifier).stopTimer();
      }
    } else {
      // Enough time - end the session normally (will create valid potion)
      ref.read(timerServiceProvider.notifier).stopTimer();
    }
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
