#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "用法: $0 <version>" >&2
  exit 1
fi

APP="GatekeeperHelper.app"
VER="$1"
OUT="GatekeeperHelper-${VER}.zip"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

if [[ ! -d "$APP" ]]; then
  echo "未找到 $APP，请先构建发布版本。" >&2
  exit 1
fi

rm -f "$OUT"
/usr/bin/zip -ry "$OUT" "$APP"
SHA=$(shasum -a 256 "$OUT" | awk '{print $1}')
cat <<EOT > checksums.txt
SHA256 $SHA $OUT
EOT

echo "Built $OUT with SHA256=$SHA"
