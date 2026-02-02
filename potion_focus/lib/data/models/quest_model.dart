import 'package:isar/isar.dart';

part 'quest_model.g.dart';

@collection
class QuestModel {
  Id id = Isar.autoIncrement;
  
  late String questId;
  late String tag;
  late String questType; // time_based, session_based, streak_based
  late String timeframe; // daily, weekly
  late int targetValue;
  late int currentProgress;
  late String status; // active, completed, expired
  late int essenceReward;
  late DateTime generatedAt;
  late DateTime expiresAt;
  DateTime? completedAt;

  QuestModel({
    this.questId = '',
    this.tag = '',
    this.questType = 'time_based',
    this.timeframe = 'daily',
    this.targetValue = 0,
    this.currentProgress = 0,
    this.status = 'active',
    this.essenceReward = 0,
    required DateTime generatedAt,
    required DateTime expiresAt,
    this.completedAt,
  })  : generatedAt = generatedAt,
        expiresAt = expiresAt;

  @Index()
  String get indexedStatus => status;

  @Index()
  DateTime get indexedExpiresAt => expiresAt;

  double get progressPercentage => targetValue > 0 ? (currentProgress / targetValue).clamp(0.0, 1.0) : 0.0;

  bool get isComplete => currentProgress >= targetValue;
}

