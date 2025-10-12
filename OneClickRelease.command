#!/usr/bin/env bash
set -euo pipefail

# ─────────────────────────────────────────────────────────────
# GatekeeperHelper 一键发版（.xcodeproj / 外置 Xcode / Helper 兜底注入）
# 依赖：zip、gh（已登录）、git
# 选项：--pre（预发布）、--notes <file>
# ─────────────────────────────────────────────────────────────

# 让双击也能在仓库根运行
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"

# === 环境 ===（如你的 Xcode 路径变了，只改这一行即可）
DEVELOPER_DIR_DEFAULT="/Volumes/MacZone/Applications_add/Xcode.app/Contents/Developer"
: "${DEVELOPER_DIR:="${DEVELOPER_DIR_DEFAULT}"}"
export DEVELOPER_DIR

XCB="${DEVELOPER_DIR}/usr/bin/xcodebuild"

PROJECT_FILE="GatekeeperHelper.xcodeproj"
SCHEME_APP="GatekeeperHelper"
TARGET_HELPER="UpdaterHelper"
OWNER_REPO="Tang1206cc/GatekeeperHelper"
APP_NAME="GatekeeperHelper.app"
BUILD_DIR="build"
CONFIG="Release"        # 如需调试，可改为 Debug
# =======================

PRE_RELEASE=false
RELEASE_NOTES_FILE=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --pre) PRE_RELEASE=true; shift;;
    --notes) RELEASE_NOTES_FILE="${2:-}"; shift 2;;
    *) echo "未知参数: $1"; exit 2;;
  esac
done

# 彩色输出
RED=$'\033[31m'; GREEN=$'\033[32m'; YELLOW=$'\033[33m'; CYAN=$'\033[36m'; RESET=$'\033[0m'
say() { echo "${CYAN}➤${RESET} $*"; }
ok()  { echo "${GREEN}✔${RESET} $*"; }
warn(){ echo "${YELLOW}⚠${RESET} $*"; }
err() { echo "${RED}✘${RESET} $*"; }

# 前置检查
[[ -x "$XCB" ]] || { err "找不到 xcodebuild：$XCB"; exit 1; }
command -v zip >/dev/null || { err "未找到 zip 命令"; exit 1; }
command -v gh  >/dev/null || { err "未安装 GitHub CLI：brew install gh"; exit 1; }
gh auth status >/dev/null  || { err "gh 未登录，请先 gh auth login"; exit 1; }
[[ -d .git ]] || { err "未检测到 .git。请在仓库根目录运行。"; exit 1; }

# 工作区提示
if [[ -n "$(git status --porcelain)" ]]; then
  warn "工作区有未提交改动，建议提交后再发版。"
  read -r -p "继续吗？[y/N] " go
  [[ "${go:-N}" =~ ^[Yy]$ ]] || { err "已取消"; exit 1; }
fi

# ① 读取版本号（优先 MARKETING_VERSION）
say "读取版本号…（优先 MARKETING_VERSION）"
VERSION="$("$XCB" -project "$PROJECT_FILE" -scheme "$SCHEME_APP" -configuration "$CONFIG" -showBuildSettings 2>/dev/null \
  | awk -F= '/MARKETING_VERSION/{gsub(/^[ \t]+|[ \t]+$/, "", $2); v=$2} END{print v}')"

