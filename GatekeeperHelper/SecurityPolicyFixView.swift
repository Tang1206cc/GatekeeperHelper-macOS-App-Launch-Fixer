import Foundation
import SwiftUI
import AppKit

struct SecurityPolicyFixView: View {
    var dismiss: () -> Void
    @State private var showSIPSheet = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("解决方案：无法打开App，因为“安全策略”已设为“某某安全性”")
                    .font(.title2)
                    .bold()
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)

                Spacer()

                Button(action: dismiss) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                        .imageScale(.large)
                }
                .buttonStyle(.plain)
            }

            Divider()

            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    Text("这是因为Mac的安全策略工具拦截了此App的启动。需要注意的是，即便“宽松安全性”属于最低等级的安全策略，某些App却需要在更高等级的安全策略下才能正常打开。")

                    Text("\n解决方式如下：")

                    Text("1. 进入恢复模式：关机后长按电源键10s。\n\n2. 点击带有齿轮图标的“选项”，并输入密码即可进入恢复。\n\n3. 在导航栏中选择“实用工具”后，点击进入“启动安全性实用工具”。\n\n4. 找到你需要变更安全策略的系统磁盘（通常就是Macintosh HD），点击右下角解锁并输入该系统对应的开机密码。\n\n5. 解锁后点击右下角“安全策略”，即可进入调整。\n\n6.安全等级越高则用户安装某些三方App的限制就越高，完整安全性>降低安全性>宽松安全性。\n\n7.\n（1）完整安全性：确保只有当前的操作系统或者当前Apple信任的签名操作系统软件才能运行。此模式要求在安装软件时接入网络。【这是最高级别的安全策略，在这种模式下你下载的大多数三方App可能都无法正常安装使用】\n（2）降低安全性：允许运行Apple信任过的任何版本的签名操作系统软件。【这是相对均衡的安装策略，这是大多数用户选择的策略，在大部分情况的App都可以正常安装使用】\n（3）宽松安全性：对可启动的操作系统没有任何强制要求。【这是最低级别的安全策略，这种报告情况下安全性实用工具对系统没有任何强制要求】\n·允许用户管理来自被认可开发者的内核扩展（后两种下可选）\n·允许远程管理内核扩展和软件自动更新（后两种下可选）\n\n8.你可以结合弹窗的内容/软件的需要决定要去选择什么样的安全策略，一般情况下不建议直接设置为“宽松安全性”，即便暂时设置后也值得长期启用。\n\n9.\n需要注意的是，Mac的安全策略和系统完整性保护（SIP）实际上是相辅相成的：\n当你把安全策略设置为“完整安全性”和“降低安全性”时，SIP会始终处于开启，而当你把安全策略设置为“宽松安全性”时，SIP将始终处于关闭。\n然而，只有当你把SIP关闭后，你的启动安全性实用工具内才会显示有“宽松安全性”选项，也即你不关闭SIP，就无法调整为“宽松安全性”。因此如果你想调整为“宽松安全性”，需要先通过右下角的“关闭SIP”操作。\n关闭SIP后就会自动调整为“宽松安全性”，开启SIP后会自动调整为“降低安全性”。")
                }
                .font(.body)
            }

            Spacer()

            HStack {
                Button("关闭 SIP") {
                    showSIPSheet = true
                }
                .buttonStyle(.bordered)

                Spacer()

                Button("点按关机") {
                    shutdownMac()
                }
                .keyboardShortcut(.defaultAction)
            }

            Text("部分信息与素材转载于https://foxirj.com及其他网站。GatekeeperHelper开源免费，仅供学习交流，侵权请联系删除。")
                .font(.footnote)
                .foregroundColor(.gray)
                .lineLimit(1)
                .multilineTextAlignment(.trailing)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(20)
        .frame(minWidth: 620, minHeight: 460)
        .sheet(isPresented: $showSIPSheet) {
            SheetWrapperView(title: "关闭 SIP") {
                showSIPSheet = false
            }
        }
    }

    private func shutdownMac() {
        let process = Process()
        process.launchPath = "/usr/bin/osascript"
        process.arguments = ["-e", "tell application \"System Events\" to shut down"]
        try? process.run()
    }
}
