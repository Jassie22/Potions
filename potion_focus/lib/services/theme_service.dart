import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:potion_focus/data/local/database.dart';
import 'package:potion_focus/data/local/isar_helpers.dart';
import 'package:potion_focus/data/models/user_data_model.dart';
import 'package:potion_focus/data/models/shop_item_model.dart';

class ThemeService {
  Future<String> getActiveThemeId() async {
    final db = DatabaseHelper.instance;
    final allUserData = await db.userDataModels.getAllItems();
    final userData = allUserData.firstOrNull;
    return userData?.activeThemeId ?? 'theme_default';
  }

  Future<void> setActiveTheme(String themeId) async {
    final db = DatabaseHelper.instance;
    final allUserData = await db.userDataModels.getAllItems();
    final userData = allUserData.firstOrNull;
    if (userData != null) {
      userData.activeThemeId = themeId;
      await db.writeTxn(() async {
        await db.userDataModels.put(userData);
      });
    }
  }

  /// Returns list of theme IDs the user can use (free defaults + purchased).
  Future<List<String>> getAvailableThemes() async {
    final db = DatabaseHelper.instance;
    final allShopItems = await db.shopItemModels.getAllItems();
    final purchasedThemes = allShopItems
        .where((item) => item.category == 'background' && item.purchased)
        .map((item) => item.assetKey)
        .toList();

    // Free defaults always available
    return [
      'theme_default',
      'theme_parchment',
      ...purchasedThemes,
    ];
  }
}

/// Theme display info for the selector UI.
class ThemeInfo {
  final String id;
  final String name;

  const ThemeInfo(this.id, this.name);
}

const allThemeInfos = [
  ThemeInfo('theme_default', 'Midnight'),
  ThemeInfo('theme_parchment', 'Parchment'),
  ThemeInfo('theme_forest', 'Enchanted Forest'),
  ThemeInfo('theme_night_sky', 'Night Sky'),
  ThemeInfo('theme_alchemy_lab', 'Alchemy Lab'),
  ThemeInfo('theme_ocean_depths', 'Ocean Depths'),
  ThemeInfo('theme_crystal_cave', 'Crystal Cavern'),
  ThemeInfo('theme_mystic_garden', 'Mystic Garden'),
  ThemeInfo('theme_starfall', 'Starfall'),
  ThemeInfo('theme_ancient_library', 'Ancient Library'),
];

final themeServiceProvider = Provider<ThemeService>((ref) {
  return ThemeService();
});

final activeThemeProvider = FutureProvider<String>((ref) async {
  final service = ref.watch(themeServiceProvider);
  return await service.getActiveThemeId();
});

final availableThemesProvider = FutureProvider<List<String>>((ref) async {
  final service = ref.watch(themeServiceProvider);
  return await service.getAvailableThemes();
});
