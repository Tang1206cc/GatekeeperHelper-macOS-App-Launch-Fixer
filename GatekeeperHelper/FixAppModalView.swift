//
//  FixAppModalView.swift
//  GatekeeperHelper
//

import Foundation
import SwiftUI
import AppKit

struct FixAppModalView: View {
    let appURL: URL
    let issue: UnlockIssue
    @Environment(\.dismiss) var dismiss

    // 第一类问题：已损坏
    @Binding var selectedMethod: UnlockMethod

    // 第二类问题：意外退出
    @State private var selectedAdvancedMethod: AdvancedUnlockMethod = .appBundle

    var appIcon: NSImage? {
        NSWorkspace.shared.icon(forFile: appURL.path)
    }

    var body: some View {
        VStack(spacing: 20) {
            if let icon = appIcon {
                Image(nsImage: icon)
                    .resizable()
                    .frame(width: 64, height: 64)
                    .cornerRadius(12)
                    .shadow(radius: 4)
                    .padding(.bottom, 4)
            }

            Text(appURL.pathExtension.lowercased() == "command" ? "已选择文件" : "已选择 App")
                .font(.headline)

            Text(appURL.path)
                .font(.caption)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal)

            // 第一类问题
            if issue.title == "XXX已损坏，无法打开。您应该推出磁盘映像/移到废纸篓" {
                Picker("选择解锁方式", selection: $selectedMethod) {
                    ForEach(UnlockMethod.allCases, id: \.self) { method in
                        Text(method.description).tag(method)
                    }
                }
                .pickerStyle(.menu)
                .frame(maxWidth: .infinity)
                .padding(.horizontal)
            }

            // 第二类问题
            if issue.title == "XXX意外退出" {
                Picker("选择签名方式", selection: $selectedAdvancedMethod) {
                    ForEach(AdvancedUnlockMethod.allCases, id: \.self) { method in
                        Text(method.description).tag(method)
                    }
                }
                .pickerStyle(.menu)
                .frame(maxWidth: .infinity)
                .padding(.horizontal)
            }

            Button("立即修复") {
            switch issue.title {

                // ---------------------------
                // 第一类问题：“xxx已损坏…”
                // ---------------------------
                case "XXX已损坏，无法打开。您应该推出磁盘映像/移到废纸篓":

                    if selectedMethod == .spctl {
                        // 仅此路径：不做复查，默认成功；取消时静默退出并关闭弹窗
                        let command = "/usr/sbin/spctl --master-disable"
                        let result: AuthResult = AuthorizationBridge.run(command: command)

                        // 小函数：统一的成功提示 + 打开设置 + 写历史
                        func showSuccessGuide() {
                            // 历史记录标记为成功（按你的要求）
                            RepairHistoryManager.shared.addRecord(
                                appName: "System",
                                method: "spctl_disable",
                                success: true
                            )

                            // 复制命令（保留你之前的交互习惯）
                            NSPasteboard.general.clearContents()
                            NSPasteboard.general.setString(command, forType: .string)

                            let alert = NSAlert()
                            alert.messageText = "成功授予变更权限，需要进一步操作"
                            alert.informativeText = """
                            GatekeeperHelper 已为你的 Mac 开启使用“任何来源”选项的权限。

                            请前往：设置 > 隐私与安全性 > 允许从以下来源的应用程序，并选择“任何来源”，就可以彻底关闭 Gatekeeper。（若没有该选项，重试即可）

                            点击“好”将立即为你打开设置界面。
                            """
                            alert.addButton(withTitle: "好")
                            alert.runModalWithSystemStyle()

                            if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy") {
                                NSWorkspace.shared.open(url)
                            } else {
                                NSWorkspace.shared.open(URL(fileURLWithPath: "/System/Applications/System Settings.app"))
                            }
                        }

                        switch result {
                        case .success:
                            showSuccessGuide()
                            return   // 成功后不再走到下面的 dismiss()

                        case .failure(let msg):
                            // 仅当用户取消时静默处理并关闭弹窗
                            let lowered = msg.lowercased()
                            if lowered.contains("user canceled")
                                || lowered.contains("user cancelled")
                                || msg.contains("用户取消") {
                                dismiss()
                                return
                            }
                            // 其它失败也按“默认成功”处理（你的最新要求）
                            showSuccessGuide()
                            return
                        }

                    } else {
                        // 临时绕过 / 其它方式：交给 Unlocker（保留你已验收通过的逻辑）
                        Unlocker.unlock(appAt: appURL, with: selectedMethod)
                    }

                // ---------------------------
                // 第二类问题：“xxx”意外退出
                // ---------------------------
                case "XXX意外退出":
                    Unlocker.unlock(appAt: appURL, withAdvancedMethod: selectedAdvancedMethod)

                // ---------------------------
                // 第三类问题：“xxx软件打开失败”
                // ---------------------------
                case "XXX软件打开失败":
                    Unlocker.chmodFixExecutable(in: appURL)

                // ---------------------------
                // 第五类问题：command 无法执行
                // ---------------------------
                case "文件XXX.command无法执行，因为您没有正确的访问权限":
                    Unlocker.chmodCommand(at: appURL)

                default:
                    break
                }

                // 其余路径：触发操作后收起本弹窗
                dismiss()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)

            Button("取消") {
                dismiss()
            }
            .foregroundColor(.secondary)
        }
        .padding()
        .frame(minWidth: 360)
    }
}
