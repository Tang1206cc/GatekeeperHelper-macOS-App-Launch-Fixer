import AppKit

func relaunch(bundleID: String) {
    // 用 bundle id 重启主应用
    let task = Process()
    task.executableURL = URL(fileURLWithPath: "/usr/bin/open")
    task.arguments = ["-b", bundleID]
    try? task.run()
}
