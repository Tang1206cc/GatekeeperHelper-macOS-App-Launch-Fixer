import Foundation

struct HelperLogger {
    let logURL: URL
    private let formatter: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return f
    }()

    func log(_ message: String) {
        let line = "[HELPER] [\(formatter.string(from: Date()))] \(message)\n"
        if let data = line.data(using: .utf8) {
            if FileManager.default.fileExists(atPath: logURL.path) {
                if let handle = try? FileHandle(forWritingTo: logURL) {
                    try? handle.seekToEnd()
                    try? handle.write(contentsOf: data)
                    try? handle.close()
                }
            } else {
                try? data.write(to: logURL)
            }
        }
    }
}

enum HelperError: Error {
    case planMissing
    case unableToReadPlan
    case fileOperation(String)
    case relaunchFailed
}

struct FileOps {
    let fileManager = FileManager.default

    func backupAndReplace(plan: HelperInstallPlan, logger: HelperLogger) throws {
        logger.log("开始执行替换流程")
        try fileManager.createDirectory(at: plan.backupDirectoryURL, withIntermediateDirectories: true)
        var backupURL: URL?
        if fileManager.fileExists(atPath: plan.targetAppURL.path) {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyyMMdd-HHmmss"
            let timestamp = formatter.string(from: Date())
            backupURL = plan.backupDirectoryURL.appendingPathComponent("GatekeeperHelper-\(timestamp).app")
            logger.log("备份旧版到 \(backupURL!.path)")
            do {
                if fileManager.fileExists(atPath: backupURL!.path) {
                    try fileManager.removeItem(at: backupURL!)
                }
                try fileManager.moveItem(at: plan.targetAppURL, to: backupURL!)
            } catch {
                logger.log("备份失败: \(error.localizedDescription)")
                throw HelperError.fileOperation("备份失败")
            }
        }

        do {
            if fileManager.fileExists(atPath: plan.targetAppURL.path) {
                try fileManager.removeItem(at: plan.targetAppURL)
            }
            try fileManager.copyItem(at: plan.newAppURL, to: plan.targetAppURL)
        } catch {
            logger.log("复制新版本失败: \(error.localizedDescription)")
            if let backupURL {
                try? restoreBackup(from: backupURL, to: plan.targetAppURL, logger: logger)
            }
            throw HelperError.fileOperation("复制新版本失败")
        }

        logger.log("替换完成")
    }

    private func restoreBackup(from backup: URL, to target: URL, logger: HelperLogger) throws {
        if fileManager.fileExists(atPath: target.path) {
            try? fileManager.removeItem(at: target)
        }
        try fileManager.moveItem(at: backup, to: target)
        logger.log("已回滚到备份版本")
    }

    func removeQuarantineIfNeeded(plan: HelperInstallPlan, logger: HelperLogger) {
        guard plan.removeQuarantine else { return }
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/xattr")
        process.arguments = ["-dr", "com.apple.quarantine", plan.targetAppURL.path]
        do {
            try process.run()
            process.waitUntilExit()
            logger.log("执行 xattr 返回码 \(process.terminationStatus)")
        } catch {
            logger.log("移除隔离属性失败: \(error.localizedDescription)")
        }
    }
}
