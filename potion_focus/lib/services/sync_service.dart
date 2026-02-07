import 'dart:developer' as dev;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:potion_focus/data/local/database.dart';
import 'package:potion_focus/data/local/isar_helpers.dart';
import 'package:potion_focus/data/models/session_model.dart';
import 'package:potion_focus/data/models/potion_model.dart';
import 'package:potion_focus/data/models/quest_model.dart';
import 'package:potion_focus/data/models/user_data_model.dart';

class SyncService {
  final Ref ref;
  final SupabaseClient _supabase;

  SyncService(this.ref) : _supabase = Supabase.instance.client;

  // Check connectivity
  Future<bool> isConnected() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  // Main sync method - called periodically and on app start
  Future<void> syncAll() async {
    if (!await isConnected()) {
      return; // Silently fail if offline
    }

    final user = _supabase.auth.currentUser;
    if (user == null) {
      return; // Not authenticated, skip sync
    }

    try {
      // Push local changes first
      await _pushLocalChanges(user.id);

      // Pull remote changes
      await _pullRemoteChanges(user.id);

      // Mark all as synced
      await _markAllSynced();
    } catch (e) {
      // Silent failure - retry on next sync
      dev.log('Sync error: $e');
    }
  }

  // Push local changes to Supabase
  Future<void> _pushLocalChanges(String userId) async {
    final db = DatabaseHelper.instance;

    // Push sessions
    final allSessions = await db.sessionModels.getAllItems();
    final unsyncedSessions = allSessions.where((s) => !s.synced).toList();

    for (final session in unsyncedSessions) {
      try {
        await _supabase.from('sessions').upsert({
          'id': session.sessionId,
          'user_id': userId,
          'duration_seconds': session.durationSeconds,
          'tags': session.tags,
          'completed': session.completed,
          'started_at': session.startedAt.toIso8601String(),
          'completed_at': session.completedAt?.toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });

        session.synced = true;
        await db.writeTxn(() async {
          await db.sessionModels.put(session);
        });
      } catch (e) {
        dev.log('Error syncing session: $e');
      }
    }

    // Push potions
    final allPotions = await db.potionModels.getAllItems();
    final unsyncedPotions = allPotions.where((p) => !p.synced).toList();

    for (final potion in unsyncedPotions) {
      try {
        await _supabase.from('potions').upsert({
          'id': potion.potionId,
          'session_id': potion.sessionId,
          'user_id': userId,
          'rarity': potion.rarity,
          'essence_earned': potion.essenceEarned,
          'visual_config': potion.visualConfig,
          'created_at': potion.createdAt.toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });

        potion.synced = true;
        await db.writeTxn(() async {
          await db.potionModels.put(potion);
        });
      } catch (e) {
        dev.log('Error syncing potion: $e');
      }
    }

    // Push quests
    final allQuests = await db.questModels.getAllItems();
    final unsyncedQuests = allQuests.where((q) => q.status == 'active').toList();

    for (final quest in unsyncedQuests) {
      try {
        await _supabase.from('quests').upsert({
          'id': quest.questId,
          'user_id': userId,
          'tag': quest.tag,
          'quest_type': quest.questType,
          'timeframe': quest.timeframe,
          'target_value': quest.targetValue,
          'current_progress': quest.currentProgress,
          'status': quest.status,
          'essence_reward': quest.essenceReward,
          'generated_at': quest.generatedAt.toIso8601String(),
          'expires_at': quest.expiresAt.toIso8601String(),
          'completed_at': quest.completedAt?.toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });
      } catch (e) {
        dev.log('Error syncing quest: $e');
      }
    }

    // Push user data
    final allUserData = await db.userDataModels.getAllItems();
    final userData = allUserData.firstOrNull;
    if (userData != null) {
      try {
        await _supabase.from('user_data').upsert({
          'user_id': userId,
          'essence_balance': userData.essenceBalance,
          'total_focus_minutes': userData.totalFocusMinutes,
          'total_potions': userData.totalPotions,
          'streak_days': userData.streakDays,
          'last_focus_date': userData.lastFocusDate?.toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });
      } catch (e) {
        dev.log('Error syncing user data: $e');
      }
    }
  }

