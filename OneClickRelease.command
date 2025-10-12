#!/usr/bin/env bash
set -euo pipefail

### GatekeeperHelper 一键发版（适配外置 Xcode + .xcodeproj）

# === 必要配置（已按你的环境设置好） ===
DEVELOPER_DIR="/Volumes/MacZone/Applications_add/Xcode.app/Contents/Developer"  # 你的 Xcode
PROJECT_FILE="GatekeeperHelper.xcodeproj"   # 使用 xcodeproj
SCHEME="GatekeeperHelper"                   # 主 App 的 scheme 名，如不同可改
OWNER_REPO="Tang1206cc/GatekeeperHelper"    # GitHub 仓库
APP_NAME="GatekeeperHelper.app"
BUILD_DIR="build"
# ======================================

PRE_RELEASE=false
RELEASE_NOTES_FILE=""

# 参数解析
while [[ $# -gt 0 ]]; do
  case "$1" in
    --pre) PRE_RELEASE=true; shift ;;
    --notes) RELEASE_NOTES_FILE="${2:-}"; shift 2 ;;
    *) echo "未知参数: $1"; exit 2 ;;
  esac
done

RED=$'\033[31m'; GREEN=$'\033[32m'; YELLOW=$'\033[33m'; CYAN=$'\033[36m'; RESET=$'\033[0m'
say() { echo "${CYAN}➤${RESET} $*"; }
ok()  { echo "${GREEN}✔${RESET} $*"; }
warn(){ echo "${YELLOW}⚠${RESET} $*"; }
err() { echo "${RED}✘${RESET} $*"; }

# 切到外置 Xcode
export DEVELOPER_DIR
if [[ ! -d "$DEVELOPER_DIR" ]]; then
  err "找不到 Xcode：$DEVELOPER_DIR"
  exit 1
fi

# 前置工具
command -v xcodebuild >/dev/null || { err "未找到 xcodebuild（请检查 Xcode 安装）"; exit 1; }
command -v zip >/dev/null       || { err "未找到 zip 命令"; exit 1; }
command -v gh >/dev/null        || { err "未安装 GitHub CLI：brew install gh"; exit 1; }
gh auth status >/dev/null || { err "gh 未登录。请先执行 gh auth login"; exit 1; }

# 必须在仓库根目录
if [[ ! -d ".git" ]]; then
  err "未检测到 .git。请在仓库根目录运行此脚本。"
  exit 1
fi

# 工作区是否干净
if [[ -n "$(git status --porcelain)" ]]; then
  warn "工作区有未提交改动，建议提交后再发版。"
  read -r -p "继续吗？[y/N] " go
  [[ "${go:-N}" =~ ^[Yy]$ ]] || { err "已取消"; exit 1; }
fi

# 自动探测 scheme（如果上面 SCHEME 留空）
if [[ -z "${SCHEME}" ]]; then
  say "自动探测 scheme..."
  SCHEME=$(xcodebuild -list -project "$PROJECT_FILE" 2>/dev/null | awk '/Schemes:/{flag=1;next}/^$/{flag=0}flag' | head -n1 | xargs || true)
  [[ -z "$SCHEME" ]] && { err "无法自动探测 scheme，请在脚本顶部配置 SCHEME"; exit 1; }
  ok "使用 scheme：$SCHEME"
fi

# 从 Info.plist 读取版本号（优先用源码中的 plist）
SRC_PLIST="$(git ls-files | grep -E '/Info\.plist$' | head -n1 || true)"
if [[ -z "${SRC_PLIST}" ]]; then
  err "找不到 Info.plist，请确认工程存在 Info.plist"
  exit 1
