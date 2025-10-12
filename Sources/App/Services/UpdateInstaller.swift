import Foundation
import AppKit

public enum UpdateInstallerError: Error, LocalizedError {
    case helperNotFound
    case failedToLaunchHelper

    public var errorDescription: String? {
        switch self {
        case .helperNotFound:
            return "未找到 Updater Helper 程序。"
        case .failedToLaunchHelper:
            return "无法启动 Updater Helper。"
        }
    }
}

public final class UpdateInstaller {
    private let logger: UpdaterLogger

    public init(logger: UpdaterLogger = .shared) {
        self.logger = logger
    }

    public func install(newAppPath: URL, removeQuarantine: Bool) async throws -> Never {
        let bundle = Bundle.main
        let targetURL = bundle.bundleURL
        let backupDir = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent("Library/Application Support/GatekeeperHelper/PreviousVersions", isDirectory: true)
        try FileManager.default.createDirectory(at: backupDir, withIntermediateDirectories: true)

        let plan = InstallPlan(
            newAppPath: newAppPath.path,
            targetAppPath: targetURL.path,
            backupDir: backupDir.path,
            relaunchBundleID: bundle.bundleIdentifier ?? "",
            logFile: await logger.url().path,
            removeQuarantine: removeQuarantine
        )

        let planURL = FileManager.default.temporaryDirectory.appendingPathComponent("InstallPlan.json")
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted]
        let data = try encoder.encode(plan)
        try data.write(to: planURL, options: .atomic)

        let helperURL = bundle.url(forAuxiliaryExecutable: "UpdaterHelper")
        guard let helperURL else {
            await logger.log("未找到 UpdaterHelper 可执行文件", level: .error)
            throw UpdateInstallerError.helperNotFound
        }

        let process = Process()
        process.executableURL = helperURL
        process.arguments = ["--plan", planURL.path]

        await logger.log("启动 Helper 执行安装: \(helperURL.path) plan=\(planURL.path)")
        do {
            try process.run()
        } catch {
            await logger.log("启动 Helper 失败: \(error.localizedDescription)", level: .error)
            throw UpdateInstallerError.failedToLaunchHelper
        }

        await MainActor.run {
            NSApp.terminate(nil)
        }
        RunLoop.current.run()
        fatalError("NSApp.terminate 未返回")
    }
}
