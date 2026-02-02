# Potion Focus - Project Summary

## Overview

**Potion Focus** is a ritual-based focus and productivity app where each focus session creates a unique, collectible potion artifact. Built with Flutter for iOS and Android, the app replaces traditional productivity pressure with emotional, visual progression.

## Current Implementation Status

### ✅ Completed (14/23 features)

| Feature | Status | Description |
|---------|--------|-------------|
| Project Setup | ✅ | Complete folder structure, dependencies, configuration |
| Database | ✅ | Isar offline-first database with 7 collections |
| Navigation | ✅ | Bottom tab nav with 5 main screens |
| Timer Service | ✅ | Background timer with wake lock |
| Timer UI | ✅ | Duration selector, tag input, brewing interface |
| Potion Creation | ✅ | Rarity calculation, essence rewards, visual config |
| Essence System | ✅ | Currency tracking, spending, earning |
| Tag Statistics | ✅ | Usage tracking, 7-day rolling stats, streaks |
| Cabinet UI | ✅ | Grid view, rarity filters, potion details |
| Quest Generation | ✅ | Daily + weekly adaptive quests |
| Quest UI | ✅ | Focus Threads screen with progress tracking |
| Recipe System | ✅ | 6 condition types, unlock checking |
| Grimoire UI | ✅ | Discovered/hidden recipes, lore display |
| Shop | ✅ | Essence shop with purchase flow |

### 🚧 Remaining (9 features)

| Feature | Priority | Estimated Time |
|---------|----------|----------------|
| Potion Visuals | Medium | 1-2 days |
| Settings | Low | 1 day |
| Onboarding | High | 2-3 days |
| Supabase Setup | Medium | 2-3 days |
| Sync Service | Medium | 3-4 days |
| Animations | Medium | 2-3 days |
| Polish | High | 3-5 days |
| Testing | High | 5-7 days |
| Store Prep | High | 3-5 days |

**Total Estimated Time for MVP Completion:** 4-6 weeks

## Key Features Implemented

### 1. Tag-Based Quest System ⭐

The main feature you requested! **Focus Threads** generates personalized quests based on your most-used tags:

- **Daily Quest:** One quest from your #1 most-used tag (last 7 days)
  - Types: Time-based (60%), Session-based (30%), Streak-based (10%)
  - Adaptive difficulty (80% of your daily average)
  - 1.5x essence bonus

- **Weekly Quests:** Three quests from your top 3 tags
  - Always time-based
  - Target: 110% of last week's total
  - 2.0x essence bonus

Example quests:
- "Brew for 30 minutes with #studying" (daily)
- "Focus 7 hours with #coding this week" (weekly)
- "Continue your #writing streak today" (streak)

### 2. Complete Focus Loop

```
Select duration & tags → Start timer → Complete session
  ↓
Create potion (rarity roll) → Award essence → Update stats
  ↓
Check quest progress → Check recipe unlocks
  ↓
Update collection & achievements
```

### 3. Collection & Progression

- **Potions:** Every session becomes a permanent artifact
- **Rarities:** Common → Uncommon → Rare → Epic → Legendary
- **Essence:** Currency earned from sessions
- **Recipes:** Unlock cosmetics through natural behavior
- **Cabinet:** Visual collection with filters

### 4. Philosophy Maintained

✅ No streaks as punishment  
✅ No public leaderboards  
✅ Muddy Brews for cancelled sessions  
✅ Offline-first architecture  
✅ Calm, encouraging tone  

## Technical Architecture

### Tech Stack

- **Framework:** Flutter (Dart)
- **State Management:** Riverpod
- **Database:** Isar (NoSQL)
- **Backend (Future):** Supabase
- **UI:** Material Design 3

### Architecture Pattern

**Clean Architecture** with clear layer separation:
- **Presentation:** UI components (screens, widgets)
- **Domain:** Business logic (services, use cases)
- **Data:** Storage layer (models, repositories, database)

### Database Schema

7 Isar collections:
1. `SessionModel` - Focus session records
2. `PotionModel` - Created potions
3. `TagStatsModel` - Tag analytics
4. `QuestModel` - Active/completed quests
5. `RecipeModel` - Unlockable recipes
6. `UserDataModel` - User progress
7. `ShopItemModel` - Purchasable items

### Key Services

- `TimerService` - Session timer management
- `PotionCreationService` - Rarity & rewards
- `EssenceService` - Currency operations
- `TagStatsService` - Tag analytics
- `QuestGenerationService` - Quest creation & tracking
- `RecipeService` - Unlock conditions

## File Count & Complexity

### Lines of Code (Approximate)

