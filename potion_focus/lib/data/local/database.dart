import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:potion_focus/data/models/session_model.dart';
import 'package:potion_focus/data/models/potion_model.dart';
import 'package:potion_focus/data/models/tag_stats_model.dart';
import 'package:potion_focus/data/models/recipe_model.dart';
import 'package:potion_focus/data/models/quest_model.dart';
import 'package:potion_focus/data/models/user_data_model.dart';
import 'package:potion_focus/data/models/shop_item_model.dart';
import 'package:potion_focus/data/models/subscription_model.dart';
import 'package:potion_focus/data/models/unlockable_model.dart';

class DatabaseHelper {
  static Isar? _isar;

  static Future<void> initialize() async {
    if (_isar != null) return;

    final dir = await getApplicationDocumentsDirectory();

    _isar = await Isar.open(
      [
        SessionModelSchema,
        PotionModelSchema,
        TagStatsModelSchema,
        RecipeModelSchema,
        QuestModelSchema,
        UserDataModelSchema,
        ShopItemModelSchema,
        SubscriptionModelSchema,
        UnlockableModelSchema,
      ],
      directory: dir.path,
      name: 'potion_focus_db',
    );

    // Initialize default user data if not exists
    await _ensureUserData();
    // Initialize default subscription record
    await _ensureSubscription();
    // Initialize default shop items
    await _initializeShopItems();
    // Initialize default recipes
    await _initializeRecipes();
    // Initialize default unlockables
    await _initializeUnlockables();
  }

  static Isar get instance {
    if (_isar == null) {
      throw Exception('Database not initialized. Call DatabaseHelper.initialize() first.');
    }
    return _isar!;
  }

  static Future<void> _ensureUserData() async {
    final userDataCount = await _isar!.userDataModels.count();
    if (userDataCount == 0) {
      await _isar!.writeTxn(() async {
        await _isar!.userDataModels.put(UserDataModel());
      });
    }
  }

  static Future<void> _ensureSubscription() async {
    final count = await _isar!.subscriptionModels.count();
    if (count == 0) {
      await _isar!.writeTxn(() async {
        await _isar!.subscriptionModels.put(SubscriptionModel());
      });
    }
  }

