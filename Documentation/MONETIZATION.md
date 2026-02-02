# Monetization Design

Core principle: **the full focus loop is free**. Premium purchases are cosmetic only. Gamification motivates, not stresses.

---

## Currencies

| Currency | How Earned | What It Buys |
|----------|-----------|--------------|
| **Essence** | Earned by focusing (1 per minute, multiplied by rarity) | Basic bottles, liquids, effects |
| **Coins** | Premium (future IAP) | Premium bottles, themes, exclusive effects |

### Essence Calculation

```
essenceEarned = durationMinutes * rarityMultiplier + streakBonus
```

Rarity multipliers:
- Common: 1x
- Uncommon: 2x
- Rare: 3x
- Epic: 4x
- Legendary: 5x

### Coin Balance

Stored in `UserDataModel.coinBalance`. No earning mechanism yet -- will be tied to IAP.

---

## Subscription Tiers

Data model exists (`SubscriptionModel`) but no payment flow is implemented yet.

| Tier | Price | Features |
|------|-------|----------|
| **None** | Free | Full core loop, 2 free themes, basic bottles |
| **Basic** | TBD | +25% bonus essence, 2 exclusive bottles, all backgrounds |
| **Premium** | TBD | All cosmetics unlocked, exclusive effects, priority support |

**Feature flags** checked via `SubscriptionService.hasFeature(featureKey)`:
- `bonus_essence` -- +25% essence earned
- `exclusive_bottles_basic` -- access to basic-tier exclusive bottles
- `all_backgrounds` -- access to all background themes

Premium tier has access to all features regardless of flag.

---

## Shop Categories

| Category | Items | Currency |
|----------|-------|----------|
| **Bottles** | 8 shapes | Free (round, tall), Essence (flask, potion), Coins (heart, diamond, gourd, legendary) |
| **Liquids** | 7+ colors | Mix of Essence and Coins |
| **Effects** | 4 types | Essence (glow, sparkles), Coins (smoke, legendary aura) |
| **Backgrounds** | 6 themes | Free (default, parchment), Coins (forest, night sky, alchemy lab, ocean depths) |

### Pricing Tiers (Essence)

| Rarity | Essence Cost |
|--------|-------------|
| Common | 50 |
| Uncommon | 100-150 |
| Rare | 200-300 |
| Epic | 500 |

### Pricing Tiers (Coins)

| Rarity | Coin Cost |
|--------|----------|
| Uncommon | 50-100 |
| Rare | 150-200 |
| Epic | 300 |
| Legendary | 500 |

---

## Free vs Premium Breakdown

### Always Free
- Full focus timer
- Potion creation and collection
- Streaks and quests
- 2 bottle shapes (round, tall)
- 2 background themes (default, parchment)
- Essence currency earning
- All unlock achievements

### Essence Purchasable
- 2 bottle shapes (flask, potion)
- Several liquid colors
- Basic effects (glow, sparkles)

### Coins Purchasable
- 4 bottle shapes (heart, diamond, gourd, legendary)
- Premium liquid colors
- Premium effects (smoke, legendary aura)
- 4 background themes (forest, night sky, alchemy lab, ocean depths)

---

## Design Rules

1. **No pay-to-win.** Coins buy cosmetics, not gameplay advantages.
2. **No artificial scarcity.** Free users can earn all essence items through play.
3. **No punishing free users.** The core loop is identical for all tiers.
4. **Subscription is additive.** It unlocks extras, never removes existing features.
5. **Progress is always visible.** Free users see locked items as motivation, not frustration.

---

## Key Files

| File | Purpose |
|------|---------|
| `lib/services/coin_service.dart` | Coin balance operations |
| `lib/services/essence_service.dart` | Essence balance operations |
| `lib/services/subscription_service.dart` | Tier checks, feature flags |
| `lib/data/models/subscription_model.dart` | Subscription data model |
| `lib/data/models/shop_item_model.dart` | Shop item with dual currency |
| `lib/data/repositories/shop_repository.dart` | Purchase logic, currency routing |
| `lib/presentation/shop/shop_screen.dart` | Shop UI with dual currency display |
