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

    await _ensureUserData();
    await _ensureSubscription();
    await _initializeShopItems();
    await _initializeRecipes();
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
        await _isar!.userDataModels.put(UserDataModel(
          essenceBalance: 0,
          coinBalance: 0,
        ));
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
    if (shopItemsCount > 0) return;

    final defaultItems = [
      // ═══════════════════════════════════
      // BOTTLES (Free / Essence)
      // ═══════════════════════════════════
      ShopItemModel(
        itemId: 'bottle_round',
        name: 'Round Flask',
        category: 'bottle',
        assetKey: 'bottle_round',
        essenceCost: 0,
        currencyType: 'essence',
        rarity: 'common',
        description: 'A humble flask of smooth glass — the classic vessel for any budding alchemist.',
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
        description: 'Slender and elegant, this vial catches the light like a shard of crystal.',
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
        description: 'Favored by scholars. Its wide base holds knowledge; its narrow neck focuses intent.',
      ),
      ShopItemModel(
        itemId: 'bottle_potion',
        name: 'Classic Potion',
        category: 'bottle',
        assetKey: 'bottle_potion',
        essenceCost: 150,
        currencyType: 'essence',
        rarity: 'rare',
        description: 'The iconic shape, passed down through generations of potioneers.',
      ),

      // ═══════════════════════════════════
      // BOTTLES (Premium / Coins)
      // ═══════════════════════════════════
      ShopItemModel(
        itemId: 'bottle_heart',
        name: 'Heart Vial',
        category: 'bottle',
        assetKey: 'bottle_heart',
        coinCost: 50,
        currencyType: 'coins',
        rarity: 'rare',
        description: 'Shaped by devotion itself. Each brew within carries a whisper of affection.',
      ),
      ShopItemModel(
        itemId: 'bottle_diamond',
        name: 'Diamond Flask',
        category: 'bottle',
        assetKey: 'bottle_diamond',
        coinCost: 75,
        currencyType: 'coins',
        rarity: 'epic',
        description: 'Cut from crystallized starlight. Its facets refract the essence within.',
      ),
      ShopItemModel(
        itemId: 'bottle_gourd',
        name: 'Gourd Bottle',
        category: 'bottle',
        assetKey: 'bottle_gourd',
        coinCost: 60,
        currencyType: 'coins',
        rarity: 'rare',
        description: 'An ancient vessel, grown in enchanted gardens and hollowed by moonlight.',
      ),
      ShopItemModel(
        itemId: 'bottle_legendary',
        name: 'Ornate Bottle',
        category: 'bottle',
        assetKey: 'bottle_legendary',
        coinCost: 120,
        currencyType: 'coins',
        rarity: 'legendary',
        description: 'A masterwork of arcane glassblowing. Its crown stopper hums with dormant power.',
      ),

      // ═══════════════════════════════════
      // BOTTLES (Subscriber Exclusive)
      // ═══════════════════════════════════
      ShopItemModel(
        itemId: 'bottle_celestial',
        name: 'Celestial Vessel',
        category: 'bottle',
        assetKey: 'bottle_celestial',
        currencyType: 'subscriber_only',
        rarity: 'legendary',
        description: 'Forged in the heart of a dying star. Its glass shifts between dimensions, holding brews that transcend time itself.',
      ),
      ShopItemModel(
        itemId: 'bottle_starforged',
        name: 'Starforged Vial',
        category: 'bottle',
        assetKey: 'bottle_starforged',
        currencyType: 'subscriber_only',
        rarity: 'epic',
        description: 'Hammered from fallen meteors by cosmic smiths. Each facet captures a different constellation.',
      ),

      // ═══════════════════════════════════
      // BACKGROUNDS
      // ═══════════════════════════════════
      ShopItemModel(
        itemId: 'theme_default',
        name: 'Midnight Veil',
        category: 'background',
        assetKey: 'theme_default',
        essenceCost: 0,
        currencyType: 'essence',
        rarity: 'common',
        description: 'The deep blue darkness where all alchemy begins.',
        purchased: true,
      ),
      ShopItemModel(
        itemId: 'theme_parchment',
        name: 'Ancient Parchment',
        category: 'background',
        assetKey: 'theme_parchment',
        essenceCost: 0,
        currencyType: 'essence',
        rarity: 'common',
        description: 'Warm and weathered, like the pages of a well-loved grimoire.',
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
        description: 'Brew beneath a canopy of whispering leaves and emerald light.',
      ),
      ShopItemModel(
        itemId: 'theme_night_sky',
        name: 'Night Sky',
        category: 'background',
        assetKey: 'theme_night_sky',
        coinCost: 80,
        currencyType: 'coins',
        rarity: 'rare',
        description: 'A thousand twinkling stars witness your craft from above.',
      ),
      ShopItemModel(
        itemId: 'theme_alchemy_lab',
        name: 'Alchemy Lab',
        category: 'background',
        assetKey: 'theme_alchemy_lab',
        coinCost: 100,
        currencyType: 'coins',
        rarity: 'epic',
        description: 'The amber warmth of a master alchemist\'s workshop, shelves lined with wonder.',
      ),
      ShopItemModel(
        itemId: 'theme_ocean_depths',
        name: 'Ocean Depths',
        category: 'background',
        assetKey: 'theme_ocean_depths',
        coinCost: 100,
        currencyType: 'coins',
        rarity: 'epic',
        description: 'Brew in the serene pressure of the deep, where bubbles carry your thoughts upward.',
      ),
      // New themes
      ShopItemModel(
        itemId: 'theme_crystal_cave',
        name: 'Crystal Cavern',
        category: 'background',
        assetKey: 'theme_crystal_cave',
        coinCost: 120,
        currencyType: 'coins',
        rarity: 'epic',
        description: 'Amethyst shards hum with resonance in this hidden underground sanctuary.',
      ),
      ShopItemModel(
        itemId: 'theme_mystic_garden',
        name: 'Mystic Garden',
        category: 'background',
        assetKey: 'theme_mystic_garden',
        coinCost: 90,
        currencyType: 'coins',
        rarity: 'rare',
        description: 'Petals drift on an eternal breeze through this enchanted grove.',
      ),
      ShopItemModel(
        itemId: 'theme_starfall',
        name: 'Starfall',
        category: 'background',
        assetKey: 'theme_starfall',
        coinCost: 150,
        currencyType: 'coins',
        rarity: 'legendary',
        description: 'Shooting stars streak across the indigo firmament — make a wish with every brew.',
      ),
      ShopItemModel(
        itemId: 'theme_ancient_library',
        name: 'Ancient Library',
        category: 'background',
        assetKey: 'theme_ancient_library',
        coinCost: 110,
        currencyType: 'coins',
        rarity: 'epic',
        description: 'Towering shelves of forgotten tomes surround you with the scent of old wisdom.',
      ),

      // ═══════════════════════════════════
      // BACKGROUNDS (Subscriber Exclusive)
      // ═══════════════════════════════════
      ShopItemModel(
        itemId: 'theme_aurora',
        name: 'Aurora Borealis',
        category: 'background',
        assetKey: 'theme_aurora',
        currencyType: 'subscriber_only',
        rarity: 'legendary',
        description: 'Ribbons of celestial light dance across the arctic sky. Brew beneath the northern lights, where magic is most potent.',
      ),
      ShopItemModel(
        itemId: 'theme_cosmic_void',
        name: 'Cosmic Void',
        category: 'background',
        assetKey: 'theme_cosmic_void',
        currencyType: 'subscriber_only',
        rarity: 'epic',
        description: 'The infinite darkness between galaxies. Here, in the void, your focus becomes absolute — nothing distracts, nothing exists but the brew.',
      ),
      ShopItemModel(
        itemId: 'theme_enchanted_hearth',
        name: 'Enchanted Hearth',
        category: 'background',
        assetKey: 'theme_enchanted_hearth',
        currencyType: 'subscriber_only',
        rarity: 'rare',
        description: 'A cozy witch\'s cottage with a crackling magical fireplace. Warm, inviting, and infused with ancient protection spells.',
      ),

      // ═══════════════════════════════════
      // LIQUIDS (Essence — F2P progression)
      // ═══════════════════════════════════
      ShopItemModel(
        itemId: 'liquid_twilight_essence',
        name: 'Twilight Essence',
        category: 'liquid',
        assetKey: 'liquid_0',
        essenceCost: 50,
        currencyType: 'essence',
        rarity: 'common',
        description: 'The quiet hue of dusk distilled into liquid form. A dependable base for any brew.',
      ),
      ShopItemModel(
        itemId: 'liquid_azure_depths',
        name: 'Azure Depths',
        category: 'liquid',
        assetKey: 'liquid_1',
        essenceCost: 50,
        currencyType: 'essence',
        rarity: 'common',
        description: 'Deep ocean blue captured in a vial. Cool, calm, and endlessly deep.',
      ),
      ShopItemModel(
        itemId: 'liquid_emerald_tide',
        name: 'Emerald Tide',
        category: 'liquid',
        assetKey: 'liquid_2',
        essenceCost: 75,
        currencyType: 'essence',
        rarity: 'uncommon',
        description: 'Green as a forest canopy at midday. This liquid pulses with natural energy.',
      ),
      ShopItemModel(
        itemId: 'liquid_crimson_ember',
        name: 'Crimson Ember',
        category: 'liquid',
        assetKey: 'liquid_4',
        essenceCost: 100,
        currencyType: 'essence',
        rarity: 'uncommon',
        description: 'A smoldering red that never quite cools. Handle with intent.',
      ),
      ShopItemModel(
        itemId: 'liquid_golden_dawn',
        name: 'Golden Dawn',
        category: 'liquid',
        assetKey: 'liquid_5',
        essenceCost: 125,
        currencyType: 'essence',
        rarity: 'rare',
        description: 'Captured from the first light of sunrise. Warm, hopeful, and radiant.',
      ),
      ShopItemModel(
        itemId: 'liquid_violet_dusk',
        name: 'Violet Dusk',
        category: 'liquid',
        assetKey: 'liquid_6',
        essenceCost: 150,
        currencyType: 'essence',
        rarity: 'rare',
        description: 'The last color before nightfall. Rich, mysterious, and contemplative.',
      ),

      // ═══════════════════════════════════
      // EFFECTS (Essence — F2P progression)
      // ═══════════════════════════════════
      ShopItemModel(
        itemId: 'effect_glow_item',
        name: 'Glow Effect',
        category: 'effect',
        assetKey: 'effect_glow',
        essenceCost: 75,
        currencyType: 'essence',
        rarity: 'uncommon',
        description: 'A subtle luminescence that makes any potion shine from within.',
      ),
      ShopItemModel(
        itemId: 'effect_sparkle_item',
        name: 'Sparkle Effect',
        category: 'effect',
        assetKey: 'effect_sparkles',
        essenceCost: 100,
        currencyType: 'essence',
        rarity: 'rare',
        description: 'Tiny points of light dance around your brew like captured starlight.',
      ),
      ShopItemModel(
        itemId: 'effect_shimmer_item',
        name: 'Shimmer Effect',
        category: 'effect',
        assetKey: 'effect_smoke',
        essenceCost: 150,
        currencyType: 'essence',
        rarity: 'epic',
        description: 'Wisps of ethereal smoke rise from your potion, carrying whispers of power.',
      ),

      // ═══════════════════════════════════
      // EFFECTS (Subscriber Exclusive)
      // ═══════════════════════════════════
      ShopItemModel(
        itemId: 'effect_cosmic_trail',
        name: 'Cosmic Trail',
        category: 'effect',
        assetKey: 'effect_legendary_glow',
        currencyType: 'subscriber_only',
        rarity: 'legendary',
        description: 'A trail of cosmic particles orbits your brew, bending light and time around it.',
      ),
      ShopItemModel(
        itemId: 'effect_ethereal_glow',
        name: 'Ethereal Glow',
        category: 'effect',
        assetKey: 'effect_legendary_glow',
        currencyType: 'subscriber_only',
        rarity: 'epic',
        description: 'An otherworldly luminescence that transcends the physical realm.',
      ),

      // ═══════════════════════════════════
      // BACKGROUNDS (moved to Essence from Coins for F2P balance)
      // ═══════════════════════════════════
      ShopItemModel(
        itemId: 'theme_forest_essence',
        name: 'Enchanted Forest',
        category: 'background',
        assetKey: 'theme_forest',
        essenceCost: 200,
        currencyType: 'essence',
        rarity: 'rare',
        description: 'Brew beneath a canopy of whispering leaves and emerald light. (Essence Edition)',
      ),
      ShopItemModel(
        itemId: 'theme_night_sky_essence',
        name: 'Night Sky',
        category: 'background',
        assetKey: 'theme_night_sky',
        essenceCost: 200,
        currencyType: 'essence',
        rarity: 'rare',
        description: 'A thousand twinkling stars witness your craft from above. (Essence Edition)',
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
      // ═══════════════════════════════════════
      // LIQUID RECIPES — Common (4)
      // ═══════════════════════════════════════
      RecipeModel(
        recipeId: 'recipe_twilight_essence',
        name: 'Twilight Essence',
        unlockCondition: '{"type": "total_time", "minutes": 10}',
        rewardType: 'liquid',
        rewardAssetKey: 'liquid_0',
        rarity: 'common',
        lore: 'The first color any alchemist learns to coax from silence — ten minutes of stillness, and twilight bleeds into the glass.',
      ),
      RecipeModel(
        recipeId: 'recipe_azure_depths',
        name: 'Azure Depths',
        unlockCondition: '{"type": "potion_count", "value": 1}',
        rewardType: 'liquid',
        rewardAssetKey: 'liquid_1',
        rarity: 'common',
        lore: 'Your first brew. Trembling hands, uncertain flame, and a single shimmering drop of blue. This is where every journey begins.',
      ),
      RecipeModel(
        recipeId: 'recipe_emerald_tide',
        name: 'Emerald Tide',
        unlockCondition: '{"type": "potion_count", "value": 3}',
        rewardType: 'liquid',
        rewardAssetKey: 'liquid_2',
        rarity: 'common',
        lore: 'Three potions in, the cauldron remembers your touch. The teal deepens, the craft steadies.',
      ),
      RecipeModel(
        recipeId: 'recipe_hearthglow',
        name: 'Hearthglow',
        unlockCondition: '{"type": "total_time", "minutes": 30}',
        rewardType: 'liquid',
        rewardAssetKey: 'liquid_3',
        rarity: 'common',
        lore: 'Half an hour of patience yields warmth itself — green as a hearth flame, gentle as a whispered promise.',
      ),

      // ═══════════════════════════════════════
      // LIQUID RECIPES — Uncommon (5)
      // ═══════════════════════════════════════
      RecipeModel(
        recipeId: 'recipe_crimson_ember',
        name: 'Crimson Ember',
        unlockCondition: '{"type": "potion_count", "value": 5}',
        rewardType: 'liquid',
        rewardAssetKey: 'liquid_4',
        rarity: 'uncommon',
        lore: 'Five flames lit, five intentions set. The red of this brew shifts like embers, never quite still, never quite tame.',
      ),
      RecipeModel(
        recipeId: 'recipe_liquid_sunlight',
        name: 'Liquid Sunlight',
        unlockCondition: '{"type": "time_of_day", "after": "05:00", "before": "07:00", "sessions": 3}',
        rewardType: 'liquid',
        rewardAssetKey: 'liquid_5',
        rarity: 'uncommon',
        lore: 'Before the world stirs, you are already at work. The golden light of dawn lives in this vial — warm, hopeful, alive.',
      ),
      RecipeModel(
        recipeId: 'recipe_lavender_mist',
        name: 'Lavender Mist',
        unlockCondition: '{"type": "streak", "days": 3}',
        rewardType: 'liquid',
        rewardAssetKey: 'liquid_6',
        rarity: 'uncommon',
        lore: 'Three days without faltering. A soft purple haze rises from the brew — the color of discipline just beginning to bloom.',
      ),
      RecipeModel(
        recipeId: 'recipe_amber_dew',
        name: 'Amber Dew',
        unlockCondition: '{"type": "total_time", "minutes": 120}',
        rewardType: 'liquid',
        rewardAssetKey: 'liquid_7',
        rarity: 'uncommon',
        lore: 'Two hours of accumulated silence. Amber pools at the bottom of the flask, rich with the weight of time well spent.',
      ),
      RecipeModel(
        recipeId: 'recipe_jade_whisper',
        name: 'Jade Whisper',
        unlockCondition: '{"type": "potion_count", "value": 10}',
        rewardType: 'liquid',
        rewardAssetKey: 'liquid_8',
        rarity: 'uncommon',
        lore: 'Ten brews deep, and the cauldron speaks back. This jade elixir carries the quiet confidence of a practiced hand.',
      ),

      // ═══════════════════════════════════════
      // LIQUID RECIPES — Rare (5)
      // ═══════════════════════════════════════
      RecipeModel(
        recipeId: 'recipe_roseveil',
        name: 'Roseveil Draught',
        unlockCondition: '{"type": "potion_count", "value": 20}',
        rewardType: 'liquid',
        rewardAssetKey: 'liquid_9',
        rarity: 'rare',
        lore: 'Twenty potions line your shelf, and something new emerges — pink as the first blush of a rose, delicate yet undeniable.',
      ),
      RecipeModel(
        recipeId: 'recipe_midnight_oil',
        name: 'Midnight Oil',
        unlockCondition: '{"type": "time_of_day", "after": "22:00", "sessions": 10}',
        rewardType: 'liquid',
        rewardAssetKey: 'liquid_10',
        rarity: 'rare',
        lore: 'When the world sleeps, you work. Ten midnight sessions yield this violet draught that glows faintly in darkness.',
      ),
      RecipeModel(
        recipeId: 'recipe_frostbloom',
        name: 'Frostbloom Nectar',
        unlockCondition: '{"type": "session_duration", "minutes": 45}',
        rewardType: 'liquid',
        rewardAssetKey: 'liquid_11',
        rarity: 'rare',
        lore: 'Forty-five unbroken minutes — the threshold where distraction dies and true concentration crystallizes like frost on glass.',
      ),
      RecipeModel(
        recipeId: 'recipe_oceans_memory',
        name: "Ocean's Memory",
        unlockCondition: '{"type": "streak", "days": 7}',
        rewardType: 'liquid',
        rewardAssetKey: 'liquid_12',
        rarity: 'rare',
        lore: 'Seven days, seven tides. Consistency pulls you deeper into the craft, and this blue carries the weight of the deep.',
      ),
      RecipeModel(
        recipeId: 'recipe_autumn_blaze',
        name: 'Autumn Blaze',
        unlockCondition: '{"type": "time_of_day", "after": "17:00", "before": "19:00", "sessions": 5}',
        rewardType: 'liquid',
        rewardAssetKey: 'liquid_13',
        rarity: 'rare',
        lore: 'Brewed in the golden hour, when shadows stretch long and the day surrenders. Five sunset sessions yield fire in a bottle.',
      ),

      // ═══════════════════════════════════════
      // LIQUID RECIPES — Epic (4)
      // ═══════════════════════════════════════
      RecipeModel(
        recipeId: 'recipe_dragons_blood',
        name: "Dragon's Blood",
        unlockCondition: '{"type": "compound", "conditions": [{"type": "potion_count", "value": 50}, {"type": "total_time", "minutes": 500}]}',
        rewardType: 'liquid',
        rewardAssetKey: 'liquid_14',
        rarity: 'epic',
        lore: 'Fifty brews and five hundred minutes of fire. The cauldron runs red — not with anger, but with the fierce patience of something ancient waking.',
      ),
      RecipeModel(
        recipeId: 'recipe_starweavers_ink',
        name: "Starweaver's Ink",
        unlockCondition: '{"type": "compound", "conditions": [{"type": "streak", "days": 14}, {"type": "potion_count", "value": 25}]}',
        rewardType: 'liquid',
        rewardAssetKey: 'liquid_15',
        rarity: 'epic',
        lore: 'A fortnight\'s devotion and twenty-five bottles strong. The ink of the starweavers drips slow, dark as the space between constellations, flecked with gold.',
      ),
      RecipeModel(
        recipeId: 'recipe_phantom_mist',
        name: 'Phantom Mist',
        unlockCondition: '{"type": "compound", "conditions": [{"type": "time_of_day", "after": "00:00", "before": "03:00", "sessions": 15}, {"type": "potion_count", "value": 35}, {"type": "total_time", "minutes": 600}]}',
        rewardType: 'liquid',
        rewardAssetKey: 'liquid_16',
        rarity: 'epic',
        lore: 'Fifteen vigils between midnight and the witching hour, thirty-five brews deep, ten hours of silence. Only those who walk the boundary of waking and dreaming can distill this silver fog.',
      ),
      RecipeModel(
        recipeId: 'recipe_molten_core',
        name: 'Molten Core',
        unlockCondition: '{"type": "compound", "conditions": [{"type": "session_duration", "minutes": 120}, {"type": "potion_count", "value": 40}, {"type": "streak", "days": 10}]}',
        rewardType: 'liquid',
        rewardAssetKey: 'liquid_17',
        rarity: 'epic',
        lore: 'Two hours of unbroken will, forty brews forged, ten days of relentless flame. What remains is not patience — it is something molten, something that refuses to cool.',
      ),

      // ═══════════════════════════════════════
      // LIQUID RECIPES — Legendary (3)
      // ═══════════════════════════════════════
      RecipeModel(
        recipeId: 'recipe_phoenix_tears',
        name: 'Phoenix Tears',
        unlockCondition: '{"type": "compound", "conditions": [{"type": "streak", "days": 30}, {"type": "potion_count", "value": 100}, {"type": "total_time", "minutes": 3000}]}',
        rewardType: 'liquid',
        rewardAssetKey: 'liquid_18',
        rarity: 'legendary',
        lore: 'A month of unbroken fire, a hundred potions, three thousand minutes of absolute devotion. The phoenix does not weep for the weak — these tears are for the relentless.',
      ),
      RecipeModel(
        recipeId: 'recipe_void_ichor',
        name: 'Void Ichor',
        unlockCondition: '{"type": "compound", "conditions": [{"type": "potion_count", "value": 200}, {"type": "streak", "days": 50}]}',
        rewardType: 'liquid',
        rewardAssetKey: 'liquid_19',
        rarity: 'legendary',
        lore: 'Two hundred brews. Fifty days of flame that never died. From the void between stars comes this — not light, not dark, but the space where intention becomes infinite.',
      ),
      RecipeModel(
        recipeId: 'recipe_celestial_ambrosia',
        name: 'Celestial Ambrosia',
        unlockCondition: '{"type": "compound", "conditions": [{"type": "session_duration", "minutes": 120}, {"type": "rarity_count", "rarity": "legendary", "count": 5}, {"type": "total_time", "minutes": 5000}]}',
        rewardType: 'liquid',
        rewardAssetKey: 'liquid_20',
        rarity: 'legendary',
        lore: 'Two hours of unbroken focus. Five legendary potions. Five thousand minutes of accumulated mastery. The gods do not share their nectar lightly — but you have earned your seat at the table.',
      ),

      // ═══════════════════════════════════════
      // EFFECT RECIPES (kept from original)
      // ═══════════════════════════════════════
      RecipeModel(
        recipeId: 'recipe_marathon_brewer',
        name: 'Marathon Brewer',
        unlockCondition: '{"type": "total_time", "minutes": 600}',
        rewardType: 'effect',
        rewardAssetKey: 'effect_sparkles',
        rarity: 'uncommon',
        lore: 'Ten hours of focus is no small feat. Your cauldron hums with accumulated intention, and tiny sparks of magic begin to dance.',
      ),
      RecipeModel(
        recipeId: 'recipe_consistency_brew',
        name: 'Consistency Brew',
        unlockCondition: '{"type": "streak", "days": 7}',
        rewardType: 'effect',
        rewardAssetKey: 'effect_glow',
        rarity: 'rare',
        lore: 'Seven days, seven brews, not one missed. Consistency is the quiet spell that transforms ordinary effort into something luminous.',
      ),
      RecipeModel(
        recipeId: 'recipe_rising_mist',
        name: 'Rising Mist',
        unlockCondition: '{"type": "compound", "conditions": [{"type": "total_time", "minutes": 2500}, {"type": "streak", "days": 14}, {"type": "potion_count", "value": 40}]}',
        rewardType: 'effect',
        rewardAssetKey: 'effect_smoke',
        rarity: 'epic',
        lore: 'Forty brews, two weeks unbroken, forty hours of silence. Your dedication rises like morning mist from a forest floor — quiet, persistent, and impossible to ignore.',
      ),
      RecipeModel(
        recipeId: 'recipe_ironwill_tonic',
        name: 'Ironwill Tonic',
        unlockCondition: '{"type": "compound", "conditions": [{"type": "session_duration", "minutes": 120}, {"type": "potion_count", "value": 30}]}',
        rewardType: 'effect',
        rewardAssetKey: 'effect_smoke',
        rarity: 'epic',
        lore: 'Two hours of unbroken resolve and thirty brews behind you. The iron in your will has tempered into something unshakable, and this brew carries its weight.',
      ),
      RecipeModel(
        recipeId: 'recipe_eternal_ember',
        name: 'Eternal Ember',
        unlockCondition: '{"type": "streak", "days": 30}',
        rewardType: 'effect',
        rewardAssetKey: 'effect_legendary_glow',
        rarity: 'legendary',
        lore: 'Thirty days without faltering. You have kept the flame alive through storms, through doubt, through exhaustion. This ember will never die.',
      ),
      RecipeModel(
        recipeId: 'recipe_philosophers_flame',
        name: "Philosopher's Flame",
        unlockCondition: '{"type": "rarity_count", "rarity": "legendary", "count": 3}',
        rewardType: 'effect',
        rewardAssetKey: 'effect_legendary_glow',
        rarity: 'legendary',
        lore: 'Three legendary potions — the final proof. You have transmuted time itself into gold, and the philosopher\'s flame burns eternal in your hands.',
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
      // ═══════════════════════════════════
      // EASY (Common/Uncommon) — first few days
      // ═══════════════════════════════════
      UnlockableModel(
        unlockableId: 'style_first_step',
        name: 'First Step',
        description: 'The journey of a thousand potions begins with a single brew. Welcome, young alchemist.',
        unlockCondition: '{"type": "potion_count", "value": 1}',
        rewardVisualConfig: '{"bottle": "bottle_round", "liquid": "liquid_0", "effect": "none", "rarity": "common"}',
        rarity: 'common',
        unlocked: true,
      ),
      UnlockableModel(
        unlockableId: 'style_spark_of_intent',
        name: 'Spark of Intent',
        description: 'Thirty minutes of focus — enough to coax the first spark from an empty cauldron.',
        unlockCondition: '{"type": "total_time", "minutes": 30}',
        rewardVisualConfig: '{"bottle": "bottle_round", "liquid": "liquid_1", "effect": "none", "rarity": "common"}',
        rarity: 'common',
      ),
      UnlockableModel(
        unlockableId: 'style_budding_alchemist',
        name: 'Budding Alchemist',
        description: 'Five potions brewed. Your hands steady, your flame grows. The craft begins to feel familiar.',
        unlockCondition: '{"type": "potion_count", "value": 5}',
        rewardVisualConfig: '{"bottle": "bottle_round", "liquid": "liquid_2", "effect": "effect_glow", "rarity": "uncommon"}',
        rarity: 'uncommon',
      ),
      UnlockableModel(
        unlockableId: 'style_ember_kindled',
        name: 'Ember Kindled',
        description: 'Three days of unbroken focus. A small streak, but the ember is lit.',
        unlockCondition: '{"type": "streak", "days": 3}',
        rewardVisualConfig: '{"bottle": "bottle_tall", "liquid": "liquid_4", "effect": "none", "rarity": "uncommon"}',
        rarity: 'uncommon',
      ),
      UnlockableModel(
        unlockableId: 'style_dedicated',
        name: 'Dedicated Brewer',
        description: 'Ten potions line your shelf. You are no longer a novice — the craft has claimed you.',
        unlockCondition: '{"type": "potion_count", "value": 10}',
        rewardVisualConfig: '{"bottle": "bottle_tall", "liquid": "liquid_2", "effect": "effect_glow", "rarity": "uncommon"}',
        rarity: 'uncommon',
      ),

      // ═══════════════════════════════════
      // MEDIUM (Uncommon/Rare) — first few weeks
      // ═══════════════════════════════════
      UnlockableModel(
        unlockableId: 'style_dawn_brew',
        name: 'Dawn Brew',
        description: 'Brewed in the tender hours before sunrise, this golden potion carries the warmth of a new beginning.',
        unlockCondition: '{"type": "time_of_day", "after": "05:00", "before": "07:00", "sessions": 5}',
        rewardVisualConfig: '{"bottle": "bottle_round", "liquid": "liquid_5", "effect": "effect_glow", "rarity": "uncommon"}',
        rarity: 'uncommon',
      ),
      UnlockableModel(
        unlockableId: 'style_afternoon_clarity',
        name: 'Afternoon Clarity',
        description: 'When the sun is high, distractions are loudest — yet you brew on. This potion tastes of discipline.',
        unlockCondition: '{"type": "time_of_day", "after": "12:00", "before": "14:00", "sessions": 5}',
        rewardVisualConfig: '{"bottle": "bottle_flask", "liquid": "liquid_3", "effect": "effect_glow", "rarity": "uncommon"}',
        rarity: 'uncommon',
      ),
      UnlockableModel(
        unlockableId: 'style_fifteen_flames',
        name: 'Fifteen Flames',
        description: 'Fifteen potions, fifteen flames that refused to die. Your cauldron remembers each one.',
        unlockCondition: '{"type": "potion_count", "value": 15}',
        rewardVisualConfig: '{"bottle": "bottle_flask", "liquid": "liquid_4", "effect": "effect_glow", "rarity": "rare"}',
        rarity: 'rare',
      ),
      UnlockableModel(
        unlockableId: 'style_focused_mind',
        name: 'Focused Mind',
        description: 'Two hours of accumulated silence. The mind sharpens, and the brew within this flask reflects its clarity.',
        unlockCondition: '{"type": "total_time", "minutes": 120}',
        rewardVisualConfig: '{"bottle": "bottle_flask", "liquid": "liquid_6", "effect": "effect_sparkles", "rarity": "rare"}',
        rarity: 'rare',
      ),
      UnlockableModel(
        unlockableId: 'style_weekly_wanderer',
        name: 'Weekly Wanderer',
        description: 'Seven days of showing up. The path is long, but you have found your rhythm.',
        unlockCondition: '{"type": "streak", "days": 7}',
        rewardVisualConfig: '{"bottle": "bottle_tall", "liquid": "liquid_5", "effect": "effect_sparkles", "rarity": "rare"}',
        rarity: 'rare',
      ),
      UnlockableModel(
        unlockableId: 'style_deep_draught',
        name: 'Deep Draught',
        description: 'A thirty-minute session, unbroken and deep. This potion is brewed in the space between thought and silence.',
        unlockCondition: '{"type": "session_duration", "minutes": 30}',
        rewardVisualConfig: '{"bottle": "bottle_potion", "liquid": "liquid_1", "effect": "effect_glow", "rarity": "rare"}',
        rarity: 'rare',
      ),

      // ═══════════════════════════════════
      // HARD (Rare/Epic) — dedicated users
      // ═══════════════════════════════════
      UnlockableModel(
        unlockableId: 'style_twilight_alchemist',
        name: 'Twilight Alchemist',
        description: 'Between day and night, in the amber hour of twilight, your best work emerges. Five evening brews prove it.',
        unlockCondition: '{"type": "time_of_day", "after": "18:00", "before": "20:00", "sessions": 5}',
        rewardVisualConfig: '{"bottle": "bottle_potion", "liquid": "liquid_5", "effect": "effect_sparkles", "rarity": "rare"}',
        rarity: 'rare',
      ),
      UnlockableModel(
        unlockableId: 'style_night_owl',
        name: 'Night Owl',
        description: 'The world sleeps, but your flame burns. Ten midnight sessions reveal a potion as dark and deep as the hour itself.',
        unlockCondition: '{"type": "time_of_day", "after": "23:00", "sessions": 10}',
        rewardVisualConfig: '{"bottle": "bottle_tall", "liquid": "liquid_7", "effect": "effect_sparkles", "rarity": "rare"}',
        rarity: 'rare',
      ),
      UnlockableModel(
        unlockableId: 'style_forty_brews',
        name: 'Forty Brews',
        description: 'Forty potions. The shelves groan with your collection, and each bottle tells a story of quiet determination.',
        unlockCondition: '{"type": "potion_count", "value": 40}',
        rewardVisualConfig: '{"bottle": "bottle_heart", "liquid": "liquid_6", "effect": "effect_sparkles", "rarity": "epic"}',
        rarity: 'epic',
      ),
      UnlockableModel(
        unlockableId: 'style_deep_well',
        name: 'Deep Well',
        description: 'Eight hours of total focus. You have drawn from a well that most never find, and this potion carries its depth.',
        unlockCondition: '{"type": "total_time", "minutes": 480}',
        rewardVisualConfig: '{"bottle": "bottle_diamond", "liquid": "liquid_1", "effect": "effect_smoke", "rarity": "epic"}',
        rarity: 'epic',
      ),
      UnlockableModel(
        unlockableId: 'style_streak_master',
        name: 'Streak Master',
        description: 'Fourteen unbroken days. The fire in your hearth has become a forge, and this potion was tempered in its heat.',
        unlockCondition: '{"type": "streak", "days": 14}',
        rewardVisualConfig: '{"bottle": "bottle_gourd", "liquid": "liquid_5", "effect": "effect_smoke", "rarity": "epic"}',
        rarity: 'epic',
      ),
      UnlockableModel(
        unlockableId: 'style_endurance_brew',
        name: 'Endurance Brew',
        description: 'Sixty minutes without pause. Your focus is a river — steady, relentless, and carving its path through stone.',
        unlockCondition: '{"type": "session_duration", "minutes": 60}',
        rewardVisualConfig: '{"bottle": "bottle_potion", "liquid": "liquid_4", "effect": "effect_smoke", "rarity": "epic"}',
        rarity: 'epic',
      ),
      UnlockableModel(
        unlockableId: 'style_uncommon_curator',
        name: 'Uncommon Curator',
        description: 'Three uncommon potions gathered. You are learning to recognize quality — not just in brews, but in effort.',
        unlockCondition: '{"type": "rarity_collection", "rarity": "uncommon", "count": 3}',
        rewardVisualConfig: '{"bottle": "bottle_flask", "liquid": "liquid_2", "effect": "effect_sparkles", "rarity": "rare"}',
        rarity: 'rare',
      ),
      UnlockableModel(
        unlockableId: 'style_rare_collector',
        name: 'Rare Collector',
        description: 'Five rare potions in your cabinet. Each one a jewel — hard-won and irreplaceable.',
        unlockCondition: '{"type": "rarity_collection", "rarity": "rare", "count": 5}',
        rewardVisualConfig: '{"bottle": "bottle_diamond", "liquid": "liquid_1", "effect": "effect_sparkles", "rarity": "epic"}',
        rarity: 'epic',
      ),

      // ═══════════════════════════════════
      // VERY HARD (Epic/Legendary) — long-term
      // ═══════════════════════════════════
      UnlockableModel(
        unlockableId: 'style_iron_marathon',
        name: 'Iron Marathon',
        description: 'Ninety minutes of pure, unbroken will. The iron in this brew was forged in the furnace of your determination.',
        unlockCondition: '{"type": "session_duration", "minutes": 90}',
        rewardVisualConfig: '{"bottle": "bottle_diamond", "liquid": "liquid_4", "effect": "effect_smoke", "rarity": "epic"}',
        rarity: 'epic',
      ),
      UnlockableModel(
        unlockableId: 'style_midnight_mystic',
        name: 'Midnight Mystic',
        description: 'Three brews between midnight and the witching hour. Only those who walk the boundary of waking and dreaming unlock this.',
        unlockCondition: '{"type": "time_of_day", "after": "00:00", "before": "03:00", "sessions": 3}',
        rewardVisualConfig: '{"bottle": "bottle_gourd", "liquid": "liquid_7", "effect": "effect_smoke", "rarity": "epic"}',
        rarity: 'epic',
      ),
      UnlockableModel(
        unlockableId: 'style_seventy_five',
        name: 'Seventy-Five Flames',
        description: 'Seventy-five potions. Your collection has become a library of focus, and each bottle is a volume.',
        unlockCondition: '{"type": "potion_count", "value": 75}',
        rewardVisualConfig: '{"bottle": "bottle_heart", "liquid": "liquid_5", "effect": "effect_smoke", "rarity": "epic"}',
        rarity: 'epic',
      ),
      UnlockableModel(
        unlockableId: 'style_deep_ocean',
        name: 'Deep Ocean',
        description: 'Fifteen hours beneath the surface of distraction. You have found a stillness that few ever reach.',
        unlockCondition: '{"type": "total_time", "minutes": 900}',
        rewardVisualConfig: '{"bottle": "bottle_gourd", "liquid": "liquid_1", "effect": "effect_smoke", "rarity": "epic"}',
        rarity: 'epic',
      ),
      UnlockableModel(
        unlockableId: 'style_epic_connoisseur',
        name: 'Epic Connoisseur',
        description: 'Three epic potions. You deal in rarities now, and the ordinary holds no interest.',
        unlockCondition: '{"type": "rarity_collection", "rarity": "epic", "count": 3}',
        rewardVisualConfig: '{"bottle": "bottle_legendary", "liquid": "liquid_6", "effect": "effect_smoke", "rarity": "epic"}',
        rarity: 'epic',
      ),
      UnlockableModel(
        unlockableId: 'style_month_of_fire',
        name: 'Month of Fire',
        description: 'Thirty days. An entire moon cycle of unbroken devotion. The flame you carry now could light a city.',
        unlockCondition: '{"type": "streak", "days": 30}',
        rewardVisualConfig: '{"bottle": "bottle_legendary", "liquid": "liquid_4", "effect": "effect_legendary_glow", "rarity": "legendary"}',
        rarity: 'legendary',
      ),
      UnlockableModel(
        unlockableId: 'style_centurion',
        name: 'Centurion',
        description: 'One hundred potions. A century of brews, each one a testament to the quiet power of showing up. You are legend.',
        unlockCondition: '{"type": "potion_count", "value": 100}',
        rewardVisualConfig: '{"bottle": "bottle_legendary", "liquid": "liquid_5", "effect": "effect_legendary_glow", "rarity": "legendary"}',
        rarity: 'legendary',
      ),
      UnlockableModel(
        unlockableId: 'style_two_hour_titan',
        name: 'Two-Hour Titan',
        description: 'One hundred and twenty minutes of absolute focus. Time itself bends around your concentration.',
        unlockCondition: '{"type": "session_duration", "minutes": 120}',
        rewardVisualConfig: '{"bottle": "bottle_diamond", "liquid": "liquid_5", "effect": "effect_legendary_glow", "rarity": "legendary"}',
        rarity: 'legendary',
      ),
      UnlockableModel(
        unlockableId: 'style_eternal_flame',
        name: 'The Eternal Flame',
        description: 'Two thousand minutes of focus and fifty days of unbroken fire. This potion does not flicker — it blazes. The pinnacle of alchemical mastery.',
        unlockCondition: '{"type": "compound", "conditions": [{"type": "total_time", "minutes": 2000}, {"type": "streak", "days": 50}]}',
        rewardVisualConfig: '{"bottle": "bottle_legendary", "liquid": "liquid_5", "effect": "effect_legendary_glow", "rarity": "legendary"}',
        rarity: 'legendary',
      ),
      UnlockableModel(
        unlockableId: 'style_legendary_witness',
        name: 'Legendary Witness',
        description: 'You have gazed upon the rarest light and held it in your hands. One legendary potion — proof that greatness is not a myth.',
        unlockCondition: '{"type": "rarity_collection", "rarity": "legendary", "count": 1}',
        rewardVisualConfig: '{"bottle": "bottle_legendary", "liquid": "liquid_0", "effect": "effect_legendary_glow", "rarity": "legendary"}',
        rarity: 'legendary',
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
