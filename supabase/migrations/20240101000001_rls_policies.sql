-- ============================================================
-- Migration 0002: Row Level Security
-- Idempotent — drops all policies before recreating them
-- ============================================================

-- ── Helper functions ──────────────────────────────────────────
CREATE OR REPLACE FUNCTION get_my_role()
RETURNS TEXT AS $$
  SELECT r.name FROM members m
  JOIN roles r ON r.id = m.role_id
  WHERE m.auth_id = auth.uid() LIMIT 1
$$ LANGUAGE sql SECURITY DEFINER STABLE;

CREATE OR REPLACE FUNCTION get_my_member_id()
RETURNS UUID AS $$
  SELECT id FROM members WHERE auth_id = auth.uid() LIMIT 1
$$ LANGUAGE sql SECURITY DEFINER STABLE;

CREATE OR REPLACE FUNCTION is_admin()
RETURNS BOOLEAN AS $$
  SELECT get_my_role() = 'admin'
$$ LANGUAGE sql SECURITY DEFINER STABLE;

CREATE OR REPLACE FUNCTION is_discipler()
RETURNS BOOLEAN AS $$
  SELECT get_my_role() IN ('admin', 'discipler')
$$ LANGUAGE sql SECURITY DEFINER STABLE;

CREATE OR REPLACE FUNCTION i_lead_this_member(p_member_id UUID)
RETURNS BOOLEAN AS $$
  SELECT EXISTS (
    SELECT 1 FROM discipleship_groups g
    JOIN group_members gm ON gm.group_id = g.id
    WHERE g.discipler_id = get_my_member_id() AND gm.member_id = p_member_id
  )
$$ LANGUAGE sql SECURITY DEFINER STABLE;

CREATE OR REPLACE FUNCTION i_am_in_meeting_group(p_meeting_id UUID)
RETURNS BOOLEAN AS $$
  SELECT EXISTS (
    SELECT 1 FROM meetings mt
    JOIN group_members gm ON gm.group_id = mt.group_id
    WHERE mt.id = p_meeting_id AND gm.member_id = get_my_member_id()
  )
$$ LANGUAGE sql SECURITY DEFINER STABLE;

-- ── Enable RLS ────────────────────────────────────────────────
ALTER TABLE roles               ENABLE ROW LEVEL SECURITY;
ALTER TABLE members             ENABLE ROW LEVEL SECURITY;
ALTER TABLE tracks              ENABLE ROW LEVEL SECURITY;
ALTER TABLE modules             ENABLE ROW LEVEL SECURITY;
ALTER TABLE discipleship_groups ENABLE ROW LEVEL SECURITY;
ALTER TABLE group_members       ENABLE ROW LEVEL SECURITY;
ALTER TABLE member_progress     ENABLE ROW LEVEL SECURITY;
ALTER TABLE meetings            ENABLE ROW LEVEL SECURITY;
ALTER TABLE attendance          ENABLE ROW LEVEL SECURITY;

-- ── Drop all existing policies (idempotency) ──────────────────
DO $$ DECLARE r RECORD;
BEGIN
  FOR r IN SELECT policyname, tablename FROM pg_policies
           WHERE schemaname = 'public' LOOP
    EXECUTE format('DROP POLICY IF EXISTS %I ON %I', r.policyname, r.tablename);
  END LOOP;
END $$;

-- ── ROLES ─────────────────────────────────────────────────────
CREATE POLICY "roles_select_all"    ON roles FOR SELECT TO authenticated USING (TRUE);
CREATE POLICY "roles_admin_write"   ON roles FOR ALL    TO authenticated
  USING (is_admin()) WITH CHECK (is_admin());

-- ── MEMBERS ───────────────────────────────────────────────────
CREATE POLICY "members_admin_all"   ON members FOR ALL  TO authenticated
  USING (is_admin()) WITH CHECK (is_admin());

CREATE POLICY "members_discipler_select" ON members FOR SELECT TO authenticated
  USING (is_discipler() AND (id = get_my_member_id() OR i_lead_this_member(id)));

CREATE POLICY "members_self_select" ON members FOR SELECT TO authenticated
  USING (auth_id = auth.uid());

CREATE POLICY "members_self_update" ON members FOR UPDATE TO authenticated
  USING (auth_id = auth.uid()) WITH CHECK (auth_id = auth.uid());

-- ── TRACKS ───────────────────────────────────────────────────
CREATE POLICY "tracks_select_active" ON tracks FOR SELECT TO authenticated
  USING (is_active = TRUE OR is_admin());

CREATE POLICY "tracks_admin_write"  ON tracks FOR ALL   TO authenticated
  USING (is_admin()) WITH CHECK (is_admin());

