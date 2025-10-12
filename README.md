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

## 发版测试与收尾清单

1. **准备工作**
   - 依据 Info.plist 更新 `CFBundleShortVersionString` 与 `CFBundleVersion`，确认主程序、`UpdaterHelper` 与 `GKHCLIUpdater` 的版本号一致。
   - 在 GitHub Release 草稿中粘贴更新日志，确保包含主要改动与 Gatekeeper 提示说明。
   - 确认 `Resources/Privacy/GatekeeperGuide.md` 与设置页文案同步，避免出现指引不一致。

2. **本地端到端模拟（无需上传 GitHub）**
   - 在包含 `GatekeeperHelper.app` 的目录执行 `Scripts/local_test_update.sh`，获取临时 zip 包与 `checksums.txt`；以 `python3 -m http.server` 或本地文件路径模拟下载源。
   - 启动旧版本 GatekeeperHelper，通过“检查更新”选择自定义下载地址（调试时可在 `GitHubAPIClient` 注入自定义 URL）验证：
     1. Release 元数据解析正确（版本号、日志显示完整）。
     2. 下载进度、SHA-256 校验、解压路径及失败重试逻辑正常工作。
     3. 勾选“允许移除隔离属性”后在安装计划中写入 `removeQuarantine: true`，并确认 Helper 执行 `xattr -d` 成功。
   - 观察 `~/Library/Logs/GatekeeperHelper/Updater.log`，确认关键节点（检查、下载、校验、解压、安装、回滚）都有记录。

3. **GitHub Release 验证**
   - 上传脚本生成的 zip 与校验文件后，在未登录或无 Token 的网络环境下尝试检查更新，确保匿名速率限制下也能完成请求。
   - 切换“包含 Beta 版本”开关，确认预发布与正式版本在 UI 中呈现逻辑正确。
   - 若启用“自动下载”，在后台等待定时器触发，确保新版本下载完成后出现安装提示。

4. **LaunchAgent（可选）**
   - 在偏好设置中开启 LaunchAgent，使用 `launchctl list | grep gkh` 确认加载成功。
   - 注销后重新登录或执行 `launchctl kickstart`，验证 CLI 工具可在无主应用的情况下写入检查结果。
   - 关闭自动检查时卸载 LaunchAgent，确认 `~/Library/LaunchAgents/com.gkh.updater.plist` 被移除。

5. **发布前收尾**
   - 再次使用旧版本完整跑一次在线更新流程，确保 Helper 能备份旧版本（位于 `~/Library/Application Support/GKH/PreviousVersions`）。
   - 检查安装完成后的 App 是否自动重启，版本号与 Release 匹配且 Gatekeeper 可正常放行。
   - 在设置页执行“恢复默认设置”，确认更新相关偏好被清空，并重新勾选所需开关。
   - 将最新日志复制备份，必要时附在 Release Notes 或 Issue 模板中作为排查参考。

## 常见问题

- **Gatekeeper 阻止启动**：参考 `Resources/Privacy/GatekeeperGuide.md`，或在偏好设置中允许更新器自动移除隔离属性。
- **GitHub 限流**：若频繁请求 API 导致 403，可在系统钥匙串添加个人访问令牌并扩展 `GitHubAPIClient` 的 `tokenProvider`。
- **失败排查**：在设置页点击“复制最近日志”或“打开日志文件夹”，将日志附在 Issue 中反馈。

更多开发细节与后续规划见 `Resources/Privacy/GatekeeperGuide.md` 与源代码注释。
