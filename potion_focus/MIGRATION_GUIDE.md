# Potion Focus - Schema Migration Guide

## Overview

This guide helps you migrate from the initial schema to the complete schema with:
- Potion types (recipes, bottles, fill %)
- Rendered potion storage
- Shop items and transactions
- User inventory tracking
- Complete unlock tracking

## Prerequisites

✅ You've already run the initial schema (from `SUPABASE_SETUP.md`)  
✅ You have existing data in `sessions`, `potions`, `quests`, `recipes`, `user_data` tables

## Migration Steps

### Step 1: Backup Your Data (IMPORTANT!)

Before running the migration:

1. **Export your data:**
   ```sql
   -- In Supabase Dashboard > SQL Editor
   -- Run this to see your data (don't delete anything yet)
   SELECT * FROM public.potions LIMIT 10;
   SELECT * FROM public.recipes LIMIT 10;
   ```

2. **Or use Supabase Dashboard:**
   - Go to Table Editor
   - Export each table as CSV (if needed)

### Step 2: Run Migration Script

1. **Open Supabase SQL Editor:**
   - Go to: https://supabase.com/dashboard/project/cfvmnhrldqlrpdwerhzn
   - Click "SQL Editor" in left sidebar
   - Click "New Query"

2. **Copy and paste `MIGRATE_SCHEMA.sql`**
   - Full script is in `MIGRATE_SCHEMA.sql`
   - Copy entire file content

3. **Run the script:**
   - Click "Run" button
   - Wait for completion (should take < 30 seconds)

### Step 3: Verify Migration

Run these queries to verify:

```sql
-- Check new tables exist
SELECT table_name FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name IN ('potion_types', 'shop_items', 'user_inventory', 'shop_transactions', 'user_unlocks', 'tag_stats');

-- Check potions table has new columns
SELECT column_name FROM information_schema.columns 
WHERE table_name = 'potions' 
AND column_name IN ('potion_type_id', 'render_url', 'render_path');

-- Check recipes table has new columns
SELECT column_name FROM information_schema.columns 
WHERE table_name = 'recipes' 
AND column_name IN ('reward_type', 'reward_item_id', 'reward_essence_amount');

-- Verify existing potions have potion_type_id
SELECT COUNT(*) as total, COUNT(potion_type_id) as with_type_id 
FROM public.potions;
```

### Step 4: Test the Migration

```sql
-- Test potion_types were created
SELECT * FROM public.potion_types LIMIT 5;

-- Test shop_items table (will be empty initially)
SELECT * FROM public.shop_items;

-- Test user_inventory table (will be empty initially)
SELECT * FROM public.user_inventory;
```

## What the Migration Does

### 1. Creates New Tables

- ✅ `potion_types` - Potion configurations
- ✅ `shop_items` - Purchasable items
- ✅ `user_inventory` - What users own
- ✅ `shop_transactions` - Purchase history
- ✅ `user_unlocks` - Recipe unlock tracking
- ✅ `tag_stats` - Tag usage statistics (if not exists)

### 2. Alters Existing Tables

**Potions Table:**
- ✅ Adds `potion_type_id` column (references potion_types)
- ✅ Adds `render_url` column (for rendered potion images)
- ✅ Adds `render_path` column (Supabase Storage path)

**Recipes Table:**
- ✅ Adds `reward_type` column (potion_type, shop_item, essence, special)
- ✅ Adds `reward_item_id` column (what you unlock)
- ✅ Adds `reward_essence_amount` column (essence reward)
- ✅ Adds `category` column (focus, time, streak, etc.)

### 3. Migrates Existing Data

**Potions Migration:**
- ✅ Creates `potion_type` records for existing potions
- ✅ Parses `visual_config` JSON to extract bottle, liquid, fill %
- ✅ Updates existing potions with `potion_type_id` reference

**Note:** Existing potions will get default potion types based on their visual_config.

### 4. Sets Up Security

- ✅ Enables RLS on all new tables
- ✅ Creates RLS policies (users can only see their own data)
- ✅ Public read access for `potion_types` and `shop_items`

### 5. Creates Triggers

- ✅ Auto-updates `updated_at` timestamps
- ✅ Auto-adds default items to new user inventory

## Data Migration Details

### Existing Potions

The migration script:
1. Reads existing `potions.visual_config` JSON
2. Extracts: `bottle`, `liquid`, `effect`, `fill_percentage`
3. Creates a `potion_type` record for each unique configuration
4. Links existing potions to their `potion_type` via `potion_type_id`

