import 'package:isar/isar.dart';

part 'unlockable_model.g.dart';

@collection
class UnlockableModel {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String unlockableId;

  late String name;
  late String description;
  late String unlockCondition; // JSON: {"type": "...", ...}
  late String rewardVisualConfig; // JSON: VisualConfig for the potion style
  late String rarity;
  late bool unlocked;
  DateTime? unlockedAt;

  UnlockableModel({
    this.unlockableId = '',
    this.name = '',
    this.description = '',
    this.unlockCondition = '{}',
    this.rewardVisualConfig = '{}',
    this.rarity = 'common',
    this.unlocked = false,
    this.unlockedAt,
  });
}
