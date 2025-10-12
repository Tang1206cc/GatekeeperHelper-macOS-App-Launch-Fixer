import Foundation
import SwiftUI
import AppKit

struct AdobeInstallFixView: View {
    var dismiss: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("解决方案：安装Adobe软件时报错")
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
                    Text("这可能是由Install文件包内Unix可执行文件的错误所致。")

                    Text("解决方式如下：")

                    Text("1. 打开用于安装Adobe软件的磁盘映像（dmg）或安装包，找到“Install”文件，选中并右击选择“显示包内容”。\n2. 在包内「Contents-MacOS」找到Install的Unix可执行文件并双击。\n3. 之后就可以正常执行安装了。")

                }
                .font(.body)
            }

            Spacer()

            HStack {
                Spacer()

                Button("打开访达") {
                    let url = URL(fileURLWithPath: "/Applications")
                    NSWorkspace.shared.open(url)
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
