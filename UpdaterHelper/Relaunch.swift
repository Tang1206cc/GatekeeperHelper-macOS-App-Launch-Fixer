import Foundation

func relaunch(appPath: String, bundleID: String) {
    let task = Process()
    task.executableURL = URL(fileURLWithPath: "/usr/bin/open")
    task.arguments = [appPath]

    do {
        try task.run()
        task.waitUntilExit()
        if task.terminationStatus == 0 {
            return
        }
    } catch {}

    let fallbackTask = Process()
    fallbackTask.executableURL = URL(fileURLWithPath: "/usr/bin/open")
    fallbackTask.arguments = ["-b", bundleID]
    try? fallbackTask.run()
}
