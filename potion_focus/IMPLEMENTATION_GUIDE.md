# Potion Focus - Implementation Guide

## Project Status

**MVP Progress:** 13 of 23 core features completed (56%)

### ✅ Completed Features

1. **Project Setup** - Full Flutter project structure with organized folders
2. **Database** - Isar local database with all models and collections
3. **Navigation** - Bottom tab navigation with 5 screens
4. **Timer Service** - Complete timer functionality with background support
5. **Timer UI** - Duration selector, tag input, and brewing interface
6. **Potion Creation** - Rarity calculation and essence rewards
7. **Essence System** - Currency management and balance tracking
8. **Tag Statistics** - Tag usage tracking and analytics
9. **Cabinet UI** - Grid view with filters and potion details
10. **Quest Generation** - Daily and weekly quest algorithms
11. **Quest UI** - Focus Threads screen with quest cards
12. **Recipe System** - Unlock conditions and reward system
13. **Grimoire UI** - Recipe discovery and lore display
14. **Shop** - Essence shop with purchase flow

### 🚧 In Progress / Remaining

1. **Potion Visuals** - Enhanced visual composition system
2. **Settings** - Full settings implementation
3. **Onboarding** - Welcome flow for new users
4. **Supabase Setup** - Backend integration
5. **Sync Service** - Offline-first synchronization
6. **Animations** - Polish animations throughout
7. **Testing** - Unit, widget, and integration tests
8. **Store Preparation** - App Store and Play Store assets
9. **Polish** - Final UX refinements

## How to Run the Project

### Prerequisites

1. **Install Flutter:**
   ```bash
   # Follow instructions at https://flutter.dev/docs/get-started/install
   flutter --version  # Should be 3.0.0 or higher
   ```

2. **Install Dependencies:**
   ```bash
   cd potion_focus
   flutter pub get
   ```

3. **Generate Code:**
   ```bash
   # Generate Isar and Riverpod code
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

4. **Run the App:**
   ```bash
   # For iOS
   flutter run -d ios

   # For Android
   flutter run -d android

   # For Web (testing only)
   flutter run -d chrome
   ```

## Architecture Overview

### Clean Architecture Layers

```
lib/
├── core/           # Configuration, theme, utilities
├── data/           # Data layer (models, repositories, local storage)
├── domain/         # Business logic (entities, use cases)
├── presentation/   # UI layer (screens, widgets)
└── services/       # Application services (timer, quests, recipes)
```

### Key Design Patterns

- **State Management:** Riverpod for reactive state
- **Database:** Isar for offline-first local storage
- **Repository Pattern:** Data abstraction layer
- **Service Layer:** Business logic separation

## Core Workflows

### 1. Focus Session Flow

```
User selects duration & tags
    ↓
Start timer → TimerService
    ↓
Session saved to local DB
    ↓
Timer completes (or cancelled)
    ↓
Create Potion → PotionCreationService
    ↓
Calculate rarity & essence
    ↓
Update UserData, TagStats, QuestProgress
    ↓
Check recipe unlocks
    ↓
Show completion UI
```

### 2. Quest System Flow

```
App opens / Daily reset
    ↓
QuestGenerationService.generateDailyQuest()
    ↓
Analyze top tags from last 7 days
    ↓
Select quest type (time/session/streak)
    ↓
Calculate adaptive target
    ↓
Create quest in DB
    ↓
User completes sessions
    ↓
Quest progress updates
    ↓
Award essence on completion
```

### 3. Recipe Unlock Flow

```
Session completes
    ↓
RecipeService.checkRecipeUnlocks()
    ↓
Get all locked recipes
    ↓
For each recipe:
  - Parse unlock condition
  - Check if condition met
  - Unlock if true
    ↓
