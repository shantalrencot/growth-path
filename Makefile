.PHONY: dev build start lint type-check check \
        setup db-push db-reset db-seed db-types \
        deploy secrets

# ── Development ───────────────────────────────────────────────
dev:
	npm run dev

build:
	npm run build

start:
	npm run start

# ── Code quality ──────────────────────────────────────────────
lint:
	npm run lint

type-check:
	npm run type-check

check: type-check lint build
	@echo "✅ All checks passed"

# ── First-time setup ──────────────────────────────────────────
setup:
	bash setup.sh

# ── Database ──────────────────────────────────────────────────

# Push all migrations to Supabase (requires Supabase CLI + linked project)
db-push:
	bash scripts/push-db.sh

# Re-run seed data only (idempotent — safe to repeat)
db-seed:
	@if [ -z "$$SUPABASE_URL" ]; then \
	  export $$(grep -v '^#' .env.local | xargs); \
	fi; \
	psql "$$DATABASE_URL" -f supabase/seed.sql 2>/dev/null || \
	  echo "ℹ️  No DATABASE_URL — run supabase/seed.sql manually in SQL Editor"

# Wipe and re-run all migrations + seed (local dev only)
db-reset:
	supabase db reset

# Pull latest schema from Supabase and generate TypeScript types
db-types:
	bash scripts/generate-types.sh

# ── Deployment ────────────────────────────────────────────────

# Deploy to Vercel (prompts for project on first run)
deploy:
	vercel --prod

# Push env vars from .env.local to Vercel
deploy-env:
	@set -a && source .env.local && set +a && \
	vercel env add NEXT_PUBLIC_SUPABASE_URL      production <<< "$$NEXT_PUBLIC_SUPABASE_URL"      2>/dev/null; \
	vercel env add NEXT_PUBLIC_SUPABASE_ANON_KEY production <<< "$$NEXT_PUBLIC_SUPABASE_ANON_KEY" 2>/dev/null; \
	vercel env add SUPABASE_SERVICE_ROLE_KEY     production <<< "$$SUPABASE_SERVICE_ROLE_KEY"     2>/dev/null; \
	vercel env add NEXT_PUBLIC_APP_NAME          production <<< "$$NEXT_PUBLIC_APP_NAME"          2>/dev/null; \
	vercel env add NEXT_PUBLIC_APP_URL           production <<< "$$NEXT_PUBLIC_APP_URL"           2>/dev/null
	@echo "✅ Vercel env vars updated — redeploy with: make deploy"

# ── GitHub secrets ────────────────────────────────────────────
secrets:
	bash scripts/set-github-secrets.sh
