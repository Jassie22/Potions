import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:potion_focus/core/utils/helpers.dart';
import 'package:potion_focus/data/local/database.dart';
import 'package:potion_focus/data/local/isar_helpers.dart';
import 'package:potion_focus/data/models/session_model.dart';
import 'package:potion_focus/data/models/potion_model.dart';
import 'package:potion_focus/data/repositories/potion_repository.dart';
import 'package:potion_focus/services/potion_creation_service.dart';
import 'package:potion_focus/services/essence_service.dart';
import 'package:potion_focus/services/tag_stats_service.dart';
import 'package:potion_focus/services/quest_generation_service.dart';
import 'package:potion_focus/services/recipe_service.dart';
import 'package:potion_focus/services/unlock_service.dart';
import 'package:potion_focus/services/subscription_service.dart';
import 'package:potion_focus/services/daily_bonus_service.dart';
import 'package:potion_focus/services/upgrade_prompt_service.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

/// Maximum duration for free-form sessions (2 hours)
const int freeFormMaxMinutes = 120;

/// Minimum duration for a valid potion (not muddy) in free-form mode
const int freeFormMinMinutes = 10;

class TimerState {
  final bool isRunning;
  final bool isPaused;
  final bool isFreeForm;
  final Duration totalDuration;
  final Duration remainingDuration;
  final Duration elapsedDuration;
  final List<String> tags;
  final String? sessionId;
  final String selectedBottle;
  final String selectedLiquid;
  final PotionModel? completedPotion;

  TimerState({
    this.isRunning = false,
    this.isPaused = false,
    this.isFreeForm = false,
    this.totalDuration = Duration.zero,
    this.remainingDuration = Duration.zero,
    this.elapsedDuration = Duration.zero,
    this.tags = const [],
    this.sessionId,
    this.selectedBottle = 'bottle_round',
    this.selectedLiquid = 'liquid_0',
    this.completedPotion,
  });

  /// Fill percent derived from timer progress (0.0 = empty, 1.0 = full).
  double get fillPercent {
    if (isFreeForm) {
      // Free-form: fill based on elapsed / 2 hours max
      return (elapsedDuration.inSeconds / (freeFormMaxMinutes * 60)).clamp(0.0, 1.0);
    }
    // Preset: fill based on remaining
    if (!isRunning || totalDuration.inSeconds == 0) return 0.0;
    return 1.0 - (remainingDuration.inSeconds / totalDuration.inSeconds);
  }

  TimerState copyWith({
    bool? isRunning,
    bool? isPaused,
    bool? isFreeForm,
    Duration? totalDuration,
    Duration? remainingDuration,
    Duration? elapsedDuration,
    List<String>? tags,
    String? sessionId,
    String? selectedBottle,
    String? selectedLiquid,
    PotionModel? completedPotion,
    bool clearCompletedPotion = false,
  }) {
    return TimerState(
      isRunning: isRunning ?? this.isRunning,
      isPaused: isPaused ?? this.isPaused,
      isFreeForm: isFreeForm ?? this.isFreeForm,
      totalDuration: totalDuration ?? this.totalDuration,
      remainingDuration: remainingDuration ?? this.remainingDuration,
      elapsedDuration: elapsedDuration ?? this.elapsedDuration,
      tags: tags ?? this.tags,
      sessionId: sessionId ?? this.sessionId,
      selectedBottle: selectedBottle ?? this.selectedBottle,
      selectedLiquid: selectedLiquid ?? this.selectedLiquid,
      completedPotion: clearCompletedPotion ? null : (completedPotion ?? this.completedPotion),
    );
  }
}

class TimerService extends StateNotifier<TimerState> {
  Timer? _timer;
  final Ref ref;

  TimerService(this.ref) : super(TimerState());

