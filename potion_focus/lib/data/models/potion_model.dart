import 'package:isar/isar.dart';

part 'potion_model.g.dart';

@collection
class PotionModel {
  Id id = Isar.autoIncrement;
  
  late String potionId;
  late String sessionId;
  late String rarity; // common, uncommon, rare, epic, legendary
  late int essenceEarned;
  late String visualConfig; // JSON string
  late DateTime createdAt;
  late bool synced;

  PotionModel({
    this.potionId = '',
    this.sessionId = '',
    this.rarity = 'common',
    this.essenceEarned = 0,
    this.visualConfig = '{}',
    required DateTime createdAt,
    this.synced = false,
  }) : createdAt = createdAt;

  @Index()
  DateTime get indexedDate => createdAt;

  @Index()
  String get indexedRarity => rarity;
}

