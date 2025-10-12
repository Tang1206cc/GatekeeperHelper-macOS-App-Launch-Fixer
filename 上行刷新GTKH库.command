#!/usr/bin/env bash
set -euo pipefail

REPO="/Users/tangziyao/Documents/GatekeeperHelper_project/GatekeeperHelper"
cd "$REPO"

# 仅在有变更时提交；提交信息带时间戳，便于追溯
if [[ -n "$(git status --porcelain)" ]]; then
  git add -A
  git commit -m "chore: quick sync @ $(date '+%Y-%m-%d %H:%M:%S')" || true
else
  echo "⚠ 无改动需要提交，直接推送…"
fi

# 推送（如需指定分支可加 origin main）
git push -u origin "$(git rev-parse --abbrev-ref HEAD)"