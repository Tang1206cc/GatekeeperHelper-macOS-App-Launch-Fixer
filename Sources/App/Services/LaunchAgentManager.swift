import Foundation
import Darwin

public enum LaunchAgentError: Error, LocalizedError {
    case templateMissing
    case writeFailed
    case commandFailed(Int32)

    public var errorDescription: String? {
        switch self {
        case .templateMissing:
            return "缺少 LaunchAgent 模板文件。"
        case .writeFailed:
            return "无法写入 LaunchAgent 文件。"
        case .commandFailed(let code):
            return "launchctl 执行失败，退出码 \(code)。"
        }
    }
}

public struct LaunchAgentManager {
    private let fileManager = FileManager.default
    private let logger: UpdaterLogger

    public init(logger: UpdaterLogger = .shared) {
        self.logger = logger
    }

    private var agentDestination: URL {
        fileManager.homeDirectoryForCurrentUser
            .appendingPathComponent("Library/LaunchAgents/com.gkh.updater.plist")
    }

    public func installAgentIfNeeded(programPath: String, hour: Int = 10, minute: Int = 0) async throws {
        guard let templateURL = Bundle.main.url(forResource: "com.gkh.updater.plist", withExtension: "template", subdirectory: "LaunchAgents") else {
            await logger.log("LaunchAgent 模板缺失", level: .error)
            throw LaunchAgentError.templateMissing
        }
        var template = try String(contentsOf: templateURL)
        template = template
            .replacingOccurrences(of: "/Applications/GatekeeperHelper.app/Contents/MacOS/GKHCLIUpdater", with: programPath)
            .replacingOccurrences(of: "<HOUR>", with: String(hour))
            .replacingOccurrences(of: "<MINUTE>", with: String(minute))
        let destination = agentDestination
        try fileManager.createDirectory(at: destination.deletingLastPathComponent(), withIntermediateDirectories: true)
        do {
            try template.write(to: destination, atomically: true, encoding: .utf8)
        } catch {
            await logger.log("写入 LaunchAgent 失败: \(error.localizedDescription)", level: .error)
            throw LaunchAgentError.writeFailed
        }
        try await runLaunchCtl(arguments: ["bootstrap", "gui/\(geteuid())", destination.path])
        await logger.log("LaunchAgent 已安装: \(destination.path)")
    }

    public func removeAgentIfNeeded() async throws {
        let destination = agentDestination
        if fileManager.fileExists(atPath: destination.path) {
            try? await runLaunchCtl(arguments: ["bootout", "gui/\(geteuid())", destination.path])
            try? fileManager.removeItem(at: destination)
            await logger.log("LaunchAgent 已移除")
        }
    }

    private func runLaunchCtl(arguments: [String]) async throws {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/launchctl")
        process.arguments = arguments
        try process.run()
        process.waitUntilExit()
        if process.terminationStatus != 0 {
            await logger.log("launchctl 失败 code=\(process.terminationStatus)", level: .error)
            throw LaunchAgentError.commandFailed(process.terminationStatus)
        }
    }
}
