import 'package:isar/isar.dart';

part 'session_model.g.dart';

@collection
class SessionModel {
  Id id = Isar.autoIncrement;
  
  late String sessionId;
  String? userId;
  late int durationSeconds;
  late List<String> tags;
  late bool completed;
  late DateTime startedAt;
  DateTime? completedAt;
  late bool synced;

  SessionModel({
    this.sessionId = '',
    this.userId,
    this.durationSeconds = 0,
    this.tags = const [],
    this.completed = false,
    required DateTime startedAt,
    this.completedAt,
    this.synced = false,
  }) : startedAt = startedAt;

  @Index()
  DateTime get indexedDate => startedAt;

  @Index(type: IndexType.value)
  List<String> get indexedTags => tags;

  int get durationMinutes => (durationSeconds / 60).floor();
}

