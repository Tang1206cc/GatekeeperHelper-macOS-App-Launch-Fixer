import AppKit
import Foundation

final class UpdateManager {
    static let shared = UpdateManager()

    private struct LatestInfo {
        let latestVersion: Version
        let assetURL: URL
    }

    private var downloadController: DownloadWindowController?

    private init() {}

    func checkForUpdate(interactive: Bool = true) {
        Task { @MainActor [weak self] in
            guard let self else { return }
            do {
                let localVersion = Bundle.main.shortVersion ?? Version("0.0.0")!
                let release = try await GitHubAPI.fetchLatestRelease()
                guard let latestVersion = Version(release.tag_name) else {
                    throw NSError(domain: "Update", code: 0, userInfo: [NSLocalizedDescriptionKey: "无法解析远端版本"])
                }

                if localVersion >= latestVersion {
                    if interactive {
                        showAlert(title: "提示", message: "当前已是最新版本！", buttonTitles: ["好"])
                    }
                    return
                }

                guard let zipAsset = release.assets.first(where: { $0.name.hasSuffix(".zip") }) else {
                    throw NSError(domain: "Update", code: 0, userInfo: [NSLocalizedDescriptionKey: "未找到可下载资产（.zip）"])
                }

                let response = showUpdateAlert(
                    localVersion: localVersion,
                    latestVersion: latestVersion,
                    releaseBody: release.body
                )

                if response == .alertFirstButtonReturn {
                    let info = LatestInfo(latestVersion: latestVersion, assetURL: zipAsset.browser_download_url)
                    beginDownloadAndInstall(with: info)
                }
            } catch {
                if interactive {
                    showAlert(title: "检查失败", message: error.localizedDescription, buttonTitles: ["好"])
                }
            }
        }
    }

    @discardableResult
    private func showAlert(title: String, message: String, buttonTitles: [String]) -> NSApplication.ModalResponse {
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = message
        alert.alertStyle = .informational
        buttonTitles.forEach { alert.addButton(withTitle: $0) }
        return alert.runModalWithSystemStyle()
    }

    @discardableResult
    private func showUpdateAlert(localVersion: Version, latestVersion: Version, releaseBody: String?) -> NSApplication.ModalResponse {
        let appName = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
            ?? Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String
            ?? "GatekeeperHelper"

        let alert = NSAlert()
        alert.messageText = "\(appName) 有新版本可用"
        alert.informativeText = "版本：v\(localVersion.description) - v\(latestVersion.description)\n可立即下载并安装更新。"
        alert.alertStyle = .informational
        alert.icon = NSApp.applicationIconImage
        alert.accessoryView = makeReleaseNotesView(releaseBody)
        alert.addButton(withTitle: "立即更新")
        alert.addButton(withTitle: "下次再说")
        return alert.runModalWithSystemStyle()
    }

    private func makeReleaseNotesView(_ releaseBody: String?) -> NSView {
        let trimmedBody = (releaseBody ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let notesText = trimmedBody.isEmpty ? "此版本暂无推版描述。" : trimmedBody

        let container = NSView(frame: NSRect(x: 0, y: 0, width: 430, height: 190))

        let titleField = NSTextField(labelWithString: "GitHub 推版描述")
        titleField.font = .boldSystemFont(ofSize: 13)
        titleField.frame = NSRect(x: 0, y: 166, width: 430, height: 18)

        let scrollView = NSScrollView(frame: NSRect(x: 0, y: 0, width: 430, height: 156))
        scrollView.borderType = .bezelBorder
        scrollView.hasVerticalScroller = true
        scrollView.autohidesScrollers = true

        let textView = NSTextView(frame: NSRect(x: 0, y: 0, width: scrollView.contentSize.width, height: 156))
        textView.string = notesText
        textView.isEditable = false
        textView.isSelectable = true
        textView.drawsBackground = false
        textView.font = .systemFont(ofSize: 12)
        textView.textColor = .labelColor
        textView.textContainerInset = NSSize(width: 8, height: 8)
        textView.isHorizontallyResizable = false
        textView.isVerticallyResizable = true
        textView.autoresizingMask = [.width]
        textView.textContainer?.widthTracksTextView = true
        textView.textContainer?.containerSize = NSSize(
            width: scrollView.contentSize.width,
            height: CGFloat.greatestFiniteMagnitude
        )

        scrollView.documentView = textView
        container.addSubview(titleField)
        container.addSubview(scrollView)
        return container
    }

    private func beginDownloadAndInstall(with info: LatestInfo) {
        let controller = DownloadWindowController()
        downloadController = controller
        controller.startDownload(from: info.assetURL) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let zipURL):
                self.downloadController = nil
                self.install(from: zipURL, info: info)
            case .failure(let error):
                self.downloadController = nil
                self.showAlert(title: "下载失败", message: error.localizedDescription, buttonTitles: ["好"])
            }
        }
    }

    private func install(from zipURL: URL, info: LatestInfo) {
        do {
            let tempDirectory = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
                .appendingPathComponent("Update-\(info.latestVersion.description)", isDirectory: true)
            try FileManager.default.createDirectory(at: tempDirectory, withIntermediateDirectories: true)

            try Installer.unzip(zipURL, to: tempDirectory)
            try FileManager.default.removeItem(at: zipURL)

            guard let appURL = locateApp(in: tempDirectory) else {
                throw NSError(domain: "Update", code: 0, userInfo: [NSLocalizedDescriptionKey: "未在压缩包中找到 .app"])
            }

            try Installer.installAndRelaunch(newAppURL: appURL)
        } catch {
            showAlert(title: "安装失败", message: error.localizedDescription, buttonTitles: ["好"])
        }
    }

    private func locateApp(in directory: URL) -> URL? {
        if directory.pathExtension == "app" { return directory }
        guard let contents = try? FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles]) else {
            return nil
        }
        for item in contents {
            if item.pathExtension == "app" {
                return item
            }
            if let found = locateApp(in: item) {
                return found
            }
        }
        return nil
    }
}
