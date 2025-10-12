import Foundation

public enum UpdatePreferencesKey {
    public static let autoUpdateEnabled = "autoUpdateEnabled"
    public static let autoUpdateIntervalHours = "autoUpdateIntervalHours"
    public static let includePrereleases = "includePrereleases"
    public static let autoDownloadWhenAvailable = "autoDownloadWhenAvailable"
    public static let allowRemoveQuarantine = "allowRemoveQuarantine"
    public static let lastCheckedAt = "lastCheckedAt"
    public static let latestKnownVersion = "latestKnownVersion"
}

public struct UpdatePreferences: Sendable {
    private let defaults: UserDefaults

    public init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    public var autoUpdateEnabled: Bool {
        get { defaults.object(forKey: UpdatePreferencesKey.autoUpdateEnabled) as? Bool ?? true }
        set { defaults.set(newValue, forKey: UpdatePreferencesKey.autoUpdateEnabled) }
    }

    public var autoUpdateIntervalHours: Int {
        get {
            let value = defaults.object(forKey: UpdatePreferencesKey.autoUpdateIntervalHours) as? Int ?? 6
            return value
        }
        set { defaults.set(newValue, forKey: UpdatePreferencesKey.autoUpdateIntervalHours) }
    }

    public var includePrereleases: Bool {
        get { defaults.object(forKey: UpdatePreferencesKey.includePrereleases) as? Bool ?? false }
        set { defaults.set(newValue, forKey: UpdatePreferencesKey.includePrereleases) }
    }

    public var autoDownloadWhenAvailable: Bool {
        get { defaults.object(forKey: UpdatePreferencesKey.autoDownloadWhenAvailable) as? Bool ?? false }
        set { defaults.set(newValue, forKey: UpdatePreferencesKey.autoDownloadWhenAvailable) }
    }

    public var allowRemoveQuarantine: Bool {
        get { defaults.object(forKey: UpdatePreferencesKey.allowRemoveQuarantine) as? Bool ?? true }
        set { defaults.set(newValue, forKey: UpdatePreferencesKey.allowRemoveQuarantine) }
    }

    public var lastCheckedAt: Date? {
        get { defaults.object(forKey: UpdatePreferencesKey.lastCheckedAt) as? Date }
        set { defaults.set(newValue, forKey: UpdatePreferencesKey.lastCheckedAt) }
    }

    public var latestKnownVersion: String? {
        get { defaults.string(forKey: UpdatePreferencesKey.latestKnownVersion) }
        set { defaults.set(newValue, forKey: UpdatePreferencesKey.latestKnownVersion) }
    }

    public func reset() {
        defaults.removeObject(forKey: UpdatePreferencesKey.autoUpdateEnabled)
        defaults.removeObject(forKey: UpdatePreferencesKey.autoUpdateIntervalHours)
        defaults.removeObject(forKey: UpdatePreferencesKey.includePrereleases)
        defaults.removeObject(forKey: UpdatePreferencesKey.autoDownloadWhenAvailable)
        defaults.removeObject(forKey: UpdatePreferencesKey.allowRemoveQuarantine)
        defaults.removeObject(forKey: UpdatePreferencesKey.lastCheckedAt)
        defaults.removeObject(forKey: UpdatePreferencesKey.latestKnownVersion)
    }
}