- **Models:** ~400 lines (7 files)
- **Services:** ~1,200 lines (6 files)
- **Repositories:** ~200 lines (2 files)
- **Screens:** ~1,000 lines (6 files)
- **Widgets:** ~800 lines (8 files)
- **Core/Utils:** ~400 lines (4 files)
- **Config:** ~300 lines (3 files)

**Total:** ~4,300 lines of production code

### File Structure

```
lib/ (54 files)
├── core/ (5 files)
├── data/ (12 files)
│   ├── local/ (1 file)
│   ├── models/ (7 files + 7 generated)
│   └── repositories/ (2 files)
├── domain/ (0 files - future)
├── presentation/ (24 files)
│   ├── home/ (4 files)
│   ├── cabinet/ (4 files)
│   ├── grimoire/ (3 files)
│   ├── quests/ (3 files)
│   ├── shop/ (3 files)
│   ├── settings/ (1 file)
│   └── shared/ (1 file)
└── services/ (6 files)
```

## What's Working Now

### You Can:

✅ Start focus timers with tags  
✅ Complete or cancel sessions  
✅ View all potions in Cabinet  
✅ Filter potions by rarity  
✅ See personalized daily/weekly quests  
✅ Track quest progress in real-time  
✅ Discover and unlock recipes  
✅ Spend essence in the Shop  
✅ Purchase cosmetic items  
✅ View statistics and streaks  

### Placeholders:

⚠️ Potion visuals (using icons)  
⚠️ Animations (basic only)  
⚠️ Sound effects (not implemented)  
⚠️ Onboarding (not implemented)  
⚠️ Cloud sync (offline only)  

## Next Development Phases

### Phase 1: Essential Polish (1-2 weeks)
- Enhanced potion visuals
- Loading animations
- Onboarding flow
- Notification service
- Settings improvements

### Phase 2: Backend (2-3 weeks)
- Supabase project setup
- Authentication system
- Cloud sync service
- Multi-device support
- Data backup

### Phase 3: Launch Prep (2-3 weeks)
- Comprehensive testing
- Bug fixes
- Performance optimization
- App Store assets
- Store submission

## Running the Project

### Quick Start

```powershell
cd c:\Users\jasme\Potions\potion_focus
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
flutter run
```

See `QUICK_START.md` for detailed instructions.

## Design Highlights

### Color Palette

- **Primary:** Muted purple (#6B4E71)
- **Secondary:** Warm brown (#8B7355)
- **Background:** Soft cream (#F5F1ED)
- **Rarities:** Gray → Green → Blue → Purple → Gold

### Typography

- **Headings:** Playfair Display (elegant, serif)
- **Body:** Inter (clean, readable)
- **Style:** Calm, generous whitespace

### UX Principles

- No harsh language ("You failed" → "Part of your journey")
- Soft animations (60fps minimum)
- Generous padding and spacing
- Clear visual hierarchy
- Accessible touch targets

## Known Issues & Limitations

### Current MVP Limitations

1. **No background timer on iOS** - Requires platform-specific implementation
2. **Simplified visuals** - Using icon placeholders
3. **No sound** - Audio system not implemented
4. **Limited recipes** - Only 5 default recipes
5. **No cloud sync** - Offline-only for MVP
6. **No friends** - Social features deferred to v2

### Technical Debt

- TODO: Implement notification service
- TODO: Add comprehensive error handling
- TODO: Implement proper logging
- TODO: Add analytics events
- TODO: Optimize large collection rendering

## Future Roadmap (Post-MVP)

### Version 1.1
- Friend system (companionship, not competition)
- Shared focus sessions
- Monthly collection quests
- Seasonal recipes
- More cosmetic items

### Version 1.2
- Advanced statistics
- Customizable cabinet layouts
- Export focus history
- Multiple themes
- Accessibility improvements

### Version 2.0
- Group focus sessions
- Story arcs and events
- Limited-time recipes
- Cross-platform sync (web)
- Localization (multiple languages)

## Credits & Acknowledgments

- **Design Philosophy:** Inspired by Forest app's calm approach
- **Visual Style:** Alchemy and potion brewing aesthetics
- **UX Principles:** Anti-productivity-guilt, pro-ritual

---

## Summary for Developers

**Potion Focus** is 56% complete (14/23 features) with a solid foundation:
- ✅ Complete core loop (timer → potion → collection)
- ✅ Tag-based quest system (the main requested feature!)
- ✅ Recipe discovery & unlocks
- ✅ Essence economy with shop
- ✅ Offline-first data persistence

**Remaining work** focuses on:
- Polish (animations, visuals, onboarding)
- Backend integration (Supabase sync)
- Testing & launch preparation

**Estimated completion:** 4-6 weeks of focused development

---

**Generated:** January 16, 2026  
**Version:** 1.0.0-beta



