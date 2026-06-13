-- ─────────────────────────────────────────────────────────────────
-- Configure / Custom Order Submissions
-- Run this in the Supabase SQL Editor
-- ─────────────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS configure_submissions (
  id               UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  ref_code         TEXT        NOT NULL,
  first_name       TEXT        NOT NULL,
  last_name        TEXT        NOT NULL,
  email            TEXT        NOT NULL,
  phone            TEXT        NOT NULL,
  province         TEXT,
  timeline         TEXT,
  notes            TEXT,
  reference_images TEXT,
  furniture_name   TEXT,
  furniture_id     TEXT,
  dimensions       JSONB,
  timber           TEXT,
  finish_type      TEXT,
  upholstery       TEXT,
  fabric_colour    TEXT,
  hardware         TEXT,
  features         TEXT[],
  estimated_total  NUMERIC,
  is_read          BOOLEAN     NOT NULL DEFAULT FALSE,
  created_at       TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

ALTER TABLE configure_submissions ENABLE ROW LEVEL SECURITY;

-- Public form can insert
CREATE POLICY "anon_insert_configure" ON configure_submissions
  FOR INSERT TO anon WITH CHECK (true);

-- Admin (authenticated) can do everything
CREATE POLICY "auth_all_configure" ON configure_submissions
  FOR ALL TO authenticated USING (true) WITH CHECK (true);
