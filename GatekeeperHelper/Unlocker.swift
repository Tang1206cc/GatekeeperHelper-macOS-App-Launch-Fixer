//
//  Unlocker.swift
//  GatekeeperHelper
//

import Foundation
import AppKit

struct Unlocker {

    // MARK: - 第一个问题：“xxx已损坏…”
    static func unlock(appAt url: URL, with method: UnlockMethod) {
        let path = url.path

        switch method {
        case .xattr:
            // ① 先判断是否真的带 quarantine
            if !isQuarantined(path: path) {
                showAlert(
                    title: "无需修复",
                    message: "该 App 不包含隔离属性（com.apple.quarantine），已可直接尝试打开。"
                )
                return
            }

            // ② 执行移除 quarantine
            let command = "/usr/bin/xattr -r -d com.apple.quarantine \"\(path)\""
            let result: AuthResult = AuthorizationBridge.run(command: command)

            // ③ 以“是否仍带 quarantine”为准，避免误报
            let nowQuarantined = isQuarantined(path: path)
            let success = !nowQuarantined

            // 历史记录（仅在实际执行过时记录）
            RepairHistoryManager.shared.addRecord(
                appName: url.lastPathComponent,
                method: "xattr",
                success: success
            )

            if success {
                showAlert(title: "执行成功", message: "已移除隔离属性（quarantine）。")
            } else {
                // 尝试给出更友好的失败信息
                let msg: String = {
                    if case .failure(let m) = result { return m }
                    return "命令已执行，但未检测到隔离属性被移除。"
                }()
                showAlert(title: "执行失败", message: "\(msg)\n命令已复制，可在终端手动执行：\n\(command)")
                copyToPasteboard(command)
            }

        case .spctl:
            // 永久禁用 Gatekeeper（危险）
            // ✅ 仅执行命令，后续弹窗 / 跳转 / 历史记录均由 FixAppModalView 统一处理
            let command = "/usr/sbin/spctl --master-disable"
            _ = AuthorizationBridge.run(command: command)
            return
        }
    }

    // MARK: - 一键恢复 Gatekeeper（状态优先判定）
    static func restoreGatekeeper() {
        // ① 如果已经开启，则直接提示“无需恢复”并引导到设置
        if gatekeeperIsEnabled() {
            showAlert(
                title: "无需恢复",
                message: """
                当前系统已取消“任何来源”，启用了 Gatekeeper 保护。
                你可前往“设置 > 隐私与安全性 > 允许从以下来源的应用程序”，做出保护策略的进一步选择：
                • 允许 App Store 与已知开发者（推荐）
                • 仅允许 App Store
                点击“好”，我将为你打开该页面。
                """
            )
            openSecurityPrivacyPane()
            return
        }

        // ② 尝试开启
        let command = "/usr/sbin/spctl --master-enable"
        let result: AuthResult = AuthorizationBridge.run(command: command)

        // ③ 以系统状态为准：只要现在是已开启，就视为成功
        if gatekeeperIsEnabled() {
            RepairHistoryManager.shared.addRecord(
                appName: "System",
                method: "spctl_enable",
                success: true
            )
            showAlert(
                title: "已恢复 Gatekeeper",
                message: """
                系统已取消“任何来源”，启用了 Gatekeeper 保护。
                你可前往“设置 > 隐私与安全性 > 允许从以下来源的应用程序”，做出保护策略的进一步选择：
                • 允许 App Store 与已知开发者（推荐）
                • 仅允许 App Store
                点击“好”，我将为你打开该页面。
                """
            )
            openSecurityPrivacyPane()
            return
        }

        // ④ 仍未开启：视为失败，并记录历史
        RepairHistoryManager.shared.addRecord(
            appName: "System",
            method: "spctl_enable",
            success: false
        )

        let failMsg: String = {
            if case .failure(let m) = result { return m }
            return "命令已执行，但系统仍未检测到 Gatekeeper 开启。"
        }()

        showAlert(title: "恢复失败", message: "\(failMsg)\n命令已复制，可在终端手动执行：\n\(command)")
        copyToPasteboard(command)
    }