  static Future<void> _initializeShopItems() async {
    final shopItemsCount = await _isar!.shopItemModels.count();
    if (shopItemsCount > 0) return; // Already initialized

    final defaultItems = [
      // === BOTTLES (Free / Essence) ===
      ShopItemModel(
        itemId: 'bottle_round',
        name: 'Round Flask',
        category: 'bottle',
        assetKey: 'bottle_round',
        essenceCost: 0,
        currencyType: 'essence',
        rarity: 'common',
        purchased: true,
      ),
      ShopItemModel(
        itemId: 'bottle_tall',
        name: 'Tall Vial',
        category: 'bottle',
        assetKey: 'bottle_tall',
        essenceCost: 0,
        currencyType: 'essence',
        rarity: 'common',
        purchased: true,
      ),
      ShopItemModel(
        itemId: 'bottle_flask',
        name: 'Erlenmeyer Flask',
        category: 'bottle',
        assetKey: 'bottle_flask',
        essenceCost: 100,
        currencyType: 'essence',
        rarity: 'uncommon',
      ),
      ShopItemModel(
        itemId: 'bottle_potion',
        name: 'Classic Potion',
        category: 'bottle',
        assetKey: 'bottle_potion',
        essenceCost: 150,
        currencyType: 'essence',
        rarity: 'rare',
      ),

      // === BOTTLES (Premium / Coins) ===
      ShopItemModel(
        itemId: 'bottle_heart',
        name: 'Heart Vial',
        category: 'bottle',
        assetKey: 'bottle_heart',
        coinCost: 50,
        currencyType: 'coins',
        rarity: 'rare',
      ),
      ShopItemModel(
        itemId: 'bottle_diamond',
        name: 'Diamond Flask',
        category: 'bottle',
        assetKey: 'bottle_diamond',
        coinCost: 75,
        currencyType: 'coins',
        rarity: 'epic',
      ),
      ShopItemModel(
        itemId: 'bottle_gourd',
        name: 'Gourd Bottle',
        category: 'bottle',
        assetKey: 'bottle_gourd',
        coinCost: 60,
        currencyType: 'coins',
        rarity: 'rare',
      ),
      ShopItemModel(
        itemId: 'bottle_legendary',
        name: 'Ornate Bottle',
        category: 'bottle',
        assetKey: 'bottle_legendary',
        coinCost: 120,
        currencyType: 'coins',
        rarity: 'legendary',
      ),

      // === LIQUIDS ===
      ShopItemModel(
        itemId: 'liquid_purple',
        name: 'Purple Liquid',
        category: 'liquid',
        assetKey: 'liquid_0',
        essenceCost: 0,
        currencyType: 'essence',
        rarity: 'common',
        purchased: true,
      ),
      ShopItemModel(
        itemId: 'liquid_blue',
        name: 'Blue Liquid',
        category: 'liquid',
        assetKey: 'liquid_1',
        essenceCost: 30,
        currencyType: 'essence',
        rarity: 'common',
      ),
      ShopItemModel(
        itemId: 'liquid_teal',
        name: 'Teal Liquid',
        category: 'liquid',
        assetKey: 'liquid_2',
        essenceCost: 30,
        currencyType: 'essence',
        rarity: 'common',
      ),
      ShopItemModel(
        itemId: 'liquid_green',
        name: 'Green Liquid',
        category: 'liquid',
        assetKey: 'liquid_3',
        essenceCost: 30,
        currencyType: 'essence',
        rarity: 'common',
      ),
      ShopItemModel(
        itemId: 'liquid_gold',
        name: 'Gold Liquid',
        category: 'liquid',
        assetKey: 'liquid_5',
        essenceCost: 80,
        currencyType: 'essence',
        rarity: 'uncommon',
      ),
      ShopItemModel(
        itemId: 'liquid_coral',
        name: 'Coral Liquid',
        category: 'liquid',
        assetKey: 'liquid_4',
        coinCost: 30,
        currencyType: 'coins',
        rarity: 'rare',
      ),
      ShopItemModel(
        itemId: 'liquid_pink',
        name: 'Pink Liquid',
        category: 'liquid',
        assetKey: 'liquid_6',
        coinCost: 30,
        currencyType: 'coins',
        rarity: 'rare',
      ),

      // === EFFECTS ===
      ShopItemModel(
        itemId: 'effect_glow',
        name: 'Gentle Glow',
        category: 'effect',
        assetKey: 'effect_glow',
        essenceCost: 100,
        currencyType: 'essence',
        rarity: 'uncommon',
      ),
      ShopItemModel(
        itemId: 'effect_sparkles',
        name: 'Sparkles',
        category: 'effect',
        assetKey: 'effect_sparkles',
        essenceCost: 150,
        currencyType: 'essence',
        rarity: 'rare',
      ),
      ShopItemModel(
        itemId: 'effect_smoke',
        name: 'Smoke',
        category: 'effect',
        assetKey: 'effect_smoke',
        coinCost: 60,
        currencyType: 'coins',
        rarity: 'epic',
      ),
      ShopItemModel(
        itemId: 'effect_legendary_glow',
        name: 'Legendary Aura',
        category: 'effect',
        assetKey: 'effect_legendary_glow',
        coinCost: 100,
        currencyType: 'coins',
        rarity: 'legendary',
      ),

      // === BACKGROUNDS ===
      ShopItemModel(
        itemId: 'theme_default',
        name: 'Dark Gradient',
        category: 'background',
        assetKey: 'theme_default',
        essenceCost: 0,
        currencyType: 'essence',
        rarity: 'common',
        purchased: true,
      ),
      ShopItemModel(
        itemId: 'theme_parchment',
        name: 'Parchment',
        category: 'background',
        assetKey: 'theme_parchment',
        essenceCost: 0,
        currencyType: 'essence',
        rarity: 'common',
        purchased: true,
      ),
      ShopItemModel(
        itemId: 'theme_forest',
        name: 'Enchanted Forest',
        category: 'background',
        assetKey: 'theme_forest',
        coinCost: 80,
        currencyType: 'coins',
        rarity: 'rare',
      ),
      ShopItemModel(
        itemId: 'theme_night_sky',
        name: 'Night Sky',
        category: 'background',
        assetKey: 'theme_night_sky',
        coinCost: 80,
        currencyType: 'coins',
        rarity: 'rare',
      ),
      ShopItemModel(
        itemId: 'theme_alchemy_lab',
        name: 'Alchemy Lab',
        category: 'background',
        assetKey: 'theme_alchemy_lab',
        coinCost: 100,
        currencyType: 'coins',
        rarity: 'epic',
      ),
      ShopItemModel(
        itemId: 'theme_ocean_depths',
        name: 'Ocean Depths',
        category: 'background',
        assetKey: 'theme_ocean_depths',
        coinCost: 100,
        currencyType: 'coins',
        rarity: 'epic',
      ),
    ];

    await _isar!.writeTxn(() async {
      for (final item in defaultItems) {
        await _isar!.shopItemModels.put(item);
      }
    });
  }