-- ── MODULES ───────────────────────────────────────────────────
CREATE POLICY "modules_select_active" ON modules FOR SELECT TO authenticated
  USING (is_active = TRUE OR is_admin());

CREATE POLICY "modules_admin_write" ON modules FOR ALL  TO authenticated
  USING (is_admin()) WITH CHECK (is_admin());

-- ── DISCIPLESHIP_GROUPS ───────────────────────────────────────
CREATE POLICY "groups_admin_all"    ON discipleship_groups FOR ALL TO authenticated
  USING (is_admin()) WITH CHECK (is_admin());

CREATE POLICY "groups_discipler_select" ON discipleship_groups FOR SELECT TO authenticated
  USING (discipler_id = get_my_member_id());

CREATE POLICY "groups_member_select" ON discipleship_groups FOR SELECT TO authenticated
  USING (EXISTS (
    SELECT 1 FROM group_members gm
    WHERE gm.group_id = id AND gm.member_id = get_my_member_id()
  ));

-- ── GROUP_MEMBERS ─────────────────────────────────────────────
CREATE POLICY "group_members_admin_all" ON group_members FOR ALL TO authenticated
  USING (is_admin()) WITH CHECK (is_admin());

CREATE POLICY "group_members_discipler_all" ON group_members FOR ALL TO authenticated
  USING (EXISTS (
    SELECT 1 FROM discipleship_groups g
    WHERE g.id = group_id AND g.discipler_id = get_my_member_id()
  ))
  WITH CHECK (EXISTS (
    SELECT 1 FROM discipleship_groups g
    WHERE g.id = group_id AND g.discipler_id = get_my_member_id()
  ));

CREATE POLICY "group_members_self_select" ON group_members FOR SELECT TO authenticated
  USING (member_id = get_my_member_id());

-- ── MEMBER_PROGRESS ───────────────────────────────────────────
CREATE POLICY "progress_admin_all"  ON member_progress FOR ALL TO authenticated
  USING (is_admin()) WITH CHECK (is_admin());

CREATE POLICY "progress_discipler_all" ON member_progress FOR ALL TO authenticated
  USING (is_discipler() AND i_lead_this_member(member_id))
  WITH CHECK (is_discipler() AND i_lead_this_member(member_id));

CREATE POLICY "progress_self_select" ON member_progress FOR SELECT TO authenticated
  USING (member_id = get_my_member_id());

CREATE POLICY "progress_self_update" ON member_progress FOR UPDATE TO authenticated
  USING (member_id = get_my_member_id()) WITH CHECK (member_id = get_my_member_id());

CREATE POLICY "progress_self_insert" ON member_progress FOR INSERT TO authenticated
  WITH CHECK (member_id = get_my_member_id());

-- ── MEETINGS ──────────────────────────────────────────────────
CREATE POLICY "meetings_admin_all"  ON meetings FOR ALL TO authenticated
  USING (is_admin()) WITH CHECK (is_admin());

CREATE POLICY "meetings_discipler_all" ON meetings FOR ALL TO authenticated
  USING (EXISTS (
    SELECT 1 FROM discipleship_groups g
    WHERE g.id = group_id AND g.discipler_id = get_my_member_id()
  ))
  WITH CHECK (EXISTS (
    SELECT 1 FROM discipleship_groups g
    WHERE g.id = group_id AND g.discipler_id = get_my_member_id()
  ));

CREATE POLICY "meetings_member_select" ON meetings FOR SELECT TO authenticated
  USING (EXISTS (
    SELECT 1 FROM group_members gm
    WHERE gm.group_id = group_id AND gm.member_id = get_my_member_id()
  ));

-- ── ATTENDANCE ────────────────────────────────────────────────
CREATE POLICY "attendance_admin_all" ON attendance FOR ALL TO authenticated
  USING (is_admin()) WITH CHECK (is_admin());

CREATE POLICY "attendance_discipler_all" ON attendance FOR ALL TO authenticated
  USING (EXISTS (
    SELECT 1 FROM meetings mt
    JOIN discipleship_groups g ON g.id = mt.group_id
    WHERE mt.id = meeting_id AND g.discipler_id = get_my_member_id()
  ))
  WITH CHECK (EXISTS (
    SELECT 1 FROM meetings mt
    JOIN discipleship_groups g ON g.id = mt.group_id
    WHERE mt.id = meeting_id AND g.discipler_id = get_my_member_id()
  ));

CREATE POLICY "attendance_self_select" ON attendance FOR SELECT TO authenticated
  USING (member_id = get_my_member_id());
