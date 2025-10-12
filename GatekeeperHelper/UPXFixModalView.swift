import SwiftUI
import AppKit
import Foundation

struct UPXFixModalView: View {
    let appURL: URL
    @Environment(\.dismiss) private var dismiss

    @State private var showBrewGuide = false
    @State private var showUPXGuide = false
    @State private var showFixGuide = false

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

            Text("已选择 App")
                .font(.headline)

            Text(appURL.path)
                .font(.caption)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal)

            Button("第一步：安装Brew工具") { installBrew() }

            Button("第二步：安装UPX工具") { installUPX() }

            HStack {
                Button("前往修复") { showFixGuide = true }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
            }

            Text("确保上面两步执行返回成功后再点击“前往修复”按钮，否则无法真正脱壳解锁")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            Button("取消") { dismiss() }
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(minWidth: 360)
        .sheet(isPresented: $showBrewGuide) {
            BrewInstallGuideView {
                showBrewGuide = false
            } onOpenSettings: {
                if let url = URL(string: "x-apple.systempreferences:com.apple.preferences.softwareupdate") {
                    NSWorkspace.shared.open(url)
                }
            }
        }
        .sheet(isPresented: $showUPXGuide) {
            UPXInstallGuideView {
                showUPXGuide = false
            }
        }
        .sheet(isPresented: $showFixGuide) {
            UPXManualFixGuideView {
                showFixGuide = false
                markFixResult(success: true)
            } onCancel: {
                showFixGuide = false
                markFixResult(success: false)
            }
        }
    }

    private func installBrew() {
        showBrewGuide = true
    }

    private func installUPX() {
        showUPXGuide = true
    }

    private func markFixResult(success: Bool) {
        RepairHistoryManager.shared.addRecord(appName: appURL.lastPathComponent, method: "upx", success: success)
        if success {
            Unlocker.showAlert(title: "完成", message: "您已完成全部脱壳操作，若无效可多次重试或反馈作者！")
        } else {
            Unlocker.showAlert(title: "修复失败", message: "用户取消。")
        }
        dismiss()
    }
}

private struct BrewInstallGuideView: View {
    let onClose: () -> Void
    let onOpenSettings: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("安装提示：务必逐条阅读，按下方内容操作完毕再关闭本弹窗")
                .font(.headline)

            VStack(alignment: .leading, spacing: 8) {
                Text("1. 请拷贝下列命令至“终端”执行：")
                CodeBlock(command: "/bin/bash -c \"$(curl -fsSL https://gitee.com/ineo6/homebrew-install/raw/master/install.sh)\"")
                Text("2.若终端提示“Checking for sudo access (which may request your password).”，在下方Password处输入电脑密码后回车（输入过程不可见），完成后跟随提示开始下载。")
                Text("3.若终端提示“curl: (6) Could not resolve host: gitee.com”说明当前无法访问下载地址，请稍候再试。")
                Text("4.若终端提示缺乏命令行工具等相关英文内容，说明Mac当前没有相关配置。稍等片刻后，“设置-通用-软件更新”内就会自动推送相关配置更新，下载安装更新后（不关机更新）即可重试操作。")
                Text("完成上述后，若提示“执行成功”则代表安装成功")
            }
            .font(.body)

            HStack {
                Button("为你打开“设置”更新界面") { onOpenSettings() }
                    .buttonStyle(.bordered)
                Spacer()
                Button("好，我已完成") { onClose() }
                    .buttonStyle(.borderedProminent)
            }
            .padding(.top, 10)
        }
        .padding()
        .frame(width: 960)
    }
}

private struct UPXInstallGuideView: View {
    let onClose: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("安装提示：务必逐条阅读，按下方内容操作完毕再关闭本弹窗")
                .font(.headline)

            VStack(alignment: .leading, spacing: 8) {
                Text("1. 请拷贝下列命令至“终端”执行：")
                CodeBlock(command: "brew install upx")
                Text("2.耐心等待下载完毕即可，注意终端返回内容，可多次尝试。")
            }
            .font(.body)

            HStack {
                Spacer()
                Button("好，我已完成") { onClose() }
                    .buttonStyle(.borderedProminent)
            }
            .padding(.top, 10)
        }
        .padding()
        .frame(width: 420)
    }
}

private struct UPXManualFixGuideView: View {
    let onComplete: () -> Void
    let onCancel: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("修复提示：务必逐条阅读，按下方内容操作完毕再关闭本弹窗")
                .font(.headline)

            VStack(alignment: .leading, spacing: 8) {
                Text("1.完成最后的脱壳解锁操作，请打开终端输入以下代码，空格一个。")
                CodeBlock(command: "upx -d")
                Text("2.把软件拖到桌面上，右键显示包内容，进入Contents/MacOS中找到 Unix可执行文件（一般和软件名相同的就是，不行就多试几个）。")
                Text("3.把找到的Unix可执行文件拖进终端，并回车等待返回即可。")
            }
            .font(.body)

            HStack {
                Spacer()
                Button("取消") { onCancel() }
                    .buttonStyle(.bordered)
                Button("好，我已完成") { onComplete() }
                    .buttonStyle(.borderedProminent)
            }
            .padding(.top, 10)
        }
        .padding()
        .frame(width: 520)
    }
}
