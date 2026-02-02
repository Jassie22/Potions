-- ============================================
-- Potion Focus - Schema Migration Script
-- ============================================
-- This script migrates from the initial schema to the complete schema
-- Run this AFTER you've already created the basic tables
-- ============================================

-- ============================================
-- 1. CREATE NEW TABLES
-- ============================================

-- Potion Types Table (NEW)
CREATE TABLE IF NOT EXISTS public.potion_types (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  recipe_id TEXT, -- References grimoire recipe (optional)
  bottle_id TEXT NOT NULL, -- References shop_item (bottle)
  liquid_color TEXT NOT NULL, -- Color/pattern identifier
  fill_percentage INTEGER NOT NULL CHECK (fill_percentage >= 0 AND fill_percentage <= 100),
  effect_id TEXT, -- References shop_item (effect) - nullable
  rarity TEXT NOT NULL DEFAULT 'common' CHECK (rarity IN ('common', 'uncommon', 'rare', 'epic', 'legendary', 'muddy')),
  unlock_source TEXT NOT NULL CHECK (unlock_source IN ('default', 'recipe', 'shop', 'quest', 'special')),
  unlock_condition JSONB, -- For recipe-based unlocks
  lore TEXT, -- Description/lore for this potion type
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS potion_types_rarity_idx ON public.potion_types(rarity);
CREATE INDEX IF NOT EXISTS potion_types_unlock_source_idx ON public.potion_types(unlock_source);
CREATE INDEX IF NOT EXISTS potion_types_recipe_id_idx ON public.potion_types(recipe_id);

-- Shop Items Table (NEW)
CREATE TABLE IF NOT EXISTS public.shop_items (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  category TEXT NOT NULL CHECK (category IN ('bottle', 'liquid', 'effect', 'background', 'sound', 'theme')),
  asset_key TEXT NOT NULL, -- Identifier for asset in app
  asset_url TEXT, -- URL to asset file (if external)
  essence_cost INTEGER NOT NULL DEFAULT 0,
  rarity TEXT NOT NULL DEFAULT 'common' CHECK (rarity IN ('common', 'uncommon', 'rare', 'epic', 'legendary')),
  description TEXT,
  preview_url TEXT, -- Preview image URL
  is_default BOOLEAN NOT NULL DEFAULT false, -- True if included by default (free)
  unlock_source TEXT CHECK (unlock_source IN ('shop', 'recipe', 'quest', 'default')),
  unlock_recipe_id TEXT, -- If unlocked via recipe, reference recipe
  metadata JSONB DEFAULT '{}'::jsonb, -- Additional data
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS shop_items_category_idx ON public.shop_items(category);
CREATE INDEX IF NOT EXISTS shop_items_rarity_idx ON public.shop_items(rarity);
CREATE INDEX IF NOT EXISTS shop_items_unlock_source_idx ON public.shop_items(unlock_source);

-- User Inventory Table (NEW)
CREATE TABLE IF NOT EXISTS public.user_inventory (
  id BIGSERIAL PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  item_id TEXT NOT NULL, -- References shop_item.id or recipe.id
  item_type TEXT NOT NULL CHECK (item_type IN ('shop_item', 'recipe', 'potion_type')),
  source TEXT NOT NULL CHECK (source IN ('default', 'purchase', 'recipe_unlock', 'quest_reward', 'special')),
  purchased_at TIMESTAMPTZ, -- When purchased (if from shop)
  unlocked_at TIMESTAMPTZ NOT NULL DEFAULT now(), -- When unlocked
  transaction_id TEXT, -- Reference to shop_transaction if purchased
  metadata JSONB DEFAULT '{}'::jsonb,
  UNIQUE(user_id, item_id, item_type)
);

CREATE INDEX IF NOT EXISTS user_inventory_user_id_idx ON public.user_inventory(user_id);
CREATE INDEX IF NOT EXISTS user_inventory_item_id_idx ON public.user_inventory(item_id);
CREATE INDEX IF NOT EXISTS user_inventory_item_type_idx ON public.user_inventory(item_type);
CREATE INDEX IF NOT EXISTS user_inventory_source_idx ON public.user_inventory(source);

-- Shop Transactions Table (NEW)
CREATE TABLE IF NOT EXISTS public.shop_transactions (
  id TEXT PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  transaction_type TEXT NOT NULL CHECK (transaction_type IN ('purchase', 'reward', 'refund', 'adjustment')),
  item_id TEXT REFERENCES public.shop_items(id), -- If purchase
  item_type TEXT, -- 'shop_item', 'recipe', etc.
  essence_amount INTEGER NOT NULL, -- Positive for rewards, negative for purchases
  essence_balance_before INTEGER NOT NULL,
  essence_balance_after INTEGER NOT NULL,
  description TEXT,
  metadata JSONB DEFAULT '{}'::jsonb,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS shop_transactions_user_id_idx ON public.shop_transactions(user_id);
CREATE INDEX IF NOT EXISTS shop_transactions_type_idx ON public.shop_transactions(transaction_type);
CREATE INDEX IF NOT EXISTS shop_transactions_created_at_idx ON public.shop_transactions(created_at);
CREATE INDEX IF NOT EXISTS shop_transactions_item_id_idx ON public.shop_transactions(item_id);

-- User Unlocks Table (NEW - for Grimoire recipe tracking)
-- Note: Foreign key to recipes will be added after recipes table exists
CREATE TABLE IF NOT EXISTS public.user_unlocks (
  id BIGSERIAL PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  recipe_id TEXT NOT NULL, -- Will add FK constraint after recipes table exists
  unlocked_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  condition_met_at TIMESTAMPTZ NOT NULL, -- When condition was met
  UNIQUE(user_id, recipe_id)
);

CREATE INDEX IF NOT EXISTS user_unlocks_user_id_idx ON public.user_unlocks(user_id);
CREATE INDEX IF NOT EXISTS user_unlocks_recipe_id_idx ON public.user_unlocks(recipe_id);

-- Tag Stats Table (NEW - if not already created)
CREATE TABLE IF NOT EXISTS public.tag_stats (
  id BIGSERIAL PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  tag TEXT NOT NULL,
  total_minutes INTEGER NOT NULL DEFAULT 0,
  total_sessions INTEGER NOT NULL DEFAULT 0,
  last_7_days_minutes INTEGER NOT NULL DEFAULT 0,
  last_7_days_sessions INTEGER NOT NULL DEFAULT 0,
  current_streak INTEGER NOT NULL DEFAULT 0,
  longest_streak INTEGER NOT NULL DEFAULT 0,
  last_session_date TIMESTAMPTZ,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(user_id, tag)
);

CREATE INDEX IF NOT EXISTS tag_stats_user_id_idx ON public.tag_stats(user_id);
CREATE INDEX IF NOT EXISTS tag_stats_tag_idx ON public.tag_stats(tag);
CREATE INDEX IF NOT EXISTS tag_stats_last_7_days_idx ON public.tag_stats(last_7_days_minutes DESC);

-- ============================================
-- 2. ALTER EXISTING TABLES
-- ============================================

-- Add new columns to potions table (if table exists)
-- Note: potion_type_id can't have foreign key constraint until potion_types table exists
-- We'll add the foreign key constraint after potion_types is created

DO $$
BEGIN
  -- Only proceed if potions table exists
  IF EXISTS (SELECT 1 FROM information_schema.tables 
             WHERE table_schema = 'public' 
             AND table_name = 'potions') THEN
    
    -- Add potion_type_id column (without FK constraint first)
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_schema = 'public' 
                   AND table_name = 'potions' 
                   AND column_name = 'potion_type_id') THEN
      ALTER TABLE public.potions ADD COLUMN potion_type_id TEXT;
    END IF;
  
    
    -- Add render_url column
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_schema = 'public' 
                   AND table_name = 'potions' 
                   AND column_name = 'render_url') THEN
      ALTER TABLE public.potions ADD COLUMN render_url TEXT;
    END IF;
    
    -- Add render_path column
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_schema = 'public' 
                   AND table_name = 'potions' 
                   AND column_name = 'render_path') THEN
      ALTER TABLE public.potions ADD COLUMN render_path TEXT;
    END IF;
    
  END IF; -- End of potions table exists check
