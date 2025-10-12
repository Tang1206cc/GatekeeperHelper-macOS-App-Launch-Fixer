import Foundation

public struct UpdateInfo: Sendable {
    public let current: String
    public let latest: String
    public let asset: GHAsset
    public let sha256: String
    public let notes: String?
    public let publishedAt: Date?
}

public enum UpdateCheckerError: Error, LocalizedError {
    case alreadyLatest

    public var errorDescription: String? {
        switch self {
        case .alreadyLatest:
            return "当前已是最新版本。"
        }
    }
}

public final actor UpdateChecker {
    private let api: GitHubAPI
    private let preferences: UpdatePreferences
    private let logger: UpdaterLogger
    private let bundle: Bundle

    public init(api: GitHubAPI, preferences: UpdatePreferences = UpdatePreferences(), logger: UpdaterLogger = .shared, bundle: Bundle = .main) {
        self.api = api
        self.preferences = preferences
        self.logger = logger
        self.bundle = bundle
    }

    public func check(includePrereleases: Bool) async throws -> UpdateInfo {
        await logger.log("开始检查更新 (includePrereleases=\(includePrereleases))")
        let release = try await api.latestRelease(includePrereleases: includePrereleases)
        guard let versionAsset = release.assets.first(where: { $0.name.lowercased().hasSuffix(".zip") }) else {
            await logger.log("最新 Release 缺少 zip 资产", level: .error)
            throw GHError.noAsset
        }

        let checksums = try await api.fetchChecksums(from: release)
        guard let sha256 = checksums[versionAsset.name] ?? checksums.values.first else {
            await logger.log("未找到 \(versionAsset.name) 对应的 SHA256", level: .error)
            throw GHError.checksumMissing
        }

        let localVersion = bundle.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "0.0.0"
        let remoteVersion = release.tagName
        await logger.log("当前版本 \(localVersion)，远端版本 \(remoteVersion)")
        preferences.lastCheckedAt = Date()
        preferences.latestKnownVersion = remoteVersion

        guard Versioning.isNewer(remote: remoteVersion, than: localVersion) else {
            throw UpdateCheckerError.alreadyLatest
        }

        return UpdateInfo(
            current: localVersion,
            latest: remoteVersion,
            asset: versionAsset,
            sha256: sha256,
            notes: release.body,
            publishedAt: release.publishedAt
        )
    }
}
