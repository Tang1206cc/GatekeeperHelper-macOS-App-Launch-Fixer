# GatekeeperHelper - macOS App Launch Fixer

**GatekeeperHelper** is a native macOS utility for diagnosing and fixing common "app cannot be opened" problems.

它不是单一的 Gatekeeper 开关工具，而是一个面向普通 macOS 用户的 **App 启动异常修复助手**：围绕“已损坏无法打开”“无法验证开发者”“Apple 无法检查是否包含恶意软件”“执行权限不足”“签名异常”“SIP / 安全策略限制”“磁盘映像与安装包异常”等场景，提供清晰的问题识别、自动修复入口和必要的手动操作指引。

<p align="center">
  <a href="#中文说明"><img alt="中文说明" src="https://img.shields.io/badge/中文说明-0A66C2?style=for-the-badge"></a>
  <a href="#english"><img alt="English" src="https://img.shields.io/badge/English-111827?style=for-the-badge"></a>
  <a href="https://github.com/Tang1206cc/GatekeeperHelper-macOS-App-Launch-Fixer/releases/latest"><img alt="Download" src="https://img.shields.io/badge/Download-Latest%20Release-22C55E?style=for-the-badge"></a>
  <a href="https://github.com/Tang1206cc/GatekeeperHelper-macOS-App-Launch-Fixer/issues"><img alt="Issues" src="https://img.shields.io/badge/Feedback-Issues-FF9500?style=for-the-badge"></a>
</p>

---

## 中文说明

### 这个项目解决什么问题

在 macOS 上，从浏览器、网盘、开发者网站、旧安装包或第三方渠道获得的 App，有时会因为 Gatekeeper、隔离属性、签名、公证、执行权限、SIP 或系统安全策略而无法正常打开。用户看到的提示往往很模糊，例如：

- “XXX 已损坏，无法打开。您应该推出磁盘映像 / 移到废纸篓”
- “无法打开 XXX，因为 Apple 无法检查其是否包含恶意软件”
- “Apple 无法验证 XXX 是否包含可能危害 Mac 安全或泄漏隐私的恶意软件”
- “无法打开 XXX，因为无法验证开发者”
- “XXX 意外退出”
- “XXX 软件打开失败”
- “文件 XXX.command 无法执行，因为您没有正确的访问权限”
- “无法打开 XXX，因为它不是从 App Store 下载”
- “无法打开 XXX，因为安全策略已设为某某安全性”
- “未能打开磁盘映像，磁盘映像格式已过时”
- 启动软件时反复弹出密码 / 钥匙串提示
- 安装 Adobe 软件时运行 `Install` 文件后报错

GatekeeperHelper 将这些分散的问题整理为一个本地原生图形界面：先帮助用户识别自己遇到的提示，再给出对应的修复方式。能自动修复的场景直接执行；不适合自动处理的场景提供步骤化说明和跳转入口。

### 主要特性

- **原生 macOS 应用**：使用 SwiftUI + AppKit 构建，不是网页壳。
- **问题库式入口**：内置 13 类常见 App 启动 / 安装失败场景，用户按弹窗文字选择即可。
- **拖拽式修复**：支持拖入 `.app` 或 `.command` 文件，减少手动敲命令。
- **隔离属性处理**：可移除 `com.apple.quarantine`，用于处理常见的“已损坏无法打开”问题。
- **Gatekeeper 控制与恢复**：提供临时绕过优先的处理路径，也提供恢复 Gatekeeper 的入口。
- **签名修复**：支持对 App Bundle 或内部 Unix 可执行文件执行 ad-hoc `codesign`。
- **执行权限修复**：支持为 App 内部可执行文件或 `.command` 文件添加执行权限。
- **UPX / 壳相关问题指引**：针对“应用程序无法打开”等场景提供 Homebrew、UPX 与手动处理步骤。
- **系统设置跳转**：对公证、开发者验证、App Store 来源限制等问题，直接引导到 macOS 隐私与安全性设置。
- **SIP 与安全策略说明**：提供 SIP 状态判断、恢复模式操作说明和风险提示。
- **修复历史**：记录最近 20 条修复操作，便于回看。
- **偏好设置**：支持开机自启动、主题模式、Esc 退出、关闭最后窗口时退出等选项。
- **应用内更新**：通过 GitHub Releases 检查、下载并安装新版本。

