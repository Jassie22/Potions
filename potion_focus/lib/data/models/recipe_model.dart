import 'package:isar/isar.dart';

part 'recipe_model.g.dart';

@collection
class RecipeModel {
  Id id = Isar.autoIncrement;
  
  @Index(unique: true)
  late String recipeId;
  
  late String name;
  late String unlockCondition; // JSON string
  late String rewardType; // bottle, liquid, background, effect
  late String rewardAssetKey;
  late String rarity;
  late String lore;
  late bool unlocked;
  DateTime? unlockedAt;

  RecipeModel({
    this.recipeId = '',
    this.name = '',
    this.unlockCondition = '{}',
    this.rewardType = '',
    this.rewardAssetKey = '',
    this.rarity = 'common',
    this.lore = '',
    this.unlocked = false,
    this.unlockedAt,
  });
}



