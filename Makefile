.PHONY: dev build lint type-check setup db-schema db-rls db-seed

dev:
	npm run dev

build:
	npm run build

lint:
	npm run lint

type-check:
	npx tsc --noEmit

# First-time setup after cloning
setup:
	npm install
	@echo "Fill in .env.local then run: make db-schema db-rls db-seed"

# Run SQL files (requires psql + DATABASE_URL in env)
db-schema:
	psql "$$DATABASE_URL" -f supabase/schema.sql

db-rls:
	psql "$$DATABASE_URL" -f supabase/rls_policies.sql

db-seed:
	psql "$$DATABASE_URL" -f supabase/seed.sql
