#!/usr/bin/env bash
set -e

echo "========================================================"
echo "  EmpathIQ - Production Web Builder & Deployer"
echo "  Security: Serverless Backend Proxy Architecture"
echo "========================================================"

echo ""
echo "[1/3] Compiling Flutter Web release bundle (key-free client)..."
flutter build web --release

echo ""
echo "[2/3] Staging compiled web assets and configs..."
git add build/web/ api/ vercel.json .gitignore lib/ publish.bat publish.sh

COMMIT_MSG="${1:-deploy: update web release bundle with secure serverless proxy}"
echo "[3/3] Committing and pushing to origin main..."
git commit -m "$COMMIT_MSG" || echo "No changes to commit"
git push origin main

echo ""
echo "========================================================"
echo "  SUCCESS! Deployment submitted to Vercel production:"
echo "  https://empath-iq-theta.vercel.app/"
echo "========================================================"