  // Pull remote changes from Supabase
  Future<void> _pullRemoteChanges(String userId) async {
    final db = DatabaseHelper.instance;

    // Pull sessions (merge with local by last write wins)
    try {
      final remoteSessions = await _supabase
          .from('sessions')
          .select()
          .eq('user_id', userId)
          .order('updated_at', ascending: false)
          .limit(100);

      for (final remote in remoteSessions) {
        final allLocalSessions = await db.sessionModels.getAllItems();
        final local = allLocalSessions.where(
          (s) => s.sessionId == remote['id'] as String
        ).firstOrNull;

        if (local == null || _shouldUseRemote(remote['updated_at'], local.startedAt)) {
          final session = SessionModel(
            sessionId: remote['id'] as String,
            userId: userId,
            durationSeconds: remote['duration_seconds'] as int,
            tags: List<String>.from(remote['tags'] as List),
            completed: remote['completed'] as bool,
            startedAt: DateTime.parse(remote['started_at'] as String),
            completedAt: remote['completed_at'] != null
                ? DateTime.parse(remote['completed_at'] as String)
                : null,
            synced: true,
          );

          await db.writeTxn(() async {
            await db.sessionModels.put(session);
          });
        }
      }
    } catch (e) {
      dev.log('Error pulling sessions: $e');
    }

    // Pull potions
    try {
      final remotePotions = await _supabase
          .from('potions')
          .select()
          .eq('user_id', userId)
          .order('updated_at', ascending: false)
          .limit(100);

      for (final remote in remotePotions) {
        final allPotions = await db.potionModels.getAllItems();
        final local = allPotions.where((p) => p.potionId == remote['id'] as String).firstOrNull;

        if (local == null || _shouldUseRemote(remote['updated_at'], local.createdAt)) {
          final potion = PotionModel(
            potionId: remote['id'] as String,
            sessionId: remote['session_id'] as String,
            rarity: remote['rarity'] as String,
            essenceEarned: remote['essence_earned'] as int,
            visualConfig: remote['visual_config'] as String,
            createdAt: DateTime.parse(remote['created_at'] as String),
            synced: true,
          );

          await db.writeTxn(() async {
            await db.potionModels.put(potion);
          });
        }
      }
    } catch (e) {
      dev.log('Error pulling potions: $e');
    }

    // Pull user data (merge essence balances)
    try {
      final remoteData = await _supabase
          .from('user_data')
          .select()
          .eq('user_id', userId)
          .single();

      final allLocalData = await db.userDataModels.getAllItems();
      final localData = allLocalData.firstOrNull;

      if (localData != null) {
        // Use maximum of local and remote essence (safety net)
        localData.essenceBalance = (remoteData['essence_balance'] as int)
            .clamp(localData.essenceBalance, double.infinity)
            .toInt();

        localData.totalFocusMinutes = remoteData['total_focus_minutes'] as int;
        localData.totalPotions = remoteData['total_potions'] as int;
        localData.streakDays = remoteData['streak_days'] as int;

        if (remoteData['last_focus_date'] != null) {
          localData.lastFocusDate =
              DateTime.parse(remoteData['last_focus_date'] as String);
        }

        await db.writeTxn(() async {
          await db.userDataModels.put(localData);
        });
      }
        } catch (e) {
      dev.log('Error pulling user data: $e');
    }
  }

  bool _shouldUseRemote(String? remoteUpdatedAt, DateTime localUpdatedAt) {
    if (remoteUpdatedAt == null) return false;
    final remoteTime = DateTime.parse(remoteUpdatedAt);
    return remoteTime.isAfter(localUpdatedAt);
  }

  Future<void> _markAllSynced() async {
    // Sync is handled per-record in _pushLocalChanges
    // This is a placeholder for any final sync operations
  }

  // Sign in anonymously (for offline-first MVP)
  Future<bool> signInAnonymously() async {
    try {
      final response = await _supabase.auth.signInAnonymously();
      return response.user != null;
    } catch (e) {
      dev.log('Error signing in: $e');
      return false;
    }
  }

  // Sign in with email/password
  Future<bool> signInWithEmail(String email, String password) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response.user != null;
    } catch (e) {
      dev.log('Error signing in: $e');
      return false;
    }
  }

  // Sign up with email/password
  Future<bool> signUpWithEmail(String email, String password) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );
      return response.user != null;
    } catch (e) {
      dev.log('Error signing up: $e');
      return false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  // Get current user
  User? getCurrentUser() {
    return _supabase.auth.currentUser;
  }

  // Check if authenticated
  bool isAuthenticated() {
    return _supabase.auth.currentUser != null;
  }
}

final syncServiceProvider = Provider<SyncService>((ref) {
  return SyncService(ref);
});

