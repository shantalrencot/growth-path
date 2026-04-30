#!/bin/bash
# ============================================================
# THE DISCIPLES — Fully Automated Project Setup
# Run once after cloning: bash setup.sh
# ============================================================

set -e

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; BOLD='\033[1m'; RESET='\033[0m'

info()    { echo -e "${BLUE}▶${RESET}  $*"; }
success() { echo -e "${GREEN}✅${RESET} $*"; }
warn()    { echo -e "${YELLOW}⚠️ ${RESET}  $*"; }
manual()  { echo -e "${YELLOW}👉 MANUAL:${RESET} $*"; }
step()    { echo -e "\n${BOLD}── $* ──${RESET}"; }

echo ""
echo -e "${BOLD}╔══════════════════════════════════════════╗${RESET}"
echo -e "${BOLD}║   The Disciples — Automated Setup        ║${RESET}"
echo -e "${BOLD}╚══════════════════════════════════════════╝${RESET}"
echo ""

# ── Prerequisites ─────────────────────────────────────────────
step "Checking prerequisites"

command -v node  >/dev/null 2>&1 || { echo "❌ Node.js required (nodejs.org)"; exit 1; }
command -v npm   >/dev/null 2>&1 || { echo "❌ npm required"; exit 1; }
command -v git   >/dev/null 2>&1 || { echo "❌ Git required"; exit 1; }
command -v curl  >/dev/null 2>&1 || { echo "❌ curl required"; exit 1; }

NODE_VER=$(node -v | cut -d'v' -f2 | cut -d'.' -f1)
[ "$NODE_VER" -lt 18 ] && { echo "❌ Node 18+ required (got $(node -v))"; exit 1; }
success "Node $(node -v)  npm $(npm -v)"

# ── Auto-install optional CLIs ────────────────────────────────
step "Checking optional CLIs"

if ! command -v supabase >/dev/null 2>&1; then
  warn "Supabase CLI not found — installing..."
  npm install -g supabase 2>/dev/null && success "Supabase CLI installed" \
    || warn "Could not install Supabase CLI — DB steps will be manual"
else
  success "Supabase CLI $(supabase --version 2>/dev/null | head -1)"
fi

if ! command -v vercel >/dev/null 2>&1; then
  warn "Vercel CLI not found — installing..."
  npm install -g vercel 2>/dev/null && success "Vercel CLI installed" \
    || warn "Could not install Vercel CLI — deploy step will be manual"
else
  success "Vercel CLI $(vercel --version 2>/dev/null | head -1)"
fi

if ! command -v gh >/dev/null 2>&1; then
  warn "GitHub CLI (gh) not found — GitHub secrets step will be manual"
  HAS_GH=false
else
  success "GitHub CLI $(gh --version | head -1)"
  HAS_GH=true
fi

# ── Collect Supabase credentials ──────────────────────────────
step "Supabase credentials"
echo "  Find these at: Supabase Dashboard → Project Settings → API"
echo ""

read -p "  Project ref (e.g. abcdefghijklmnop):   " SUPABASE_REF
read -p "  Project URL (https://xxx.supabase.co): " SUPABASE_URL
read -p "  Anon key:                              " SUPABASE_ANON_KEY
read -p "  Service role key:                      " SERVICE_ROLE_KEY
read -p "  Supabase access token (for CLI):       " SUPABASE_ACCESS_TOKEN

# ── npm install ───────────────────────────────────────────────
step "Installing dependencies"
npm install
success "Dependencies installed"

# ── .env.local ────────────────────────────────────────────────
step "Writing .env.local"
cat > .env.local <<EOF
NEXT_PUBLIC_SUPABASE_URL=${SUPABASE_URL}
NEXT_PUBLIC_SUPABASE_ANON_KEY=${SUPABASE_ANON_KEY}
SUPABASE_SERVICE_ROLE_KEY=${SERVICE_ROLE_KEY}
NEXT_PUBLIC_APP_NAME=The Disciples
NEXT_PUBLIC_APP_URL=http://localhost:3000
EOF
success ".env.local written"

# ── .gitignore guard ──────────────────────────────────────────
grep -q ".env.local" .gitignore 2>/dev/null \
  || printf '\n.env.local\n.env.*.local\n.supabase/\n' >> .gitignore

# ── Link Supabase project + push schema ──────────────────────
step "Supabase database setup"

