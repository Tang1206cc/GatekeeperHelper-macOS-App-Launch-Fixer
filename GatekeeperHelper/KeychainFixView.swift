import Foundation
import SwiftUI
import AppKit

struct KeychainFixView: View {
    var dismiss: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 标题栏 + 关闭按钮
            HStack {
                Text("解决方案：启动软件时一直弹窗输入密码或存储密码/钥匙串")
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
                    Text("这是因为Mac密码/钥匙串功能错误所导致。")

                    Text("解决方式如下：")

                    Text("1.在桌面上点击顶部导航菜单内的“前往”，并按住 Option键，点击打开弹出的“资源库”。\n2.在资源库中找到并打开Keychains文件夹，仔细查找里面有没有相关应用名称的文件/钥匙串。假设遇到问题的软件为B站，就在其中找所有带有“bilibili”字样的文件/钥匙串，将其全部删除后重启电脑即可。\n3.重启后再次打开软件如果提示创建新的钥匙串，则创建即可，不提示就忽略此步骤。")

                    Image("detail12")
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

                Button("打开Keychains文件夹") {
                    let url = URL(fileURLWithPath: NSHomeDirectory()).appendingPathComponent("Library/Keychains")
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
