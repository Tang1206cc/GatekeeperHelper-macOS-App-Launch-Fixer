import Foundation

struct GitHubAsset: Decodable {
    let name: String
    let browser_download_url: URL
}

struct GitHubRelease: Decodable {
    let tag_name: String
    let draft: Bool
    let prerelease: Bool
    let assets: [GitHubAsset]
}

enum GitHubAPI {
    private static let owner = "Tang1206cc"
    private static let repo = "GatekeeperHelper"

    static func fetchLatestRelease(
        usePrerelease: Bool = false,
        token: String? = ProcessInfo.processInfo.environment["GITHUB_TOKEN"]
    ) async throws -> GitHubRelease {
        let url = URL(string: "https://api.github.com/repos/\(owner)/\(repo)/releases/latest")!
        var request = URLRequest(url: url)
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        if let token { request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization") }

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, (200..<300).contains(httpResponse.statusCode) else {
            throw NSError(domain: "GitHub", code: 1, userInfo: [NSLocalizedDescriptionKey: "GitHub API 返回异常"])
        }
        return try JSONDecoder().decode(GitHubRelease.self, from: data)
    }
}
