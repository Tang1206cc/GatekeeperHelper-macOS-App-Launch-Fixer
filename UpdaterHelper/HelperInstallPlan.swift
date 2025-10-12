import Foundation

struct InstallPlan: Codable {
    let newAppPath: String
    let targetAppPath: String
    let backupDir: String
    let removeQuarantine: Bool
    let relaunchBundleID: String
    let logFile: String
}

enum HelperError: Error {
    case invalidPlan
    case copyFailed(String)
    case restoreFailed
}