# ② 失败则从源码 Info.plist 读取
if [[ -z "${VERSION}" ]]; then
  SRC_PLIST="$(git ls-files | grep -E '/Info\.plist$' | head -n1 || true)"
  if [[ -n "${SRC_PLIST}" ]]; then
    VERSION=$(/usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" "${SRC_PLIST}" 2>/dev/null || true)
  fi
fi

# ③ 仍取不到 → 先构建再从产物 Info.plist 读取
if [[ -z "${VERSION}" ]]; then
  warn "未从 Build Settings/源码 Info.plist 读到版本，将先构建再从产物读取。"
  rm -rf "${BUILD_DIR}"
  "$XCB" -project "$PROJECT_FILE" -scheme "$SCHEME_APP" -configuration "$CONFIG" -derivedDataPath "$BUILD_DIR" > /dev/null
  PROD_PLIST="${BUILD_DIR}/Build/Products/${CONFIG}/${APP_NAME}/Contents/Info.plist"
  [[ -f "${PROD_PLIST}" ]] || { err "构建后仍未找到产物 Info.plist：${PROD_PLIST}"; exit 1; }
  VERSION=$(/usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" "${PROD_PLIST}" 2>/dev/null || true)
fi

[[ -n "${VERSION}" ]] || { err "无法确定版本号（请在 Target→General→Version 设置或 Info.plist 写入 CFBundleShortVersionString）。"; exit 1; }
TAG="v${VERSION}"
ok "版本号：${VERSION}（Tag: ${TAG}）"

# ④ 构建 Helper（优先 scheme，失败再 fallback）
say "构建 UpdaterHelper（${CONFIG}）…"
rm -rf "${BUILD_DIR}"
set +e
"${XCB}" -project "$PROJECT_FILE" -scheme "$TARGET_HELPER" -configuration "$CONFIG" -derivedDataPath "$BUILD_DIR" > /dev/null
SCHEME_RC=$?
set -e

if [[ $SCHEME_RC -ne 0 ]]; then
  warn "使用 -scheme 构建 UpdaterHelper 失败，改用 -target（不带 -derivedDataPath）重试…"
  "${XCB}" -project "$PROJECT_FILE" -target "$TARGET_HELPER" -configuration "$CONFIG" > /dev/null

  # 在默认 DerivedData 下找 Helper 产物
  DEFAULT_DD="$("${XCB}" -project "$PROJECT_FILE" -showBuildSettings 2>/dev/null | awk -F= '/BUILD_DIR/{gsub(/^[ \t]+|[ \t]+$/, "", $2);print $2;exit}')"
  CAND1="${DEFAULT_DD}/${CONFIG}/UpdaterHelper"
  CAND2="${DEFAULT_DD}/Debug/UpdaterHelper"
  mkdir -p "${BUILD_DIR}/Build/Products/${CONFIG}"
  if [[ -f "$CAND1" ]]; then
    cp -f "$CAND1" "${BUILD_DIR}/Build/Products/${CONFIG}/UpdaterHelper"
  elif [[ -f "$CAND2" ]]; then
    cp -f "$CAND2" "${BUILD_DIR}/Build/Products/${CONFIG}/UpdaterHelper"
  else
    err "未找到 UpdaterHelper 构建产物（默认 DerivedData）。"
    exit 1
  fi
fi

HELPER_BIN_REL="${BUILD_DIR}/Build/Products/${CONFIG}/UpdaterHelper"
HELPER_BIN_DBG="${BUILD_DIR}/Build/Products/Debug/UpdaterHelper"
[[ -f "$HELPER_BIN_REL" || -f "$HELPER_BIN_DBG" ]] || {
  err "未找到 UpdaterHelper 构建产物（Release/Debug）。"
  exit 1
}
ok "UpdaterHelper 已构建"

# ⑤ 构建主 App（scheme）
say "构建主 App（${CONFIG}）…"
"$XCB" -project "$PROJECT_FILE" -scheme "$SCHEME_APP" -configuration "$CONFIG" -derivedDataPath "$BUILD_DIR" > /dev/null
APP_BUILD_PATH="${BUILD_DIR}/Build/Products/${CONFIG}/${APP_NAME}"
[[ -d "$APP_BUILD_PATH" ]] || { err "主 App 产物不存在：$APP_BUILD_PATH"; exit 1; }
ok "主 App 构建完成"

# ⑥ 将 .app 拷到仓库根，便于打包与脚本校验
rm -rf "${APP_NAME}"
cp -R "${APP_BUILD_PATH}" "${APP_NAME}"
ok "拷贝 ${APP_NAME} 到仓库根目录"

# ⑦ 校验 Helper 是否在包内；不在则兜底注入（自动拷入）
HELPER_IN_APP="${APP_NAME}/Contents/Helpers/UpdaterHelper"
if [[ ! -f "${HELPER_IN_APP}" ]]; then
  warn "未发现 ${HELPER_IN_APP}。将从构建产物中兜底拷入一次（请稍后在 Xcode 正式修好 Copy Files 设置）。"
  mkdir -p "${APP_NAME}/Contents/Helpers"
  SRC_HELPER="${HELPER_BIN_REL}"
  [[ -f "$SRC_HELPER" ]] || SRC_HELPER="${HELPER_BIN_DBG}"
  cp -f "$SRC_HELPER" "${HELPER_IN_APP}"
  chmod +x "${HELPER_IN_APP}"
  ok "已兜底拷入 UpdaterHelper"
fi

# ⑧ 打包 ZIP + 生成 checksums.txt
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

# ⑨ 创建 tag（若不存在）
if git rev-parse "${TAG}" >/dev/null 2>&1; then
  warn "本地已存在 tag ${TAG}"
else
  say "创建 tag ${TAG} 并推送…"
  git tag "${TAG}"
  git push origin "${TAG}"
  ok "Tag 已推送"
fi

# ⑩ 准备 Release Notes（安全展开，兼容 set -u）
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

# ⑪ 创建/更新 Release（用参数数组更稳）
say "创建/更新 GitHub Release：${OWNER_REPO} @ ${TAG} …"

# 是否已有 release
if gh release view "${TAG}" -R "${OWNER_REPO}" >/dev/null 2>&1; then
  warn "Release ${TAG} 已存在 → 更新资产"
  gh release upload "${TAG}" "${ZIP}" checksums.txt -R "${OWNER_REPO}" --clobber
else
  # 组装参数数组，避免空参数触发 zsh/bash 的奇怪展开
  ARGS=( "${TAG}" "${ZIP}" "checksums.txt" -R "${OWNER_REPO}" --title "GatekeeperHelper ${VERSION}" )

  # 预发布标记
  if ${PRE_RELEASE}; then
    ARGS+=( --prerelease )
  fi

  # 备注文件（沿用前面生成的 NOTES_OPT 逻辑）
  if [[ -n "${RELEASE_NOTES_FILE}" && -f "${RELEASE_NOTES_FILE}" ]]; then
    ARGS+=( --notes-file "${RELEASE_NOTES_FILE}" )
  else
    LAST_TAG="$(git describe --tags --abbrev=0 2>/dev/null || echo "")"
    if [[ -n "${LAST_TAG}" && "${LAST_TAG}" != "${TAG}" ]]; then
      NOTES_FILE="$(mktemp)"
      echo "Changes since ${LAST_TAG}:" > "${NOTES_FILE}"
      git log --pretty=format:"- %s (%h)" "${LAST_TAG}..HEAD" >> "${NOTES_FILE}"
      ARGS+=( --notes-file "${NOTES_FILE}" )
    fi
  fi

  gh release create "${ARGS[@]}"
fi

ok "发版成功！"
echo "  • ZIP: ${ZIP}"
echo "  • SHA: ${SHA}"
echo "  • Release: https://github.com/${OWNER_REPO}/releases/tag/${TAG}"