#!/usr/bin/env bash
set -euo pipefail

cd "$(cd "$(dirname "$0")" && pwd)"

cyan=$'\033[36m'; green=$'\033[32m'; yellow=$'\033[33m'; red=$'\033[31m'; reset=$'\033[0m'
say(){ echo "${cyan}➤${reset} $*"; }
ok(){ echo "${green}✔${reset} $*"; }
warn(){ echo "${yellow}⚠${reset} $*"; }
err(){ echo "${red}✘${reset} $*"; }

command -v git >/dev/null || { err "未找到 git"; exit 1; }

REMOTE_SSH="git@github.com:Tang1206cc/GatekeeperHelper.git"
REMOTE_HTTPS="https://github.com/Tang1206cc/GatekeeperHelper.git"

warn "将删除当前 .git 并重建历史，仅保留【当前文件快照】。远端 main 将被强制覆盖。"
read -r -p "确认执行？[type: REINIT] " ans
[[ "${ans:-}" == "REINIT" ]] || { err "已取消"; exit 1; }

# 1) 备份旧 .git
if [[ -d .git ]]; then
  ts="$(date +%Y%m%d-%H%M%S)"
  say "备份现有 .git → .git.backup-${ts}"
  mv .git ".git.backup-${ts}"
fi

# 2) 重建仓库
say "初始化新的 git 仓库并切到 main"
git init >/dev/null
git branch -M main

# 3) 写一个常用 .gitignore（若没有）
if [[ ! -f .gitignore ]]; then
cat > .gitignore <<'EOF'
# Xcode / Derived
build/
DerivedData/
*.xcuserdatad/
*.xcworkspace/xcuserdata/
# macOS
.DS_Store
# Logs
*.log
EOF
fi

# 4) 首次提交
say "添加全部文件并提交"
git add -A
git commit -m "reinit: import working tree as fresh history" >/dev/null

# 5) 远端优先用 SSH，更稳；若没配 SSH 再回落到 HTTPS
USE_HTTPS=false
if ssh -T git@github.com -o StrictHostKeyChecking=accept-new 2>/dev/null; then
  say "检测到可用的 GitHub SSH，使用 SSH 远端"
  git remote add origin "${REMOTE_SSH}" || git remote set-url origin "${REMOTE_SSH}"
else
  warn "未检测到可用 SSH，将使用 HTTPS（临时用 HTTP/1.1）"
  USE_HTTPS=true
  git remote add origin "${REMOTE_HTTPS}" || git remote set-url origin "${REMOTE_HTTPS}"
  git config http.version HTTP/1.1 || true
fi

# 6) 强制平推
say "强制推送到 origin/main（覆盖远端历史）"
set +e
git push -u --force origin main
rc=$?
set -e

if [[ $rc -ne 0 && "$USE_HTTPS" = true ]]; then
  warn "HTTPS 推送失败，建议改用 SSH。若你还没配置 SSH key："
  echo "  1) ssh-keygen -t ed25519 -C \"your_email@example.com\""
  echo "  2) 将 ~/.ssh/id_ed25519.pub 公钥添加到 GitHub → Settings → SSH and GPG keys"
  echo "  3) git remote set-url origin ${REMOTE_SSH}"
  echo "  4) 再运行本脚本或手动：git push -u --force origin main"
  err "已退出（rc=$rc）"
  exit $rc
fi

ok "完成！远端代码已与本地一致。"

# 7) 清理提示
if git config --get http.version >/dev/null 2>&1; then
  warn "你当前仓库设置了 http.version=HTTP/1.1，如需恢复默认：git config --unset http.version"
fi

say "如需保持 Releases 不变，暂时不要推 tags；若日后要同步 tags：git push --tags"