END $$;

-- Add foreign key constraints after tables exist
DO $$
BEGIN
  -- Add FK constraint for potion_type_id (after potion_types table exists)
  IF EXISTS (SELECT 1 FROM information_schema.tables 
             WHERE table_schema = 'public' 
             AND table_name = 'potion_types')
     AND EXISTS (SELECT 1 FROM information_schema.tables 
                 WHERE table_schema = 'public' 
                 AND table_name = 'potions')
     AND NOT EXISTS (
       SELECT 1 FROM pg_constraint 
       WHERE conname = 'potions_potion_type_id_fkey'
     ) THEN
    ALTER TABLE public.potions 
      ADD CONSTRAINT potions_potion_type_id_fkey 
      FOREIGN KEY (potion_type_id) REFERENCES public.potion_types(id);
  END IF;
  
  -- Add FK constraint for user_unlocks.recipe_id (after recipes table exists)
  IF EXISTS (SELECT 1 FROM information_schema.tables 
             WHERE table_schema = 'public' 
             AND table_name = 'recipes')
     AND EXISTS (SELECT 1 FROM information_schema.tables 
                 WHERE table_schema = 'public' 
                 AND table_name = 'user_unlocks')
     AND NOT EXISTS (
       SELECT 1 FROM pg_constraint 
       WHERE conname = 'user_unlocks_recipe_id_fkey'
     ) THEN
    ALTER TABLE public.user_unlocks 
      ADD CONSTRAINT user_unlocks_recipe_id_fkey 
      FOREIGN KEY (recipe_id) REFERENCES public.recipes(id);
  END IF;
