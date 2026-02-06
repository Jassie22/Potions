import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:potion_focus/core/config/app_preferences.dart';

/// Types of sounds the app can play
enum SoundType {
  tap,           // Button tap
  sessionStart,  // Timer started
  sessionComplete, // Session finished successfully
  purchase,      // Item purchased
  questComplete, // Quest completed
  error,         // Error occurred
}

/// Types of haptic feedback
enum HapticType {
  light,    // Subtle feedback for minor interactions
  medium,   // Standard feedback for button taps
  heavy,    // Strong feedback for important actions
  success,  // Selection feedback pattern
  error,    // Vibrate pattern for errors
}

/// Service for providing audio and haptic feedback throughout the app.
/// Respects user preferences from AppPreferences.
class FeedbackService {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isInitialized = false;

  /// Initialize the feedback service
  Future<void> init() async {
    if (_isInitialized) return;
    await AppPreferences.init();
    // Pre-configure audio player for low latency
    await _audioPlayer.setReleaseMode(ReleaseMode.stop);
    _isInitialized = true;
  }

  /// Play a sound effect if sounds are enabled
  Future<void> playSound(SoundType type) async {
    if (!AppPreferences.soundsEnabled) return;

    final assetPath = _getSoundAsset(type);
    if (assetPath == null) return;

    try {
      await _audioPlayer.play(AssetSource(assetPath));
    } catch (e) {
      // Silently fail if sound can't be played
      // This prevents crashes if asset is missing
    }
  }

  /// Trigger haptic feedback if haptics are enabled
  Future<void> haptic(HapticType type) async {
    if (!AppPreferences.hapticFeedbackEnabled) return;

    switch (type) {
      case HapticType.light:
        await HapticFeedback.lightImpact();
        break;
      case HapticType.medium:
        await HapticFeedback.mediumImpact();
        break;
      case HapticType.heavy:
        await HapticFeedback.heavyImpact();
        break;
      case HapticType.success:
        await HapticFeedback.selectionClick();
        break;
      case HapticType.error:
        await HapticFeedback.vibrate();
        break;
    }
  }

  /// Play sound and haptic together for important interactions
  Future<void> feedback({
    required SoundType sound,
    required HapticType haptic,
  }) async {
    // Run both in parallel
    await Future.wait([
      playSound(sound),
      this.haptic(haptic),
    ]);
  }

  /// Get the asset path for a sound type
  String? _getSoundAsset(SoundType type) {
    switch (type) {
      case SoundType.tap:
        return 'sounds/tap.wav';
      case SoundType.sessionStart:
        return 'sounds/start.wav';
      case SoundType.sessionComplete:
        return 'sounds/complete.wav';
      case SoundType.purchase:
        return 'sounds/purchase.wav';
      case SoundType.questComplete:
        return 'sounds/quest_complete.wav';
      case SoundType.error:
        return 'sounds/error.wav';
    }
  }

  /// Clean up resources
  void dispose() {
    _audioPlayer.dispose();
  }
}

/// Provider for the feedback service
final feedbackServiceProvider = Provider<FeedbackService>((ref) {
  final service = FeedbackService();
  ref.onDispose(() => service.dispose());
  return service;
});
