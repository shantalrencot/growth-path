#!/bin/bash
# ============================================================
# THE DISCIPLES — Automated Project Setup Script
# Run once in the cloned repo folder: bash setup.sh
# ============================================================

set -e

echo ""
echo "╔══════════════════════════════════════════╗"
echo "║   The Disciples — Project Setup          ║"
echo "╚══════════════════════════════════════════╝"
echo ""

# ── Step 1: Prerequisites check ──────────────────────────────
echo "▶ Checking prerequisites..."
command -v node >/dev/null 2>&1 || { echo "❌ Node.js required. Install from nodejs.org"; exit 1; }
command -v npm  >/dev/null 2>&1 || { echo "❌ npm required."; exit 1; }
command -v git  >/dev/null 2>&1 || { echo "❌ Git required."; exit 1; }
command -v curl >/dev/null 2>&1 || { echo "❌ curl required."; exit 1; }

NODE_VERSION=$(node -v | cut -d'v' -f2 | cut -d'.' -f1)
if [ "$NODE_VERSION" -lt 18 ]; then
  echo "❌ Node.js 18+ required. Current: $(node -v)"; exit 1
fi
echo "✅ Node $(node -v), npm $(npm -v)"

# ── Step 2: Collect Supabase credentials ─────────────────────
echo ""
echo "▶ Supabase credentials (from your Supabase project → Settings → API)"
echo "  Leave blank if you want to fill in .env.local manually later."
echo ""

read -p "  SUPABASE_URL (e.g. https://xxx.supabase.co): " SUPABASE_URL
read -p "  SUPABASE_ANON_KEY: "                          SUPABASE_ANON_KEY
read -p "  SUPABASE_SERVICE_ROLE_KEY: "                  SERVICE_ROLE_KEY

# ── Step 3: Install dependencies ─────────────────────────────
echo ""
echo "▶ Installing dependencies..."
npm install \
  @supabase/supabase-js \
  @supabase/ssr \
  lucide-react \
  clsx \
  tailwind-merge \
  date-fns \
  react-hot-toast
npm install -D @types/node
echo "✅ Dependencies installed"

# ── Step 4: Environment files ─────────────────────────────────
echo ""
echo "▶ Writing environment files..."
cat > .env.local << EOF
# Supabase
NEXT_PUBLIC_SUPABASE_URL=${SUPABASE_URL}
NEXT_PUBLIC_SUPABASE_ANON_KEY=${SUPABASE_ANON_KEY}
SUPABASE_SERVICE_ROLE_KEY=${SERVICE_ROLE_KEY}

# App
NEXT_PUBLIC_APP_NAME=The Disciples
NEXT_PUBLIC_APP_URL=http://localhost:3000
EOF
echo "✅ .env.local written"

# ── Step 5: Secure .gitignore ─────────────────────────────────
if ! grep -q ".env.local" .gitignore 2>/dev/null; then
printf '\n# Environment — NEVER commit these\n.env.local\n.env.*.local\n.supabase/\n' >> .gitignore
fi
echo "✅ .gitignore secured"

# ── Step 6: Run schema via Supabase CLI or print instructions ──
echo ""
if command -v supabase >/dev/null 2>&1 && [ -n "$SUPABASE_URL" ]; then
  PROJECT_REF=$(echo "$SUPABASE_URL" | sed 's|https://||' | cut -d'.' -f1)
  echo "▶ Linking Supabase project ($PROJECT_REF)..."
  supabase link --project-ref "$PROJECT_REF" --password "" 2>/dev/null || true
  echo "▶ Pushing schema..."
  supabase db push 2>/dev/null && echo "✅ Schema pushed via Supabase CLI" || {
    echo "⚠  CLI push failed — run SQL files manually (see below)"
  }
else
  echo "ℹ  Supabase CLI not found (or no URL provided)."
  echo "   → Install: npm install -g supabase"
  echo "   → Or run supabase/schema.sql then supabase/rls_policies.sql"
  echo "     manually in the Supabase SQL Editor."
fi