    // MARK: - 第二个问题：“xxx 意外退出”
    static func unlock(appAt url: URL, withAdvancedMethod method: AdvancedUnlockMethod) {
        switch method {
        case .appBundle:
            codesignApp(at: url)
        case .executable:
            codesignExecutable(in: url)
        }
    }

    // App Bundle 签名
    static func codesignApp(at url: URL) {
        let path = url.path
        let command = "/usr/bin/codesign --force --deep --sign - \"\(path)\""
        let result: AuthResult = AuthorizationBridge.run(command: command)
        let success = (result == .success)

        RepairHistoryManager.shared.addRecord(
            appName: url.lastPathComponent,
            method: "codesign_bundle",
            success: success
        )

        if success {
            showAlert(title: "签名成功", message: "App 签名命令已自动执行。")
        } else {
            let msg: String = {
                if case .failure(let m) = result { return m }
                return "命令执行失败，请重试。"
            }()
            showAlert(title: "签名失败", message: "\(msg)\n命令已复制，可手动粘贴至终端：\n\(command)")
            copyToPasteboard(command)
        }
    }

    // 可执行文件签名
    static func codesignExecutable(in appURL: URL) {
        let execDir = appURL.appendingPathComponent("Contents/MacOS")
        do {
            let contents = try FileManager.default.contentsOfDirectory(at: execDir, includingPropertiesForKeys: nil, options: [])
            guard let executable = contents.first else {
                showAlert(title: "未找到可执行文件", message: "在 Contents/MacOS 中未发现可执行文件。")
                return
            }

            let path = executable.path
            let command = "/usr/bin/codesign --force --sign - \"\(path)\""
            let result: AuthResult = AuthorizationBridge.run(command: command)
            let success = (result == .success)

            RepairHistoryManager.shared.addRecord(
                appName: executable.lastPathComponent,
                method: "codesign_exec",
                success: success
            )

            if success {
                showAlert(title: "签名成功", message: "可执行文件签名命令已自动执行。")
            } else {
                let msg: String = {
                    if case .failure(let m) = result { return m }
                    return "命令执行失败，请重试。"
                }()
                showAlert(title: "签名失败", message: "\(msg)\n命令已复制，可手动粘贴至终端：\n\(command)")
                copyToPasteboard(command)
            }

        } catch {
            showAlert(title: "出错了", message: "无法读取 Contents/MacOS 文件夹：\(error.localizedDescription)")
        }
    }

    // MARK: - 第三个问题：“软件打开失败（chmod +x）”
    static func chmodFixExecutable(in appURL: URL) {
        let execDir = appURL.appendingPathComponent("Contents/MacOS")

        do {
            let contents = try FileManager.default.contentsOfDirectory(at: execDir, includingPropertiesForKeys: [.isRegularFileKey], options: [])
            // 找出没有可执行权限的文件（不检查扩展名，按权限判断）
            let nonExecutable = contents.first(where: { !checkExecutablePermission(of: $0) })

            guard let target = nonExecutable else {
                showAlert(title: "无需修复", message: "此 App 包内的可执行文件已具备可执行权限。")
                return
            }

            let path = target.path
            let command = "/bin/chmod +x \"\(path)\""
            let result: AuthResult = AuthorizationBridge.run(command: command)
            let success = (result == .success) && checkExecutablePermission(of: target)

            RepairHistoryManager.shared.addRecord(
                appName: appURL.lastPathComponent,
                method: "chmod",
                success: success
            )

            if success {
                showAlert(title: "修复成功", message: "已为可执行文件添加执行权限。")
            } else {
                let msg: String = {
                    if case .failure(let m) = result { return m }
                    return "命令执行失败，请重试。"
                }()
                showAlert(title: "修复失败", message: "\(msg)\n命令已复制，请在终端手动执行：\n\(command)")
                copyToPasteboard(command)
            }

        } catch {
            showAlert(title: "出错了", message: "无法访问 Contents/MacOS：\(error.localizedDescription)")
        }
    }

