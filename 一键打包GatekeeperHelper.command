#!/bin/bash

# 项目源目录
cd /Users/tangziyao/Documents/GatekeeperHelper_project

# 构造 zip 文件名（带时间戳）
ZIP_NAME="GatekeeperHelper_$(date '+%Y-%m-%d_%H-%M-%S').zip"

# 压缩并输出到桌面
DEST_PATH=~/Desktop/$ZIP_NAME
zip -r "$DEST_PATH" GatekeeperHelper > /dev/null

# 打开桌面，提示完成
echo "✅ 项目已打包：$DEST_PATH"
open ~/Desktop
echo ""
read -n 1 -s -r -p "📦 打包完成，文件已生成在桌面，按任意键关闭窗口"