  void startTimer(Duration duration, List<String> tags, {String selectedBottle = 'bottle_round', String selectedLiquid = 'liquid_0'}) async {
    if (state.isRunning) return;

    try {
      final sessionId = Helpers.generateId();

      // Create session record
      final now = DateTime.now();
      final session = SessionModel(
        sessionId: sessionId,
        durationSeconds: duration.inSeconds,
        tags: tags,
        completed: false,
        startedAt: now,
      );

      final db = DatabaseHelper.instance;
      await db.writeTxn(() async {
        await db.sessionModels.put(session);
      });

      // Enable wakelock AFTER successful DB write
      WakelockPlus.enable();

      state = TimerState(
        isRunning: true,
        isPaused: false,
        totalDuration: duration,
        remainingDuration: duration,
        tags: tags,
        sessionId: sessionId,
        selectedBottle: selectedBottle,
        selectedLiquid: selectedLiquid,
      );

      _startTicking();
    } catch (e) {
      WakelockPlus.disable();
      debugPrint('Failed to start timer session: $e');
      rethrow;
    }
  }

  /// Start a free-form session that counts UP to a maximum of 2 hours.
  void startFreeFormSession(List<String> tags, {String selectedBottle = 'bottle_round', String selectedLiquid = 'liquid_0'}) async {
    if (state.isRunning) return;

    try {
      final sessionId = Helpers.generateId();

      // Create session with 0 duration; actual time set on completion (Bug 1.6 fix)
      final now = DateTime.now();
      final session = SessionModel(
        sessionId: sessionId,
        durationSeconds: 0, // Will be set to actual elapsed time on completion
        tags: tags,
        completed: false,
        startedAt: now,
      );

      final db = DatabaseHelper.instance;
      await db.writeTxn(() async {
        await db.sessionModels.put(session);
      });

      // Enable wakelock AFTER successful DB write
      WakelockPlus.enable();

      state = TimerState(
        isRunning: true,
        isPaused: false,
        isFreeForm: true,
        totalDuration: Duration(minutes: freeFormMaxMinutes),
        remainingDuration: Duration(minutes: freeFormMaxMinutes),
        elapsedDuration: Duration.zero,
        tags: tags,
        sessionId: sessionId,
        selectedBottle: selectedBottle,
        selectedLiquid: selectedLiquid,
      );

      _startTicking();
    } catch (e) {
      WakelockPlus.disable();
      debugPrint('Failed to start free-form session: $e');
      rethrow;
    }
  }

