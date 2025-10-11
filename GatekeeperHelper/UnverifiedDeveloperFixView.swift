import Foundation
import SwiftUI
import AppKit

struct UnverifiedDeveloperFixView: View {
    var dismiss: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 标题栏 + 关闭按钮
            HStack {
                Text("解决方案：无法打开App，因为无法验证开发者")
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
                    Text("这是由于虽然macOS的软件安装安全性设置已经允许安装App Store和已知开发者的应用，但由于某些应用不属于“已知开发者”范畴或一系列其他原因，使你仍然看到此类警告")

                    Text("解决方式如下：")

                    Text("1.右键点击对应App，选择打开，连续操作两次。\n2.再在访达中对应位置找到软件，选中并右击打开。\n3.完成上述以后，之后就可以通过双击打开软件了。")

                    Rectangle()
                        .fill(Color.gray.opacity(0.1))
                        .frame(height: 180)
                        .overlay(
                            Text("【图片占位】展示访达中打开应用流程")
                                .foregroundColor(.gray)
                        )
                }
                .font(.body)
            }

            Spacer()

            HStack {
                Spacer()

                Button("跳转至访达界面") {
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
