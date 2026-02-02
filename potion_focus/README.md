# Potion Focus

A ritual-based focus and productivity application where each focus session creates a permanent potion artifact that represents time, intention, and effort.

## Philosophy

Potion Focus replaces traditional productivity pressure with emotional, visual progression. It's designed for users who want a calmer relationship with focus - no guilt-driven streaks, no competitive tracking, just a quiet personal archive of effort.

## Features

- **Focus Sessions**: Start a timer and watch your potion brew
- **Potion Collection**: Every session becomes a unique, collectible potion
- **Essence Economy**: Earn essence to unlock new bottles, liquids, and effects
- **Recipes**: Discover recipes through natural focus patterns
- **Focus Threads**: Personalized daily and weekly quests
- **Grimoire**: Explore lore and track your discoveries
- **Shop**: Spend essence on cosmetic upgrades
- **Offline-First**: Works fully without internet connection

## Tech Stack

- **Flutter** (Dart) - Cross-platform mobile framework
- **Isar** - Local NoSQL database for offline-first architecture
- **Supabase** - Backend database, auth, and storage
- **Riverpod** - State management

## Getting Started

### Prerequisites

- Flutter SDK (3.0.0 or higher)
- Dart SDK
- iOS/Android development environment

### Installation

```bash
# Get dependencies
flutter pub get

# Run code generation
flutter pub run build_runner build --delete-conflicting-outputs

# Run the app
flutter run
```

## Project Structure

```
lib/
├── core/           # Configuration, theme, utilities
├── data/           # Data layer (local DB, remote API, models)
├── domain/         # Business logic (entities, use cases)
├── presentation/   # UI layer (screens, widgets)
└── services/       # Background services (timer, sync, notifications)
```

## Development Phases

- **Phase 1**: Core loop (timer → potion → cabinet)
- **Phase 2**: Progression (recipes, shop, full visuals)
- **Phase 3**: Quests & polish (Focus Threads, onboarding)
- **Phase 4**: Sync & backend (Supabase integration)
- **Phase 5**: Testing & launch

## License

All rights reserved © 2026



