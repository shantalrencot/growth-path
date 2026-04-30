#!/bin/bash
# Generate TypeScript types from your live Supabase schema
# Usage: bash scripts/generate-types.sh

set -e

if ! command -v supabase >/dev/null 2>&1; then
  echo "❌ Supabase CLI required: npm install -g supabase"
  exit 1
fi

if [ ! -f .env.local ]; then
  echo "❌ .env.local not found"
  exit 1
fi

# Extract project ref from SUPABASE_URL
SUPABASE_URL=$(grep NEXT_PUBLIC_SUPABASE_URL .env.local | cut -d= -f2)
PROJECT_REF=$(echo "$SUPABASE_URL" | sed 's|https://||' | cut -d'.' -f1)

if [ -z "$PROJECT_REF" ]; then
  echo "❌ Could not determine project ref from .env.local"
  exit 1
fi

echo "▶ Generating types for project: $PROJECT_REF"
supabase gen types typescript --project-id "$PROJECT_REF" > src/types/database.types.ts
echo "✅ Types written to src/types/database.types.ts"
