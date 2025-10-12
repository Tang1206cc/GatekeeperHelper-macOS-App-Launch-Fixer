#!/usr/bin/env zsh
set -euo pipefail

REPO="/Users/tangziyao/Documents/GatekeeperHelper_project/GatekeeperHelper"
echo ""
echo "进入工程：$REPO"
cd "$REPO" || { echo "[ERROR] 找不到目录 $REPO"; exit 1; }

# 仅在存在未提交改动时才暂存
if [[ -n "$(git status --porcelain)" ]]; then
  echo ""
  echo "[WARN] 检测到未提交改动，先暂存："
  git stash push -m "auto-stash-before-downsync-$(date +%Y%m%d-%H%M%S)" || true
fi

echo ""
echo "获取远端最新提交…"
# --rebase 保持线性历史；--autostash 对极少数情况下也能自动暂存
if ! git pull --rebase --autostash origin main; then
  echo ""
  echo "⚠ 拉取冲突或失败，请手动处理（或使用 git status / git rebase --continue / --abort）"
  exit 2
fi

echo ""
echo "[成功] ✅ 已同步最新代码（main 分支）"