#!/bin/bash
# Push database migrations to Supabase
# Usage: bash scripts/push-db.sh

set -e

if ! command -v supabase >/dev/null 2>&1; then
  echo "❌ Supabase CLI required: npm install -g supabase"
  exit 1
fi

if [ ! -f .env.local ]; then
  echo "❌ .env.local not found"
  exit 1
fi

SUPABASE_URL=$(grep NEXT_PUBLIC_SUPABASE_URL .env.local | cut -d= -f2)
PROJECT_REF=$(echo "$SUPABASE_URL" | sed 's|https://||' | cut -d'.' -f1)

echo "▶ Linking project: $PROJECT_REF"
supabase link --project-ref "$PROJECT_REF"

echo "▶ Pushing migrations..."
supabase db push

echo "✅ Database up to date"
