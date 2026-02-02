# Supabase Setup Guide for Potion Focus

## Configuration Complete ✅

Your Supabase project has been integrated with the app:
- **Project ID:** cfvmnhrldqlrpdwerhzn
- **URL:** https://cfvmnhrldqlrpdwerhzn.supabase.co
- **Publishable Key:** Configured in app

## Required Database Tables

Run these SQL commands in your Supabase SQL Editor to create the necessary tables:

### 1. Sessions Table

```sql
CREATE TABLE IF NOT EXISTS sessions (
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

CREATE INDEX IF NOT EXISTS sessions_user_id_idx ON sessions(user_id);
CREATE INDEX IF NOT EXISTS sessions_started_at_idx ON sessions(started_at);
CREATE INDEX IF NOT EXISTS sessions_user_updated_idx ON sessions(user_id, updated_at);
```

### 2. Potions Table

```sql
CREATE TABLE IF NOT EXISTS potions (
  id TEXT PRIMARY KEY,
  session_id TEXT NOT NULL REFERENCES sessions(id) ON DELETE CASCADE,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  rarity TEXT NOT NULL DEFAULT 'common',
  essence_earned INTEGER NOT NULL DEFAULT 0,
  visual_config TEXT NOT NULL DEFAULT '{}',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS potions_user_id_idx ON potions(user_id);
CREATE INDEX IF NOT EXISTS potions_created_at_idx ON potions(created_at);
CREATE INDEX IF NOT EXISTS potions_rarity_idx ON potions(rarity);
```

### 3. Quests Table

```sql
CREATE TABLE IF NOT EXISTS quests (
  id TEXT PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  tag TEXT NOT NULL,
  quest_type TEXT NOT NULL,
  timeframe TEXT NOT NULL,
  target_value INTEGER NOT NULL,
  current_progress INTEGER NOT NULL DEFAULT 0,
  status TEXT NOT NULL DEFAULT 'active',
  essence_reward INTEGER NOT NULL DEFAULT 0,
  generated_at TIMESTAMPTZ NOT NULL,
  expires_at TIMESTAMPTZ NOT NULL,
  completed_at TIMESTAMPTZ,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS quests_user_id_idx ON quests(user_id);
CREATE INDEX IF NOT EXISTS quests_status_idx ON quests(status);
CREATE INDEX IF NOT EXISTS quests_expires_at_idx ON quests(expires_at);
```

### 4. User Data Table

```sql
CREATE TABLE IF NOT EXISTS user_data (
  user_id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  essence_balance INTEGER NOT NULL DEFAULT 0,
  total_focus_minutes INTEGER NOT NULL DEFAULT 0,
  total_potions INTEGER NOT NULL DEFAULT 0,
  streak_days INTEGER NOT NULL DEFAULT 0,
  last_focus_date TIMESTAMPTZ,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
```

## Row Level Security (RLS) Policies

Enable RLS and create policies for data isolation:

### Enable RLS

```sql
ALTER TABLE sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE potions ENABLE ROW LEVEL SECURITY;
ALTER TABLE quests ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_data ENABLE ROW LEVEL SECURITY;
```

### Sessions Policies

```sql
-- Users can only see their own sessions
CREATE POLICY "Users can view own sessions"
  ON sessions FOR SELECT
  USING (auth.uid() = user_id);

-- Users can insert their own sessions
CREATE POLICY "Users can insert own sessions"
  ON sessions FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Users can update their own sessions
CREATE POLICY "Users can update own sessions"
  ON sessions FOR UPDATE
  USING (auth.uid() = user_id);
```

### Potions Policies

```sql
-- Users can only see their own potions
CREATE POLICY "Users can view own potions"
  ON potions FOR SELECT
  USING (auth.uid() = user_id);

-- Users can insert their own potions
CREATE POLICY "Users can insert own potions"
  ON potions FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Users can update their own potions
CREATE POLICY "Users can update own potions"
  ON potions FOR UPDATE
  USING (auth.uid() = user_id);
```

### Quests Policies

```sql
-- Users can only see their own quests
CREATE POLICY "Users can view own quests"
  ON quests FOR SELECT
  USING (auth.uid() = user_id);

-- Users can insert their own quests
CREATE POLICY "Users can insert own quests"
  ON quests FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Users can update their own quests
CREATE POLICY "Users can update own quests"
  ON quests FOR UPDATE
  USING (auth.uid() = user_id);
```

### User Data Policies

```sql
-- Users can only see their own data
CREATE POLICY "Users can view own user_data"
  ON user_data FOR SELECT
  USING (auth.uid() = user_id);

-- Users can insert their own data
CREATE POLICY "Users can insert own user_data"
  ON user_data FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Users can update their own data
CREATE POLICY "Users can update own user_data"
  ON user_data FOR UPDATE
  USING (auth.uid() = user_id);
```

## Authentication Setup

### Enable Anonymous Auth (Optional)

In Supabase Dashboard:
1. Go to Authentication → Providers
2. Enable "Anonymous" provider
3. This allows offline-first functionality without requiring email sign-up

### Enable Email Auth

Already enabled by default. Users can:
- Sign up with email/password
- Sign in with email/password
- Reset password via email

## Sync Behavior

The app uses an **offline-first** approach:

1. **All writes go to local database first**
2. **Sync happens in background when online**
3. **Last-write-wins conflict resolution**
4. **Silent failures** - app never blocks on sync
5. **Automatic retry** on next sync interval (5 minutes)

## Testing Sync

1. **Enable sync in app:**
   - App will attempt anonymous sign-in automatically
   - Or implement sign-in UI (future feature)

2. **Check Supabase Dashboard:**
   - Go to Table Editor
   - Verify data appears after sync

3. **Test offline/online:**
   - Disable internet → app works normally
   - Enable internet → data syncs automatically

## Monitoring

### Check Sync Status

In Supabase Dashboard:
- **Logs:** Check API logs for sync requests
- **Table Editor:** View synced data
- **Database:** Check for errors in Postgres logs

### Common Issues

1. **RLS blocking writes:**
   - Verify policies are created correctly
   - Check user is authenticated

2. **Sync not working:**
   - Check connectivity
   - Verify Supabase URL and keys
   - Check browser console for errors

3. **Data conflicts:**
   - Last-write-wins is used
   - Essence balance uses maximum (safety net)

## Next Steps

1. ✅ Run SQL scripts above in Supabase SQL Editor
2. ✅ Enable RLS and create policies
3. ✅ Test sync with anonymous auth
4. ⏳ (Optional) Add email auth UI
5. ⏳ (Optional) Add sync status indicator in app

## Notes

- **Secret key is server-side only** - not used in app
- **All data is user-isolated** via RLS
- **App works fully offline** - sync is optional
- **No sensitive data** in sync payloads



