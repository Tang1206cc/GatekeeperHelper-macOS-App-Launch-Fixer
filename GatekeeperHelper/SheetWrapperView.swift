//
//  SheetWrapperView.swift
//  GatekeeperHelper
//

import SwiftUI

struct SheetWrapperView: View {
    let title: String
    let onClose: () -> Void

    @StateObject private var sipChecker = SIPStatusChecker()

    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack {
                if title.contains("捐赠") {
                    // ✅ 捐赠弹窗内容
                    VStack(spacing: 16) {
                        Text("感谢您的支持 ❤️")
                            .font(.title2)
                            .bold()
                            .padding(.top, 16)

                        Text("""
                        您的鼓励是我持续优化 GatekeeperHelper 的最大动力！

                        如果这个工具对您有所帮助，欢迎通过以下方式打赏支持。
                        """)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)

                        HStack(spacing: 32) {
                            VStack(spacing: 8) {
                                Image("donation_wechat")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 120, height: 120)
                                Text("微信")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }

                            VStack(spacing: 8) {
                                Image("donation_alipay")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 120, height: 120)
                                Text("支付宝")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.top, 8)

                        Spacer(minLength: 12)
                    }

                } else if title.contains("关闭 SIP") {
                    // ✅ 关闭 SIP 弹窗内容
                    ScrollView {
                        VStack(alignment: .leading, spacing: 18) {
                            Text("关闭系统完整性保护（SIP）")
                                .font(.title2)
                                .bold()

                            Text("⚠️ 请谨慎操作！非必要不要关闭 SIP。")
                                .font(.body)
                                .foregroundColor(.red)
                                .bold()

                            Text("确保您是在主页所有选项都尝试过后仍然无法解决 App 启动问题，才使用此方法。")
                                .foregroundColor(.secondary)

                            Divider()

                            Text("📘 什么是 SIP？")
                                .font(.headline)
                            Text("SIP（System Integrity Protection）是 Apple 自 OS X 10.11 起引入的一项安全机制，用于防止恶意软件修改系统文件。关闭 SIP 后，您将获得对 macOS 系统更深层级的控制权限，但也会增加系统风险。")

                            Divider()

                            Text("📌 为什么要关闭 SIP？")
                                .font(.headline)
                            Text("""
在 macOS 11 Big Sur 之前，关闭 SIP 可用于降级或删除预装 App（如 iTunes、Safari 等）。现在，它主要用于让部分修改过的 App（如破解软件、未签名工具）正常运行。

如果您的 App 无法通过 xattr 或 codesign 解锁，请尝试关闭 SIP。
""")

                            Divider()

                            Text("🔍 如何判断当前是否关闭 SIP？")
                                .font(.headline)

                            HStack {
                                Button("一键判断") {
                                    sipChecker.checkStatus()
                                }

                                Text(sipChecker.getStatusSymbol())
                                    .font(.body)
                                    .foregroundColor(.secondary)
                                    .padding(.leading, 6)
                            }

                            CodeBlock(command: "csrutil status")

                            Divider()

                            Text("❌ 如何关闭 SIP")
                                .font(.headline)

                            Text("注意：必须进入“恢复模式”才能关闭 SIP，且操作中可能需要输入 y/n 确认，务必仔细阅读终端提示。")

                            Text("🔧 步骤：")
                                .bold()

                            Text("""
1）进入恢复模式：
   - Intel 机型：重启时按住 Command + R，直到出现 Apple 标志。
   - Apple Silicon 机型：关机后，长按电源按钮直到出现“选项”，进入恢复模式。

2）在菜单栏选择“实用工具” > 打开“终端”

3）执行以下命令：
""")
                            CodeBlock(command: "csrutil disable")

                            Text("如果提示 [y/n]，请输入 y 并回车；提示Password或出现小钥匙图标时输入电脑开机密码即可，输入过程不可见，确保正确输入后按下回车键即可。")

                            Text("4）重启电脑以完成操作：")
                            CodeBlock(command: "reboot")

                            Divider()

                            Text("✅ 如何重新开启 SIP")
                                .font(.headline)

                            Text("""
重复步骤1-2后，在“终端”输入以下命令：

如果提示 [y/n]，同样输入 y 并回车。
""")
                            CodeBlock(command: "csrutil enable")

                            Text("然后再次执行：")
                            CodeBlock(command: "reboot")

                            Divider()

                            Text("⚠️ 没有特殊需要，不要禁用 SIP！")
                                .font(.headline)
                                .foregroundColor(.red)
                                .bold()
                        }
                        .padding()
                    }

                } else if title.contains("联系") || title.contains("反馈") {
                    // ✅ 联系与反馈弹窗内容
                    VStack(alignment: .leading, spacing: 16) {
                        Text("联系与反馈")
                            .font(.title2)
                            .bold()

                        Text("如果您在使用过程中遇到问题，或有任何建议，欢迎通过以下方式联系我：")
                            .font(.body)
                            .foregroundColor(.secondary)

                        Divider()

                        VStack(alignment: .leading, spacing: 10) {
                            Label("B站：智影逐风（UID:3632305813850646）「点击可打开」", systemImage: "play.rectangle.fill")
                                .onTapGesture {
                                    if let url = URL(string: "https://b23.tv/t5x24uV") {
                                        NSWorkspace.shared.open(url)
                                    }
                                }//链接到bilibili个人主页
                            Label("邮箱：1767707905@qq.com", systemImage: "envelope")
                            Label("QQ 讨论群：850780538", systemImage: "message")
                            Label("GitHub 项目仓库：https://github.com/Tang1206cc/GatekeeperHelper-macOS-App-Launch-Fixer", systemImage: "link")
                                .onTapGesture {
                                    if let url = URL(string: "https://github.com/Tang1206cc/GatekeeperHelper-macOS-App-Launch-Fixer") {
                                        NSWorkspace.shared.open(url)
                                    }
                                }//链接到GitHub对应仓库
                        }
                        .font(.body)

                        Spacer()
                    }
                    .padding()

                } else {
                    VStack(alignment: .leading, spacing: 16) {
                        Text(title)
                            .font(.title3)
                            .bold()
                        Spacer()
                    }
                    .padding()
                }
            }
            .frame(width: 520, height: 460)
            .background(Color(NSColor.windowBackgroundColor))
            .clipShape(RoundedRectangle(cornerRadius: 12))

            // 通用关闭按钮
            Button(action: onClose) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.secondary)
                    .imageScale(.large)
                    .padding(10)
            }
            .buttonStyle(.plain)
        }
    }
}

#Preview {
    SheetWrapperView(title: "联系&反馈") {}
}
