# Gatekeeper 放行指南

由于 GatekeeperHelper 目前未使用 Apple Developer 证书签名，第一次运行或每次自动更新后，macOS 可能弹出 “无法验证开发者” 的提示。您可以按照以下任意方式放行：

1. 在 Finder 中找到 `GatekeeperHelper.app`，按住 `Control` 键并点击图标，选择 **打开**，随后在弹出的提示框中再次点击 **打开**。
2. 打开 **系统设置 → 隐私与安全性**，在“安全性”部分看到 “来自开发者 Tang1206cc 的 `GatekeeperHelper.app` 已被阻止使用”，点击 **仍要打开**。

勾选偏好设置中的“允许更新器在安装后移除 Gatekeeper 隔离属性”选项后，更新器将在安装完成后为您执行 `xattr -d com.apple.quarantine`，仅作用于 GatekeeperHelper 的应用包，可减少重复出现的提醒。请在理解风险并确认来源可信的前提下启用该选项。

如遇问题，欢迎在 [GitHub Issues](https://github.com/Tang1206cc/GatekeeperHelper/issues) 中反馈，并附上 `~/Library/Logs/GatekeeperHelper/Updater.log` 日志的最近内容以便排查。
