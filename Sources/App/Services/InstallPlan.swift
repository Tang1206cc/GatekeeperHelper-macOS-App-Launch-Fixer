import Foundation

public struct InstallPlan: Codable, Sendable {
    public let newAppPath: String
    public let targetAppPath: String
    public let backupDir: String
    public let relaunchBundleID: String
    public let logFile: String
    public let removeQuarantine: Bool
}