  static Future<void> _initializeRecipes() async {
    final recipesCount = await _isar!.recipeModels.count();
    if (recipesCount > 0) return;

    final defaultRecipes = [
      RecipeModel(
        recipeId: 'recipe_first_brew',
        name: 'First Brew',
        unlockCondition: '{"type": "potion_count", "value": 1}',
        rewardType: 'liquid',
        rewardAssetKey: 'liquid_2',
        rarity: 'common',
        lore: 'Every alchemist remembers their first potion. A simple brew, yet profound in meaning.',
      ),
      RecipeModel(
        recipeId: 'recipe_scholar_elixir',
        name: "Scholar's Elixir",
        unlockCondition: '{"type": "tag_time", "tag": "studying", "minutes": 300}',
        rewardType: 'bottle',
        rewardAssetKey: 'bottle_flask',
        rarity: 'uncommon',
        lore: 'Through focused study, the mind becomes a vessel for knowledge.',
      ),
      RecipeModel(
        recipeId: 'recipe_consistency_brew',
        name: 'Consistency Brew',
        unlockCondition: '{"type": "streak", "days": 7}',
        rewardType: 'effect',
        rewardAssetKey: 'effect_glow',
        rarity: 'rare',
        lore: 'Consistency is the most powerful magic. Seven days of showing up.',
      ),
      RecipeModel(
        recipeId: 'recipe_midnight_oil',
        name: 'Midnight Oil',
        unlockCondition: '{"type": "time_of_day", "after": "22:00", "sessions": 10}',
        rewardType: 'liquid',
        rewardAssetKey: 'liquid_7',
        rarity: 'rare',
        lore: 'When the world sleeps, the night owls brew.',
      ),
      RecipeModel(
        recipeId: 'recipe_legendary_alchemist',
        name: 'Legendary Alchemist',
        unlockCondition: '{"type": "rarity_count", "rarity": "legendary", "count": 3}',
        rewardType: 'bottle',
        rewardAssetKey: 'bottle_legendary',
        rarity: 'legendary',
        lore: 'Only the most dedicated alchemists achieve this. Three legendary potions, proof of mastery.',
      ),
      // New recipes
      RecipeModel(
        recipeId: 'recipe_marathon_brewer',
        name: 'Marathon Brewer',
        unlockCondition: '{"type": "total_time", "minutes": 600}',
        rewardType: 'effect',
        rewardAssetKey: 'effect_sparkles',
        rarity: 'uncommon',
        lore: 'Ten hours of focus is no small feat. Your persistence sparkles.',
      ),
      RecipeModel(
        recipeId: 'recipe_collectors_pride',
        name: "Collector's Pride",
        unlockCondition: '{"type": "potion_count", "value": 25}',
        rewardType: 'bottle',
        rewardAssetKey: 'bottle_potion',
        rarity: 'rare',
        lore: 'Twenty-five potions line your shelves. A true collector.',
      ),
      RecipeModel(
        recipeId: 'recipe_code_wizard',
        name: 'Code Wizard',
        unlockCondition: '{"type": "tag_time", "tag": "coding", "minutes": 500}',
        rewardType: 'liquid',
        rewardAssetKey: 'liquid_3',
        rarity: 'rare',
        lore: 'Lines of code become spells. The screen glows with your creations.',
      ),
      RecipeModel(
        recipeId: 'recipe_early_bird',
        name: 'Early Bird Elixir',
        unlockCondition: '{"type": "total_time", "minutes": 1500}',
        rewardType: 'effect',
        rewardAssetKey: 'effect_smoke',
        rarity: 'epic',
        lore: 'Twenty-five hours of focused alchemy. Your dedication rises like morning mist.',
      ),
      RecipeModel(
        recipeId: 'recipe_centurion',
        name: 'The Centurion',
        unlockCondition: '{"type": "potion_count", "value": 100}',
        rewardType: 'bottle',
        rewardAssetKey: 'bottle_diamond',
        rarity: 'epic',
        lore: 'One hundred potions. Each one a chapter in your alchemical journey.',
      ),
    ];

    await _isar!.writeTxn(() async {
      for (final recipe in defaultRecipes) {
        await _isar!.recipeModels.put(recipe);
      }
    });
  }

