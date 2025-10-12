#!/bin/zsh

echo ""
echo "进入工程：/Users/tangziyao/Documents/GatekeeperHelper_project/GatekeeperHelper"
cd /Users/tangziyao/Documents/GatekeeperHelper_project/GatekeeperHelper || {
    echo "[ERROR] 找不到目录 /Users/tangziyao/Documents/GatekeeperHelper_project/GatekeeperHelper"
    exit 1
}

echo ""
echo "[WARN] 检测到未提交改动，先暂存："
git stash push -m "auto-stash-before-downsync-$(date +%Y%m%d-%H%M%S)"

echo ""
echo "获取远端最新提交…"
git pull --rebase origin main

echo ""
echo "[成功] ✅ 已同步最新代码（main 分支）"