Show unlock notification
```

## Database Schema

### Collections

1. **SessionModel** - Focus session records
2. **PotionModel** - Created potion artifacts
3. **TagStatsModel** - Tag usage statistics
4. **RecipeModel** - Unlockable recipes
5. **QuestModel** - Daily and weekly quests
6. **UserDataModel** - User progress data
7. **ShopItemModel** - Purchasable items

## Key Services

### TimerService
- Manages focus session timer
- Handles background timer state
- Integrates with wake lock
- Triggers potion creation on completion

### PotionCreationService
- Calculates rarity based on duration and streak
- Generates visual configuration
- Awards essence
- Creates "Muddy Brew" for cancelled sessions

### EssenceService
- Tracks essence balance
- Handles spending and earning
- Updates user statistics
- Manages streak calculations

### TagStatsService
- Aggregates tag usage data
- Calculates 7-day rolling stats
- Tracks tag streaks
- Provides data for quest generation

### QuestGenerationService
- Generates personalized daily quests
- Creates weekly quests from top 3 tags
- Updates quest progress
- Expires old quests

### RecipeService
- Checks unlock conditions
- Supports multiple condition types
- Provides cryptic hints for locked recipes
- Awards cosmetic rewards

## Configuration Files

### pubspec.yaml
Key dependencies:
- `flutter_riverpod` - State management
- `isar` - Local database
- `supabase_flutter` - Backend (future)
- `google_fonts` - Typography
- `wakelock_plus` - Keep screen on during focus
- `workmanager` - Background tasks

### App Constants
Located in `lib/core/config/app_constants.dart`:
- Timer presets
- Essence calculations
- Rarity probabilities
- Quest difficulty factors

## UI Components

### Screens
1. **HomeScreen** - Timer and brewing interface
2. **CabinetScreen** - Potion collection grid
3. **GrimoireScreen** - Recipe discovery
4. **QuestsScreen** - Focus Threads
5. **ShopScreen** - Essence shop
6. **SettingsScreen** - App preferences

### Reusable Widgets
- `TimerWidget` - Circular timer display
- `DurationSelector` - Duration chips
- `TagSelector` - Tag input with autocomplete
- `PotionGridItem` - Potion card in cabinet
- `PotionDetailModal` - Full potion details
- `QuestCard` - Quest display with progress
- `RecipeCard` - Recipe with unlock status
- `ShopItemCard` - Purchasable item card

## Next Steps for Development

### Phase 1: Essential Polish (1-2 weeks)
1. Add loading animations
2. Implement notification service
3. Build onboarding flow
4. Enhance potion visuals
5. Polish Settings screen

### Phase 2: Backend Integration (2-3 weeks)
1. Setup Supabase project
2. Implement authentication
3. Build sync service
4. Test offline scenarios
5. Add friend features (optional)

### Phase 3: Testing & Launch (2-3 weeks)
1. Write unit tests
2. Add widget tests
3. Conduct user testing
4. Fix bugs and polish
5. Prepare store assets
6. Submit to App Store and Play Store

## Testing Strategy

### Unit Tests
- Rarity calculation logic
- Essence calculation
- Quest generation algorithms
- Recipe unlock conditions

### Widget Tests
- Timer UI interactions
- Tag selector
- Cabinet filters
- Shop purchase flow

### Integration Tests
- Full session flow
- Quest completion
- Recipe unlocking
- Offline data persistence

## Customization Guide

### Adding New Quest Types

1. Add to `AppConstants.questTypeWeights`
2. Implement calculation in `QuestGenerationService._calculateDailyTarget()`
3. Update `QuestCard._getQuestTitle()` for display
4. Add progress tracking in `updateQuestProgress()`

### Adding New Unlock Conditions

1. Define condition JSON structure
2. Add case in `RecipeService._checkUnlockCondition()`
3. Implement checking logic
4. Add hint text in `RecipeService.getRecipeHint()`

### Adding New Shop Items

Default items are initialized in `DatabaseHelper._initializeShopItems()`.
To add more:
1. Add `ShopItemModel` to the initialization list
2. Rebuild app to initialize database
3. Items will appear in shop automatically

## Performance Considerations

- Isar database is highly performant (no queries over 10ms expected)
- Use `.where().limit()` for large collections
- Implement lazy loading for cabinet grid if >1000 potions
- Profile animations with Flutter DevTools
- Keep image assets compressed

## Known Limitations (MVP)

1. **No real-time multiplayer** - Friend features planned for v2
2. **Simple visuals** - Potion rendering is placeholder icons
3. **No sound effects** - Audio planned for future release
4. **Limited recipes** - Starting with 5 default recipes
5. **No themes** - Single theme for MVP
6. **No data export** - Planned for v1.1

## Troubleshooting

### Build Runner Issues
```bash
flutter pub run build_runner clean
flutter pub run build_runner build --delete-conflicting-outputs
```

### Database Issues
```bash
# Delete app and reinstall to reset database
flutter clean
flutter pub get
flutter run
```

### Hot Reload Not Working
- Restart app completely after database schema changes
- Code generation requires full rebuild

## Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Riverpod Guide](https://riverpod.dev/)
- [Isar Database](https://isar.dev/)
- [Material Design 3](https://m3.material.io/)

## Contact & Support

For questions or issues:
- Check existing GitHub issues
- Create new issue with details
- Include Flutter doctor output

---

**Last Updated:** January 2026  
**Version:** 1.0.0-beta  
**License:** All rights reserved



