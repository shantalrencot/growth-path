-- ============================================================
-- THE DISCIPLES — Database Schema
-- Run this FIRST in Supabase SQL Editor before rls_policies.sql
-- ============================================================

-- ── Extensions ───────────────────────────────────────────────
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ── Helper: auto-update updated_at ───────────────────────────
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ── Roles ─────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS roles (
  id          UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  name        TEXT        UNIQUE NOT NULL,
  description TEXT,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

-- ── Members ───────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS members (
  id           UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  auth_id      UUID        UNIQUE REFERENCES auth.users(id) ON DELETE SET NULL,
  name         TEXT        NOT NULL,
  email        TEXT        UNIQUE NOT NULL,
  phone        TEXT,
  gender       TEXT        CHECK (gender IN ('male', 'female', 'other')),
  home_group   TEXT,
  role_id      UUID        NOT NULL REFERENCES roles(id),
  is_discipler BOOLEAN     DEFAULT FALSE,
  discipler_id UUID        REFERENCES members(id) ON DELETE SET NULL,
  status       TEXT        DEFAULT 'active' CHECK (status IN ('active', 'inactive')),
  joined_at    TIMESTAMPTZ DEFAULT NOW(),
  created_at   TIMESTAMPTZ DEFAULT NOW(),
  updated_at   TIMESTAMPTZ DEFAULT NOW()
);

CREATE TRIGGER members_updated_at
  BEFORE UPDATE ON members
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- ── Tracks ────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS tracks (
  id             UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  title          TEXT        NOT NULL,
  description    TEXT,
  order_index    INTEGER     NOT NULL DEFAULT 1,
  duration_weeks INTEGER     DEFAULT 6 CHECK (duration_weeks BETWEEN 1 AND 52),
  is_active      BOOLEAN     DEFAULT TRUE,
  created_at     TIMESTAMPTZ DEFAULT NOW(),
  updated_at     TIMESTAMPTZ DEFAULT NOW()
);

CREATE TRIGGER tracks_updated_at
  BEFORE UPDATE ON tracks
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- ── Modules ───────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS modules (
  id          UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  track_id    UUID        NOT NULL REFERENCES tracks(id) ON DELETE CASCADE,
  title       TEXT        NOT NULL,
  description TEXT,
  order_index INTEGER     NOT NULL DEFAULT 1,
  is_active   BOOLEAN     DEFAULT TRUE,
  created_at  TIMESTAMPTZ DEFAULT NOW(),
  updated_at  TIMESTAMPTZ DEFAULT NOW()
);

CREATE TRIGGER modules_updated_at
  BEFORE UPDATE ON modules
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- ── Discipleship Groups ───────────────────────────────────────
CREATE TABLE IF NOT EXISTS discipleship_groups (
  id           UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  name         TEXT        NOT NULL,
  discipler_id UUID        NOT NULL REFERENCES members(id),
  track_id     UUID        NOT NULL REFERENCES tracks(id),
  max_size     INTEGER     DEFAULT 8 CHECK (max_size BETWEEN 1 AND 20),
  is_active    BOOLEAN     DEFAULT TRUE,
  created_at   TIMESTAMPTZ DEFAULT NOW(),
  updated_at   TIMESTAMPTZ DEFAULT NOW()
);

CREATE TRIGGER discipleship_groups_updated_at
  BEFORE UPDATE ON discipleship_groups
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- ── Group Members ─────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS group_members (
  id        UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  group_id  UUID        NOT NULL REFERENCES discipleship_groups(id) ON DELETE CASCADE,
  member_id UUID        NOT NULL REFERENCES members(id) ON DELETE CASCADE,
  joined_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE (group_id, member_id)
);

-- ── Member Progress ───────────────────────────────────────────
CREATE TABLE IF NOT EXISTS member_progress (
  id           UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  member_id    UUID        NOT NULL REFERENCES members(id) ON DELETE CASCADE,
  module_id    UUID        NOT NULL REFERENCES modules(id) ON DELETE CASCADE,
  track_id     UUID        NOT NULL REFERENCES tracks(id),
  status       TEXT        DEFAULT 'not_started'
                           CHECK (status IN ('not_started', 'in_progress', 'completed')),
  completed_at TIMESTAMPTZ,
  updated_at   TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE (member_id, module_id)
);

CREATE TRIGGER member_progress_updated_at
  BEFORE UPDATE ON member_progress
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- Auto-set completed_at when status flips to completed
CREATE OR REPLACE FUNCTION set_completed_at()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.status = 'completed' AND OLD.status != 'completed' THEN
    NEW.completed_at = NOW();
  ELSIF NEW.status != 'completed' THEN
    NEW.completed_at = NULL;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER member_progress_completed_at
  BEFORE UPDATE ON member_progress
  FOR EACH ROW EXECUTE FUNCTION set_completed_at();

-- ── Meetings ──────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS meetings (
  id           UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  group_id     UUID        NOT NULL REFERENCES discipleship_groups(id) ON DELETE CASCADE,
  title        TEXT,
  scheduled_at TIMESTAMPTZ NOT NULL,
  location     TEXT,
  notes        TEXT,
  created_at   TIMESTAMPTZ DEFAULT NOW(),
  updated_at   TIMESTAMPTZ DEFAULT NOW()
);

CREATE TRIGGER meetings_updated_at
  BEFORE UPDATE ON meetings
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- ── Attendance ────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS attendance (
  id         UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  meeting_id UUID        NOT NULL REFERENCES meetings(id) ON DELETE CASCADE,
  member_id  UUID        NOT NULL REFERENCES members(id) ON DELETE CASCADE,
  attended   BOOLEAN     DEFAULT FALSE,
  notes      TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE (meeting_id, member_id)
);

-- ── Indexes ───────────────────────────────────────────────────
CREATE INDEX IF NOT EXISTS idx_members_auth_id      ON members(auth_id);
CREATE INDEX IF NOT EXISTS idx_members_role_id      ON members(role_id);
CREATE INDEX IF NOT EXISTS idx_members_status       ON members(status);
CREATE INDEX IF NOT EXISTS idx_modules_track_id     ON modules(track_id);
CREATE INDEX IF NOT EXISTS idx_groups_discipler_id  ON discipleship_groups(discipler_id);
CREATE INDEX IF NOT EXISTS idx_groups_track_id      ON discipleship_groups(track_id);
CREATE INDEX IF NOT EXISTS idx_group_members_group  ON group_members(group_id);
CREATE INDEX IF NOT EXISTS idx_group_members_member ON group_members(member_id);
CREATE INDEX IF NOT EXISTS idx_progress_member      ON member_progress(member_id);
CREATE INDEX IF NOT EXISTS idx_progress_module      ON member_progress(module_id);
CREATE INDEX IF NOT EXISTS idx_meetings_group       ON meetings(group_id);
CREATE INDEX IF NOT EXISTS idx_meetings_scheduled   ON meetings(scheduled_at);
CREATE INDEX IF NOT EXISTS idx_attendance_meeting   ON attendance(meeting_id);
CREATE INDEX IF NOT EXISTS idx_attendance_member    ON attendance(member_id);

-- ── Views ─────────────────────────────────────────────────────
CREATE OR REPLACE VIEW group_progress_summary AS
SELECT
  g.id                                                       AS group_id,
  g.name                                                     AS group_name,
  m.id                                                       AS member_id,
  m.name                                                     AS member_name,
  t.title                                                    AS track_title,
  COUNT(mo.id)                                               AS total_modules,
  COUNT(mp.id) FILTER (WHERE mp.status = 'completed')        AS completed_modules,
  ROUND(
    COUNT(mp.id) FILTER (WHERE mp.status = 'completed')::numeric
    / NULLIF(COUNT(mo.id), 0) * 100
  )                                                          AS completion_percentage
FROM discipleship_groups g
JOIN group_members gm   ON gm.group_id  = g.id
JOIN members m          ON m.id         = gm.member_id
JOIN tracks t           ON t.id         = g.track_id
JOIN modules mo         ON mo.track_id  = t.id AND mo.is_active = TRUE
LEFT JOIN member_progress mp
  ON mp.member_id = m.id AND mp.module_id = mo.id
GROUP BY g.id, g.name, m.id, m.name, t.title;

CREATE OR REPLACE VIEW attendance_summary AS
SELECT
  g.id                                                           AS group_id,
  g.name                                                         AS group_name,
  mt.id                                                          AS meeting_id,
  mt.scheduled_at,
  COUNT(a.id)                                                    AS total_members,
  COUNT(a.id) FILTER (WHERE a.attended = TRUE)                   AS attended_count,
  ROUND(
    COUNT(a.id) FILTER (WHERE a.attended = TRUE)::numeric
    / NULLIF(COUNT(a.id), 0) * 100
  )                                                              AS attendance_rate
FROM discipleship_groups g
JOIN meetings mt ON mt.group_id = g.id
LEFT JOIN attendance a ON a.meeting_id = mt.id
GROUP BY g.id, g.name, mt.id, mt.scheduled_at;
