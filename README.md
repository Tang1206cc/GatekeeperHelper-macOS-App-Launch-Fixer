# 🧩 GatekeeperHelper

**GatekeeperHelper** 是一款 macOS 原生工具，用于快速修复 Gatekeeper 安全限制、开发者验证问题及常见 App 启动失败等情况。  
本项目完全本地运行，不依赖任何网络通信，安全且高效。

---

## 🚀 一键操作脚本

本仓库提供 5 个 `.command` 脚本，可直接双击运行（建议已赋予执行权限）。

| 脚本名称 | 功能简介 |
|-----------|-----------|
| **上行刷新GTKH库.command** | 普通上行推送，将本地更新同步到 GitHub 仓库 |
| **下行刷新GTKH库.command** | 拉取远端最新提交（含自动暂存当前修改） |
| **上行平推GTKH库.command** | ⚠️ 强制覆盖远端分支，仅保留当前本地快照（慎用） |
| **OneClickRelease.command** | 一键打包 & 构建 & 推送 GitHub Release（含 Helper 构建自动兜底） |
| **切换GitHub连接模式.command** | 一键切换 SSH / HTTPS / HTTP1.1 / HTTP2 模式（连接异常时使用） |

---

## 💡 使用建议

- **日常开发**  
  使用 `上行刷新GTKH库.command` 与 `下行刷新GTKH库.command` 进行常规同步即可。
- **网络卡顿 / 推送失败时**  
  运行 `切换GitHub连接模式.command`，可在 SSH 与 HTTPS(HTTP1.1) 之间自由切换。
- **全量替换远端仓库**  
  仅当远端仓库混乱或损坏时执行 `上行平推GTKH库.command`。
- **版本发版**  
  调整 Info.plist / MARKETING_VERSION 后，运行 `OneClickRelease.command` 自动构建、打包并上传 GitHub Release。

---

## ⚙️ 环境要求

- macOS 13+  
- Xcode.app 已正确安装（可为外置路径）  
- Homebrew + Git + GitHub CLI (`gh`)  
- 已登录 GitHub：  
  ```bash
  gh auth login
