import Foundation
import AppKit

struct Relauncher {
    func waitForTermination(bundleID: String, logger: HelperLogger) {
        guard !bundleID.isEmpty else { return }
        logger.log("等待主程序退出：\(bundleID)")
        let timeout: TimeInterval = 60
        let start = Date()
        while Date().timeIntervalSince(start) < timeout {
            let running = NSRunningApplication.runningApplications(withBundleIdentifier: bundleID)
            if running.isEmpty { break }
            RunLoop.current.run(until: Date().addingTimeInterval(0.5))
        }
    }

    func relaunch(bundleID: String, logger: HelperLogger) throws {
        guard !bundleID.isEmpty else { return }
        logger.log("尝试通过 open -b \(bundleID) 重启应用")
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/open")
        process.arguments = ["-b", bundleID]
        try process.run()
        process.waitUntilExit()
        if process.terminationStatus != 0 {
            logger.log("open 退出码 \(process.terminationStatus)")
            throw HelperError.relaunchFailed
        }
    }
}
