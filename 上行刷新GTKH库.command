#!/usr/bin/env bash
set -euo pipefail

REPO="/Users/tangziyao/Documents/GatekeeperHelper_project/GatekeeperHelper"
cd "$REPO"

cyan=$'\033[36m'; green=$'\033[32m'; yellow=$'\033[33m'; red=$'\033[31m'; reset=$'\033[0m'
say(){ echo "${cyan}➤${reset} $*"; }
ok(){ echo "${green}✔${reset} $*"; }
warn(){ echo "${yellow}⚠${reset} $*"; }
err(){ echo "${red}✘${reset} $*"; }

say "进入仓库：$REPO"

# 检查是否在 Git 仓库
if [[ ! -d .git ]]; then
  err "未检测到 .git 仓库，请确认路径。"
  exit 1
fi

# 自动提交本地变更
if [[ -n "$(git status --porcelain)" ]]; then
  say "检测到改动，正在提交…"
  git add -A
  git commit -m "chore: quick sync @ $(date '+%Y-%m-%d %H:%M:%S')" || true
else
  warn "无改动需要提交。"
fi

# 更新远端状态
say "获取远端最新状态…"
git fetch origin main

# 统计 ahead / behind
read BEHIND AHEAD <<<"$(git rev-list --left-right --count origin/main...HEAD | awk '{print $1, $2}')"

say "比较结果：本地领先 $AHEAD，落后 $BEHIND。"

if [[ "$BEHIND" -eq 0 && "$AHEAD" -eq 0 ]]; then
  ok "✅ 已完全同步，无需推送。"
elif [[ "$BEHIND" -eq 0 && "$AHEAD" -gt 0 ]]; then
  say "本地领先 → 正在推送更新…"
  git push origin main
  ok "本地更新已推送至远端。"
elif [[ "$BEHIND" -gt 0 && "$AHEAD" -eq 0 ]]; then
  warn "远端领先 → 正在下拉最新提交以保持一致…"
  git pull --rebase origin main
  ok "已同步远端最新版本。"
elif [[ "$BEHIND" -gt 0 && "$AHEAD" -gt 0 ]]; then
  warn "检测到分叉：两边都有新提交。执行 rebase 以合并…"
  git pull --rebase origin main || {
    err "rebase 失败，请手动解决冲突后重试。"
    exit 1
  }
  git push origin main
  ok "冲突解决后已成功推送。"
fi

echo
ok "操作完成！"
echo "分支：$(git rev-parse --abbrev-ref HEAD)"
echo "远端：$(git config --get remote.origin.url)"