END $$;

-- Add new columns to recipes table (if table exists)
DO $$
BEGIN
  -- Only proceed if recipes table exists
  IF EXISTS (SELECT 1 FROM information_schema.tables 
             WHERE table_schema = 'public' 
             AND table_name = 'recipes') THEN
    
    -- Add reward_type column
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_schema = 'public' 
                   AND table_name = 'recipes' 
                   AND column_name = 'reward_type') THEN
      ALTER TABLE public.recipes ADD COLUMN reward_type TEXT 
        CHECK (reward_type IN ('potion_type', 'shop_item', 'essence', 'special'));
    END IF;
  
    
    -- Add reward_item_id column
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_schema = 'public' 
                   AND table_name = 'recipes' 
                   AND column_name = 'reward_item_id') THEN
      ALTER TABLE public.recipes ADD COLUMN reward_item_id TEXT;
    END IF;
    
    -- Add reward_essence_amount column
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_schema = 'public' 
                   AND table_name = 'recipes' 
                   AND column_name = 'reward_essence_amount') THEN
      ALTER TABLE public.recipes ADD COLUMN reward_essence_amount INTEGER DEFAULT 0;
    END IF;
    
    -- Add category column
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_schema = 'public' 
                   AND table_name = 'recipes' 
                   AND column_name = 'category') THEN
      ALTER TABLE public.recipes ADD COLUMN category TEXT 
        CHECK (category IN ('focus', 'time', 'streak', 'collection', 'special'));
    END IF;
    
  END IF; -- End of recipes table exists check
END $$;

