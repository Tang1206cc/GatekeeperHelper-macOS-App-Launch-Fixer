#!/usr/bin/env zsh
set -euo pipefail

REPO="/Users/tangziyao/Documents/GatekeeperHelper_project/GatekeeperHelper"

# 颜色 & 输出
cyan=$'\033[36m'; green=$'\033[32m'; yellow=$'\033[33m'; red=$'\033[31m'; reset=$'\033[0m'
say(){ echo "${cyan}➤${reset} $*"; }
ok(){ echo "${green}✔${reset} $*"; }
warn(){ echo "${yellow}⚠${reset} $*"; }
err(){ echo "${red}✘${reset} $*"; }

echo
say "进入工程：$REPO"
cd "$REPO" || { err "找不到目录：$REPO"; exit 1; }
[[ -d .git ]] || { err "当前目录不是 Git 仓库（缺少 .git）"; exit 1; }

CUR_BRANCH="$(git rev-parse --abbrev-ref HEAD)"
[[ -n "$CUR_BRANCH" && "$CUR_BRANCH" != "HEAD" ]] || { err "当前处于 detached HEAD，请切到 main 再试"; exit 1; }

# 如未设置 upstream，则设为 origin/main
UPSTREAM="$(git rev-parse --abbrev-ref --symbolic-full-name '@{u}' 2>/dev/null || true)"
if [[ -z "$UPSTREAM" ]]; then
  warn "当前分支未设置 upstream，设置为 origin/main"
  git branch --set-upstream-to=origin/main "$CUR_BRANCH" 2>/dev/null || true
fi

# 有未提交改动则先暂存（包含未跟踪文件）
STASHED="false"
if [[ -n "$(git status --porcelain)" ]]; then
  echo
  warn "检测到未提交改动，先暂存以便下拉："
  git stash push -u -m "auto-stash-before-downsync-$(date +%Y%m%d-%H%M%S)" >/dev/null || true
  STASHED="true"
fi

echo
say "获取远端最新状态…"
git fetch origin main

# 计算 ahead / behind
# 使用三点比较：origin/main...HEAD
AHEAD=0
BEHIND=0
OUT="$(git rev-list --left-right --count origin/main...HEAD 2>/dev/null || echo '')"
if [[ -n "$OUT" ]]; then
  BEHIND="$(awk '{print $1}' <<<"$OUT" 2>/dev/null || echo 0)"
  AHEAD="$(awk '{print $2}' <<<"$OUT" 2>/dev/null || echo 0)"
fi
BEHIND="${BEHIND:-0}"
AHEAD="${AHEAD:-0}"

say "比较结果：本地领先 ${AHEAD}，落后 ${BEHIND}。"

# 根据状态采取动作
if [[ "$BEHIND" -eq 0 && "$AHEAD" -eq 0 ]]; then
  ok "✅ 已与远端完全一致，无需操作。"

elif [[ "$BEHIND" -gt 0 && "$AHEAD" -eq 0 ]]; then
  say "远端领先（有新提交）→ 正在下拉以保持一致…"
  # --rebase 保持线性历史；--autostash 兜底自动暂存
  if git pull --rebase --autostash origin main; then
    ok "已同步远端最新版本。"
  else
    err "拉取过程中出现冲突，请按提示解决后再运行本脚本："
    echo "  • 查看状态：git status"
    echo "  • 解决冲突后继续：git rebase --continue"
    echo "  • 或放弃本次 rebase：git rebase --abort"
    exit 2
  fi

elif [[ "$BEHIND" -gt 0 && "$AHEAD" -gt 0 ]]; then
  warn "检测到分叉（两边都有新的提交）→ 尝试 rebase 远端提交到本地之上…"
  if git pull --rebase --autostash origin main; then
    ok "rebase 完成，本地已包含远端变更。"
  else
    err "rebase 过程中出现冲突，请处理后再继续："
    echo "  • 查看状态：git status"
    echo "  • 解决冲突后继续：git rebase --continue"
    echo "  • 或放弃本次 rebase：git rebase --abort"
    exit 2
  fi

else # BEHIND==0 && AHEAD>0
  warn "本地领先、远端无新提交（下行刷新无需操作）。"
  echo "  如希望以远端为准覆盖本地（危险，会丢本地提交）："
  echo "    git reset --hard origin/main"
  echo "  如希望将本地更新推上去，请执行你的『上行刷新』脚本。"
fi

# 如果我们手动做过 stash，则尝试弹回
if [[ "$STASHED" == "true" ]]; then
  echo
  say "弹回之前暂存的工作区改动…"
  if git stash pop >/dev/null 2>&1; then
    ok "已恢复未提交改动。"
  else
    warn "自动弹回出现冲突，请手动处理（git status / 解决后提交）。"
  fi
fi

echo
ok "下行刷新完成。"
echo "  • 分支：$(git rev-parse --abbrev-ref HEAD)"
echo "  • 远端：$(git config --get remote.origin.url)"