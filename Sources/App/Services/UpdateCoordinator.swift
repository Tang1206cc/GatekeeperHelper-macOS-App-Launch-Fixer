import Foundation
import Combine
import AppKit

@MainActor
public final class UpdateCoordinator: ObservableObject {
    public enum Status {
        case idle
        case checking
        case upToDate
        case updateAvailable(UpdateInfo)
        case downloading(Double)
        case downloaded
        case installing
        case error(String)
    }

    @Published public private(set) var status: Status = .idle
    @Published public private(set) var lastErrorMessage: String?
    @Published public private(set) var lastCheckedAt: Date?
    @Published public private(set) var latestKnownVersion: String?
    @Published public private(set) var currentVersion: String

    public var autoUpdateEnabled: Bool {
        get { preferences.autoUpdateEnabled }
        set {
            preferences.autoUpdateEnabled = newValue
            configureTimer()
        }
    }

    public var autoUpdateIntervalHours: Int {
        get { preferences.autoUpdateIntervalHours }
        set {
            preferences.autoUpdateIntervalHours = newValue
            configureTimer()
        }
    }

    public var includePrereleases: Bool {
        get { preferences.includePrereleases }
        set { preferences.includePrereleases = newValue }
    }

    public var autoDownloadWhenAvailable: Bool {
        get { preferences.autoDownloadWhenAvailable }
        set { preferences.autoDownloadWhenAvailable = newValue }
    }

    public var allowRemoveQuarantine: Bool {
        get { preferences.allowRemoveQuarantine }
        set { preferences.allowRemoveQuarantine = newValue }
    }

    private let checker: UpdateChecker
    private let downloader: UpdateDownloader
    private let installer: UpdateInstaller
    private let preferences: UpdatePreferences
    private let logger: UpdaterLogger
    private var autoTimer: Timer?
    private var cancellables: Set<AnyCancellable> = []
    private var downloadedUpdate: DownloadedUpdate?

    public init(checker: UpdateChecker, downloader: UpdateDownloader, installer: UpdateInstaller, preferences: UpdatePreferences = UpdatePreferences(), logger: UpdaterLogger = .shared) {
        self.checker = checker
        self.downloader = downloader
        self.installer = installer
        self.preferences = preferences
        self.logger = logger
        self.currentVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "0.0.0"
        self.lastCheckedAt = preferences.lastCheckedAt
        self.latestKnownVersion = preferences.latestKnownVersion
        bindDownloader()
        configureTimer()
    }

    private func bindDownloader() {
        downloader.onProgress = { [weak self] progress in
            let fraction: Double
            if progress.total > 0 {
                fraction = Double(progress.received) / Double(progress.total)
            } else {
                fraction = 0
            }
            Task { @MainActor in
                self?.status = .downloading(fraction)
            }
        }
    }

    private func configureTimer() {
        autoTimer?.invalidate()
        guard autoUpdateEnabled else { return }
        let interval = TimeInterval(autoUpdateIntervalHours * 3600)
        guard interval > 0 else { return }
        let jitterMinutes = Double(Int.random(in: 5...15)) * 60
        let timer = Timer(timeInterval: interval + jitterMinutes, repeats: true) { [weak self] _ in
            Task { await self?.autoCheck() }
        }
        RunLoop.main.add(timer, forMode: .common)
        autoTimer = timer
    }

    private func autoCheck() async {
        await logger.log("触发自动检查更新")
        await checkForUpdates(manual: false)
    }

    public func checkForUpdates(manual: Bool) async {
        status = .checking
        lastErrorMessage = nil
        do {
            let info = try await checker.check(includePrereleases: includePrereleases)
            latestKnownVersion = info.latest
            preferences.latestKnownVersion = info.latest
            lastCheckedAt = preferences.lastCheckedAt
            status = .updateAvailable(info)
            if autoDownloadWhenAvailable && !manual {
                await startDownload(for: info)
            }
        } catch UpdateCheckerError.alreadyLatest {
            lastCheckedAt = preferences.lastCheckedAt
            status = .upToDate
            await logger.log("当前已是最新版本")
        } catch {
            let message = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
            lastErrorMessage = message
            status = .error(message)
            await logger.log("检查更新失败: \(message)", level: .error)
        }
    }

    public func startDownload(for info: UpdateInfo) async {
        status = .downloading(0)
        do {
            let downloaded = try await downloader.download(asset: info.asset, sha256: info.sha256)
            downloadedUpdate = downloaded
            status = .downloaded
        } catch {
            let message = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
            lastErrorMessage = message
            status = .error(message)
            await logger.log("下载更新失败: \(message)", level: .error)
        }
    }

    public func installUpdate() async {
        guard let downloadedUpdate else { return }
        status = .installing
        do {
            _ = try await installer.install(newAppPath: downloadedUpdate.extractedAppURL, removeQuarantine: allowRemoveQuarantine)
        } catch {
            let message = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
            lastErrorMessage = message
            status = .error(message)
            await logger.log("安装更新失败: \(message)", level: .error)
        }
    }

    public func cancelScheduledChecks() {
        autoTimer?.invalidate()
        autoTimer = nil
    }
}