-- Create indexes for recipes (only if table and columns exist)
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables 
             WHERE table_schema = 'public' 
             AND table_name = 'recipes') THEN
    
    IF EXISTS (SELECT 1 FROM information_schema.columns 
               WHERE table_schema = 'public' 
               AND table_name = 'recipes' 
               AND column_name = 'reward_type') THEN
      CREATE INDEX IF NOT EXISTS recipes_reward_type_idx ON public.recipes(reward_type);
    END IF;
    
    IF EXISTS (SELECT 1 FROM information_schema.columns 
               WHERE table_schema = 'public' 
               AND table_name = 'recipes' 
               AND column_name = 'category') THEN
      CREATE INDEX IF NOT EXISTS recipes_category_idx ON public.recipes(category);
    END IF;
    
    -- Ensure recipes table has created_at column (if not exists)
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_schema = 'public' 
                   AND table_name = 'recipes' 
                   AND column_name = 'created_at') THEN
      ALTER TABLE public.recipes ADD COLUMN created_at TIMESTAMPTZ NOT NULL DEFAULT now();
    END IF;
    
  END IF;
END $$;

-- ============================================
-- 3. MIGRATE EXISTING DATA
-- ============================================

-- Migrate existing potions: Create default potion types based on existing potions
-- This creates potion types for existing potions
DO $$
DECLARE
  potion_record RECORD;
  potion_type_id TEXT;
  potion_visual_config JSONB;
  bottle_id TEXT;
  liquid_color TEXT;
  fill_pct INTEGER;
BEGIN
  -- Only proceed if potions table exists
  IF EXISTS (SELECT 1 FROM information_schema.tables 
             WHERE table_schema = 'public' 
             AND table_name = 'potions') THEN
    
    FOR potion_record IN 
      SELECT p.id, p.visual_config, p.rarity 
      FROM public.potions p 
      WHERE p.potion_type_id IS NULL
    LOOP
      -- Parse visual_config JSON (use record field to avoid ambiguity)
      potion_visual_config := potion_record.visual_config::JSONB;
      bottle_id := COALESCE(potion_visual_config->>'bottle', 'bottle_round');
      liquid_color := COALESCE(potion_visual_config->>'liquid', 'liquid_purple');
      fill_pct := COALESCE((potion_visual_config->>'fill_percentage')::INTEGER, 75);
      
      -- Create potion_type_id
      potion_type_id := 'potion_type_' || potion_record.id;
      
      -- Insert or update potion_type
      INSERT INTO public.potion_types (
        id,
        name,
        bottle_id,
        liquid_color,
        fill_percentage,
        effect_id,
        rarity,
        unlock_source
      ) VALUES (
        potion_type_id,
        'Potion ' || potion_record.rarity,
        bottle_id,
        liquid_color,
        fill_pct,
        COALESCE(potion_visual_config->>'effect', NULL),
        potion_record.rarity,
        'default'
      )
      ON CONFLICT (id) DO NOTHING;
      
      -- Update potion to reference potion_type
      UPDATE public.potions
      SET potion_type_id = potion_type_id
      WHERE id = potion_record.id;
    END LOOP;
    
  END IF; -- End of potions table exists check
END $$;

-- Migrate existing recipe unlocks to user_unlocks table
-- (if recipes table has unlocked column)
DO $$
DECLARE
  recipe_record RECORD;
BEGIN
  -- Check if recipes table has unlocked column
  IF EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_schema = 'public' 
    AND table_name = 'recipes' 
    AND column_name = 'unlocked'
  ) THEN
    -- Migrate unlocked recipes to user_unlocks
    -- Note: This assumes you have user_id somewhere (may need adjustment)
    -- For now, this is a placeholder - you may need to manually migrate based on your data
    NULL; -- Placeholder - adjust based on your data structure
  END IF;
END $$;

-- ============================================
-- 4. ENABLE ROW LEVEL SECURITY ON NEW TABLES
-- ============================================

ALTER TABLE public.potion_types ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.shop_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_inventory ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.shop_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_unlocks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tag_stats ENABLE ROW LEVEL SECURITY;

-- ============================================
-- 5. CREATE RLS POLICIES FOR NEW TABLES
-- ============================================

-- Potion Types (read-only for users)
DROP POLICY IF EXISTS "Anyone can view potion_types" ON public.potion_types;
CREATE POLICY "Anyone can view potion_types" ON public.potion_types FOR SELECT USING (true);