if command -v supabase >/dev/null 2>&1 && [ -n "$SUPABASE_REF" ]; then
  info "Linking Supabase project..."

  if [ -n "$SUPABASE_ACCESS_TOKEN" ]; then
    export SUPABASE_ACCESS_TOKEN
    supabase link --project-ref "$SUPABASE_REF" 2>/dev/null \
      && success "Project linked" \
      || warn "Link failed — will try pushing SQL directly"
  fi

  info "Pushing schema migration..."
  supabase db push 2>/dev/null \
    && success "Schema pushed via Supabase CLI" \
    || {
      warn "supabase db push failed — running SQL via REST API..."
      _push_sql() {
        local FILE="$1"; local SQL; SQL=$(cat "$FILE")
        curl -s -X POST \
          "${SUPABASE_URL}/rest/v1/rpc/query" \
          -H "apikey: ${SERVICE_ROLE_KEY}" \
          -H "Authorization: Bearer ${SERVICE_ROLE_KEY}" \
          -H "Content-Type: application/json" \
          -d "{\"query\": $(echo "$SQL" | python3 -c 'import json,sys; print(json.dumps(sys.stdin.read()))')}" \
          > /dev/null
      }
      _push_sql supabase/migrations/20240101000000_schema.sql      && success "Schema applied"
      _push_sql supabase/migrations/20240101000001_rls_policies.sql && success "RLS policies applied"
    }
else
  manual "Run these in Supabase SQL Editor (in order):"
  manual "  1. supabase/migrations/20240101000000_schema.sql"
  manual "  2. supabase/migrations/20240101000001_rls_policies.sql"
fi

# ── Create Auth users via Admin API ──────────────────────────
step "Creating Auth users"

if [ -n "$SUPABASE_URL" ] && [ -n "$SERVICE_ROLE_KEY" ]; then
  _create_user() {
    local EMAIL="$1" PASS="$2"
    curl -s -X POST "${SUPABASE_URL}/auth/v1/admin/users" \
      -H "apikey: ${SERVICE_ROLE_KEY}" \
      -H "Authorization: Bearer ${SERVICE_ROLE_KEY}" \
      -H "Content-Type: application/json" \
      -d "{\"email\":\"${EMAIL}\",\"password\":\"${PASS}\",\"email_confirm\":true}" \
      | grep -o '"id":"[^"]*"' | head -1 | cut -d'"' -f4
  }

  ADMIN_UUID=$(    _create_user "shantalr@team.co.zw"      "Disciples2024!")
  DISCIPLER_UUID=$(    _create_user "shantalrencot@gmail.com" "Disciples2024!")
  DISCIPLE_UUID=$(    _create_user "rencoshantalt@gmail.com"  "Disciples2024!")

  _report_user() {
    local LABEL="$1" UUID="$2" PLACEHOLDER="$3"
    if [ -n "$UUID" ] && [ "$UUID" != "null" ]; then
      success "$LABEL: $UUID"
    else
      warn "$LABEL already exists or creation failed"
      UUID="$PLACEHOLDER"
    fi
    echo "$UUID"
  }

  ADMIN_UUID=$(    _report_user "Admin"     "$ADMIN_UUID"     "ADMIN-AUTH-UUID-HERE")
  DISCIPLER_UUID=$(    _report_user "Discipler" "$DISCIPLER_UUID" "DISCIPLER-AUTH-UUID-HERE")
  DISCIPLE_UUID=$(    _report_user "Disciple"  "$DISCIPLE_UUID"  "DISCIPLE-AUTH-UUID-HERE")

  # Patch UUIDs into seed.sql
  cp supabase/seed.sql supabase/seed.sql.bak
  sed -i \
    -e "s/ADMIN-AUTH-UUID-HERE/${ADMIN_UUID}/g" \
    -e "s/DISCIPLER-AUTH-UUID-HERE/${DISCIPLER_UUID}/g" \
    -e "s/DISCIPLE-AUTH-UUID-HERE/${DISCIPLE_UUID}/g" \
    supabase/seed.sql
  success "UUIDs patched into supabase/seed.sql"

  # Run seed via REST
  info "Running seed data..."
  SEED_SQL=$(cat supabase/seed.sql)
  curl -s -X POST "${SUPABASE_URL}/rest/v1/rpc/query" \
    -H "apikey: ${SERVICE_ROLE_KEY}" \
    -H "Authorization: Bearer ${SERVICE_ROLE_KEY}" \
    -H "Content-Type: application/json" \
    -d "{\"query\": $(echo "$SEED_SQL" | python3 -c 'import json,sys; print(json.dumps(sys.stdin.read()))')}" \
    > /dev/null \
    && success "Seed data inserted" \
    || {
      warn "Seed via REST failed"
      manual "Run supabase/seed.sql manually in SQL Editor"
    }
else
  manual "Create 3 users in Supabase Dashboard → Authentication → Users"
  manual "Paste their UUIDs into supabase/seed.sql, then run it in SQL Editor"
fi

# ── Generate TypeScript types from live schema ────────────────
step "Generating TypeScript types"

if command -v supabase >/dev/null 2>&1 && [ -n "$SUPABASE_REF" ]; then
  supabase gen types typescript --project-id "$SUPABASE_REF" \
    > src/types/database.types.ts 2>/dev/null \
    && success "Types generated → src/types/database.types.ts" \
    || warn "Type generation failed — skipping"
else
  manual "Run later: supabase gen types typescript --project-id <ref> > src/types/database.types.ts"
fi

# ── GitHub secrets ────────────────────────────────────────────
step "GitHub repository secrets"

