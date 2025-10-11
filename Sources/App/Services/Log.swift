import Foundation

public enum UpdaterLogLevel: String {
    case info = "INFO"
    case warning = "WARN"
    case error = "ERROR"
}

public actor UpdaterLogger {
    public static let shared = UpdaterLogger()

    private let fileManager = FileManager.default
    private let logURL: URL

    private init() {
        let logsDir = fileManager.homeDirectoryForCurrentUser
            .appendingPathComponent("Library/Logs/GatekeeperHelper", isDirectory: true)
        try? fileManager.createDirectory(at: logsDir, withIntermediateDirectories: true)
        logURL = logsDir.appendingPathComponent("Updater.log")
    }

    public func log(_ message: String, level: UpdaterLogLevel = .info) {
        let timestamp = ISO8601DateFormatter().string(from: Date())
        let line = "[\(level.rawValue)] [\(timestamp)] \(message)\n"
        if let data = line.data(using: .utf8) {
            if fileManager.fileExists(atPath: logURL.path) {
                if let handle = try? FileHandle(forWritingTo: logURL) {
                    do {
                        try handle.seekToEnd()
                        try handle.write(contentsOf: data)
                    } catch {
                        print("[UpdaterLogger] Failed writing log: \(error)")
                    }
                    try? handle.close()
                }
            } else {
                try? data.write(to: logURL)
            }
        }
        #if DEBUG
        print("[Updater] \(line.trimmingCharacters(in: .whitespacesAndNewlines))")
        #endif
    }

    public func url() -> URL { logURL }

    public func recentLines(limit: Int = 200) -> String {
        guard let data = try? Data(contentsOf: logURL), let text = String(data: data, encoding: .utf8) else {
            return ""
        }
        let lines = text.split(whereSeparator: { $0.isNewline })
        return lines.suffix(limit).joined(separator: "\n")
    }
}
