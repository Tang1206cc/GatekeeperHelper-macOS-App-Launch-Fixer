import Foundation

struct HelperInstallPlan: Codable {
    let newAppPath: String
    let targetAppPath: String
    let backupDir: String
    let relaunchBundleID: String
    let logFile: String
    let removeQuarantine: Bool

    var newAppURL: URL { URL(fileURLWithPath: newAppPath) }
    var targetAppURL: URL { URL(fileURLWithPath: targetAppPath) }
    var backupDirectoryURL: URL { URL(fileURLWithPath: backupDir, isDirectory: true) }
    var logFileURL: URL { URL(fileURLWithPath: logFile) }
}