if [ "$HAS_GH" = true ]; then
  REMOTE_URL=$(git remote get-url origin 2>/dev/null || echo "")
  GH_REPO=$(echo "$REMOTE_URL" | sed 's|.*github.com[:/]\(.*\)\.git|\1|' | sed 's|.*github.com[:/]\(.*\)|\1|')

  if [ -n "$GH_REPO" ]; then
    info "Setting secrets on $GH_REPO..."
    gh secret set NEXT_PUBLIC_SUPABASE_URL      --body "$SUPABASE_URL"      -R "$GH_REPO" 2>/dev/null
    gh secret set NEXT_PUBLIC_SUPABASE_ANON_KEY --body "$SUPABASE_ANON_KEY" -R "$GH_REPO" 2>/dev/null
    gh secret set SUPABASE_SERVICE_ROLE_KEY     --body "$SERVICE_ROLE_KEY"  -R "$GH_REPO" 2>/dev/null
    gh secret set SUPABASE_ACCESS_TOKEN         --body "$SUPABASE_ACCESS_TOKEN" -R "$GH_REPO" 2>/dev/null
    success "GitHub secrets set"
  else
    manual "Push to GitHub first, then re-run: bash scripts/set-github-secrets.sh"
  fi
else
  manual "Set these as GitHub repository secrets (Settings → Secrets → Actions):"
  manual "  NEXT_PUBLIC_SUPABASE_URL      = $SUPABASE_URL"
  manual "  NEXT_PUBLIC_SUPABASE_ANON_KEY = <your anon key>"
  manual "  SUPABASE_SERVICE_ROLE_KEY     = <your service role key>"
  manual "  SUPABASE_ACCESS_TOKEN         = <your supabase access token>"
fi

# ── Vercel deployment ─────────────────────────────────────────
step "Vercel deployment"

if command -v vercel >/dev/null 2>&1; then
  read -p "  Deploy to Vercel now? (Y/n): " DO_DEPLOY
  if [[ ! "$DO_DEPLOY" =~ ^[Nn]$ ]]; then
    vercel --yes 2>/dev/null && {
      VERCEL_URL=$(vercel ls 2>/dev/null | grep -oP 'https://[^\s]+' | head -1 || echo "")
      success "Deployed to Vercel${VERCEL_URL:+ → $VERCEL_URL}"

      if [ -n "$VERCEL_URL" ]; then
        info "Setting Vercel env vars..."
        echo "$SUPABASE_URL"      | vercel env add NEXT_PUBLIC_SUPABASE_URL      production 2>/dev/null
        echo "$SUPABASE_ANON_KEY" | vercel env add NEXT_PUBLIC_SUPABASE_ANON_KEY production 2>/dev/null
        echo "$SERVICE_ROLE_KEY"  | vercel env add SUPABASE_SERVICE_ROLE_KEY     production 2>/dev/null
        echo "The Disciples"      | vercel env add NEXT_PUBLIC_APP_NAME          production 2>/dev/null
        echo "$VERCEL_URL"        | vercel env add NEXT_PUBLIC_APP_URL           production 2>/dev/null
        success "Vercel env vars set"
        info "Redeploying with env vars..."
        vercel --prod 2>/dev/null && success "Production deployment complete → $VERCEL_URL"
      fi
    } || warn "Vercel deploy failed — run 'vercel' manually"
  fi
else
  manual "Deploy: npm install -g vercel && vercel"
fi

# ── Supabase Auth redirect URL ────────────────────────────────
step "Auth configuration"
manual "In Supabase Dashboard → Authentication → URL Configuration:"
manual "  Site URL:          \${NEXT_PUBLIC_APP_URL} (or your Vercel URL)"
manual "  Redirect URLs:     https://your-app.vercel.app/**"
manual "                     http://localhost:3000/**"

# ── Build check ───────────────────────────────────────────────
step "Build verification"
npm run build && success "Build passed" || warn "Build failed — check errors above"

# ── Done ──────────────────────────────────────────────────────
echo ""
echo -e "${BOLD}╔══════════════════════════════════════════════════════════╗${RESET}"
echo -e "${BOLD}║   ✅ Setup Complete                                      ║${RESET}"
echo -e "${BOLD}╠══════════════════════════════════════════════════════════╣${RESET}"
echo -e "${BOLD}║                                                          ║${RESET}"
echo -e "${BOLD}║  Test accounts (password: Disciples2024!)                ║${RESET}"
echo -e "${BOLD}║  Admin:     shantalr@team.co.zw                          ║${RESET}"
echo -e "${BOLD}║  Discipler: shantalrencot@gmail.com                      ║${RESET}"
echo -e "${BOLD}║  Disciple:  rencoshantalt@gmail.com                      ║${RESET}"
echo -e "${BOLD}║                                                          ║${RESET}"
echo -e "${BOLD}╚══════════════════════════════════════════════════════════╝${RESET}"
echo ""

read -p "Start dev server now? (Y/n): " START_DEV
[[ "$START_DEV" =~ ^[Nn]$ ]] || npm run dev
