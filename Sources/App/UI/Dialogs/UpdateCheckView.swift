import SwiftUI

struct UpdateCheckView: View {
    @ObservedObject var coordinator: UpdateCoordinator
    @Binding var isPresented: Bool

    @State private var isDownloading = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("检查更新")
                .font(.title2)
                .bold()

            Divider()

            content
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 8)

            HStack {
                Button("关闭") { isPresented = false }
                Spacer()
                if case .updateAvailable(let info) = coordinator.status {
                    Button("下载并更新") {
                        Task { await coordinator.startDownload(for: info) }
                    }
                } else if case .downloaded = coordinator.status {
                    Button("安装并重启") {
                        Task { await coordinator.installUpdate() }
                    }
                }
            }
        }
        .padding(24)
        .frame(minWidth: 440, minHeight: 320)
    }

    @ViewBuilder
    private var content: some View {
        switch coordinator.status {
        case .idle:
            Text("准备就绪，点击“检查更新”开始。")
                .foregroundColor(.secondary)
        case .checking:
            HStack(spacing: 12) {
                ProgressView()
                Text("正在联系 GitHub Releases…")
            }
        case .upToDate:
            Label("当前版本已是最新。", systemImage: "checkmark.seal")
                .foregroundColor(.green)
        case .updateAvailable(let info):
            VStack(alignment: .leading, spacing: 8) {
                Label("发现新版本 \(info.latest)", systemImage: "arrow.down.circle")
                    .font(.headline)
                if let publishedAt = info.publishedAt {
                    Text("发布时间：\(formatted(date: publishedAt))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                if let notes = info.notes, !notes.isEmpty {
                    Text("更新摘要：")
                        .font(.subheadline)
                        .bold()
                    ScrollView {
                        Text(notes)
                            .font(.callout)
                            .textSelection(.enabled)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .frame(maxHeight: 160)
                    .background(.regularMaterial)
                    .cornerRadius(8)
                }
            }
        case .downloading(let progress):
            VStack(alignment: .leading, spacing: 12) {
                Text("正在下载更新…")
                ProgressView(value: progress)
                Text(String(format: "%.0f%%", progress * 100))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        case .downloaded:
            Label("下载完成，准备安装。", systemImage: "tray.and.arrow.down.fill")
        case .installing:
            HStack(spacing: 12) {
                ProgressView()
                Text("正在安装并重启，请稍候…")
            }
        case .error(let message):
            VStack(alignment: .leading, spacing: 8) {
                Label("更新失败", systemImage: "exclamationmark.triangle")
                    .foregroundColor(.orange)
                    .font(.headline)
                Text(message)
                    .font(.callout)
                Button("复制日志") {
                    Task {
                        let logs = await UpdaterLogger.shared.recentLines()
                        NSPasteboard.general.clearContents()
                        NSPasteboard.general.setString(logs, forType: .string)
                    }
                }
                Button("提交 Issue") {
                    if let url = URL(string: "https://github.com/Tang1206cc/GatekeeperHelper/issues/new/choose") {
                        NSWorkspace.shared.open(url)
                    }
                }
            }
        }
    }

    private func formatted(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
