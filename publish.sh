#!/usr/bin/env bash
set -e

echo "========================================================"
echo "  EmpathIQ - Production Web Builder & Deployer"
echo "========================================================"

# Determine GEMINI_API_KEY from argument $1 or system environment variable
API_KEY="${1:-$GEMINI_API_KEY}"

if [ -n "$API_KEY" ]; then
  echo "[INFO] Compiling with injected GEMINI_API_KEY."
  flutter build web --release --dart-define=GEMINI_API_KEY="$API_KEY"
else
  echo "[INFO] No GEMINI_API_KEY provided. Building in smart simulation fallback mode."
  echo "[INFO] Usage: ./publish.sh [YOUR_GEMINI_API_KEY]"
  flutter build web --release
fi

echo ""
echo "[1/2] Staging compiled web assets and configs..."
git add build/web/ vercel.json .gitignore lib/

COMMIT_MSG="${2:-deploy: update web release bundle}"
echo "[2/2] Committing and pushing to origin main..."
git commit -m "$COMMIT_MSG" || echo "No changes to commit"
git push origin main

echo ""
echo "========================================================"
echo "  SUCCESS! Deployment submitted to Vercel production:"
echo "  https://empath-iq-theta.vercel.app/"
echo "========================================================"
