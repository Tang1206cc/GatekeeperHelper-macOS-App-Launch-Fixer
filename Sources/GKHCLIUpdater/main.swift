import Foundation

@main
struct GKHCLIUpdater {
    static func main() async {
        let arguments = CommandLine.arguments
        guard arguments.contains("--check") else {
            print("用法: GKHCLIUpdater --check")
            return
        }
        let prefs = UpdatePreferences()
        let logger = UpdaterLogger.shared
        let api = GitHubAPIClient(owner: "Tang1206cc", repo: "GatekeeperHelper")
        let checker = UpdateChecker(api: api, preferences: prefs, logger: logger)
        do {
            let info = try await checker.check(includePrereleases: prefs.includePrereleases)
            print("发现新版本: \(info.latest)")
        } catch UpdateCheckerError.alreadyLatest {
            print("当前已是最新版本。")
        } catch {
            print("检查更新失败: \(error.localizedDescription)")
        }
    }
}
