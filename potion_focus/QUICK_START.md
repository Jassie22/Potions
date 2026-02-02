# Potion Focus - Quick Start Guide

## Setup (First Time)

1. **Install Flutter** (if not already installed)
   - Download from: https://flutter.dev/docs/get-started/install
   - Follow platform-specific instructions for Windows

2. **Navigate to Project**
   ```powershell
   cd c:\Users\jasme\Potions\potion_focus
   ```

3. **Install Dependencies**
   ```powershell
   flutter pub get
   ```

4. **Generate Required Code**
   ```powershell
   flutter pub run build_runner build --delete-conflicting-outputs
   ```
   This generates database and state management code (required!)

5. **Run the App**
   ```powershell
   # Connect your Android device or start Android emulator
   flutter devices  # See available devices
   flutter run      # Run on default device
   
   # Or for iOS (requires Mac)
   flutter run -d ios
   ```

## Project Structure Summary

```
potion_focus/
├── lib/
│   ├── main.dart                    # App entry point
│   ├── core/
│   │   ├── config/                  # Constants
│   │   ├── theme/                   # Colors and theme
│   │   └── utils/                   # Helpers and extensions
│   ├── data/
│   │   ├── local/                   # Isar database
│   │   ├── models/                  # Data models
│   │   └── repositories/            # Data access
│   ├── presentation/
│   │   ├── home/                    # Timer screen
│   │   ├── cabinet/                 # Potion collection
│   │   ├── grimoire/                # Recipe discovery
│   │   ├── quests/                  # Focus Threads
│   │   ├── shop/                    # Essence shop
│   │   └── settings/                # Settings
│   └── services/
│       ├── timer_service.dart       # Focus timer
│       ├── potion_creation_service.dart
│       ├── essence_service.dart
│       ├── tag_stats_service.dart
│       ├── quest_generation_service.dart
│       └── recipe_service.dart
└── assets/
    ├── images/
    ├── lottie/
    └── fonts/
```

## Current Features

### ✅ Working Features

1. **Focus Timer**
   - Preset durations (15, 25, 45, 60, 90 min)
   - Custom durations (10-120 min)
   - Tag selection (up to 5 tags)
   - Background timer support
   - Pause and cancel functionality

2. **Potion System**
   - Automatic potion creation on session completion
   - 5 rarity levels (common → legendary)
   - "Muddy Brew" for cancelled sessions
   - Essence rewards based on duration and rarity
   - Visual collection in Cabinet

3. **Cabinet**
   - Grid view of all potions
   - Filter by rarity
   - Detailed potion information
   - Session history for each potion

4. **Focus Threads (Quests)**
   - Personalized daily quest (from top tag)
   - 3 weekly quests (from top 3 tags)
   - Adaptive difficulty
   - Bonus essence rewards
   - Real-time progress tracking

5. **Grimoire**
   - Recipe discovery system
   - 5 default recipes with unlock conditions
   - Poetic lore for each recipe
   - Cryptic hints for locked recipes

6. **Shop**
   - Spend essence on cosmetic items
   - Categories: Bottles, Liquids, Effects, Backgrounds
   - Permanent unlocks
   - Default items included

7. **Statistics**
   - Tag usage tracking
   - Total focus time
   - Streak tracking
   - Potion count

### 🚧 Placeholder/Simplified

- Potion visuals (using icons for now)
- Settings (basic version)
- Onboarding (not implemented)
- Backend sync (offline-only for now)
- Animations (basic Flutter animations)

## Testing the App

### Test Flow 1: Complete a Focus Session

1. Open app → Home screen
2. Select a tag (e.g., "studying")
3. Choose 15 minute duration
4. Press "Start Brewing"
5. Wait for timer or fast-forward by changing device time
6. Session completes → Potion created
7. Check Cabinet to see your new potion
8. Check Focus Threads to see quest progress
9. Check Grimoire to see if any recipes unlocked

### Test Flow 2: Quest System

1. Complete a few sessions with the same tag
2. Navigate to Focus Threads tab
3. See generated daily quest for that tag
4. Complete sessions to fulfill quest
5. Quest marks complete and awards bonus essence
6. Return next day to see new daily quest

### Test Flow 3: Shop

1. Earn essence by completing sessions
2. Navigate to Shop tab
3. View available items by category
4. Purchase item with essence
5. Item marked as "Owned"

### Test Flow 4: Recipe Discovery

1. Complete specific challenge (e.g., brew 1 potion)
2. Navigate to Grimoire
3. See "First Brew" recipe unlocked
4. Read the lore
5. Reward automatically added to collection

## Common Issues & Solutions

### Issue: App won't run
**Solution:** 
```powershell
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
flutter run
```

### Issue: Database errors
**Solution:** Uninstall app from device and reinstall
```powershell
flutter run
```

### Issue: Hot reload not working after changes
**Solution:** Full restart required for database/model changes
- Press `R` in terminal (capital R for full restart)

### Issue: Code generation errors
**Solution:**
```powershell
flutter pub run build_runner clean
flutter pub run build_runner build --delete-conflicting-outputs
```

## Making Changes

### Adding a New Recipe

1. Open `lib/data/local/database.dart`
2. Find `_initializeRecipes()` method
3. Add new `RecipeModel` to `defaultRecipes` list
4. Specify unlock condition as JSON
5. Rebuild app to initialize new recipe

Example:
```dart
RecipeModel(
  recipeId: 'recipe_my_new_recipe',
  name: 'My Recipe',
  unlockCondition: '{"type": "potion_count", "value": 10}',
  rewardType: 'bottle',
  rewardAssetKey: 'bottle_special',
  rarity: 'rare',
  lore: 'A special recipe for dedicated alchemists.',
),
```

### Adding a New Shop Item

Similar process in `_initializeShopItems()` in `database.dart`:

```dart
ShopItemModel(
  itemId: 'liquid_rainbow',
  name: 'Rainbow Liquid',
  category: 'liquid',
  assetKey: 'liquid_rainbow',
  essenceCost: 200,
  rarity: 'epic',
),
```

### Changing Timer Presets

Edit `lib/core/config/app_constants.dart`:
```dart
static const List<int> timerPresets = [10, 20, 30, 60]; // Your custom presets
```

### Changing Essence Calculations

Edit `lib/core/utils/helpers.dart`:
```dart
static int calculateEssence({...}) {
  final base = durationMinutes ~/ 5; // Change divisor to adjust rate
  // ... rest of calculation
}
```

## Development Workflow

1. **Make changes** to Dart files
2. **Hot reload** with `r` in terminal (for UI changes)
3. **Hot restart** with `R` for logic changes
4. **Full rebuild** for database changes
5. **Test** on device/emulator
6. **Repeat**

## Next Steps

See `IMPLEMENTATION_GUIDE.md` for:
- Detailed architecture documentation
- Remaining features to implement
- Backend integration guide
- Testing strategy
- Launch preparation

## Need Help?

1. Check `IMPLEMENTATION_GUIDE.md` for detailed docs
2. Review Flutter documentation: https://flutter.dev/docs
3. Check Isar docs for database: https://isar.dev/
4. Riverpod docs for state management: https://riverpod.dev/

---

**Happy Brewing! 🧪✨**



