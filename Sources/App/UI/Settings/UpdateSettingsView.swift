import SwiftUI

struct UpdateSettingsView: View {
    @StateObject private var coordinator = UpdateSettingsView.makeCoordinator()
    @State private var showingUpdateSheet = false

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("软件更新")
                .font(.title2)
                .bold()

            Divider()

            Toggle("自动检查并下载更新", isOn: Binding(
                get: { coordinator.autoUpdateEnabled && coordinator.autoDownloadWhenAvailable },
                set: { newValue in
                    coordinator.autoUpdateEnabled = newValue
                    coordinator.autoDownloadWhenAvailable = newValue
                    if newValue { coordinator.autoUpdateIntervalHours = 24 }
                }
            ))

            Toggle("获取 Beta 更新", isOn: Binding(
                get: { coordinator.includePrereleases },
                set: { coordinator.includePrereleases = $0 }
            ))

            Toggle("允许更新器在安装后自动移除新版本软件的 Gatekeeper 隔离属性", isOn: Binding(
                get: { coordinator.allowRemoveQuarantine },
                set: { coordinator.allowRemoveQuarantine = $0 }
            ))
            .help("建议保持勾选，使后续更新后的首次启动更顺畅。此操作仅针对 GatekeeperHelper.app 生效。")

            HStack {
                Text("当前版本：")
                    .font(.callout)
                    .foregroundColor(.secondary)
                Text(coordinator.currentVersion)
                    .fontWeight(.semibold)
            }

            HStack {
                Spacer()
                Button("检查更新") {
                    showingUpdateSheet = true
                    Task { await coordinator.checkForUpdates(manual: true) }
                }
                .buttonStyle(.borderedProminent)
                Spacer()
            }

            if let lastChecked = coordinator.lastCheckedAt {
                Text("（上次检查：\(formatted(date: lastChecked))）")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
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
        return UpdateCoordinator(
            checker: checker,
            downloader: downloader,
            installer: installer,
            preferences: prefs,
            logger: logger
        )
    }
}