  static Future<void> _initializeUnlockables() async {
    final count = await _isar!.unlockableModels.count();
    if (count > 0) return;

    final defaults = [
      UnlockableModel(
        unlockableId: 'style_dawn_brew',
        name: 'Dawn Brew',
        description: 'A warm golden potion brewed in the early hours.',
        unlockCondition: '{"type": "time_of_day", "after": "05:00", "before": "08:00", "sessions": 5}',
        rewardVisualConfig: '{"bottle": "bottle_round", "liquid": "liquid_5", "effect": "effect_glow", "rarity": "uncommon"}',
        rarity: 'uncommon',
      ),
      UnlockableModel(
        unlockableId: 'style_night_owl',
        name: 'Night Owl',
        description: 'A deep midnight brew for the late-night focused.',
        unlockCondition: '{"type": "time_of_day", "after": "23:00", "sessions": 10}',
        rewardVisualConfig: '{"bottle": "bottle_tall", "liquid": "liquid_7", "effect": "effect_sparkles", "rarity": "rare"}',
        rarity: 'rare',
      ),
      UnlockableModel(
        unlockableId: 'style_scholars_blend',
        name: "Scholar's Blend",
        description: 'A cerebral concoction earned through diligent study.',
        unlockCondition: '{"type": "tag_mastery", "tag": "studying", "minutes": 600}',
        rewardVisualConfig: '{"bottle": "bottle_flask", "liquid": "liquid_1", "effect": "effect_glow", "rarity": "rare"}',
        rarity: 'rare',
      ),
      UnlockableModel(
        unlockableId: 'style_coders_elixir',
        name: "Coder's Elixir",
        description: 'Digital alchemy. Code is your spell.',
        unlockCondition: '{"type": "tag_mastery", "tag": "coding", "minutes": 600}',
        rewardVisualConfig: '{"bottle": "bottle_tall", "liquid": "liquid_3", "effect": "effect_sparkles", "rarity": "rare"}',
        rarity: 'rare',
      ),
      UnlockableModel(
        unlockableId: 'style_endurance_brew',
        name: 'Endurance Brew',
        description: 'Earned by completing a 90-minute focus session.',
        unlockCondition: '{"type": "session_duration", "minutes": 90}',
        rewardVisualConfig: '{"bottle": "bottle_potion", "liquid": "liquid_4", "effect": "effect_smoke", "rarity": "epic"}',
        rarity: 'epic',
      ),
      UnlockableModel(
        unlockableId: 'style_centurion',
        name: 'Centurion Potion',
        description: 'Brew 100 potions to master this ancient recipe.',
        unlockCondition: '{"type": "potion_count", "value": 100}',
        rewardVisualConfig: '{"bottle": "bottle_legendary", "liquid": "liquid_5", "effect": "effect_legendary_glow", "rarity": "legendary"}',
        rarity: 'legendary',
      ),
      UnlockableModel(
        unlockableId: 'style_streak_master',
        name: 'Streak Master',
        description: 'A 14-day streak reveals this golden recipe.',
        unlockCondition: '{"type": "streak", "days": 14}',
        rewardVisualConfig: '{"bottle": "bottle_gourd", "liquid": "liquid_5", "effect": "effect_smoke", "rarity": "epic"}',
        rarity: 'epic',
      ),
      UnlockableModel(
        unlockableId: 'style_first_step',
        name: 'First Step',
        description: 'Your very first brew.',
        unlockCondition: '{"type": "potion_count", "value": 1}',
        rewardVisualConfig: '{"bottle": "bottle_round", "liquid": "liquid_0", "effect": "none", "rarity": "common"}',
        rarity: 'common',
        unlocked: true,
      ),
      UnlockableModel(
        unlockableId: 'style_dedicated',
        name: 'Dedicated Brewer',
        description: 'Brew 10 potions.',
        unlockCondition: '{"type": "potion_count", "value": 10}',
        rewardVisualConfig: '{"bottle": "bottle_tall", "liquid": "liquid_2", "effect": "effect_glow", "rarity": "uncommon"}',
        rarity: 'uncommon',
      ),
      UnlockableModel(
        unlockableId: 'style_focused_mind',
        name: 'Focused Mind',
        description: 'Accumulate 5 hours of total focus time.',
        unlockCondition: '{"type": "total_time", "minutes": 300}',
        rewardVisualConfig: '{"bottle": "bottle_flask", "liquid": "liquid_6", "effect": "effect_sparkles", "rarity": "rare"}',
        rarity: 'rare',
      ),
      UnlockableModel(
        unlockableId: 'style_writing_muse',
        name: 'Writing Muse',
        description: 'Focus 500 minutes with the writing tag.',
        unlockCondition: '{"type": "tag_mastery", "tag": "writing", "minutes": 500}',
        rewardVisualConfig: '{"bottle": "bottle_heart", "liquid": "liquid_6", "effect": "effect_glow", "rarity": "rare"}',
        rarity: 'rare',
      ),
      UnlockableModel(
        unlockableId: 'style_rare_collector',
        name: 'Rare Collector',
        description: 'Collect 5 rare potions.',
        unlockCondition: '{"type": "rarity_collection", "rarity": "rare", "count": 5}',
        rewardVisualConfig: '{"bottle": "bottle_diamond", "liquid": "liquid_1", "effect": "effect_sparkles", "rarity": "epic"}',
        rarity: 'epic',
      ),
    ];

    await _isar!.writeTxn(() async {
      for (final item in defaults) {
        await _isar!.unlockableModels.put(item);
      }
    });
  }

  static Future<void> close() async {
    await _isar?.close();
    _isar = null;
  }
}
