# GatekeeperHelper 更新机制说明

GatekeeperHelper 通过 GitHub Releases 提供自更新能力，包括检查、下载、校验与自动替换应用。主要特性：

- 在偏好设置中手动或自动检查更新，可选择是否包含预发布版本。
- 支持运行期自动轮询与可选 LaunchAgent（即使主程序未运行也可定时检查）。
- 下载完成后执行 SHA-256 校验，并在用户授权下移除隔离属性，尽可能减少 Gatekeeper 阻拦。
- 由独立的 `UpdaterHelper` 进程负责备份旧版、替换新版本与重启应用，若失败会尝试回滚并记录日志。
- 所有更新日志与故障信息统一写入 `~/Library/Logs/GatekeeperHelper/Updater.log`，可在 UI 中一键复制或定位。

## 发布流程

1. 执行 `Scripts/release_build.sh <版本号>` 生成 `GatekeeperHelper-<版本号>.zip` 与 `checksums.txt`。
2. 在 GitHub 创建 Tag（格式 `vX.Y.Z`）并发布 Release，上传生成的压缩包与校验文件，填入更新日志。
3. 预发布版本请勾选 **Pre-release**，主程序可通过“包含 Beta 版本”开关订阅。
4. 发布后使用旧版本的 GatekeeperHelper 点击“检查更新”，验证完整链路。

## 常见问题

- **Gatekeeper 阻止启动**：参考 `Resources/Privacy/GatekeeperGuide.md`，或在偏好设置中允许更新器自动移除隔离属性。
- **GitHub 限流**：若频繁请求 API 导致 403，可在系统钥匙串添加个人访问令牌并扩展 `GitHubAPIClient` 的 `tokenProvider`。
- **失败排查**：在设置页点击“复制最近日志”或“打开日志文件夹”，将日志附在 Issue 中反馈。

更多开发细节与后续规划见 `Resources/Privacy/GatekeeperGuide.md` 与源代码注释。
