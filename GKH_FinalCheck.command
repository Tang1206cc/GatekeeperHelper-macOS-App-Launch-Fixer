#!/bin/bash
echo "──────────────────────────────────────────────"
echo "🧩 GatekeeperHelper 更新系统 收尾检查工具"
echo "──────────────────────────────────────────────"
echo

BASE_DIR="$(cd "$(dirname "$0")" && pwd)"
APP_DIR="$BASE_DIR/GatekeeperHelper.app"
SCRIPT_DIR="$BASE_DIR/Scripts"
LOG_DIR="$HOME/Library/Logs/GatekeeperHelper"

PASS=true

# 1️⃣ 目录结构检查
echo "① 检查项目结构..."
REQUIRED_DIRS=("Sources/App" "Sources/UpdaterHelper" "Scripts" "Resources")
for d in "${REQUIRED_DIRS[@]}"; do
  if [ ! -d "$BASE_DIR/$d" ]; then
    echo "❌ 缺少目录: $d"
    PASS=false
  else
    echo "✅ 存在: $d"
  fi
done
echo

# 2️⃣ 脚本权限检查
echo "② 检查脚本执行权限..."
for f in "$SCRIPT_DIR"/*.sh; do
  if [ ! -x "$f" ]; then
    echo "⚠️  修正权限: $f"
    chmod +x "$f"
  else
    echo "✅ 可执行: $(basename "$f")"
  fi
done
echo

# 3️⃣ 检查 Helper 是否存在于包内
echo "③ 检查 UpdaterHelper 打包路径..."
HELPER_PATH="$APP_DIR/Contents/Helpers/UpdaterHelper"
if [ -f "$HELPER_PATH" ]; then
  echo "✅ 已找到 Helper 可执行文件"
else
  echo "❌ 未找到 UpdaterHelper，可执行文件未被正确打包"
  PASS=false
fi
echo

# 4️⃣ 版本号与构建号
echo "④ 检查 Info.plist 版本信息..."
PLIST="$APP_DIR/Contents/Info.plist"
if [ -f "$PLIST" ]; then
  VERSION=$(/usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" "$PLIST" 2>/dev/null)
  BUILD=$(/usr/libexec/PlistBuddy -c "Print :CFBundleVersion" "$PLIST" 2>/dev/null)
  echo "✅ CFBundleShortVersionString = $VERSION"
  echo "✅ CFBundleVersion = $BUILD"
else
  echo "❌ 未找到 Info.plist"
  PASS=false
fi
echo

# 5️⃣ Bundle Identifier 检查
echo "⑤ 检查 Bundle Identifier..."
BUNDLE_ID=$(/usr/libexec/PlistBuddy -c "Print :CFBundleIdentifier" "$PLIST" 2>/dev/null)
if [[ -n "$BUNDLE_ID" ]]; then
  echo "✅ Bundle Identifier = $BUNDLE_ID"
else
  echo "❌ 无法读取 Bundle ID"
  PASS=false
fi
echo

# 6️⃣ 检查打包脚本可运行性
echo "⑥ 测试 release_build.sh ..."
if [ -f "$SCRIPT_DIR/release_build.sh" ]; then
  bash "$SCRIPT_DIR/release_build.sh" --check >/dev/null 2>&1
  if [ $? -eq 0 ]; then
    echo "✅ 打包脚本运行正常"
  else
    echo "⚠️  打包脚本存在潜在错误，请手动测试 ./Scripts/release_build.sh 1.0.0"
  fi
else
  echo "❌ 缺少 release_build.sh"
  PASS=false
fi
echo

# 7️⃣ 日志目录检查
echo "⑦ 检查日志目录..."
if [ ! -d "$LOG_DIR" ]; then
  echo "⚠️  创建日志目录: $LOG_DIR"
  mkdir -p "$LOG_DIR"
fi
if [ -w "$LOG_DIR" ]; then
  echo "✅ 日志目录可写"
else
  echo "❌ 日志目录不可写"
  PASS=false
fi
echo

# 8️⃣ 结果总结
echo "──────────────────────────────────────────────"
if [ "$PASS" = true ]; then
  echo "🎉 所有检查均通过！GatekeeperHelper 可进行首次发版测试。"
else
  echo "⚠️ 存在未通过项，请根据提示修复后重试。"
fi
echo "──────────────────────────────────────────────"