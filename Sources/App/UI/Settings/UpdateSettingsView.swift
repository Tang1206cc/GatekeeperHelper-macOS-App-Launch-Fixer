import SwiftUI
import AppKit

struct UpdateSettingsView: View {
    @StateObject private var coordinator = UpdateSettingsView.makeCoordinator()
    @State private var showingUpdateSheet = false
    @State private var copiedLogs = false

    private let issueURL = URL(string: "https://github.com/Tang1206cc/GatekeeperHelper/issues/new/choose")!
    private let releasesURL = URL(string: "https://github.com/Tang1206cc/GatekeeperHelper/releases")!

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "更新")

            Toggle("自动检查更新", isOn: Binding(
                get: { coordinator.autoUpdateEnabled },
                set: { coordinator.autoUpdateEnabled = $0 }
            ))

            HStack(spacing: 16) {
                Text("检查频率")
                Picker("检查频率", selection: Binding(
                    get: { coordinator.autoUpdateIntervalHours },
                    set: { coordinator.autoUpdateIntervalHours = $0 }
                )) {
                    Text("仅在启动时").tag(0)
                    Text("每 6 小时").tag(6)
                    Text("每 12 小时").tag(12)
                    Text("每日").tag(24)
                }
                .pickerStyle(.segmented)
                .frame(maxWidth: 320)
            }
            .opacity(coordinator.autoUpdateEnabled ? 1 : 0.5)
            .disabled(!coordinator.autoUpdateEnabled)

            Toggle("包含 Beta 版本", isOn: Binding(
                get: { coordinator.includePrereleases },
                set: { coordinator.includePrereleases = $0 }
            ))

            Toggle("有新版本时自动下载", isOn: Binding(
                get: { coordinator.autoDownloadWhenAvailable },
                set: { coordinator.autoDownloadWhenAvailable = $0 }
            ))

            Toggle("允许更新器在安装后移除 Gatekeeper 隔离属性", isOn: Binding(
                get: { coordinator.allowRemoveQuarantine },
                set: { coordinator.allowRemoveQuarantine = $0 }
            ))
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
                    Text(coordinator.currentVersion)
                        .fontWeight(.semibold)
                }
                HStack {
                    Text("最新版本：")
                        .font(.callout)
                        .foregroundColor(.secondary)
                    Text(coordinator.latestKnownVersion ?? "-")
                        .fontWeight(.semibold)
                    if let lastChecked = coordinator.lastCheckedAt {
                        Text("（上次检查：\(formatted(date: lastChecked))）")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }

            HStack(spacing: 12) {
                Button("检查更新…") {
                    showingUpdateSheet = true
                    Task { await coordinator.checkForUpdates(manual: true) }
                }
                Button("查看更新日志…") {
                    NSWorkspace.shared.open(releasesURL)
                }
                Button("打开日志文件夹") {
                    let url = try? FileManager.default.url(for: .libraryDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                        .appendingPathComponent("Logs/GatekeeperHelper", isDirectory: true)
                    if let url { NSWorkspace.shared.open(url) }
                }
                Button("复制最近日志") {
                    Task {
                        let logs = await UpdaterLogger.shared.recentLines()
                        NSPasteboard.general.clearContents()
                        NSPasteboard.general.setString(logs, forType: .string)
                        copiedLogs = true
                    }
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
        .sheet(isPresented: $showingUpdateSheet) {
            UpdateCheckView(coordinator: coordinator, isPresented: $showingUpdateSheet)
                .frame(minWidth: 420, minHeight: 320)
        }
        .onAppear {
            Task { await coordinator.checkForUpdates(manual: false) }
        }
    }

    private func formatted(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    private static func makeCoordinator() -> UpdateCoordinator {
        let prefs = UpdatePreferences()
        let logger = UpdaterLogger.shared
        let api = GitHubAPIClient(owner: "Tang1206cc", repo: "GatekeeperHelper")
        let checker = UpdateChecker(api: api, preferences: prefs, logger: logger)
        let downloader = UpdateDownloader(logger: logger)
        let installer = UpdateInstaller(logger: logger)
        return UpdateCoordinator(checker: checker, downloader: downloader, installer: installer, preferences: prefs, logger: logger)
    }
}

private struct SectionHeader: View {
    let title: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.title3)
                .bold()
            Divider()
        }
    }
}
