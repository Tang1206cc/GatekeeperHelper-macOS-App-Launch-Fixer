import AppKit

final class DownloadWindowController: NSWindowController, URLSessionDownloadDelegate {
    private let progressIndicator = NSProgressIndicator()
    private let percentField = NSTextField(labelWithString: "下载进度：0%")
    private let etaField = NSTextField(labelWithString: "剩余时间：—")

    private var session: URLSession?
    private var startTime: Date?
    private var completion: ((Result<URL, Error>) -> Void)?

    convenience init() {
        self.init(window: nil)
        setupWindow()
    }

    override init(window: NSWindow?) {
        super.init(window: window)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupWindow() {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 420, height: 150),
            styleMask: [.titled, .closable, .miniaturizable],
            backing: .buffered,
            defer: false
        )
        window.center()
        window.title = "正在下载"
        window.isReleasedWhenClosed = false
        window.standardWindowButton(.closeButton)?.isEnabled = false
        window.standardWindowButton(.zoomButton)?.isEnabled = false
        window.standardWindowButton(.miniaturizeButton)?.isEnabled = true
        window.collectionBehavior = []

        let contentView = NSView(frame: window.contentRect(forFrameRect: window.frame))
        contentView.translatesAutoresizingMaskIntoConstraints = false
        window.contentView = contentView

        progressIndicator.translatesAutoresizingMaskIntoConstraints = false
        progressIndicator.isIndeterminate = false
        progressIndicator.minValue = 0
        progressIndicator.maxValue = 1
        progressIndicator.doubleValue = 0
        progressIndicator.controlSize = .regular
        progressIndicator.style = .bar

        percentField.translatesAutoresizingMaskIntoConstraints = false
        percentField.font = .systemFont(ofSize: 13)

        etaField.translatesAutoresizingMaskIntoConstraints = false
        etaField.font = .systemFont(ofSize: 12)
        etaField.alignment = .right

        contentView.addSubview(percentField)
        contentView.addSubview(progressIndicator)
        contentView.addSubview(etaField)

        NSLayoutConstraint.activate([
            percentField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            percentField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),

            progressIndicator.topAnchor.constraint(equalTo: percentField.bottomAnchor, constant: 12),
            progressIndicator.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            progressIndicator.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),

            etaField.topAnchor.constraint(equalTo: progressIndicator.bottomAnchor, constant: 12),
            etaField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            etaField.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])

        self.window = window
    }

    func startDownload(from url: URL, completion: @escaping (Result<URL, Error>) -> Void) {
        self.completion = completion
        percentField.stringValue = "下载进度：0%"
        etaField.stringValue = "剩余时间：—"
        progressIndicator.doubleValue = 0
        progressIndicator.isIndeterminate = false
        startTime = Date()

        let configuration = URLSessionConfiguration.ephemeral
        let session = URLSession(configuration: configuration, delegate: self, delegateQueue: .main)
        self.session = session
        session.downloadTask(with: url).resume()

        showWindow(nil)
        window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    // MARK: URLSessionDownloadDelegate

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask,
                    didWriteData bytesWritten: Int64,
                    totalBytesWritten: Int64,
                    totalBytesExpectedToWrite: Int64) {
        guard totalBytesExpectedToWrite > 0 else { return }

        let progress = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
        progressIndicator.doubleValue = progress
        percentField.stringValue = String(format: "下载进度：%.0f%%", progress * 100)

        if let startTime, totalBytesWritten > 0 {
            let elapsed = Date().timeIntervalSince(startTime)
            let speed = Double(totalBytesWritten) / max(elapsed, 0.1)
            let remainingBytes = Double(totalBytesExpectedToWrite - totalBytesWritten)
            let remainingTime = remainingBytes / max(speed, 1)
            etaField.stringValue = "剩余时间：" + format(seconds: Int(remainingTime))
        }
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask,
                    didFinishDownloadingTo location: URL) {
        let destination = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("zip")
        do {
            try FileManager.default.moveItem(at: location, to: destination)
            complete(with: .success(destination), cancelTasks: false)
        } catch {
            complete(with: .failure(error), cancelTasks: true)
        }
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error {
            complete(with: .failure(error), cancelTasks: true)
        }
    }

    private func complete(with result: Result<URL, Error>, cancelTasks: Bool) {
        window?.orderOut(nil)
        if cancelTasks {
            session?.invalidateAndCancel()
        } else {
            session?.finishTasksAndInvalidate()
        }
        session = nil
        let completion = self.completion
        self.completion = nil
        completion?(result)
    }

    private func format(seconds: Int) -> String {
        let minutes = seconds / 60
        let secs = seconds % 60
        if minutes > 0 {
            return "\(minutes) 分 \(secs) 秒"
        } else {
            return "\(secs) 秒"
        }
    }
}
