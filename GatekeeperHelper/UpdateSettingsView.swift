import SwiftUI
import AppKit

private enum UpdatePreferencesKey {
    static let autoUpdateEnabled = "autoUpdateEnabled"
    static let autoUpdateIntervalHours = "autoUpdateIntervalHours"
    static let includePrereleases = "includePrereleases"
    static let autoDownloadWhenAvailable = "autoDownloadWhenAvailable"
    static let allowRemoveQuarantine = "allowRemoveQuarantine"
    static let lastCheckedAt = "lastCheckedAt"
    static let latestKnownVersion = "latestKnownVersion"
}

struct UpdatePreferences {
    private let defaults: UserDefaults = .standard

    func reset() {
        defaults.removeObject(forKey: UpdatePreferencesKey.autoUpdateEnabled)
        defaults.removeObject(forKey: UpdatePreferencesKey.autoUpdateIntervalHours)
        defaults.removeObject(forKey: UpdatePreferencesKey.includePrereleases)
        defaults.removeObject(forKey: UpdatePreferencesKey.autoDownloadWhenAvailable)
        defaults.removeObject(forKey: UpdatePreferencesKey.allowRemoveQuarantine)
        defaults.removeObject(forKey: UpdatePreferencesKey.lastCheckedAt)
        defaults.removeObject(forKey: UpdatePreferencesKey.latestKnownVersion)
    }
}

struct UpdateSettingsView: View {
    @AppStorage(UpdatePreferencesKey.autoUpdateEnabled) private var autoUpdateEnabled = true
    @AppStorage(UpdatePreferencesKey.autoUpdateIntervalHours) private var autoUpdateIntervalHours = 6
    @AppStorage(UpdatePreferencesKey.includePrereleases) private var includePrereleases = false
    @AppStorage(UpdatePreferencesKey.autoDownloadWhenAvailable) private var autoDownloadWhenAvailable = false
    @AppStorage(UpdatePreferencesKey.allowRemoveQuarantine) private var allowRemoveQuarantine = true
    @State private var copiedLogs = false

    private let issueURL = URL(string: "https://github.com/Tang1206cc/GatekeeperHelper/issues/new/choose")!
    private let releasesURL = URL(string: "https://github.com/Tang1206cc/GatekeeperHelper/releases")!

    private var currentVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "-"
    }

    private var latestKnownVersion: String {
        UserDefaults.standard.string(forKey: UpdatePreferencesKey.latestKnownVersion) ?? "-"
    }

    private var lastCheckedDescription: String? {
        guard let date = UserDefaults.standard.object(forKey: UpdatePreferencesKey.lastCheckedAt) as? Date else {
            return nil
        }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text("更新")
                    .font(.title3)
                    .bold()
                Divider()
            }

            Toggle("自动检查更新", isOn: $autoUpdateEnabled)

            HStack(spacing: 16) {
                Text("检查频率")
                Picker("检查频率", selection: $autoUpdateIntervalHours) {
                    Text("仅在启动时").tag(0)
                    Text("每 6 小时").tag(6)
                    Text("每 12 小时").tag(12)
                    Text("每日").tag(24)
                }
                .pickerStyle(.segmented)
                .frame(maxWidth: 320)
            }
            .opacity(autoUpdateEnabled ? 1 : 0.5)
            .disabled(!autoUpdateEnabled)

            Toggle("包含 Beta 版本", isOn: $includePrereleases)
            Toggle("有新版本时自动下载", isOn: $autoDownloadWhenAvailable)

            Toggle("允许更新器在安装后移除 Gatekeeper 隔离属性", isOn: $allowRemoveQuarantine)
                .help("建议保持勾选，使后续更新后的首次启动更顺畅。此操作仅针对 GatekeeperHelper.app 生效。")

            Button("查看 Gatekeeper 放行指南…") {
                if let url = Bundle.main.url(forResource: "GatekeeperGuide", withExtension: "md", subdirectory: "Privacy") {
                    NSWorkspace.shared.open(url)
                }
            }
            .buttonStyle(.link)
            .font(.caption)

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("当前版本：")
                        .font(.callout)
                        .foregroundColor(.secondary)
                    Text(currentVersion)
                        .fontWeight(.semibold)
                }
                HStack {
                    Text("最新版本：")
                        .font(.callout)
                        .foregroundColor(.secondary)
                    Text(latestKnownVersion)
                        .fontWeight(.semibold)
                    if let lastCheckedDescription {
                        Text("（上次检查：\(lastCheckedDescription)）")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }

            HStack(spacing: 12) {
                Button("检查更新…") {
                    recordManualCheck()
                    NSWorkspace.shared.open(releasesURL)
                }
                Button("查看更新日志…") {
                    NSWorkspace.shared.open(releasesURL)
                }
                Button("打开日志文件夹") {
                    openLogsDirectory()
                }
                Button("复制最近日志") {
                    copyPlaceholderLogs()
                }
                Button("提交 Issue") {
                    NSWorkspace.shared.open(issueURL)
                }
            }

            if copiedLogs {
                Text("已复制最近日志，可以前往 Issue 粘贴。")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer(minLength: 0)
        }
        .padding(20)
    }

    private func recordManualCheck() {
        UserDefaults.standard.set(Date(), forKey: UpdatePreferencesKey.lastCheckedAt)
    }

    private func openLogsDirectory() {
        let url = (try? FileManager.default.url(for: .libraryDirectory, in: .userDomainMask, appropriateFor: nil, create: false))?
            .appendingPathComponent("Logs/GatekeeperHelper", isDirectory: true)
        if let url { NSWorkspace.shared.open(url) }
    }

    private func copyPlaceholderLogs() {
        copiedLogs = true
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString("Updater logs are not available in this build.", forType: .string)
    }
}
