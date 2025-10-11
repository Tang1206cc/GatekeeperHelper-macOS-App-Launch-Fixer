import Foundation
import SwiftUI
import AppKit

struct AppStoreFixView: View {
    var dismiss: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 标题栏 + 关闭按钮
            HStack {
                Text("解决方案：无法打开App，因为它不是从App Store下载")
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
                    Text("这是由于macOS的软件来源安全性设置默认是仅允许安装来自「App Store 」的软件，进入设置调整修改即可。")

                    Text("解决方式如下：")

                    Text("1. 打开「系统设置」→「隐私与安全性」。\n2. 滚动到底部，在“安全性-允许以下来源的应用程序”处选择“App Store与已知开发者”后输入密码确认修改。\n3. 完成调整后即可运行相应App。\n\n你也可通过本软件第一个App启动问题中的“永久禁用Gatekeeper”功能，获得把该设置改为“任何来源”的权限。否则，Apple出于安全考虑,不会直接展示此选项。")

                    Image("detail8")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                        .cornerRadius(8)
                }
                .font(.body)
            }

            Spacer()

            HStack {
                Spacer()

                Button("跳转至设置界面") {
                    if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?General") {
                        NSWorkspace.shared.open(url)
                    }
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
    }
}
