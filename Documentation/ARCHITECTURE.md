# Architecture

## Stack

- **Framework:** Flutter (Dart)
- **State Management:** Riverpod (StateNotifier, Provider, FutureProvider)
- **Local Database:** Isar (offline-first NoSQL)
- **Backend:** Supabase (initialized but sync not yet active)
- **Rendering:** CustomPaint (all bottles, effects, backgrounds)

---

## Project Structure

```
potion_focus/lib/
  core/
    config/          # App constants, preferences, Supabase config
    models/          # Typed wrappers (VisualConfig)
    theme/           # AppColors, AppTheme (Material 3)
    utils/           # Helpers, extensions
  data/
    local/           # Isar database setup, helpers
    models/          # Isar collections (9 total)
    repositories/    # ShopRepository, PotionRepository
  presentation/
    cabinet/         # Potion collection grid
    grimoire/        # Recipe book (PageView)
    home/            # Timer, brewing display, completion modal
    onboarding/      # First-run screen
    quests/          # Quest cards
    settings/        # Theme selector, tag management
    shared/          # Navigation, painters, animations
    shop/            # Dual-currency shop
  services/          # Business logic layer
```

---

## Isar Collections

9 collections registered in `DatabaseHelper.initialize()`:

| Collection | Purpose |
|-----------|---------|
| `SessionModel` | Focus session records (duration, tags, completion) |
| `PotionModel` | Created potions with visualConfig JSON |
| `TagStatsModel` | Cumulative stats per tag (minutes, sessions) |
| `RecipeModel` | Unlock-able recipes with conditions |
| `QuestModel` | Dynamic daily/weekly quests |
| `UserDataModel` | Player profile (essence, coins, streak, theme) |
| `ShopItemModel` | Purchasable cosmetics (bottles, liquids, effects, themes) |
| `SubscriptionModel` | Premium membership tier |
| `UnlockableModel` | Achievement-based potion style unlocks |

---

## Navigation

5 tabs in `AppNavigation`:

| Tab | Screen | Purpose |
|-----|--------|---------|
| Brew | `HomeScreen` | Timer, bottle filling animation, completion modal |
| Cabinet | `CabinetScreen` | Potion collection grid, detail modals |
| Grimoire | `GrimoireBookScreen` | Swipeable recipe book with parchment pages |
| Threads | `QuestsScreen` | Active quests, progress tracking |
| Shop | `ShopScreen` | Buy cosmetics with Essence or Coins |

---

## Core Data Flow

### Focus Session to Potion

```
User taps "Start" on HomeScreen
  |
  v
TimerService.startTimer(duration, tags)
  ├─ Creates SessionModel (saved to Isar)
  ├─ Sets TimerState.isRunning = true
  └─ Starts WakelockPlus
  |
  v
Timer ticks (1s interval)
  ├─ fillPercent = 1 - (remaining / total)
  └─ PotionRenderer shows liquid rising
  |
  v
Timer reaches 0 -> _completeSession()
  ├─ PotionCreationService.createPotion()
  │   ├─ calculateRarity(duration, streak)
  │   ├─ calculateEssence(duration, multiplier, streak)
  │   ├─ generateVisualConfig(rarity, tags)
  │   └─ Save PotionModel to Isar
  │
  ├─ EssenceService.addEssence(amount)
  ├─ TagStatsService.updateTagStats(tags, duration)
  ├─ QuestGenerationService.updateQuestProgress()
  ├─ RecipeService.checkRecipeUnlocks()
  ├─ UnlockService.checkUnlocks()
  │
  └─ TimerState.completedPotion = potion
      └─ CompletionModal shown with rarity reveal
```

### Cancelled Session

```
User taps "Stop"
  |
  v
TimerService.stopTimer() -> _cancelSession()
  ├─ Creates "Muddy Brew" (rarity: muddy, essence: 1)
  └─ Resets TimerState
```

---

## Provider Graph

```
timerServiceProvider (StateNotifier<TimerState>)
  ├─ reads: potionCreationServiceProvider
  ├─ reads: essenceServiceProvider
  ├─ reads: tagStatsServiceProvider
  ├─ reads: questGenerationServiceProvider
  ├─ reads: recipeServiceProvider
  └─ reads: unlockServiceProvider

potionCreationServiceProvider (Provider)
essenceServiceProvider (StateNotifier)
coinServiceProvider (StateNotifier)
tagStatsServiceProvider (StateNotifier)
questGenerationServiceProvider (StateNotifier)

recipeServiceProvider (Provider)
  └─ exposes: allRecipesProvider, recipesByRarityProvider

unlockServiceProvider (StateNotifier)
  └─ exposes: unlockedStylesProvider

subscriptionServiceProvider (Provider)
  └─ exposes: subscriptionTierProvider

shopRepositoryProvider (Provider)
  └─ exposes: shopItemsProvider, shopItemsByCategoryProvider

potionRepositoryProvider (Provider)
  └─ exposes: allPotionsProvider

essenceBalanceProvider (FutureProvider)
coinBalanceProvider (FutureProvider)
```

---

## Unlock System

Two parallel unlock systems:

### Recipes
- Unlock individual cosmetic items (a bottle, a liquid, an effect)
- Shown in the Grimoire as pages
- Conditions stored as JSON in `RecipeModel.unlockCondition`

### Unlockable Styles
- Unlock preset potion combos (bottle + liquid + effect)
- 12 default styles seeded on first run
- Conditions stored as JSON in `UnlockableModel.unlockCondition`

### Condition Types

| Type | Parameters | Example |
|------|-----------|---------|
| `potion_count` | `value: int` | Brew 10 potions |
| `total_time` | `minutes: int` | Focus 300 minutes total |
| `streak` | `days: int` | 14-day streak |
| `tag_mastery` | `tag, minutes` | 600 minutes of "coding" |
| `rarity_collection` | `rarity, count` | Collect 5 rare potions |
| `session_duration` | `minutes: int` | Complete a 90-minute session |
| `time_of_day` | `after (HH:MM), sessions` | 5 sessions after 05:00 |

---

## Database Seeding

On first run, `DatabaseHelper.initialize()` seeds:
- 1 `UserDataModel` (default balances)
- 1 `SubscriptionModel` (tier: none)
- 26 `ShopItemModel` entries (bottles, liquids, effects, themes)
- 10 `RecipeModel` entries (unlock challenges)
- 12 `UnlockableModel` entries (achievement styles)

---

## Key Architectural Decisions

1. **Offline-first.** All data in Isar. Supabase sync is future work.
2. **No image assets for game content.** All visuals are CustomPaint. This keeps APK small and allows infinite variation.
3. **JSON conditions.** Unlock rules are data, not code. New unlock types can be added without changing the evaluation engine.
4. **Dual currency.** Essence (free) and Coins (premium) are separate economies. This prevents IAP from disrupting the free progression loop.
5. **Rarity drives visuals.** A potion's rarity determines its default bottle shape, effect, and glow. This creates visual hierarchy without user configuration.
