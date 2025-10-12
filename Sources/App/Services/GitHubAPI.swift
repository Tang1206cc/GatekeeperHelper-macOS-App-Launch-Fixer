import Foundation

public struct GHAsset: Decodable, Sendable {
    public let name: String
    public let browserDownloadURL: URL
    public let size: Int

    enum CodingKeys: String, CodingKey {
        case name
        case browserDownloadURL = "browser_download_url"
        case size
    }
}

public struct GHRelease: Decodable, Sendable {
    public let tagName: String
    public let prerelease: Bool
    public let assets: [GHAsset]
    public let body: String?
    public let publishedAt: Date?

    enum CodingKeys: String, CodingKey {
        case tagName = "tag_name"
        case prerelease
        case assets
        case body
        case publishedAt = "published_at"
    }
}

public enum GHError: Error, LocalizedError {
    case rateLimited
    case network(status: Int)
    case parse
    case noAsset
    case checksumMissing

    public var errorDescription: String? {
        switch self {
        case .rateLimited:
            return "GitHub API 请求已达未认证配额，请稍后再试或提供 Token。"
        case .network(let status):
            return "GitHub API 请求失败，状态码 \(status)。"
        case .parse:
            return "无法解析 GitHub Release 数据。"
        case .noAsset:
            return "最新 Release 中缺少可用的更新资产。"
        case .checksumMissing:
            return "未找到用于校验的 SHA-256 值。"
        }
    }
}

public protocol GitHubAPI: Sendable {
    func latestRelease(includePrereleases: Bool) async throws -> GHRelease
    func fetchChecksums(from release: GHRelease) async throws -> [String: String]
}

public actor GitHubAPIClient: GitHubAPI {
    public enum Source {
        case stable
        case all
    }

    private let owner: String
    private let repo: String
    private let tokenProvider: () -> String?
    private let session: URLSession

    public init(owner: String, repo: String, tokenProvider: @escaping () -> String? = { nil }) {
        self.owner = owner
        self.repo = repo
        self.tokenProvider = tokenProvider
        let configuration = URLSessionConfiguration.default
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 60
        self.session = URLSession(configuration: configuration)
    }

    public func latestRelease(includePrereleases: Bool) async throws -> GHRelease {
        let url = includePrereleases
            ? URL(string: "https://api.github.com/repos/\(owner)/\(repo)/releases")!
            : URL(string: "https://api.github.com/repos/\(owner)/\(repo)/releases/latest")!
        var request = URLRequest(url: url)
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        request.setValue("GatekeeperHelper-Updater", forHTTPHeaderField: "User-Agent")
        if let token = tokenProvider() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse else {
            throw GHError.network(status: -1)
        }
        guard http.statusCode == 200 else {
            if http.statusCode == 403 { throw GHError.rateLimited }
            throw GHError.network(status: http.statusCode)
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        if includePrereleases {
            let releases = try decoder.decode([GHRelease].self, from: data)
            if let stable = releases.first(where: { !$0.prerelease }) {
                return stable
            }
            if let first = releases.first {
                return first
            }
            throw GHError.parse
        } else {
            return try decoder.decode(GHRelease.self, from: data)
        }
    }

    public func fetchChecksums(from release: GHRelease) async throws -> [String: String] {
        if let checksumAsset = release.assets.first(where: { $0.name.lowercased() == "checksums.txt" }) {
            let (data, response) = try await session.data(from: checksumAsset.browserDownloadURL)
            guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
                throw GHError.network(status: (response as? HTTPURLResponse)?.statusCode ?? -1)
            }
            return parseChecksums(from: data)
        }

        if let body = release.body {
            if let range = body.range(of: #"(?i)sha256[:\s]+([a-f0-9]{64})"#, options: .regularExpression) {
                let substring = body[range]
                let hash = substring.split(whereSeparator: { $0.isWhitespace || $0 == ":" }).last
                if let hash, hash.count == 64 {
                    return ["GatekeeperHelper": String(hash)]
                }
            }
        }

        throw GHError.checksumMissing
    }

    private func parseChecksums(from data: Data) -> [String: String] {
        guard let string = String(data: data, encoding: .utf8) else { return [:] }
        var mapping: [String: String] = [:]
        string.enumerateLines { line, _ in
            let parts = line.split(whereSeparator: { $0.isWhitespace })
            if parts.count >= 3 {
                let hash = String(parts[1])
                let name = String(parts[2])
                mapping[name] = hash
            }
        }
        return mapping
    }
}
