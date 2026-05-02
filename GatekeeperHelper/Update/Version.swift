import Foundation

struct Version: Comparable, CustomStringConvertible {
    let major: Int
    let minor: Int
    let patch: Int

    var description: String {
        "\(major).\(minor).\(patch)"
    }

    init?(_ string: String) {
        let trimmed = string
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .trimmingCharacters(in: CharacterSet(charactersIn: "vV"))
        let components = trimmed.split(separator: ".")
        guard !components.isEmpty else { return nil }

        func value(at index: Int) -> Int {
            guard components.indices.contains(index) else { return 0 }
            return Int(components[index]) ?? 0
        }

        self.major = value(at: 0)
        self.minor = value(at: 1)
        self.patch = value(at: 2)
    }

    static func < (lhs: Version, rhs: Version) -> Bool {
        if lhs.major != rhs.major { return lhs.major < rhs.major }
        if lhs.minor != rhs.minor { return lhs.minor < rhs.minor }
        return lhs.patch < rhs.patch
    }
}

extension Bundle {
    var shortVersion: Version? {
        guard let string = infoDictionary?["CFBundleShortVersionString"] as? String else { return nil }
        return Version(string)
    }
}