### 支持的问题与处理方式

| 场景 | GatekeeperHelper 的处理方式 |
| --- | --- |
| App 提示“已损坏，无法打开” | 推荐移除 quarantine；必要时引导用户调整 Gatekeeper 设置 |
| App “意外退出” | 提供 App Bundle 签名和 Unix 可执行文件签名两种方式 |
| App 包内可执行文件没有执行权限 | 检测 `Contents/MacOS` 并执行 `chmod +x` |
| `.command` 文件无法执行 | 为指定 `.command` 文件添加执行权限 |
| Apple 无法检查是否包含恶意软件 | 引导用户到“隐私与安全性”中手动允许 |
| 无法验证开发者 | 提供右键打开、系统允许等处理步骤 |
| 不是从 App Store 下载 | 引导调整“允许从以下来源的应用程序”设置 |
| 安全策略限制 | 说明恢复模式、启动安全性实用工具与 SIP 的关系 |
| 磁盘映像格式已过时 | 引导使用系统“磁盘工具”打开映像 |
| 钥匙串反复弹窗 | 引导定位用户目录下的 Keychains 文件夹 |
| Adobe Install 报错 | 引导进入安装包内容并运行内部 Unix 可执行文件 |
| UPX / 带壳 App 无法打开 | 提供 Homebrew、UPX 安装与手动脱壳操作说明 |

### 自动修复与手动指引的边界

GatekeeperHelper 的目标是让修复过程更清楚、更少出错，但不会把所有系统安全限制都粗暴地“一键关闭”。

自动执行的操作主要包括：

- `xattr -r -d com.apple.quarantine`
- `spctl --master-disable` / `spctl --master-enable`
- `codesign --force --deep --sign -`
- `codesign --force --sign -`
- `chmod +x`

需要用户自行确认或手动完成的操作包括：

- 在“系统设置 > 隐私与安全性”中点击“仍要打开”或调整来源选项
- 进入恢复模式修改 SIP 或启动安全性策略
- 按说明安装 Homebrew / UPX 并处理带壳 App
- 处理钥匙串、磁盘工具、Adobe 安装包等无法可靠自动化的场景

这样做是有意为之：涉及系统安全策略、SIP、恢复模式和第三方工具安装的操作，本就应该由用户明确理解后再执行。

### 安全说明

- 本工具不会上传用户拖入的 App、文件路径或系统信息。
- 常规修复命令在本机执行；需要管理员权限时会触发 macOS 系统授权弹窗。
- “检查更新”会访问 GitHub Releases，用于获取最新版本信息和下载更新包。
- 优先使用“临时绕过 / 单个 App 修复”，不要在没有明确需要时长期关闭 Gatekeeper 或 SIP。
- GatekeeperHelper 不是杀毒软件，不能判断某个 App 是否真的安全。请只运行你信任来源的应用。

### 下载与安装

