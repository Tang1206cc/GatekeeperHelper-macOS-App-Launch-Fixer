import Foundation
import AppKit

@main
struct UpdaterHelperMain {
    static func main() async {
        let arguments = CommandLine.arguments
        guard let planIndex = arguments.firstIndex(of: "--plan"), planIndex + 1 < arguments.count else {
            fputs("UpdaterHelper 缺少 --plan 参数\n", stderr)
            exit(2)
        }

        let planPath = arguments[planIndex + 1]
        let planURL = URL(fileURLWithPath: planPath)
        do {
            let data = try Data(contentsOf: planURL)
            let plan = try JSONDecoder().decode(HelperInstallPlan.self, from: data)
            let logger = HelperLogger(logURL: plan.logFileURL)
            logger.log("Helper 启动，计划文件：\(planPath)")
            try execute(plan: plan, logger: logger)
            exit(0)
        } catch {
            fputs("UpdaterHelper 执行失败: \(error)\n", stderr)
            exit(1)
        }
    }

    private static func execute(plan: HelperInstallPlan, logger: HelperLogger) throws {
        let ops = FileOps()
        let relauncher = Relauncher()
        relauncher.waitForTermination(bundleID: plan.relaunchBundleID, logger: logger)
        try ops.backupAndReplace(plan: plan, logger: logger)
        ops.removeQuarantineIfNeeded(plan: plan, logger: logger)
        do {
            try relauncher.relaunch(bundleID: plan.relaunchBundleID, logger: logger)
            logger.log("重启命令已触发")
        } catch {
            logger.log("重启失败: \(error.localizedDescription)")
            throw error
        }
    }
}