# ── Step 7: Auto-create Auth users via Admin API ──────────────
if [ -n "$SUPABASE_URL" ] && [ -n "$SERVICE_ROLE_KEY" ]; then
  echo ""
  echo "▶ Creating Auth users via Supabase Admin API..."

  create_user() {
    local EMAIL="$1"
    local PASSWORD="$2"
    local RESPONSE
    RESPONSE=$(curl -s -X POST \
      "${SUPABASE_URL}/auth/v1/admin/users" \
      -H "apikey: ${SERVICE_ROLE_KEY}" \
      -H "Authorization: Bearer ${SERVICE_ROLE_KEY}" \
      -H "Content-Type: application/json" \
      -d "{\"email\":\"${EMAIL}\",\"password\":\"${PASSWORD}\",\"email_confirm\":true}")
    echo "$RESPONSE" | grep -o '"id":"[^"]*"' | head -1 | cut -d'"' -f4
  }

  ADMIN_UUID=$(create_user "shantalr@team.co.zw" "Disciples2024!")
  DISCIPLER_UUID=$(create_user "shantalrencot@gmail.com" "Disciples2024!")
  DISCIPLE_UUID=$(create_user "rencoshantalt@gmail.com" "Disciples2024!")

  if [ -n "$ADMIN_UUID" ] && [ "$ADMIN_UUID" != "null" ]; then
    echo "  ✅ Admin user:     $ADMIN_UUID"
  else
    echo "  ⚠  Admin user already exists or creation failed — update UUID manually"
    ADMIN_UUID="ADMIN-AUTH-UUID-HERE"
  fi

  if [ -n "$DISCIPLER_UUID" ] && [ "$DISCIPLER_UUID" != "null" ]; then
    echo "  ✅ Discipler user: $DISCIPLER_UUID"
  else
    echo "  ⚠  Discipler user already exists or creation failed — update UUID manually"
    DISCIPLER_UUID="DISCIPLER-AUTH-UUID-HERE"
  fi

  if [ -n "$DISCIPLE_UUID" ] && [ "$DISCIPLE_UUID" != "null" ]; then
    echo "  ✅ Disciple user:  $DISCIPLE_UUID"
  else
    echo "  ⚠  Disciple user already exists or creation failed — update UUID manually"
    DISCIPLE_UUID="DISCIPLE-AUTH-UUID-HERE"
  fi

  # Patch UUIDs into seed.sql
  sed -i \
    -e "s/ADMIN-AUTH-UUID-HERE/${ADMIN_UUID}/g" \
    -e "s/DISCIPLER-AUTH-UUID-HERE/${DISCIPLER_UUID}/g" \
    -e "s/DISCIPLE-AUTH-UUID-HERE/${DISCIPLE_UUID}/g" \
    supabase/seed.sql
  echo "✅ UUIDs injected into supabase/seed.sql"
else
  echo ""
  echo "ℹ  Skipping Auth user creation (no Supabase URL / service role key)."
  echo "   → Create users in Supabase Dashboard → Authentication → Users"
  echo "   → Paste UUIDs into supabase/seed.sql manually"
fi

# ── Step 8: Run seed SQL via REST API ─────────────────────────
if [ -n "$SUPABASE_URL" ] && [ -n "$SERVICE_ROLE_KEY" ] \
   && [ "$ADMIN_UUID" != "ADMIN-AUTH-UUID-HERE" ]; then
  echo ""
  echo "▶ Running seed SQL..."
  SEED_SQL=$(cat supabase/seed.sql)
  SEED_RESPONSE=$(curl -s -X POST \
    "${SUPABASE_URL}/rest/v1/rpc/exec_sql" \
    -H "apikey: ${SERVICE_ROLE_KEY}" \
    -H "Authorization: Bearer ${SERVICE_ROLE_KEY}" \
    -H "Content-Type: application/json" \
    -d "{\"query\": $(echo "$SEED_SQL" | jq -Rs .)}" 2>/dev/null || echo "skipped")

  if echo "$SEED_RESPONSE" | grep -q "error"; then
    echo "  ⚠  Seed via REST failed — run supabase/seed.sql manually in SQL Editor"
  else
    echo "✅ Seed data inserted"
  fi
fi

# ── Step 9: GitHub repo (optional, requires gh CLI) ───────────
echo ""
if command -v gh >/dev/null 2>&1; then
  read -p "▶ Create GitHub repo? (y/N): " CREATE_GH
  if [[ "$CREATE_GH" =~ ^[Yy]$ ]]; then
    read -p "  Repo name (e.g. disciples-app): " GH_REPO
    gh repo create "$GH_REPO" --private --source=. --remote=origin --push \
      && echo "✅ GitHub repo created and pushed" \
      || echo "⚠  GitHub repo creation failed — push manually"
  fi
else
  echo "ℹ  gh CLI not found — push to GitHub manually:"
  echo "   git remote add origin <your-repo-url>"
  echo "   git push -u origin main"
fi

# ── Step 10: Vercel deployment (optional) ────────────────────
echo ""
if command -v vercel >/dev/null 2>&1; then
  read -p "▶ Deploy to Vercel now? (y/N): " DEPLOY_VERCEL
  if [[ "$DEPLOY_VERCEL" =~ ^[Yy]$ ]]; then
    vercel --yes && echo "✅ Deployed to Vercel"
  fi
else
  echo "ℹ  Vercel CLI not found — deploy later:"
  echo "   npm install -g vercel && vercel"
fi

# ── Step 11: Start dev server ────────────────────────────────
echo ""
echo "╔══════════════════════════════════════════════════════════╗"
echo "║   ✅ Setup Complete!                                     ║"
echo "╠══════════════════════════════════════════════════════════╣"
echo "║                                                          ║"
echo "║   Remaining manual steps (if auto-steps were skipped):  ║"
echo "║   1. Fill in .env.local with Supabase values            ║"
echo "║   2. Run supabase/schema.sql in Supabase SQL Editor      ║"
echo "║   3. Run supabase/rls_policies.sql in SQL Editor         ║"
echo "║   4. Run supabase/seed.sql in SQL Editor                 ║"
echo "║                                                          ║"
echo "║   Default test passwords: Disciples2024!                 ║"
echo "║                                                          ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo ""
read -p "▶ Start dev server now? (Y/n): " START_DEV
if [[ ! "$START_DEV" =~ ^[Nn]$ ]]; then
  npm run dev
fi