1. 打开 [Latest Release](https://github.com/Tang1206cc/GatekeeperHelper-macOS-App-Launch-Fixer/releases/latest)。
2. 下载 `GatekeeperHelper-*.zip`。
3. 解压后将 `GatekeeperHelper.app` 拖入“应用程序”文件夹。
4. 如果 macOS 首次阻止打开，可在 Finder 中右键点击 App，选择“打开”，并按系统提示确认。

### 基本使用

1. 启动 GatekeeperHelper。
2. 在左侧选择与你看到的 macOS 弹窗最接近的问题。
3. 阅读右侧说明，确认该问题是否匹配。
4. 如果页面提供拖拽区域，将需要修复的 `.app` 或 `.command` 拖入窗口。
5. 按弹窗选择推荐方式执行修复。
6. 如果是手动指引类问题，按步骤跳转到系统设置、访达、磁盘工具或恢复模式完成操作。

### 开发与构建

本仓库是一个 Xcode 原生 macOS 项目，主要结构如下：

```text
GatekeeperHelper.xcodeproj
GatekeeperHelper/
  ContentView.swift              主界面与问题库
  Unlocker.swift                 核心修复命令封装
  AuthorizationTool.m/.h         管理员权限命令执行
  AuthorizationBridge.swift      Swift 调用桥接
  FixAppModalView.swift          拖入 App 后的修复弹窗
  *FixView.swift                 各类问题的解决方案说明
  RepairHistory.swift            修复历史
  SettingsView.swift             偏好设置
  Update/                        GitHub Releases 更新检查、下载、安装
UpdaterHelper/
  main.swift                     独立更新助手
```

构建方式：

1. 使用 Xcode 打开 `GatekeeperHelper.xcodeproj`。
2. 选择 `GatekeeperHelper` scheme。
3. 直接 Run 或 Archive。

当前工程包含主 App 与 `UpdaterHelper` 两部分；更新安装逻辑依赖打包时将更新助手放入 App Bundle。

### 适合谁使用

- 不熟悉终端命令，但需要处理 macOS App 打不开问题的普通用户。
- 经常测试第三方 macOS App、旧版本 App、未公证 App 的用户。
- 希望把 `xattr`、`codesign`、`chmod`、Gatekeeper 恢复等操作集中到一个图形化入口的用户。
- 需要给他人远程说明 macOS 启动报错处理流程的人。

### 不适合的场景

- 你希望工具替你判断软件来源是否可信。
- 你希望绕过企业、学校或组织强制部署的安全策略。
- 你不理解关闭 Gatekeeper / SIP 的风险，却希望长期关闭系统保护。
- 你遇到的是 App 自身崩溃、缺少运行库、架构不兼容或网络服务故障，而不是 macOS 安全拦截。

### 反馈

如果你发现某类 macOS 弹窗没有覆盖，或某个步骤在新版本 macOS 上已经变化，欢迎在 [Issues](https://github.com/Tang1206cc/GatekeeperHelper-macOS-App-Launch-Fixer/issues) 中反馈。

---

## English

### What This Project Does

GatekeeperHelper is a native macOS utility for users who run into confusing app launch errors after downloading apps from browsers, cloud drives, developer websites, older installers, or other non-App-Store sources.

Instead of presenting one risky "disable everything" switch, it organizes common macOS launch and installation problems into a guided interface. For issues that can be safely automated, it runs the corresponding local command. For issues that require user judgment, system settings, recovery mode, or external tools, it provides practical step-by-step instructions.

### Common Problems It Covers

- "App is damaged and can't be opened"
- "Apple cannot check it for malicious software"
- "Apple cannot verify that this app is free from malware"
- "Cannot verify developer"
- "App quit unexpectedly"
- Internal Unix executable is missing execute permission
- `.command` file cannot be executed due to insufficient permission
- App is not from the App Store
- macOS security policy prevents the app from opening
- Disk image format is outdated
- Repeated password / Keychain prompts when launching an app
- Adobe installer `Install` file reports an error
- Packed / UPX-related launch failures

### Key Features

- **Native macOS app** built with SwiftUI and AppKit.
- **Guided issue library** with 13 common macOS app launch and installation scenarios.
- **Drag-and-drop repair flow** for `.app` and `.command` files.
- **Quarantine removal** for `com.apple.quarantine`.
- **Gatekeeper disable / restore flow** with risk-aware UI.
- **Ad-hoc signing helpers** for App Bundles and internal Unix executables.
- **Execute permission repair** using `chmod +x`.
- **Manual UPX workflow guidance** for packed apps.
- **System Settings shortcuts** for privacy, security, notarization, and developer verification cases.
- **SIP and security policy guidance** with clear warnings.
- **Repair history** for the latest 20 operations.
- **Preferences** for launch at login, theme mode, Esc-to-quit, and close-window behavior.
- **In-app updater** based on GitHub Releases.

### Automation Boundaries

GatekeeperHelper automates the parts that are reasonable to automate:

- `xattr -r -d com.apple.quarantine`
- `spctl --master-disable` / `spctl --master-enable`
- `codesign --force --deep --sign -`
- `codesign --force --sign -`
- `chmod +x`

It intentionally keeps the following actions as guided manual steps:

- Allowing a blocked app in System Settings
- Changing SIP or startup security policy in recovery mode
- Installing Homebrew / UPX and unpacking apps manually
- Fixing Keychain, Disk Utility, and Adobe installer workflows

This boundary is important because system security changes should be visible, deliberate, and reversible.

### Privacy And Safety

- GatekeeperHelper does not upload your apps, file paths, or system information.
- Repair commands run locally on your Mac.
- Administrator-level actions use the standard macOS authorization prompt.
- The update checker contacts GitHub Releases to check and download new versions.
- Prefer per-app fixes over permanently disabling Gatekeeper or SIP.
- This tool is not antivirus software. It cannot tell whether an app is trustworthy.

### Download And Install

1. Go to the [Latest Release](https://github.com/Tang1206cc/GatekeeperHelper-macOS-App-Launch-Fixer/releases/latest).
2. Download `GatekeeperHelper-*.zip`.
3. Unzip it and move `GatekeeperHelper.app` to `/Applications`.
4. If macOS blocks the app on first launch, right-click it in Finder, choose **Open**, and confirm the system prompt.

### How To Use

1. Open GatekeeperHelper.
2. Select the macOS error message that best matches what you saw.
3. Read the explanation and confirm that the scenario matches your case.
4. If a drop area is shown, drag the affected `.app` or `.command` file into it.
5. Run the recommended repair.
6. For manual-guide scenarios, follow the shown steps and use the provided shortcuts to System Settings, Finder, Disk Utility, or recovery-mode instructions.

### Build From Source

This repository is a native Xcode macOS project.

```text
GatekeeperHelper.xcodeproj
GatekeeperHelper/
  ContentView.swift              Main UI and issue library
  Unlocker.swift                 Core repair command wrapper
  AuthorizationTool.m/.h         Administrator command execution
  AuthorizationBridge.swift      Swift bridge for authorization
  FixAppModalView.swift          Repair modal after app selection
  *FixView.swift                 Guided solution views
  RepairHistory.swift            Repair history
  SettingsView.swift             Preferences
  Update/                        GitHub Releases update flow
UpdaterHelper/
  main.swift                     Standalone update helper
```

To build:

1. Open `GatekeeperHelper.xcodeproj` in Xcode.
2. Select the `GatekeeperHelper` scheme.
3. Run or archive the app.

The project includes both the main app and `UpdaterHelper`; release packaging should include the helper inside the app bundle for the in-app update flow.

### Who It Is For

- Users who need a clearer way to handle macOS app launch blocks.
- People who frequently test third-party, unsigned, older, or non-notarized macOS apps.
- Users who want a GUI wrapper around common `xattr`, `codesign`, `chmod`, and Gatekeeper recovery operations.
- Anyone who needs to explain macOS app launch errors to less technical users.

### What It Is Not

- It is not antivirus software.
- It does not prove that a downloaded app is safe.
- It is not meant to bypass organization-managed security policies.
- It is not a cure for app bugs, missing dependencies, CPU architecture mismatch, or service-side failures.

### Feedback

If a newer macOS version changes a workflow, or if you find an app launch error that is not covered yet, please open an [Issue](https://github.com/Tang1206cc/GatekeeperHelper-macOS-App-Launch-Fixer/issues).

---

## License

No explicit license file is currently included in this repository. Please contact the author before redistributing or reusing substantial parts of the project.

Developer: Tang Ziyao