**Example:**
```
Existing Potion:
- visual_config: {"bottle": "bottle_round", "liquid": "liquid_purple", "fill_percentage": 75}
- rarity: "common"

Creates Potion Type:
- id: "potion_type_{potion_id}"
- bottle_id: "bottle_round"
- liquid_color: "liquid_purple"
- fill_percentage: 75
- rarity: "common"
```

### Existing Recipes

The migration script:
1. Adds new columns to `recipes` table
2. Existing recipes keep their `unlock_condition` JSON
3. New `reward_type` and `reward_item_id` columns are NULL initially
4. You can update recipes later to specify rewards

## Post-Migration Tasks

### 1. Populate Shop Items

You'll need to insert shop items manually or via app:

```sql
-- Example: Insert default shop items
INSERT INTO public.shop_items (id, name, category, asset_key, essence_cost, rarity, is_default)
VALUES 
  ('shop_item_bottle_round', 'Round Bottle', 'bottle', 'bottle_round', 0, 'common', true),
  ('shop_item_liquid_purple', 'Purple Liquid', 'liquid', 'liquid_purple', 0, 'common', true),
  ('shop_item_bottle_tall', 'Tall Bottle', 'bottle', 'bottle_tall', 50, 'common', false);
```

### 2. Update Recipe Rewards

Update existing recipes to specify what they unlock:

```sql
-- Example: Update recipe to give potion type
UPDATE public.recipes
SET 
  reward_type = 'potion_type',
  reward_item_id = 'potion_type_scholar_elixir'
WHERE id = 'recipe_scholar_elixir';
```

### 3. Add Default Items to User Inventory

For existing users, add default items:

```sql
-- Add default shop items to all existing users
INSERT INTO public.user_inventory (user_id, item_id, item_type, source)
SELECT 
  u.id,
  si.id,
  'shop_item',
  'default'
FROM auth.users u
CROSS JOIN public.shop_items si
WHERE si.is_default = true
ON CONFLICT (user_id, item_id, item_type) DO NOTHING;
```

### 4. Update App Code

After migration:
1. Update app models to match new schema
2. Update sync service for new tables
3. Update inventory checking logic
4. Implement potion rendering system

## Rollback Plan (If Needed)

If something goes wrong:

1. **Don't panic** - The migration only ADDS columns and tables
2. **Existing data is preserved** - No columns deleted
3. **To rollback:**
   ```sql
   -- Remove new columns (optional - data still works without them)
   ALTER TABLE public.potions DROP COLUMN IF EXISTS potion_type_id;
   ALTER TABLE public.potions DROP COLUMN IF EXISTS render_url;
   ALTER TABLE public.potions DROP COLUMN IF EXISTS render_path;
   
   -- Drop new tables (if needed)
   DROP TABLE IF EXISTS public.user_inventory CASCADE;
   DROP TABLE IF EXISTS public.shop_transactions CASCADE;
   DROP TABLE IF EXISTS public.user_unlocks CASCADE;
   DROP TABLE IF EXISTS public.potion_types CASCADE;
   DROP TABLE IF EXISTS public.shop_items CASCADE;
   ```

## Troubleshooting

### Error: Column already exists

This means the column was already added. The script uses `ADD COLUMN IF NOT EXISTS`, so it should be safe to run multiple times.

### Error: Table already exists

The script uses `CREATE TABLE IF NOT EXISTS`, so existing tables are preserved.

### Error: Policy already exists

The script uses `DROP POLICY IF EXISTS` before creating, so it should handle this.

### Existing Potions Missing potion_type_id

The migration script tries to create potion types for existing potions. If some are missing:
1. Check if `visual_config` is valid JSON
2. Run migration again (it's idempotent)
3. Or manually create potion types

## Next Steps

After successful migration:

1. ✅ Verify all tables exist and have correct columns
2. ✅ Populate `shop_items` with your items
3. ✅ Update `recipes` with reward information
4. ✅ Add default items to existing users' inventory
5. ✅ Update app code to use new schema
6. ✅ Test potion creation with new system

## Support

If you encounter issues:
1. Check Supabase logs for detailed error messages
2. Verify RLS policies are correct
3. Check that foreign key constraints are valid
4. Ensure user authentication is working

---

**Migration is safe to run multiple times** - The script uses `IF NOT EXISTS` and `IF EXISTS` checks throughout.



