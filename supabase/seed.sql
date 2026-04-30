-- ============================================================
-- THE DISCIPLES — Seed Data
-- setup.sh auto-injects UUIDs. If running manually:
--   1. Create users in Supabase Dashboard → Auth → Users
--   2. Replace the placeholder UUIDs below
--   3. Run this file in Supabase SQL Editor
-- ============================================================

-- Roles
INSERT INTO roles (name, description) VALUES
  ('admin',     'Full system access'),
  ('discipler', 'Leads a group of max 8 disciples'),
  ('disciple',  'Member going through discipleship tracks')
ON CONFLICT (name) DO NOTHING;

-- Admin member
INSERT INTO members (auth_id, name, email, role_id, is_discipler, status, joined_at)
VALUES (
  'ADMIN-AUTH-UUID-HERE',
  'Shantal Admin',
  'shantalr@team.co.zw',
  (SELECT id FROM roles WHERE name = 'admin'),
  FALSE, 'active', NOW()
) ON CONFLICT (email) DO NOTHING;

-- Discipler member
INSERT INTO members (auth_id, name, email, role_id, is_discipler, status, joined_at)
VALUES (
  'DISCIPLER-AUTH-UUID-HERE',
  'Shantal Discipler',
  'shantalrencot@gmail.com',
  (SELECT id FROM roles WHERE name = 'discipler'),
  TRUE, 'active', NOW()
) ON CONFLICT (email) DO NOTHING;

-- Disciple member
INSERT INTO members (auth_id, name, email, role_id, is_discipler, status, joined_at)
VALUES (
  'DISCIPLE-AUTH-UUID-HERE',
  'Shantal Disciple',
  'rencoshantalt@gmail.com',
  (SELECT id FROM roles WHERE name = 'disciple'),
  FALSE, 'active', NOW()
) ON CONFLICT (email) DO NOTHING;

-- 4 default tracks
INSERT INTO tracks (title, description, order_index, duration_weeks, is_active) VALUES
  ('Track 1 — Foundation',     'Core discipleship foundations',         1, 6, TRUE),
  ('Track 2 — Growth',         'Growing in faith and community',        2, 8, TRUE),
  ('Track 3 — Leadership',     'Preparing to lead and disciple others', 3, 8, TRUE),
  ('Track 4 — Multiplication', 'Multiplying disciples and groups',      4, 6, TRUE)
ON CONFLICT DO NOTHING;

-- Modules for Track 1
INSERT INTO modules (track_id, title, order_index) VALUES
  ((SELECT id FROM tracks WHERE order_index = 1), 'Who is God?',               1),
  ((SELECT id FROM tracks WHERE order_index = 1), 'Who am I in Christ?',       2),
  ((SELECT id FROM tracks WHERE order_index = 1), 'The Word of God',           3),
  ((SELECT id FROM tracks WHERE order_index = 1), 'Prayer',                    4),
  ((SELECT id FROM tracks WHERE order_index = 1), 'The Holy Spirit',           5),
  ((SELECT id FROM tracks WHERE order_index = 1), 'Church and Community',      6)
ON CONFLICT DO NOTHING;

-- Modules for Track 2
INSERT INTO modules (track_id, title, order_index) VALUES
  ((SELECT id FROM tracks WHERE order_index = 2), 'Spiritual Disciplines',     1),
  ((SELECT id FROM tracks WHERE order_index = 2), 'Faith and Works',           2),
  ((SELECT id FROM tracks WHERE order_index = 2), 'Serving Others',            3),
  ((SELECT id FROM tracks WHERE order_index = 2), 'Stewardship',               4),
  ((SELECT id FROM tracks WHERE order_index = 2), 'Evangelism',                5),
  ((SELECT id FROM tracks WHERE order_index = 2), 'Relationships',             6),
  ((SELECT id FROM tracks WHERE order_index = 2), 'Conflict Resolution',       7),
  ((SELECT id FROM tracks WHERE order_index = 2), 'Spiritual Growth Review',   8)
ON CONFLICT DO NOTHING;

-- Modules for Track 3
INSERT INTO modules (track_id, title, order_index) VALUES
  ((SELECT id FROM tracks WHERE order_index = 3), 'Character of a Leader',     1),
  ((SELECT id FROM tracks WHERE order_index = 3), 'Servant Leadership',        2),
  ((SELECT id FROM tracks WHERE order_index = 3), 'Vision and Mission',        3),
  ((SELECT id FROM tracks WHERE order_index = 3), 'Mentoring Others',          4),
  ((SELECT id FROM tracks WHERE order_index = 3), 'Handling Authority',        5),
  ((SELECT id FROM tracks WHERE order_index = 3), 'Accountability',            6),
  ((SELECT id FROM tracks WHERE order_index = 3), 'Team Dynamics',             7),
  ((SELECT id FROM tracks WHERE order_index = 3), 'Leadership Review',         8)
ON CONFLICT DO NOTHING;

-- Modules for Track 4
INSERT INTO modules (track_id, title, order_index) VALUES
  ((SELECT id FROM tracks WHERE order_index = 4), 'The Great Commission',      1),
  ((SELECT id FROM tracks WHERE order_index = 4), 'Making Disciples',          2),
  ((SELECT id FROM tracks WHERE order_index = 4), 'Starting a Group',          3),
  ((SELECT id FROM tracks WHERE order_index = 4), 'Multiplication Strategy',   4),
  ((SELECT id FROM tracks WHERE order_index = 4), 'Sustaining Movements',      5),
  ((SELECT id FROM tracks WHERE order_index = 4), 'Graduation & Commissioning',6)
ON CONFLICT DO NOTHING;
