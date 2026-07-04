import Foundation
import AppKit

// 简单日志到文件
func log(_ s: String, to file: String) {
    let line = "[\(ISO8601DateFormatter().string(from: Date()))] \(s)\n"
    if let data = line.data(using: .utf8) {
        if FileManager.default.fileExists(atPath: file) {
            if let handle = try? FileHandle(forWritingTo: URL(fileURLWithPath: file)) {
                handle.seekToEndOfFile()
                try? handle.write(contentsOf: data)
                try? handle.close()
            }
        } else {
            try? data.write(to: URL(fileURLWithPath: file))
        }
    }
}

func waitUntilAppQuit(bundleID: String, timeout: TimeInterval = 60) {
    let end = Date().addingTimeInterval(timeout)
    while Date() < end {
        let apps = NSRunningApplication.runningApplications(withBundleIdentifier: bundleID)
        if apps.isEmpty { return }
        Thread.sleep(forTimeInterval: 0.5)
    }
}

func readPlan() throws -> InstallPlan {
    let args = CommandLine.arguments
    guard let idx = args.firstIndex(of: "--plan"), idx+1 < args.count else {
        throw HelperError.invalidPlan
    }
    let url = URL(fileURLWithPath: args[idx+1])
    let data = try Data(contentsOf: url)
    return try JSONDecoder().decode(InstallPlan.self, from: data)
}

var currentLogFile: String?

do {
    let plan = try readPlan()
    currentLogFile = plan.logFile
    log("Helper started.", to: plan.logFile)
    log("Plan new app: \(plan.newAppPath)", to: plan.logFile)
    log("Plan target app: \(plan.targetAppPath)", to: plan.logFile)

    // 等待主程序退出
    if !plan.relaunchBundleID.isEmpty {
        log("Waiting for app to quit: \(plan.relaunchBundleID)", to: plan.logFile)
        waitUntilAppQuit(bundleID: plan.relaunchBundleID, timeout: 60)
    }

    // 备份旧版
    if let backupPath = try backupExistingApp(targetPath: plan.targetAppPath, backupDir: plan.backupDir) {
        log("Backed up existing app to: \(backupPath)", to: plan.logFile)
    } else {
        log("No existing app found at target path.", to: plan.logFile)
    }

    // 覆盖替换
    log("Moving new app into target path.", to: plan.logFile)
    try moveItem(from: plan.newAppPath, to: plan.targetAppPath)
    log("Move finished.", to: plan.logFile)

    // 可选：去隔离
    if plan.removeQuarantine {
        log("Removing quarantine attribute", to: plan.logFile)
        removeQuarantineIfNeeded(plan.targetAppPath)
    }

    // 重启主应用
    if !plan.relaunchBundleID.isEmpty {
        log("Relaunching app.", to: plan.logFile)
        relaunch(appPath: plan.targetAppPath, bundleID: plan.relaunchBundleID)
    }

    log("Helper finished successfully.", to: plan.logFile)
    exit(0)
} catch {
    // 简单失败日志
    let msg = "Helper failed: \(error)"
    if let currentLogFile {
        log(msg, to: currentLogFile)
    }
    fputs(msg + "\n", stderr)
    exit(1)
}
