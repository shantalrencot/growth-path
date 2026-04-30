#!/bin/bash
# Set GitHub Actions secrets from .env.local
# Usage: bash scripts/set-github-secrets.sh

set -e

if ! command -v gh >/dev/null 2>&1; then
  echo "❌ GitHub CLI required: https://cli.github.com"
  exit 1
fi

if [ ! -f .env.local ]; then
  echo "❌ .env.local not found — run setup.sh first"
  exit 1
fi

REPO=$(gh repo view --json nameWithOwner -q .nameWithOwner 2>/dev/null)
if [ -z "$REPO" ]; then
  echo "❌ Not a GitHub repo or not authenticated. Run: gh auth login"
  exit 1
fi

echo "▶ Setting secrets on $REPO..."

# Load vars from .env.local
set -a; source .env.local; set +a

gh secret set NEXT_PUBLIC_SUPABASE_URL      --body "$NEXT_PUBLIC_SUPABASE_URL"      -R "$REPO"
gh secret set NEXT_PUBLIC_SUPABASE_ANON_KEY --body "$NEXT_PUBLIC_SUPABASE_ANON_KEY" -R "$REPO"
gh secret set SUPABASE_SERVICE_ROLE_KEY     --body "$SUPABASE_SERVICE_ROLE_KEY"     -R "$REPO"

read -p "Supabase access token (for CLI/type gen): " SUPABASE_ACCESS_TOKEN
[ -n "$SUPABASE_ACCESS_TOKEN" ] && \
  gh secret set SUPABASE_ACCESS_TOKEN --body "$SUPABASE_ACCESS_TOKEN" -R "$REPO"

echo "✅ All secrets set on $REPO"
