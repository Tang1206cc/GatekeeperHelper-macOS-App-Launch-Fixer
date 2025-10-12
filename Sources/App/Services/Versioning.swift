import Foundation

public struct Semver: Comparable, Codable {
    public let major: Int
    public let minor: Int
    public let patch: Int

    public init(_ versionString: String) {
        let trimmed = versionString
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .trimmingCharacters(in: CharacterSet(charactersIn: "vV"))
        let components = trimmed.split(separator: ".").map { Int($0) ?? 0 }
        major = components.indices.contains(0) ? components[0] : 0
        minor = components.indices.contains(1) ? components[1] : 0
        patch = components.indices.contains(2) ? components[2] : 0
    }

    public init(major: Int, minor: Int, patch: Int) {
        self.major = major
        self.minor = minor
        self.patch = patch
    }

    public static func < (lhs: Semver, rhs: Semver) -> Bool {
        if lhs.major != rhs.major { return lhs.major < rhs.major }
        if lhs.minor != rhs.minor { return lhs.minor < rhs.minor }
        return lhs.patch < rhs.patch
    }

    public var stringValue: String {
        "\(major).\(minor).\(patch)"
    }
}

public enum Versioning {
    public static func isNewer(remote: String, than local: String) -> Bool {
        Semver(remote) > Semver(local)
    }
}
