# Potion Focus - Complete Schema Explained

## Overview

This schema addresses all the concerns raised:
- ✅ **Potion types** with recipes, bottles, fill %
- ✅ **Rendered potion storage** (render_url/render_path)
- ✅ **Shop items and transactions** (full audit trail)
- ✅ **User inventory** (tracks what's owned)
- ✅ **Unlocks tracking** (Grimoire recipes vs Shop purchases)

## Key Tables Explained

### 1. `potion_types` - Available Potion Configurations

**Purpose:** Defines all possible potion configurations (recipes).

**Key Fields:**
- `recipe_id` - Links to grimoire recipe (optional)
- `bottle_id` - References shop_item (which bottle)
- `liquid_color` - Color/pattern identifier
- `fill_percentage` - How full the bottle is (0-100%)
- `effect_id` - Visual effect (optional)
- `unlock_source` - Where it comes from (default, recipe, shop, etc.)

**Example:**
```
id: "potion_type_scholar_elixir"
name: "Scholar's Elixir"
recipe_id: "recipe_scholar_elixir" (from grimoire)
bottle_id: "shop_item_bottle_scholar"
liquid_color: "blue_gradient"
fill_percentage: 85
effect_id: "shop_item_effect_sparkles"
rarity: "uncommon"
unlock_source: "recipe"
```

### 2. `potions` - Actual Created Potions

**Purpose:** Stores each potion created by a user.

**Key Fields:**
- `potion_type_id` - Which configuration was used
- `visual_config` - Exact JSON config (for recreation)
- `render_url` - Public URL to rendered image
- `render_path` - Path in Supabase Storage (`potions/{user_id}/{potion_id}.png`)

**How it works:**
1. User completes session
2. System selects/create `potion_type` based on rarity/unlocks
3. Potion is rendered (server-side or client-side)
4. Image saved to Supabase Storage
5. `render_url` and `render_path` stored in database

### 3. `shop_items` - Purchasable Items

**Purpose:** Everything sold in the shop (bottles, liquids, effects, backgrounds).

**Key Fields:**
- `category` - bottle, liquid, effect, background, sound, theme
- `asset_key` - Identifier used in app
- `asset_url` - URL to asset file (if external)
- `essence_cost` - Cost in essence
- `is_default` - Free item included by default
- `unlock_source` - Where it can be unlocked (shop, recipe, etc.)
- `unlock_recipe_id` - If unlocked via recipe

**Example:**
```
id: "shop_item_bottle_tall"
name: "Tall Bottle"
category: "bottle"
asset_key: "bottle_tall"
essence_cost: 50
rarity: "common"
is_default: false
unlock_source: "shop"
```

### 4. `user_inventory` - What Users Own

**Purpose:** Single source of truth for what each user has unlocked/purchased.

**Key Fields:**
- `item_id` - References shop_item.id or recipe.id
- `item_type` - 'shop_item', 'recipe', or 'potion_type'
- `source` - How they got it (default, purchase, recipe_unlock, quest_reward)
- `purchased_at` - When purchased (if from shop)
- `unlocked_at` - When unlocked
- `transaction_id` - Link to shop_transaction if purchased

**How it works:**
- When user signs up → default items added automatically (via trigger)
- When user purchases → new row with `source='purchase'`
- When recipe unlocks → new row with `source='recipe_unlock'`
- When checking availability → query `user_inventory` table

**Example Query:**
```sql
-- Check if user has a specific bottle
SELECT * FROM user_inventory
WHERE user_id = ? AND item_id = 'shop_item_bottle_tall' AND item_type = 'shop_item';

-- Get all items user owns
SELECT * FROM user_inventory
WHERE user_id = ?;
```

### 5. `shop_transactions` - Purchase History

**Purpose:** Complete audit trail of all essence transactions.

**Key Fields:**
- `transaction_type` - purchase, reward, refund, adjustment
- `item_id` - What was purchased (if applicable)
- `essence_amount` - Positive for rewards, negative for purchases
- `essence_balance_before` - Balance before transaction
- `essence_balance_after` - Balance after transaction
- `metadata` - Additional context (quest_id, session_id, etc.)

**How it works:**
- Every essence transaction is recorded
- Can trace back any balance change
- Supports refunds and adjustments
- Links to `user_inventory` via `transaction_id`

**Example:**
```
transaction_type: "purchase"
item_id: "shop_item_bottle_tall"
essence_amount: -50
essence_balance_before: 100
essence_balance_after: 50
```

### 6. `recipes` - Grimoire Recipes

**Purpose:** Unlockable recipes that grant potion types or shop items.

**Key Fields:**
- `unlock_condition` - JSON condition (same as before)
- `reward_type` - potion_type, shop_item, essence, special
- `reward_item_id` - What you get (potion_type.id or shop_item.id)
- `reward_essence_amount` - Essence reward (if applicable)

**Example:**
```
id: "recipe_scholar_elixir"
name: "Scholar's Elixir"
unlock_condition: {"type": "tag_time", "tag": "studying", "minutes": 300}
reward_type: "potion_type"
reward_item_id: "potion_type_scholar_elixir"
```

### 7. `user_unlocks` - Recipe Unlock Status

**Purpose:** Tracks which Grimoire recipes users have unlocked.

**Key Fields:**
- `recipe_id` - References recipes table
- `unlocked_at` - When unlocked
- `condition_met_at` - When condition was fulfilled

**How it works:**
- Separate from `user_inventory` for clarity
- Can easily query "which recipes are unlocked"
- Used in Grimoire screen

## Data Flow Examples

### Example 1: User Purchases Bottle from Shop

1. **Check if owned:**
   ```sql
   SELECT * FROM user_inventory
   WHERE user_id = ? AND item_id = 'shop_item_bottle_tall';
   ```

2. **If not owned, create transaction:**
   ```sql
   INSERT INTO shop_transactions (...)
   VALUES (..., -50, 100, 50); -- -50 cost, 100 before, 50 after
   ```

3. **Add to inventory:**
   ```sql
   INSERT INTO user_inventory (...)
   VALUES (..., 'purchase', transaction_id);
   ```

4. **Update user_data essence_balance:**
   ```sql
   UPDATE user_data SET essence_balance = 50 WHERE user_id = ?;
   ```

### Example 2: User Unlocks Recipe from Grimoire

1. **Check condition is met** (in app code)
2. **Create user_unlock:**
   ```sql
   INSERT INTO user_unlocks (user_id, recipe_id, condition_met_at)
   VALUES (?, 'recipe_scholar_elixir', now());
   ```

3. **Add reward to inventory:**
   ```sql
   INSERT INTO user_inventory (user_id, item_id, item_type, source)
   VALUES (?, 'potion_type_scholar_elixir', 'potion_type', 'recipe_unlock');
   ```

4. **If reward is essence, create transaction:**
   ```sql
   INSERT INTO shop_transactions (..., transaction_type, essence_amount)
   VALUES (..., 'reward', +100);
   ```

### Example 3: Creating a Potion

1. **Select potion type based on:**
   - Rarity roll
   - User's unlocked potion types (from inventory)
   - Default fallback

2. **Get configuration from potion_type:**
   ```sql
   SELECT * FROM potion_types WHERE id = ?;
   ```

3. **Render potion** (using bottle, liquid, fill %, effect from potion_type)

4. **Save rendered image** to Supabase Storage:
   - Path: `potions/{user_id}/{potion_id}.png`
   - Get public URL

5. **Create potion record:**
   ```sql
   INSERT INTO potions (..., potion_type_id, render_url, render_path)
   VALUES (..., ?, 'https://...', 'potions/{user_id}/{potion_id}.png');
   ```

### Example 4: Checking Available Items for Potion Creation

```sql
-- Get all bottles user owns
SELECT si.* FROM shop_items si
INNER JOIN user_inventory ui ON ui.item_id = si.id
WHERE ui.user_id = ? AND si.category = 'bottle';

-- Get all liquids user owns
SELECT si.* FROM shop_items si
INNER JOIN user_inventory ui ON ui.item_id = si.id
WHERE ui.user_id = ? AND si.category = 'liquid';

-- Get all effects user owns
SELECT si.* FROM shop_items si
INNER JOIN user_inventory ui ON ui.item_id = si.id
WHERE ui.user_id = ? AND si.category = 'effect';
```

## Key Design Decisions

### 1. Why `potion_types` separate from `potions`?

- **Reusability:** Same potion type can be created multiple times
- **Configuration:** Store recipe, bottle, fill % in one place
- **Unlocks:** Easier to track what's available
- **Performance:** Don't duplicate config for each potion

### 2. Why `user_inventory` separate table?

- **Single source of truth:** One place to check ownership
- **Flexibility:** Supports items from multiple sources
- **Performance:** Fast queries for "does user have X?"
- **History:** Tracks when/how items were acquired

### 3. Why `shop_transactions` separate?

- **Audit trail:** Complete history of essence changes
- **Debugging:** Can trace any balance discrepancy
- **Refunds:** Easy to implement
- **Analytics:** Track spending patterns

### 4. Why separate `user_unlocks` from `user_inventory`?

- **Clarity:** Recipes are conceptually different from shop items
- **Queries:** Easier to filter "unlocked recipes" vs "purchased items"
- **Grimoire:** Dedicated table for Grimoire screen
- **Can still join:** Easy to get full inventory if needed

## Rendering Strategy

### Option 1: Server-Side Rendering (Recommended)

1. App sends potion config to Supabase Edge Function
2. Edge Function renders potion image
3. Image saved to Supabase Storage
4. URL returned to app
5. App stores `render_url` in database

**Pros:**
- Consistent rendering
- Offloads processing
- Works on all devices

**Cons:**
- Requires Edge Function
- Slight latency

### Option 2: Client-Side Rendering

1. App renders potion using Flutter Canvas/Widgets
2. Image saved to device storage
3. Upload to Supabase Storage
4. Store `render_url` in database

**Pros:**
- No server dependency
- Instant rendering

**Cons:**
- Device-specific rendering
- Requires storage permission

### Option 3: Hybrid

1. Client renders for immediate display
2. Server renders for consistency
3. Use server version if available

## Next Steps

1. ✅ Run `SCHEMA_COMPLETE.sql` in Supabase SQL Editor
2. ⏳ Update app models to match new schema
3. ⏳ Update sync service for new tables
4. ⏳ Implement potion rendering system
5. ⏳ Update inventory checking logic
6. ⏳ Add transaction recording



