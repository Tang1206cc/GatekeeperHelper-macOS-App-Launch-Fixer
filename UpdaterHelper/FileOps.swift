import Foundation

@discardableResult
func shell(_ launchPath: String, _ args: [String]) -> Int32 {
    let task = Process()
    task.executableURL = URL(fileURLWithPath: launchPath)
    task.arguments = args
    try? task.run()
    task.waitUntilExit()
    return task.terminationStatus
}

func ensureDir(_ path: String) throws {
    try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true)
}

func removeItemIfExists(_ path: String) throws {
    if FileManager.default.fileExists(atPath: path) {
        try FileManager.default.removeItem(atPath: path)
    }
}

func copyItem(from: String, to: String) throws {
    try removeItemIfExists(to)
    try FileManager.default.copyItem(atPath: from, toPath: to)
}

func moveItem(from: String, to: String) throws {
    try removeItemIfExists(to)
    try FileManager.default.moveItem(atPath: from, toPath: to)
}

func backupExistingApp(targetPath: String, backupDir: String) throws -> String? {
    guard FileManager.default.fileExists(atPath: targetPath) else { return nil }
    try ensureDir(backupDir)
    let ts = Int(Date().timeIntervalSince1970)
    let backupPath = (backupDir as NSString).appendingPathComponent("GatekeeperHelper-\(ts).app")
    try copyItem(from: targetPath, to: backupPath)
    return backupPath
}

func removeQuarantineIfNeeded(_ path: String) {
    _ = shell("/usr/bin/xattr", ["-d", "com.apple.quarantine", path])
}
