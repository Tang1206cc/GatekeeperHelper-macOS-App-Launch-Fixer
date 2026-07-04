import Foundation

struct GitHubAsset: Decodable {
    let name: String
    let browser_download_url: URL
}

struct GitHubRelease: Decodable {
    let tag_name: String
    let draft: Bool
    let prerelease: Bool
    let body: String?
    let assets: [GitHubAsset]
}

enum GitHubAPI {
    private static let owner = "Tang1206cc"
    private static let repo = "GatekeeperHelper-macOS-App-Launch-Fixer"

    static func fetchLatestRelease(
        usePrerelease: Bool = false,
        token: String? = ProcessInfo.processInfo.environment["GITHUB_TOKEN"]
    ) async throws -> GitHubRelease {
        do {
            return try await fetchLatestReleaseFromAPI(token: token)
        } catch {
            return try await fetchLatestReleaseFromAtomFeed()
        }
    }

    private static func fetchLatestReleaseFromAPI(token: String?) async throws -> GitHubRelease {
        let url = URL(string: "https://api.github.com/repos/\(owner)/\(repo)/releases/latest")!
        var request = URLRequest(url: url)
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        request.setValue("2022-11-28", forHTTPHeaderField: "X-GitHub-Api-Version")
        request.setValue("GatekeeperHelper", forHTTPHeaderField: "User-Agent")
        if let token, !token.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, (200..<300).contains(httpResponse.statusCode) else {
            throw NSError(domain: "GitHub", code: 1, userInfo: [NSLocalizedDescriptionKey: "GitHub API 返回异常"])
        }
        return try JSONDecoder().decode(GitHubRelease.self, from: data)
    }

    private static func fetchLatestReleaseFromAtomFeed() async throws -> GitHubRelease {
        let url = URL(string: "https://github.com/\(owner)/\(repo)/releases.atom")!
        var request = URLRequest(url: url)
        request.setValue("GatekeeperHelper", forHTTPHeaderField: "User-Agent")

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, (200..<300).contains(httpResponse.statusCode) else {
            throw NSError(domain: "GitHub", code: 2, userInfo: [NSLocalizedDescriptionKey: "无法获取 GitHub Releases 信息"])
        }

        let parser = LatestReleaseFeedParser(data: data)
        guard let entry = parser.parse(), let latestVersion = Version(entry.tagName) else {
            throw NSError(domain: "GitHub", code: 3, userInfo: [NSLocalizedDescriptionKey: "无法解析 GitHub Releases 信息"])
        }

        let assetName = "GatekeeperHelper-\(latestVersion.description).zip"
        let assetURL = URL(string: "https://github.com/\(owner)/\(repo)/releases/download/\(entry.tagName)/\(assetName)")!
        guard try await releaseAssetExists(at: assetURL) else {
            throw NSError(domain: "GitHub", code: 4, userInfo: [NSLocalizedDescriptionKey: "未找到可下载资产（.zip）"])
        }

        return GitHubRelease(
            tag_name: entry.tagName,
            draft: false,
            prerelease: false,
            body: entry.releaseNotes,
            assets: [GitHubAsset(name: assetName, browser_download_url: assetURL)]
        )
    }

    private static func releaseAssetExists(at url: URL) async throws -> Bool {
        var request = URLRequest(url: url)
        request.httpMethod = "HEAD"
        request.setValue("GatekeeperHelper", forHTTPHeaderField: "User-Agent")

        let (_, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else { return false }
        return (200..<300).contains(httpResponse.statusCode)
    }
}

private final class LatestReleaseFeedParser: NSObject, XMLParserDelegate {
    private struct Entry {
        var tagName: String
        var releaseNotes: String?
    }

    private let parser: XMLParser
    private var isReadingLatestEntry = false
    private var didReadLatestEntry = false
    private var currentElement = ""
    private var latestLink = ""
    private var latestID = ""
    private var latestContent = ""

    init(data: Data) {
        parser = XMLParser(data: data)
        super.init()
        parser.delegate = self
    }

    func parse() -> (tagName: String, releaseNotes: String?)? {
        guard parser.parse() else { return nil }
        let tagName = tagName(from: latestLink) ?? tagName(from: latestID)
        guard let tagName else { return nil }

        let notes = plainText(from: latestContent)
        return (tagName: tagName, releaseNotes: notes.isEmpty || notes == "No content." ? nil : notes)
    }

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?,
                qualifiedName qName: String?, attributes attributeDict: [String: String] = [:]) {
        guard !didReadLatestEntry else { return }

        if elementName == "entry" {
            isReadingLatestEntry = true
            return
        }

        guard isReadingLatestEntry else { return }
        currentElement = elementName

        if elementName == "link", attributeDict["rel"] == "alternate", let href = attributeDict["href"] {
            latestLink = href
        }
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        guard isReadingLatestEntry else { return }

        switch currentElement {
        case "id":
            latestID += string
        case "content":
            latestContent += string
        default:
            break
        }
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        guard isReadingLatestEntry else { return }

        if elementName == currentElement {
            currentElement = ""
        }

        if elementName == "entry" {
            isReadingLatestEntry = false
            didReadLatestEntry = true
        }
    }

    private func tagName(from string: String) -> String? {
        guard let range = string.range(of: "/releases/tag/") else {
            return string.split(separator: "/").last.map(String.init)
        }

        let suffix = string[range.upperBound...]
        return suffix.split(separator: "/").first.map(String.init)
    }

    private func plainText(from html: String) -> String {
        html
            .replacingOccurrences(of: "<br>", with: "\n")
            .replacingOccurrences(of: "<br/>", with: "\n")
            .replacingOccurrences(of: "<br />", with: "\n")
            .replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
            .replacingOccurrences(of: "&nbsp;", with: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
