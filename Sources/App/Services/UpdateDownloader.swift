import Foundation
#if canImport(ZipFoundation)
import ZipFoundation
#endif

public struct DownloadedUpdate: Sendable {
    public let extractedAppURL: URL
    public let archiveURL: URL
}

public final class UpdateDownloader: NSObject, URLSessionDownloadDelegate {
    public struct Progress: Sendable {
        public let received: Int64
        public let total: Int64
    }

    public var onProgress: ((Progress) -> Void)?

    private lazy var session: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.allowsExpensiveNetworkAccess = true
        configuration.allowsConstrainedNetworkAccess = true
        configuration.timeoutIntervalForRequest = 60
        return URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    }()

    private let logger: UpdaterLogger

    public init(logger: UpdaterLogger = .shared) {
        self.logger = logger
    }

    public func download(asset: GHAsset, sha256: String) async throws -> DownloadedUpdate {
        await logger.log("开始下载更新: \(asset.name) 大小 \(asset.size)")
        let (tempURL, response) = try await session.download(from: asset.browserDownloadURL)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            await logger.log("下载失败 status=\((response as? HTTPURLResponse)?.statusCode ?? -1)", level: .error)
            throw GHError.network(status: (response as? HTTPURLResponse)?.statusCode ?? -1)
        }

        let temporaryDirectory = FileManager.default.temporaryDirectory
        let archiveURL = temporaryDirectory.appendingPathComponent(asset.name)
        try? FileManager.default.removeItem(at: archiveURL)
        try FileManager.default.moveItem(at: tempURL, to: archiveURL)
        let digest = try Checksum.sha256(for: archiveURL)
        guard digest.lowercased() == sha256.lowercased() else {
            await logger.log("SHA256 校验失败 expected=\(sha256) actual=\(digest)", level: .error)
            try? FileManager.default.removeItem(at: archiveURL)
            throw UpdateDownloadError.checksumMismatch
        }
        await logger.log("SHA256 校验通过")

        let extractionURL = temporaryDirectory.appendingPathComponent("GKHNew", isDirectory: true)
        try? FileManager.default.removeItem(at: extractionURL)
        try FileManager.default.createDirectory(at: extractionURL, withIntermediateDirectories: true)
        try await unzip(archive: archiveURL, to: extractionURL)

        let appURL = extractionURL.appendingPathComponent("GatekeeperHelper.app")
        guard FileManager.default.fileExists(atPath: appURL.path) else {
            await logger.log("解压后未找到 GatekeeperHelper.app", level: .error)
            throw UpdateDownloadError.missingAppBundle
        }

        await logger.log("下载并解压完成，路径: \(appURL.path)")
        return DownloadedUpdate(extractedAppURL: appURL, archiveURL: archiveURL)
    }

    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        let progress = Progress(received: totalBytesWritten, total: totalBytesExpectedToWrite)
        DispatchQueue.main.async { [weak self] in
            self?.onProgress?(progress)
        }
    }

    private func unzip(archive: URL, to destination: URL) async throws {
        if try await unzipWithZipFoundation(archive: archive, to: destination) {
            return
        }
        try await unzipWithCLI(archive: archive, to: destination)
    }

    private func unzipWithZipFoundation(archive: URL, to destination: URL) async throws -> Bool {
        #if canImport(ZipFoundation)
        guard let zipArchive = Archive(url: archive, accessMode: .read) else {
            return false
        }
        for entry in zipArchive {
            let destinationURL = destination.appendingPathComponent(entry.path)
            let directoryURL = destinationURL.deletingLastPathComponent()
            try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true)
            _ = try zipArchive.extract(entry, to: destinationURL)
        }
        return true
        #else
        return false
        #endif
    }

    private func unzipWithCLI(archive: URL, to destination: URL) async throws {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/unzip")
        process.arguments = [archive.path, "-d", destination.path]
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe
        try process.run()
        process.waitUntilExit()
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        if process.terminationStatus != 0 {
            let message = String(data: data, encoding: .utf8) ?? "unknown"
            await logger.log("unzip 失败: \(message)", level: .error)
            throw UpdateDownloadError.unzipFailed(message: message)
        }
    }
}

public enum UpdateDownloadError: Error, LocalizedError {
    case checksumMismatch
    case missingAppBundle
    case unzipFailed(message: String)

    public var errorDescription: String? {
        switch self {
        case .checksumMismatch:
            return "下载文件的 SHA-256 校验失败，可能被篡改。"
        case .missingAppBundle:
            return "解压后的文件缺少 GatekeeperHelper.app。"
        case .unzipFailed(let message):
            return "解压失败：\(message)"
        }
    }
}
