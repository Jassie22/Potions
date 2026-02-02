-- ============================================
-- Potion Focus - Complete Database Schema
-- ============================================
-- This schema addresses:
-- - Potion types with recipes, bottles, fill %
-- - Rendered potion storage
-- - Shop items and transactions
-- - User inventory (what's unlocked/purchased)
-- - Unlocks tracking (Grimoire vs Shop)
-- ============================================

-- ============================================
-- 1. CORE TABLES (Sessions, Potions, User Data)
-- ============================================

CREATE TABLE public.sessions (
  id TEXT PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  duration_seconds INTEGER NOT NULL,
  tags JSONB NOT NULL DEFAULT '[]'::jsonb,
  completed BOOLEAN NOT NULL DEFAULT false,
  started_at TIMESTAMPTZ NOT NULL,
  completed_at TIMESTAMPTZ,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX sessions_user_id_idx ON public.sessions(user_id);
CREATE INDEX sessions_started_at_idx ON public.sessions(started_at);
CREATE INDEX sessions_user_updated_idx ON public.sessions(user_id, updated_at);

-- ============================================
-- 2. POTION TYPES (Recipes/Configurations)
-- ============================================
-- Defines available potion configurations (recipes)
-- Each potion type has: recipe, bottle, fill percentage, etc.

CREATE TABLE public.potion_types (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  recipe_id TEXT, -- References grimoire recipe (optional - default potions have no recipe)
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

CREATE INDEX potion_types_rarity_idx ON public.potion_types(rarity);
CREATE INDEX potion_types_unlock_source_idx ON public.potion_types(unlock_source);
CREATE INDEX potion_types_recipe_id_idx ON public.potion_types(recipe_id);

-- ============================================
-- 3. POTIONS (Actual Created Potions)
-- ============================================
-- Each potion references a potion_type and stores its rendered image

CREATE TABLE public.potions (
  id TEXT PRIMARY KEY,
  session_id TEXT NOT NULL REFERENCES public.sessions(id) ON DELETE CASCADE,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  potion_type_id TEXT NOT NULL REFERENCES public.potion_types(id),
  rarity TEXT NOT NULL CHECK (rarity IN ('common', 'uncommon', 'rare', 'epic', 'legendary', 'muddy')),
  essence_earned INTEGER NOT NULL DEFAULT 0,
  visual_config JSONB NOT NULL DEFAULT '{}'::jsonb, -- Store exact config used
  render_url TEXT, -- URL to rendered potion image (Supabase Storage or external)
  render_path TEXT, -- Path in Supabase Storage (e.g., 'potions/{user_id}/{potion_id}.png')
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX potions_user_id_idx ON public.potions(user_id);
CREATE INDEX potions_session_id_idx ON public.potions(session_id);
CREATE INDEX potions_created_at_idx ON public.potions(created_at);
CREATE INDEX potions_rarity_idx ON public.potions(rarity);
CREATE INDEX potions_potion_type_id_idx ON public.potions(potion_type_id);

-- ============================================
-- 4. SHOP ITEMS (Purchasable Items)
-- ============================================
-- Bottles, liquids, effects, backgrounds sold in shop

CREATE TABLE public.shop_items (
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
  metadata JSONB DEFAULT '{}'::jsonb, -- Additional data (fill percentages, colors, etc.)
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX shop_items_category_idx ON public.shop_items(category);
CREATE INDEX shop_items_rarity_idx ON public.shop_items(rarity);
CREATE INDEX shop_items_unlock_source_idx ON public.shop_items(unlock_source);

-- ============================================
-- 5. USER INVENTORY (What Users Own)
-- ============================================
-- Tracks all items unlocked/purchased by each user
-- Combines shop purchases, recipe unlocks, default items

CREATE TABLE public.user_inventory (
  id BIGSERIAL PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  item_id TEXT NOT NULL, -- References shop_item.id or recipe.id
  item_type TEXT NOT NULL CHECK (item_type IN ('shop_item', 'recipe', 'potion_type')),
  source TEXT NOT NULL CHECK (source IN ('default', 'purchase', 'recipe_unlock', 'quest_reward', 'special')),
  purchased_at TIMESTAMPTZ, -- When purchased (if from shop)
  unlocked_at TIMESTAMPTZ NOT NULL DEFAULT now(), -- When unlocked
  transaction_id TEXT, -- Reference to shop_transaction if purchased
  metadata JSONB DEFAULT '{}'::jsonb, -- Additional info
  UNIQUE(user_id, item_id, item_type)
);

CREATE INDEX user_inventory_user_id_idx ON public.user_inventory(user_id);
CREATE INDEX user_inventory_item_id_idx ON public.user_inventory(item_id);
CREATE INDEX user_inventory_item_type_idx ON public.user_inventory(item_type);
CREATE INDEX user_inventory_source_idx ON public.user_inventory(source);

-- ============================================
-- 6. SHOP TRANSACTIONS (Purchase History)
-- ============================================
-- Records all essence transactions (purchases, rewards, etc.)

CREATE TABLE public.shop_transactions (
  id TEXT PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  transaction_type TEXT NOT NULL CHECK (transaction_type IN ('purchase', 'reward', 'refund', 'adjustment')),
  item_id TEXT REFERENCES public.shop_items(id), -- If purchase
  item_type TEXT, -- 'shop_item', 'recipe', etc.
  essence_amount INTEGER NOT NULL, -- Positive for rewards, negative for purchases
  essence_balance_before INTEGER NOT NULL,
  essence_balance_after INTEGER NOT NULL,
  description TEXT,
  metadata JSONB DEFAULT '{}'::jsonb, -- Additional context
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX shop_transactions_user_id_idx ON public.shop_transactions(user_id);
CREATE INDEX shop_transactions_type_idx ON public.shop_transactions(transaction_type);
CREATE INDEX shop_transactions_created_at_idx ON public.shop_transactions(created_at);
CREATE INDEX shop_transactions_item_id_idx ON public.shop_transactions(item_id);

-- ============================================
-- 7. RECIPES (Grimoire - Unlockable Recipes)
-- ============================================
-- Unlockable recipes that give potion types or shop items

CREATE TABLE public.recipes (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  lore TEXT NOT NULL,
  unlock_condition JSONB NOT NULL, -- Condition to unlock
  reward_type TEXT NOT NULL CHECK (reward_type IN ('potion_type', 'shop_item', 'essence', 'special')),
  reward_item_id TEXT, -- References potion_type.id or shop_item.id
  reward_essence_amount INTEGER DEFAULT 0, -- If reward is essence
  rarity TEXT NOT NULL DEFAULT 'common' CHECK (rarity IN ('common', 'uncommon', 'rare', 'epic', 'legendary')),
  category TEXT CHECK (category IN ('focus', 'time', 'streak', 'collection', 'special')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX recipes_rarity_idx ON public.recipes(rarity);
CREATE INDEX recipes_category_idx ON public.recipes(category);
CREATE INDEX recipes_reward_type_idx ON public.recipes(reward_type);

-- ============================================
-- 8. USER UNLOCKS (Recipe Unlock Status)
-- ============================================
-- Tracks which recipes users have unlocked

CREATE TABLE public.user_unlocks (
  id BIGSERIAL PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  recipe_id TEXT NOT NULL REFERENCES public.recipes(id),
  unlocked_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  condition_met_at TIMESTAMPTZ NOT NULL, -- When condition was met
  UNIQUE(user_id, recipe_id)
);

CREATE INDEX user_unlocks_user_id_idx ON public.user_unlocks(user_id);
CREATE INDEX user_unlocks_recipe_id_idx ON public.user_unlocks(recipe_id);

-- ============================================
-- 9. QUESTS (Focus Threads)
-- ============================================

CREATE TABLE public.quests (
  id TEXT PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  tag TEXT NOT NULL,
  quest_type TEXT NOT NULL CHECK (quest_type IN ('time_based', 'session_based', 'streak_based')),
  timeframe TEXT NOT NULL CHECK (timeframe IN ('daily', 'weekly', 'monthly')),
  target_value INTEGER NOT NULL,
  current_progress INTEGER NOT NULL DEFAULT 0,
  status TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'completed', 'expired')),
  essence_reward INTEGER NOT NULL DEFAULT 0,
  generated_at TIMESTAMPTZ NOT NULL,
  expires_at TIMESTAMPTZ NOT NULL,
  completed_at TIMESTAMPTZ,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX quests_user_id_idx ON public.quests(user_id);
CREATE INDEX quests_status_idx ON public.quests(status);
CREATE INDEX quests_expires_at_idx ON public.quests(expires_at);

-- ============================================
-- 10. USER DATA (User Progress Stats)
-- ============================================

CREATE TABLE public.user_data (
  user_id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  essence_balance INTEGER NOT NULL DEFAULT 0,
  total_focus_minutes INTEGER NOT NULL DEFAULT 0,
  total_potions INTEGER NOT NULL DEFAULT 0,
  streak_days INTEGER NOT NULL DEFAULT 0,
  last_focus_date TIMESTAMPTZ,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ============================================
-- 11. TAG STATISTICS (Tag Usage Tracking)
-- ============================================
-- Track tag usage per user (local only or sync for analytics)

CREATE TABLE public.tag_stats (
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

CREATE INDEX tag_stats_user_id_idx ON public.tag_stats(user_id);
CREATE INDEX tag_stats_tag_idx ON public.tag_stats(tag);
CREATE INDEX tag_stats_last_7_days_idx ON public.tag_stats(last_7_days_minutes DESC);

-- ============================================
-- 12. ROW LEVEL SECURITY (RLS) POLICIES
-- ============================================

ALTER TABLE public.sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.potions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.potion_types ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.shop_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_inventory ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.shop_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.recipes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_unlocks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.quests ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_data ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tag_stats ENABLE ROW LEVEL SECURITY;

-- Sessions Policies
CREATE POLICY "Users can view own sessions" ON public.sessions FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own sessions" ON public.sessions FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own sessions" ON public.sessions FOR UPDATE USING (auth.uid() = user_id);

-- Potions Policies
CREATE POLICY "Users can view own potions" ON public.potions FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own potions" ON public.potions FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own potions" ON public.potions FOR UPDATE USING (auth.uid() = user_id);

-- Potion Types (read-only for users, admin can modify)
CREATE POLICY "Anyone can view potion_types" ON public.potion_types FOR SELECT USING (true);

-- Shop Items (read-only for users, admin can modify)
CREATE POLICY "Anyone can view shop_items" ON public.shop_items FOR SELECT USING (true);

-- User Inventory Policies
CREATE POLICY "Users can view own inventory" ON public.user_inventory FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own inventory" ON public.user_inventory FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Shop Transactions Policies
CREATE POLICY "Users can view own transactions" ON public.shop_transactions FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own transactions" ON public.shop_transactions FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Recipes (read-only for users)
CREATE POLICY "Anyone can view recipes" ON public.recipes FOR SELECT USING (true);

-- User Unlocks Policies
CREATE POLICY "Users can view own unlocks" ON public.user_unlocks FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own unlocks" ON public.user_unlocks FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Quests Policies
CREATE POLICY "Users can view own quests" ON public.quests FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own quests" ON public.quests FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own quests" ON public.quests FOR UPDATE USING (auth.uid() = user_id);

-- User Data Policies
CREATE POLICY "Users can view own user_data" ON public.user_data FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own user_data" ON public.user_data FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own user_data" ON public.user_data FOR UPDATE USING (auth.uid() = user_id);

-- Tag Stats Policies
CREATE POLICY "Users can view own tag_stats" ON public.tag_stats FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own tag_stats" ON public.tag_stats FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own tag_stats" ON public.tag_stats FOR UPDATE USING (auth.uid() = user_id);

-- ============================================
-- 13. FUNCTIONS & TRIGGERS
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
CREATE TRIGGER update_sessions_updated_at BEFORE UPDATE ON public.sessions
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_potions_updated_at BEFORE UPDATE ON public.potions
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_shop_items_updated_at BEFORE UPDATE ON public.shop_items
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_user_data_updated_at BEFORE UPDATE ON public.user_data
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

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
CREATE TRIGGER on_user_created_add_default_items
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION add_default_items_to_inventory();

-- ============================================
-- 14. INITIAL DATA (Default Items & Types)
-- ============================================

-- Insert default potion types (will be done via app, but template here)
-- These are created when app initializes local database

-- ============================================
-- NOTES:
-- ============================================
-- 1. Potion rendering: Store render_url or render_path (Supabase Storage)
-- 2. User inventory: Tracks what users own from shop AND recipes
-- 3. Shop transactions: Full audit trail of essence spending/rewards
-- 4. Unlocks: Separate tracking for Grimoire (recipes) vs Shop
-- 5. Potion types: Defines available potion configurations
-- 6. Default items: Automatically added to inventory on signup
-- 7. RLS ensures data isolation per user



