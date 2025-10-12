#!/usr/bin/env bash
set -euo pipefail

# ───────────────────────────────────────────────
# 切换Git网络模式.command（作用域：当前仓库）
#   --http1     : 设置为 HTTP/1.1
#   --http2     : 恢复默认（未设置 http.version，Git 默认 HTTP/2）
#   --ssh       : 将 origin 切到 SSH（git@github.com:owner/repo.git）
#   --https     : 将 origin 切回 HTTPS（https://github.com/owner/repo.git）
#   --test      : 连通性测试（git ls-remote -h origin HEAD）
#   （无参数）  : 进入交互菜单
# ───────────────────────────────────────────────

# 让双击也能在仓库根执行
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

CYAN=$'\033[36m'; GREEN=$'\033[32m'; YELLOW=$'\033[33m'; RED=$'\033[31m'; RESET=$'\033[0m'
say(){ echo "${CYAN}➤${RESET} $*"; }
ok(){ echo "${GREEN}✔${RESET} $*"; }
warn(){ echo "${YELLOW}⚠${RESET} $*"; }
err(){ echo "${RED}✘${RESET} $*"; }

command -v git >/dev/null || { err "未找到 git"; exit 1; }
[[ -d .git ]] || { err "这里不是 Git 仓库（缺少 .git）"; exit 1; }

remote_name="origin"

current_mode() {
  local hv url
  hv="$(git config --get http.version || echo 'default(HTTP/2)')"
  url="$(git config --get remote.${remote_name}.url || echo '(未设置)')"
  echo "  • http.version = ${hv}"
  echo "  • ${remote_name}.url = ${url}"
}

to_http1() {
  say "将 http.version 设为 HTTP/1.1（仅当前仓库）"
  git config http.version HTTP/1.1
  ok "已切到 HTTP/1.1"
}

to_http2() {
  say "恢复默认 http.version（未设置 → HTTP/2）"
  git config --unset http.version || true
  ok "已恢复默认（HTTP/2）"
}

https_to_ssh_url() {
  # 输入 https://github.com/owner/repo.git → 输出 git@github.com:owner/repo.git
  local https="$1"
  local path="${https#https://github.com/}"
  echo "git@github.com:${path}"
}

ssh_to_https_url() {
  # 输入 git@github.com:owner/repo.git → 输出 https://github.com/owner/repo.git
  local ssh="$1"
  local path="${ssh#git@github.com:}"
  echo "https://github.com/${path}"
}

to_ssh() {
  local url new
  url="$(git config --get remote.${remote_name}.url || true)"
  if [[ -z "$url" ]]; then
    err "未找到 ${remote_name} 远端，请先 git remote add ${remote_name} <url>"
    exit 2
  fi
  if [[ "$url" =~ ^git@github\.com: ]]; then
    ok "已是 SSH，无需切换：$url"
    return
  fi
  if [[ "$url" =~ ^https://github\.com/ ]]; then
    new="$(https_to_ssh_url "$url")"
    say "切换 ${remote_name} 到 SSH：$new"
    git remote set-url "${remote_name}" "$new"
    ok "已切到 SSH"
  else
    err "无法识别当前 URL 形式：$url"
    exit 2
  fi
}

to_https() {
  local url new
  url="$(git config --get remote.${remote_name}.url || true)"
  if [[ -z "$url" ]]; then
    err "未找到 ${remote_name} 远端，请先 git remote add ${remote_name} <url>"
    exit 2
  fi
  if [[ "$url" =~ ^https://github\.com/ ]]; then
    ok "已是 HTTPS，无需切换：$url"
    return
  fi
  if [[ "$url" =~ ^git@github\.com: ]]; then
    new="$(ssh_to_https_url "$url")"
    say "切换 ${remote_name} 到 HTTPS：$new"
    git remote set-url "${remote_name}" "$new"
    ok "已切到 HTTPS"
  else
    err "无法识别当前 URL 形式：$url"
    exit 2
  fi
}

net_test() {
  say "连通性测试：git ls-remote -h ${remote_name} HEAD"
  set +e
  GIT_CURL_VERBOSE=1 git ls-remote -h "${remote_name}" HEAD >/dev/null 2>&1
  rc=$?
  set -e
  if [[ $rc -eq 0 ]]; then
    ok "远端可达 ✅"
  else
    err "远端不可达（rc=$rc）"
    warn "可尝试：切到 HTTP/1.1 或切换到 SSH 后再试。"
  fi
}

menu() {
  echo
  echo "当前配置："
  current_mode
  echo
  echo "选择操作："
  echo "  1) 切到 HTTP/1.1"
  echo "  2) 恢复默认（HTTP/2）"
  echo "  3) 将 origin 切到 SSH"
  echo "  4) 将 origin 切回 HTTPS"
  echo "  5) 连通性测试"
  echo "  0) 退出"
  read -r -p "你的选择: " sel
  case "${sel:-0}" in
    1) to_http1 ;;
    2) to_http2 ;;
    3) to_ssh ;;
    4) to_https ;;
    5) net_test ;;
    *) echo "Bye."; exit 0;;
  esac
  echo
  ok "完成。"
  echo "现在的配置："
  current_mode
}

# 参数模式
if [[ $# -gt 0 ]]; then
  case "$1" in
    --http1)  to_http1 ;;
    --http2)  to_http2 ;;
    --ssh)    to_ssh ;;
    --https)  to_https ;;
    --test)   net_test ;;
    *) err "未知参数：$1"; exit 2;;
  esac
  echo
  ok "完成。"
  echo "现在的配置："
  current_mode
else
  menu
fi