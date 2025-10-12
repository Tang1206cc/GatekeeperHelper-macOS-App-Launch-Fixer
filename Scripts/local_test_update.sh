#!/usr/bin/env bash
set -euo pipefail

APP_BUNDLE="GatekeeperHelper.app"
TEMP_DIR="$(mktemp -d /tmp/gkh-update-test.XXXXXX)"
ZIP_PATH="$TEMP_DIR/test.zip"

function cleanup() {
  rm -rf "$TEMP_DIR"
}
trap cleanup EXIT

if [[ ! -d "$APP_BUNDLE" ]]; then
  echo "请在包含 GatekeeperHelper.app 的目录执行。" >&2
  exit 1
fi

/usr/bin/zip -ry "$ZIP_PATH" "$APP_BUNDLE"
SHA=$(shasum -a 256 "$ZIP_PATH" | awk '{print $1}')
cat <<EOT > "$TEMP_DIR/checksums.txt"
SHA256 $SHA $(basename "$ZIP_PATH")
EOT

echo "已在 $TEMP_DIR 生成测试包，可模拟 GitHub Releases 进行端到端测试。"