  void _startTicking() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!state.isPaused) {
        if (state.isFreeForm) {
          // Free-form: count UP
          final newElapsed = Duration(seconds: state.elapsedDuration.inSeconds + 1);
          state = state.copyWith(elapsedDuration: newElapsed);

          // Auto-complete at 2 hours
          if (newElapsed.inMinutes >= freeFormMaxMinutes) {
            _completeSession();
          }
        } else {
          // Preset: count DOWN
          if (state.remainingDuration.inSeconds > 0) {
            state = state.copyWith(
              remainingDuration: Duration(
                seconds: state.remainingDuration.inSeconds - 1,
              ),
            );

            // Check if timer completed
            if (state.remainingDuration.inSeconds == 0) {
              _completeSession();
            }
          }
        }
      }
    });
  }

  void pauseTimer() {
    if (!state.isRunning) return;
    state = state.copyWith(isPaused: !state.isPaused);
  }

  Future<void> stopTimer() async {
    if (!state.isRunning) return;

    _timer?.cancel();
    _timer = null;

    // Disable wakelock
    WakelockPlus.disable();

    if (state.sessionId != null) {
      if (state.isFreeForm && state.elapsedDuration.inMinutes >= freeFormMinMinutes) {
        // Free-form with enough time: complete the session normally
        await _completeFreeFormSession();
      } else {
        // Preset cancelled early OR free-form with < 10 min: creates Muddy Brew
        await _cancelSession(state.sessionId!);
        state = TimerState();
      }
    } else {
      state = TimerState();
    }
  }

  /// Complete a free-form session with the actual elapsed time.
  Future<void> _completeFreeFormSession() async {
    if (state.sessionId == null) return;

    final db = DatabaseHelper.instance;
    final elapsedMinutes = state.elapsedDuration.inMinutes;
    final sessionId = state.sessionId!;

    // Idempotency: check if potion already exists for this session (bug 1.2)
    final existingPotion = await ref.read(potionRepositoryProvider).getPotionBySessionId(sessionId);
    if (existingPotion != null) {
      debugPrint('Potion already exists for session $sessionId, skipping creation');
      state = TimerState(completedPotion: existingPotion);
      return;
    }

    // Update session with actual duration
    final allSessions = await db.sessionModels.getAllItems();
    final session = allSessions.where((s) => s.sessionId == sessionId).firstOrNull;

    if (session != null) {
      session.completed = true;
      session.completedAt = DateTime.now();
      session.durationSeconds = state.elapsedDuration.inSeconds;

      await db.writeTxn(() async {
        await db.sessionModels.put(session);
      });

      // Create potion with actual elapsed time
      final potion = await ref.read(potionCreationServiceProvider).createPotion(
            session.sessionId,
            elapsedMinutes,
            session.tags,
            selectedBottle: state.selectedBottle,
            selectedLiquid: state.selectedLiquid,
          );

      // Apply premium bonus to essence (+25% for subscribers)
      final isPremium = ref.read(subscriptionServiceProvider).isPremium;
      final essenceMultiplier = isPremium ? 1.25 : 1.0;
      final finalEssence = (potion.essenceEarned * essenceMultiplier).round();

      // Downstream calls with logging on failure (bug 1.3)
      try { await ref.read(essenceServiceProvider).addEssence(finalEssence); } catch (e) { debugPrint('Failed to add essence: $e'); }
      try { await ref.read(essenceServiceProvider).updateStreak(); } catch (e) { debugPrint('Failed to update streak: $e'); }
      try { await ref.read(essenceServiceProvider).incrementPotionCount(); } catch (e) { debugPrint('Failed to increment potion count: $e'); }
      try { await ref.read(essenceServiceProvider).addFocusMinutes(elapsedMinutes); } catch (e) { debugPrint('Failed to add focus minutes: $e'); }
      try { await ref.read(dailyBonusServiceProvider).checkAndGrantDailyBonus(); } catch (e) { debugPrint('Failed to check daily bonus: $e'); }
      try { await ref.read(upgradePromptServiceProvider).incrementSessionCount(); } catch (e) { debugPrint('Failed to increment session count: $e'); }
      try { await ref.read(tagStatsServiceProvider).updateTagStats(session.tags, elapsedMinutes); } catch (e) { debugPrint('Failed to update tag stats: $e'); }
      try { await ref.read(questGenerationServiceProvider).updateQuestProgress(session.tags, elapsedMinutes); } catch (e) { debugPrint('Failed to update quest progress: $e'); }
      try { await ref.read(recipeServiceProvider).checkRecipeUnlocks(); } catch (e) { debugPrint('Failed to check recipe unlocks: $e'); }
      try { await ref.read(unlockServiceProvider).checkUnlocks(); } catch (e) { debugPrint('Failed to check unlocks: $e'); }

      // Invalidate potion cache so cabinet updates
      ref.invalidate(allPotionsProvider);

      // Expose the completed potion for the UI completion modal
      state = TimerState(completedPotion: potion);
      return;
    }

    state = TimerState();
  }

  Future<void> _completeSession() async {
    _timer?.cancel();
    _timer = null;

    // Disable wakelock in finally to prevent stuck-on state (bug 1.7)
    try {
      if (state.sessionId == null) return;

      final db = DatabaseHelper.instance;
      final sessionId = state.sessionId!;

      // For free-form sessions that auto-completed at max time, use _completeFreeFormSession
      if (state.isFreeForm) {
        await _completeFreeFormSession();
        return;
      }

      // Idempotency: check if potion already exists for this session (bug 1.2)
      final existingPotion = await ref.read(potionRepositoryProvider).getPotionBySessionId(sessionId);
      if (existingPotion != null) {
        debugPrint('Potion already exists for session $sessionId, skipping creation');
        state = TimerState(completedPotion: existingPotion);
        return;
      }

      // Update session as completed
      final allSessions = await db.sessionModels.getAllItems();
      final session = allSessions.where((s) => s.sessionId == sessionId).firstOrNull;

      if (session != null) {
        session.completed = true;
        session.completedAt = DateTime.now();

        await db.writeTxn(() async {
          await db.sessionModels.put(session);
        });

        // Create potion FIRST - this is the critical path
        final potion = await ref.read(potionCreationServiceProvider).createPotion(
              session.sessionId,
              session.durationMinutes,
              session.tags,
              selectedBottle: state.selectedBottle,
              selectedLiquid: state.selectedLiquid,
            );

        // Apply premium bonus to essence (+25% for subscribers)
        final isPremium = ref.read(subscriptionServiceProvider).isPremium;
        final essenceMultiplier = isPremium ? 1.25 : 1.0;
        final finalEssence = (potion.essenceEarned * essenceMultiplier).round();

        // Downstream calls with logging on failure (bugs 1.1, 1.3)
        try { await ref.read(essenceServiceProvider).addEssence(finalEssence); } catch (e) { debugPrint('Failed to add essence: $e'); }
        try { await ref.read(essenceServiceProvider).updateStreak(); } catch (e) { debugPrint('Failed to update streak: $e'); }
        try { await ref.read(essenceServiceProvider).incrementPotionCount(); } catch (e) { debugPrint('Failed to increment potion count: $e'); }
        try { await ref.read(essenceServiceProvider).addFocusMinutes(session.durationMinutes); } catch (e) { debugPrint('Failed to add focus minutes: $e'); }
        try { await ref.read(dailyBonusServiceProvider).checkAndGrantDailyBonus(); } catch (e) { debugPrint('Failed to check daily bonus: $e'); }
        try { await ref.read(upgradePromptServiceProvider).incrementSessionCount(); } catch (e) { debugPrint('Failed to increment session count: $e'); }
        try { await ref.read(tagStatsServiceProvider).updateTagStats(session.tags, session.durationMinutes); } catch (e) { debugPrint('Failed to update tag stats: $e'); }
        try { await ref.read(questGenerationServiceProvider).updateQuestProgress(session.tags, session.durationMinutes); } catch (e) { debugPrint('Failed to update quest progress: $e'); }
        try { await ref.read(recipeServiceProvider).checkRecipeUnlocks(); } catch (e) { debugPrint('Failed to check recipe unlocks: $e'); }
        try { await ref.read(unlockServiceProvider).checkUnlocks(); } catch (e) { debugPrint('Failed to check unlocks: $e'); }

        // Invalidate potion cache so cabinet updates
        ref.invalidate(allPotionsProvider);

        // Expose the completed potion for the UI completion modal
        state = TimerState(completedPotion: potion);
        return;
      }

      state = TimerState();
    } finally {
      WakelockPlus.disable();
    }
  }

  Future<void> _cancelSession(String sessionId) async {
    final db = DatabaseHelper.instance;
    
    final allSessions = await db.sessionModels.getAllItems();
    final session = allSessions.where((s) => s.sessionId == sessionId).firstOrNull;

    if (session != null) {
      session.completed = false;
      session.completedAt = DateTime.now();

      await db.writeTxn(() async {
        await db.sessionModels.put(session);
      });

      // Create Muddy Brew potion
      await ref.read(potionCreationServiceProvider).createMuddyBrew(
            session.sessionId,
          );
    }
  }

  /// Call after the completion modal is dismissed.
  void clearCompletedPotion() {
    if (state.completedPotion != null) {
      state = TimerState();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    WakelockPlus.disable();
    super.dispose();
  }
}

final timerServiceProvider = StateNotifierProvider<TimerService, TimerState>((ref) {
  return TimerService(ref);
});