-- Shop Items (read-only for users)
DROP POLICY IF EXISTS "Anyone can view shop_items" ON public.shop_items;
CREATE POLICY "Anyone can view shop_items" ON public.shop_items FOR SELECT USING (true);

-- User Inventory Policies
DROP POLICY IF EXISTS "Users can view own inventory" ON public.user_inventory;
CREATE POLICY "Users can view own inventory" ON public.user_inventory FOR SELECT USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can insert own inventory" ON public.user_inventory;
CREATE POLICY "Users can insert own inventory" ON public.user_inventory FOR INSERT WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can update own inventory" ON public.user_inventory;
CREATE POLICY "Users can update own inventory" ON public.user_inventory FOR UPDATE USING (auth.uid() = user_id);

-- Shop Transactions Policies
DROP POLICY IF EXISTS "Users can view own transactions" ON public.shop_transactions;
CREATE POLICY "Users can view own transactions" ON public.shop_transactions FOR SELECT USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can insert own transactions" ON public.shop_transactions;
CREATE POLICY "Users can insert own transactions" ON public.shop_transactions FOR INSERT WITH CHECK (auth.uid() = user_id);

-- User Unlocks Policies
DROP POLICY IF EXISTS "Users can view own unlocks" ON public.user_unlocks;
CREATE POLICY "Users can view own unlocks" ON public.user_unlocks FOR SELECT USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can insert own unlocks" ON public.user_unlocks;
CREATE POLICY "Users can insert own unlocks" ON public.user_unlocks FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Tag Stats Policies
DROP POLICY IF EXISTS "Users can view own tag_stats" ON public.tag_stats;
CREATE POLICY "Users can view own tag_stats" ON public.tag_stats FOR SELECT USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can insert own tag_stats" ON public.tag_stats;
CREATE POLICY "Users can insert own tag_stats" ON public.tag_stats FOR INSERT WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can update own tag_stats" ON public.tag_stats;
CREATE POLICY "Users can update own tag_stats" ON public.tag_stats FOR UPDATE USING (auth.uid() = user_id);

-- ============================================
-- 6. CREATE TRIGGERS
-- ============================================

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Triggers for updated_at
DROP TRIGGER IF EXISTS update_shop_items_updated_at ON public.shop_items;
CREATE TRIGGER update_shop_items_updated_at BEFORE UPDATE ON public.shop_items
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_tag_stats_updated_at ON public.tag_stats;
CREATE TRIGGER update_tag_stats_updated_at BEFORE UPDATE ON public.tag_stats
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Function to automatically add default items to user inventory
CREATE OR REPLACE FUNCTION add_default_items_to_inventory()
RETURNS TRIGGER AS $$
BEGIN
  -- Add default shop items to new user's inventory
  INSERT INTO public.user_inventory (user_id, item_id, item_type, source)
  SELECT NEW.id, id, 'shop_item', 'default'
  FROM public.shop_items
  WHERE is_default = true
  ON CONFLICT (user_id, item_id, item_type) DO NOTHING;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to add default items when user signs up
DROP TRIGGER IF EXISTS on_user_created_add_default_items ON auth.users;
CREATE TRIGGER on_user_created_add_default_items
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION add_default_items_to_inventory();

-- ============================================
-- 7. UPDATE EXISTING POLICIES (if needed)
-- ============================================

-- Ensure potions policies allow selecting by potion_type_id
-- (No changes needed, just verifying)

-- ============================================
-- MIGRATION COMPLETE
-- ============================================

-- Verify migration
DO $$
BEGIN
  RAISE NOTICE 'Migration complete!';
  RAISE NOTICE 'New tables created: potion_types, shop_items, user_inventory, shop_transactions, user_unlocks, tag_stats';
  RAISE NOTICE 'Existing tables updated: potions (added potion_type_id, render_url, render_path), recipes (added reward fields)';
  RAISE NOTICE 'RLS policies and triggers created';
END $$;

