//
//  AuthorizationBridge.swift
//  GatekeeperHelper
//

import Foundation

enum AuthResult: Equatable {
    case success
    case failure(String)
}

class AuthorizationBridge {
    static func run(command: String) -> AuthResult {
        var err: NSString?
        let ok = AuthorizationTool.runCommand(command, error: &err)

        // 即使命令执行 ok，也要验证 Gatekeeper 状态是否真的被关闭
        if ok {
            let status = checkGatekeeperStatus()
            if status == "disabled" {
                return .success
            } else {
                return .failure("命令执行后，Gatekeeper 仍处于启用状态，可能需要手动更改设置。")
            }
        } else {
            let msg = (err as String?) ?? "命令执行失败，请检查权限或参数。"
            return .failure(msg)
        }
    }

    static func checkGatekeeperStatus() -> String {
        let process = Process()
        process.launchPath = "/usr/sbin/spctl"
        process.arguments = ["--status"]

        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe

        process.launch()
        process.waitUntilExit()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8) ?? ""

        if output.contains("disabled") {
            return "disabled"
        } else {
            return "enabled"
        }
    }
}
