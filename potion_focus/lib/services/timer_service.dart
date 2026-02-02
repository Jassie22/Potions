import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:potion_focus/core/utils/helpers.dart';
import 'package:potion_focus/data/local/database.dart';
import 'package:potion_focus/data/local/isar_helpers.dart';
import 'package:potion_focus/data/models/session_model.dart';
import 'package:potion_focus/data/models/potion_model.dart';
import 'package:potion_focus/services/potion_creation_service.dart';
import 'package:potion_focus/services/essence_service.dart';
import 'package:potion_focus/services/tag_stats_service.dart';
import 'package:potion_focus/services/quest_generation_service.dart';
import 'package:potion_focus/services/recipe_service.dart';
import 'package:potion_focus/services/unlock_service.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class TimerState {
  final bool isRunning;
  final bool isPaused;
  final Duration totalDuration;
  final Duration remainingDuration;
  final List<String> tags;
  final String? sessionId;
  final PotionModel? completedPotion;

  TimerState({
    this.isRunning = false,
    this.isPaused = false,
    this.totalDuration = Duration.zero,
    this.remainingDuration = Duration.zero,
    this.tags = const [],
    this.sessionId,
    this.completedPotion,
  });

  /// Fill percent derived from timer progress (0.0 = empty, 1.0 = full).
  double get fillPercent {
    if (!isRunning || totalDuration.inSeconds == 0) return 0.0;
    return 1.0 - (remainingDuration.inSeconds / totalDuration.inSeconds);
  }

  TimerState copyWith({
    bool? isRunning,
    bool? isPaused,
    Duration? totalDuration,
    Duration? remainingDuration,
    List<String>? tags,
    String? sessionId,
    PotionModel? completedPotion,
    bool clearCompletedPotion = false,
  }) {
    return TimerState(
      isRunning: isRunning ?? this.isRunning,
      isPaused: isPaused ?? this.isPaused,
      totalDuration: totalDuration ?? this.totalDuration,
      remainingDuration: remainingDuration ?? this.remainingDuration,
      tags: tags ?? this.tags,
      sessionId: sessionId ?? this.sessionId,
      completedPotion: clearCompletedPotion ? null : (completedPotion ?? this.completedPotion),
    );
  }
}

class TimerService extends StateNotifier<TimerState> {
  Timer? _timer;
  final Ref ref;

  TimerService(this.ref) : super(TimerState());

  void startTimer(Duration duration, List<String> tags) async {
    if (state.isRunning) return;

    // Keep screen awake during focus session
    WakelockPlus.enable();

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

    state = TimerState(
      isRunning: true,
      isPaused: false,
      totalDuration: duration,
      remainingDuration: duration,
      tags: tags,
      sessionId: sessionId,
    );

    _startTicking();
  }

  void _startTicking() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!state.isPaused && state.remainingDuration.inSeconds > 0) {
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

    // Mark session as cancelled (creates Muddy Brew)
    if (state.sessionId != null) {
      await _cancelSession(state.sessionId!);
    }

    state = TimerState();
  }

  Future<void> _completeSession() async {
    _timer?.cancel();
    _timer = null;

    // Disable wakelock
    WakelockPlus.disable();

    if (state.sessionId == null) return;

    final db = DatabaseHelper.instance;

    // Update session as completed
    final allSessions = await db.sessionModels.getAllItems();
    final session = allSessions.where((s) => s.sessionId == state.sessionId!).firstOrNull;

    if (session != null) {
      session.completed = true;
      session.completedAt = DateTime.now();

      await db.writeTxn(() async {
        await db.sessionModels.put(session);
      });

      // Create potion
      final potion = await ref.read(potionCreationServiceProvider).createPotion(
            session.sessionId,
            session.durationMinutes,
            session.tags,
          );

      // Update essence
      await ref.read(essenceServiceProvider).addEssence(potion.essenceEarned);

      // Update tag stats
      await ref.read(tagStatsServiceProvider).updateTagStats(
            session.tags,
            session.durationMinutes,
          );

      // Update quest progress
      await ref.read(questGenerationServiceProvider).updateQuestProgress(
            session.tags,
            session.durationMinutes,
          );

      // Check recipe unlocks
      await ref.read(recipeServiceProvider).checkRecipeUnlocks();

      // Check potion style unlocks
      await ref.read(unlockServiceProvider).checkUnlocks();

      // Expose the completed potion for the UI completion modal
      state = TimerState(completedPotion: potion);
      return;
    }

    state = TimerState();
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