    // MARK: - 第五个问题：command 文件无执行权限
    static func chmodCommand(at url: URL) {
        let path = url.path
        let command = "/bin/chmod +x \"\(path)\""

        var err: NSString?
        let ok = AuthorizationTool.runCommand(command, error: &err)
        let msg = err as String? ?? ""
        let cancelled = msg.lowercased().contains("user canceled") || msg.lowercased().contains("user cancelled") || msg.contains("用户取消")

        if !ok && cancelled {
            RepairHistoryManager.shared.addRecord(
                appName: url.lastPathComponent,
                method: "chmod_command",
                success: false
            )

            let alert = NSAlert()
            alert.messageText = "执行修复失败"
            alert.informativeText = "未能给予.command文件正确的执行权限。你可拷贝该指令进入终端手动执行：\n\(command)"
            alert.addButton(withTitle: "好")
            alert.addButton(withTitle: "拷贝指令")
            let response = alert.runModalWithSystemStyle()
            if response == .alertSecondButtonReturn {
                copyToPasteboard(command)
            }
            return
        }

        RepairHistoryManager.shared.addRecord(
            appName: url.lastPathComponent,
            method: "chmod_command",
            success: true
        )

        let alert = NSAlert()
        alert.messageText = "执行修复成功"
        alert.informativeText = "已给予.command文件正确的执行权限，你可尝试重新运行。\n若仍然没有正确的执行权限，你可拷贝该指令进入终端手动执行：\n\(command)"
        alert.addButton(withTitle: "好")
        alert.addButton(withTitle: "拷贝指令")
        let response = alert.runModalWithSystemStyle()
        if response == .alertSecondButtonReturn {
            copyToPasteboard(command)
        }
    }

    // MARK: - 状态判断工具

    /// Gatekeeper 是否开启（“任何来源”已取消）
    private static func gatekeeperIsEnabled() -> Bool {
        let result = runLocal(bin: "/usr/sbin/spctl", args: ["--status"])
        // 正常情况下输出包含 “assessments enabled”
        return result.output.lowercased().contains("assessments enabled")
    }

    /// 是否带 quarantine
    private static func isQuarantined(path: String) -> Bool {
        // xattr -p com.apple.quarantine path   -> 存在则退出码 0；不存在通常非 0
        let r = runLocal(bin: "/usr/bin/xattr", args: ["-p", "com.apple.quarantine", path])
        return r.status == 0
    }

    /// 文件是否具有可执行权限（任意 x 位）
    private static func checkExecutablePermission(of fileURL: URL) -> Bool {
        // 用 FileManager 判断执行权限
        return FileManager.default.isExecutableFile(atPath: fileURL.path)
    }

    // MARK: - 公共小工具

    static func showAlert(title: String, message: String, buttonText: String = "好") {
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = message
        alert.addButton(withTitle: buttonText)
        alert.runModalWithSystemStyle()
    }

    static func copyToPasteboard(_ string: String) {
        let pb = NSPasteboard.general
        pb.clearContents()
        pb.setString(string, forType: .string)
    }

    /// 本地执行（不提权），便于读取输出/状态做校验
    @discardableResult
    private static func runLocal(bin: String, args: [String]) -> (status: Int32, output: String) {
        let p = Process()
        p.executableURL = URL(fileURLWithPath: bin)
        p.arguments = args

        let pipe = Pipe()
        p.standardOutput = pipe
        p.standardError = pipe

        do { try p.run() } catch {
            return (status: -1, output: "run error: \(error.localizedDescription)")
        }
        p.waitUntilExit()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let out = String(data: data, encoding: .utf8) ?? ""
        return (status: p.terminationStatus, output: out)
    }

    /// 打开“隐私与安全性”设置页（系统版本不同可能回退到设置首页）
    private static func openSecurityPrivacyPane() {
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security") {
            NSWorkspace.shared.open(url)
        } else {
            NSWorkspace.shared.open(URL(fileURLWithPath: "/System/Applications/System Settings.app"))
        }
    }
}