fi
VERSION=$(/usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" "${SRC_PLIST}" 2>/dev/null || true)
[[ -z "${VERSION}" ]] && { err "无法从 ${SRC_PLIST} 读取 CFBundleShortVersionString"; exit 1; }
TAG="v${VERSION}"
say "版本号：${VERSION}（Tag: ${TAG}）"

# 构建 Release
say "开始构建（使用外置 Xcode：$DEVELOPER_DIR）…"
rm -rf "${BUILD_DIR}"
xcodebuild -project "${PROJECT_FILE}" -scheme "${SCHEME}" -configuration Release -derivedDataPath "${BUILD_DIR}" > /dev/null
ok "构建完成"

# 拷贝 .app 到根目录
APP_BUILD_PATH="${BUILD_DIR}/Build/Products/Release/${APP_NAME}"
if [[ ! -d "${APP_BUILD_PATH}" ]]; then
  err "未在 ${APP_BUILD_PATH} 找到构建产物（请确认 scheme=${SCHEME} 与配置为 Release）"
  exit 1
fi
rm -rf "${APP_NAME}"
cp -R "${APP_BUILD_PATH}" "${APP_NAME}"
ok "拷贝 ${APP_NAME} 到仓库根目录"

# 检查 Helper 是否进包
if [[ ! -f "${APP_NAME}/Contents/Helpers/UpdaterHelper" ]]; then
  warn "未发现 Contents/Helpers/UpdaterHelper。请确认主 App 的 Build Phases→Copy Files 已包含 UpdaterHelper。"
  read -r -p "仍然继续发版？[y/N] " go2
  [[ "${go2:-N}" =~ ^[Yy]$ ]] || { err "已取消"; exit 1; }
fi

# 打包 & SHA
ZIP="GatekeeperHelper-${VERSION}.zip"
say "打包为 ${ZIP}…"
/usr/bin/zip -ry "${ZIP}" "${APP_NAME}" -x "*.DS_Store" > /dev/null
ok "zip 完成"

say "计算 SHA256…"
if command -v shasum >/dev/null 2>&1; then
  SHA="$(shasum -a 256 "${ZIP}" | awk '{print $1}')"
else
  SHA="$(openssl dgst -sha256 "${ZIP}" | awk '{print $2}')"
fi
echo "SHA256 ${SHA} ${ZIP}" > checksums.txt
ok "checksums.txt 已生成"

# 创建 tag（不存在则创建）
if git rev-parse "${TAG}" >/dev/null 2>&1; then
  warn "本地已存在 tag ${TAG}"
else
  say "创建 tag ${TAG} 并推送…"
  git tag "${TAG}"
  git push origin "${TAG}"
  ok "Tag 已推送"
fi

# Release Notes
NOTES_OPT=()
if [[ -n "${RELEASE_NOTES_FILE}" && -f "${RELEASE_NOTES_FILE}" ]]; then
  NOTES_OPT+=(--notes-file "${RELEASE_NOTES_FILE}")
else
  LAST_TAG="$(git describe --tags --abbrev=0 2>/dev/null || echo "")"
  if [[ -n "${LAST_TAG}" && "${LAST_TAG}" != "${TAG}" ]]; then
    NOTES_FILE="$(mktemp)"
    echo "Changes since ${LAST_TAG}:" > "${NOTES_FILE}"
    git log --pretty=format:"- %s (%h)" "${LAST_TAG}..HEAD" >> "${NOTES_FILE}"
    NOTES_OPT+=(--notes-file "${NOTES_FILE}")
  fi
fi

# 创建/更新 Release
say "创建/更新 GitHub Release：${OWNER_REPO} @ ${TAG} …"
PRERELEASE_FLAG=()
${PRE_RELEASE} && PRERELEASE_FLAG+=(--prerelease)
if gh release view "${TAG}" -R "${OWNER_REPO}" >/dev/null 2>&1; then
  warn "Release ${TAG} 已存在 → 更新资产"
  gh release upload "${TAG}" "${ZIP}" checksums.txt -R "${OWNER_REPO}" --clobber
else
  gh release create "${TAG}" "${ZIP}" checksums.txt -R "${OWNER_REPO}" \
    --title "GatekeeperHelper ${VERSION}" \
    "${PRERELEASE_FLAG[@]}" \
    "${NOTES_OPT[@]}"
fi

ok "发版成功！"
echo "  • ZIP: ${ZIP}"
echo "  • SHA: ${SHA}"
echo "  • Release: https://github.com/${OWNER_REPO}/releases/tag/${TAG}"