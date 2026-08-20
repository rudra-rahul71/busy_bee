-- Busy Bee Initial Database Migration
-- Multi-tenant schema isolation for 'busy_bee'

-- -------------------------------------------------------------
-- 1. CREATE BUSY_BEE SCHEMA AND GRANT USAGE
-- -------------------------------------------------------------
CREATE SCHEMA IF NOT EXISTS busy_bee;
GRANT USAGE ON SCHEMA busy_bee TO anon, authenticated, service_role;


-- -------------------------------------------------------------
-- 2. CREATE BUSY_BEE TABLES
-- -------------------------------------------------------------

-- User Profiles (1:1 with auth.users)
CREATE TABLE IF NOT EXISTS busy_bee.user_profiles (
    id UUID PRIMARY KEY DEFAULT auth.uid() REFERENCES auth.users(id) ON DELETE CASCADE,
    "displayName" TEXT,
    "themePreference" TEXT DEFAULT 'system',
    "createdAt" TIMESTAMPTZ NOT NULL DEFAULT now(),
    "updatedAt" TIMESTAMPTZ NOT NULL DEFAULT now()
);


-- -------------------------------------------------------------
-- 3. ENABLE ROW LEVEL SECURITY (RLS)
-- -------------------------------------------------------------
ALTER TABLE busy_bee.user_profiles ENABLE ROW LEVEL SECURITY;


-- -------------------------------------------------------------
-- 4. CREATE SECURITY POLICIES
-- -------------------------------------------------------------
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies WHERE schemaname = 'busy_bee' AND tablename = 'user_profiles' AND policyname = 'Users can access their own profile'
    ) THEN
        CREATE POLICY "Users can access their own profile" ON busy_bee.user_profiles
            FOR ALL USING (auth.uid() = id) WITH CHECK (auth.uid() = id);
    END IF;
END $$;


-- -------------------------------------------------------------
-- 5. GRANT PRIVILEGES TO AUTHENTICATED ROLE
-- -------------------------------------------------------------
GRANT ALL ON ALL TABLES IN SCHEMA busy_bee TO authenticated, service_role;
GRANT ALL ON ALL SEQUENCES IN SCHEMA busy_bee TO authenticated, service_role;


-- -------------------------------------------------------------
-- 6. ENABLE REALTIME BROADCASTING & REPLICA IDENTITY
-- -------------------------------------------------------------
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_publication_tables 
        WHERE pubname = 'supabase_realtime' 
          AND schemaname = 'busy_bee' 
          AND tablename = 'user_profiles'
    ) THEN
        ALTER PUBLICATION supabase_realtime ADD TABLE busy_bee.user_profiles;
    END IF;
END $$;

ALTER TABLE busy_bee.user_profiles REPLICA IDENTITY FULL;
