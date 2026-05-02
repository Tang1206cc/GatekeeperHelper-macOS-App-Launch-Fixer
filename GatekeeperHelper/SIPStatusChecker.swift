//
//  SIPStatusChecker.swift
//  GatekeeperHelper
//
//  Created by 唐梓耀 on 2025/07/28.
//

import Foundation

class SIPStatusChecker: ObservableObject {
    @Published var status: SIPStatus? = nil

    enum SIPStatus {
        case enabled
        case disabled
        case unknown
    }

    func checkStatus() {
        let task = Process()
        task.launchPath = "/usr/bin/env"
        task.arguments = ["csrutil", "status"]

        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = pipe

        do {
            try task.run()
        } catch {
            DispatchQueue.main.async {
                self.status = .unknown
            }
            return
        }

        task.waitUntilExit()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8) ?? ""

        DispatchQueue.main.async {
            if output.lowercased().contains("enabled") {
                self.status = .enabled
            } else if output.lowercased().contains("disabled") {
                self.status = .disabled
            } else {
                self.status = .unknown
            }
        }
    }

    func getStatusSymbol() -> String {
        switch status {
        case .enabled:
            return "⚠️ 已开启"
        case .disabled:
            return "✅ 已关闭"
        case .unknown:
            return "❓ 状态未知"
        case .none:
            return "点击“一键判断”"
        }
    }
}
