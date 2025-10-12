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

# 1) 仓库与分支检查
[[ -d .git ]] || { err "未检测到 .git 仓库"; exit 1; }
CUR_BRANCH="$(git rev-parse --abbrev-ref HEAD)"
[[ -n "$CUR_BRANCH" && "$CUR_BRANCH" != "HEAD" ]] || { err "当前处于 detached HEAD，请切到 main 再试"; exit 1; }

# 2) 自动提交本地改动
if [[ -n "$(git status --porcelain)" ]]; then
  say "检测到改动，正在提交…"
  git add -A
  git commit -m "chore: quick sync @ $(date '+%Y-%m-%d %H:%M:%S')" || true
else
  warn "无改动需要提交。"
fi

# 3) 确保有 upstream（无则设为 origin/main）
UPSTREAM="$(git rev-parse --abbrev-ref --symbolic-full-name "@{u}" 2>/dev/null || true)"
if [[ -z "$UPSTREAM" ]]; then
  warn "当前分支未设置 upstream，设置为 origin/main"
  git branch --set-upstream-to=origin/main "$CUR_BRANCH" 2>/dev/null || true
fi

# 4) fetch 远端
say "获取远端最新状态…"
git fetch origin main

# 5) 计算 ahead/behind（稳健兜底）
AHEAD=0
BEHIND=0
# 使用三点比较（upstream 可能刚设好）
OUT="$(git rev-list --left-right --count origin/main...HEAD 2>/dev/null || echo "")"
if [[ -n "$OUT" ]]; then
  # 格式: "<behind> <ahead>"
  BEHIND="$(awk '{print $1}' <<<"$OUT" 2>/dev/null || echo 0)"
  AHEAD="$(awk '{print $2}' <<<"$OUT" 2>/dev/null || echo 0)"
fi
# 再次兜底（防止空字符串触发 set -u）
BEHIND="${BEHIND:-0}"
AHEAD="${AHEAD:-0}"

say "比较结果：本地领先 ${AHEAD}，落后 ${BEHIND}。"

# 6) 基于状态采取行动
if [[ "$BEHIND" -eq 0 && "$AHEAD" -eq 0 ]]; then
  ok "✅ 已完全同步，无需推送。"

elif [[ "$BEHIND" -eq 0 && "$AHEAD" -gt 0 ]]; then
  say "本地领先 → 正在推送更新…"
  git push origin "$CUR_BRANCH:main"
  ok "本地更新已推送至远端。"

elif [[ "$BEHIND" -gt 0 && "$AHEAD" -eq 0 ]]; then
  warn "远端领先 → 正在下拉最新提交以保持一致…"
  git pull --rebase origin main
  ok "已同步远端最新版本。"

else
  # 分叉：两边都有新提交
  warn "检测到分叉：执行 rebase 整合远端提交…"
  git pull --rebase origin main || {
    err "rebase 过程中有冲突，请解决后再运行本脚本。"
    exit 1
  }
  say "rebase 完成 → 推送…"
  git push origin "$CUR_BRANCH:main"
  ok "推送完成。"
fi

echo
ok "操作完成！"
echo "分支：$(git rev-parse --abbrev-ref HEAD)"
echo "远端：$(git config --get remote.origin.url)"