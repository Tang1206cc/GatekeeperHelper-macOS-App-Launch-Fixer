
//  ContentView.swift
//  GatekeeperHelper

import SwiftUI
import AppKit

enum UnlockMethod: CaseIterable {
    case xattr
    case spctl

    var description: String {
        switch self {
        case .xattr: return "临时绕过（推荐）"
        case .spctl: return "永久禁用 Gatekeeper（危险）"
        }
    }
}

struct UnlockIssue: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let description: String
    let imageName: String
}

let knownIssues: [UnlockIssue] = [
    UnlockIssue(
        title: "XXX已损坏，无法打开。您应该推出磁盘映像/移到废纸篓",
        description: "macOS 的 Gatekeeper 安全机制阻止了该应用打开。您可以选择临时绕过（推荐，仅解除当前 App 的限制），或永久禁用 Gatekeeper（不推荐，会降低系统安全性）。",
        imageName: "issue1",
    ),
    UnlockIssue(
        title: "XXX意外退出",
        description: "Apple 会定期发布安全补丁，吊销一些“特定”的数字签名。在没有证书的情况下运行应用程序会导致错误消息，并且应用程序意外退出。所以需要对应用或其Unix可执行文件进行签名，有时也需要关闭 SIP。",
        imageName: "issue2",
    ),
    UnlockIssue(
        title: "XXX软件打开失败",
        description: "这种情况是因为当前 App 包内的 Unix 可执行文件显示为白色的文本文稿，需要赋予其可执行权限，变成黑色的 Unix 可执行文件后即可正常启动应用程序。",
        imageName: "issue_3",
    ),
    UnlockIssue(
        title: "应用程序XXX无法打开",
        description: "macOS 的安全机制针对某些第三方 App 是“带壳”的，此时这些软件将提示“应用程序\"xxx\"无法打开”。通过引入第三方工具进行脱壳操作即可正常打开。",
        imageName: "issue4",
    ),
    UnlockIssue(
        title: "文件XXX.command无法执行，因为您没有正确的访问权限",
        description: "当你初次运行一个.command文件时，可能会出现访问权限不足而无法正常执行的情况，这种情况通过指令授予其执行权限就可以解决。",
        imageName: "issue5",
    ),
    UnlockIssue(
        title: "无法打开XXX，因为 Apple 无法检查其是否包含恶意软件",
        description: "由于在 Apple 中引入了对应用程序进行公证的强制性措施，macOS Catalina 及以上版本系统不允许您运行未经验证的应用程序，即使该应用程序已经添加开发者签名也是如此。这会导致应用程序无法运行。",
        imageName: "issue6",
    ),
    UnlockIssue(
        title: "Apple无法验证XXX是否包含可能危害 Mac 安全或泄漏隐私的恶意软件",
        description: "此问题是“无法打开“xxx”，因为 Apple 无法检查其是否包含恶意软件”的另一种表述。macOS Catalina 及更高版本要求App 必须通过 Apple 的公证（Notarization）验证，未通过验证会提示类似此警告，解决方法与前者相同。",
        imageName: "issue7",
    ),
    UnlockIssue(
        title: "无法打开XXX，因为它不是从 App Store下载",
        description: "如果 Mac 是全新的或从未更改过软件安装安全性设置，其默认设置是仅允许安装来自「App Store 」的软件。而你正在安装的软件是从浏览器或其他第三方下载的时，就会看到这一警告信息。",
        imageName: "issue8",
    ),
    UnlockIssue(
        title: "无法打开XXX，因为无法验证开发者",
        description: "即便你的Mac已经允许安装App Store和已知开发者的应用，但当你尝试安装的某些App时，可能也还会看到此类警告。",
        imageName: "issue9",
    ),
    UnlockIssue(
        title: "无法打开XXX，因为“安全策略”已设为“某某安全性”",
        description: "此问题常出现在安装某些涉及较高权限的App或非正版App时，需要进入Mac恢复模式才能进行修改，并且一般情况下不建议进行修改。",
        imageName: "issue10",
    ),
    UnlockIssue(
        title: "未能打开磁盘映像。磁盘映像格式已过时。请使用命令行工具“hdiutil”将其转换为新格式",
        description: "此问题常出现在版本较旧的macOS中，通常来说问题并不出在磁盘映像本身，通过系统自带的“磁盘工具”应用程序打开此磁盘映像即可。",
        imageName: "issue11",
    ),
    UnlockIssue(
        title: "启动软件时一直弹窗输入密码或存储密码/钥匙串",
        description: "有些时候macOS的“密码/钥匙串”功能会出现崩溃或报错，而导致启动某些App时频繁弹窗提示存储钥匙串，大多数情况下进入访达清空对应软件的钥匙串文件就可解决这一问题。",
        imageName: "issue12",
    ),
    UnlockIssue(
        title: "安装 Adobe软件时运行 Install文件后报错",
        description: "当你下载完毕Adobe家族的软件，准备安装而点击dmg（或安装包）内的“Install”文件时，出现“Error”“The installation cannot continue as the installer file may be damaged. Download the installer file again.”的报错时可以尝试下面方法。",
        imageName: "issue13",
    ),
]


struct ContentView: View {
    @State private var selectedIssue: UnlockIssue? = knownIssues.first
    @State private var selectedAppURL: URL? = nil
    @State private var selectedUnlockMethod: UnlockMethod = .xattr

    @State private var showSIPSheet = false
    @State private var showDonateSheet = false
    @State private var showFeedbackSheet = false
    @State private var showSettingsSheet = false
    @State private var showHistorySheet = false
    @State private var showMalwareFixSheet = false
    @State private var showAppStoreFixSheet = false
    @State private var showUnverifiedDeveloperFixSheet = false
    @State private var showDiskImageFixSheet = false
    @State private var showSecurityPolicyFixSheet = false
    @State private var showKeychainFixSheet = false
    @State private var showAdobeInstallFixSheet = false

    var body: some View {
        GeometryReader { _ in
            VStack(spacing: 0) {
                HStack(alignment: .center) {
                    Text("请选择您遇到的 App 启动问题")
                        .font(.title2)
                        .bold()
                        .frame(height: 28)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Spacer()

                    Button("历史记录") {
                        showHistorySheet = true
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)
                    .padding(.trailing, 4)

                    HStack(spacing: 8) {
                        Button("捐赠作者") { showDonateSheet = true }
                        Button("联系&反馈") { showFeedbackSheet = true }
                        Button(action: {
                            NSApp.sendAction(#selector(AppDelegate.showPreferencesWindow(_:)), to: nil, from: nil)
                        }) {
                            Image(systemName: "gear")
                                .imageScale(.medium)
                        }
                    }
                    .font(.system(size: 13))
                    .buttonStyle(.plain)
                    .padding(.horizontal, 6)
                }
                .frame(height: 40)
                .padding(.horizontal, 24)
                .padding(.top, 12)

                Divider()

                HStack(spacing: 0) {
                    List(selection: $selectedIssue) {
                        ForEach(knownIssues) { issue in
                            Text(issue.title)
                                .font(.system(size: 15, weight: .semibold))
                                .padding(.vertical, 8)
                                .padding(.horizontal, 12)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(selectedIssue == issue ? Color.accentColor.opacity(0.2) : Color.clear)
                                )
                                .contentShape(Rectangle())
                                .tag(issue)
                        }
                    }
                    .frame(minWidth: 280)
                    .listStyle(SidebarListStyle())

                    Divider()

                    VStack(alignment: .leading, spacing: 16) {
                        if let issue = selectedIssue {
                            if issue.title == "无法打开XXX，因为 Apple 无法检查其是否包含恶意软件" || issue.title == "Apple无法验证XXX是否包含可能危害 Mac 安全或泄漏隐私的恶意软件" {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(issue.title)
                                        .font(.title2)
                                        .bold()
                                    ScrollView {
                                        Text("　　" + issue.description)
                                            .font(.body)
                                            .fixedSize(horizontal: false, vertical: true)
                                    }
                                    .frame(minHeight: 0, maxHeight: 120)

                                    Image(issue.imageName)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: issue.title == "启动软件时一直弹窗输入密码或存储密码/钥匙串" || issue.title == "安装 Adobe软件时运行 Install文件后报错" ? 170 : 220)
                                        .frame(maxWidth: .infinity)

                                    Divider()

                                    HStack {
                                        Spacer()
                                        HStack {
    Spacer()
    VStack {
        Spacer()
        Button(action: {
            showMalwareFixSheet = true
        }) {
            Text("查看解决方案")
                .font(.system(size: 16, weight: .semibold))
                .frame(minWidth: 180)
        }
        .padding()
        .background(Color.accentColor.opacity(0.12))
        .cornerRadius(10)
        Spacer()
    }
    Spacer()
}
                                        .padding()
                                        .background(Color.accentColor.opacity(0.1))
                                        .cornerRadius(8)
                                        Spacer()
                                    }
                                }
                                .padding(.top, 6)
                                .sheet(isPresented: $showMalwareFixSheet) {
                                    let sheetTitle = issue.title == "无法打开XXX，因为 Apple 无法检查其是否包含恶意软件" ?
                                        "解决方案：无法打开 App，因为 Apple 无法检查其是否包含恶意软件" :
                                        "解决方案：Apple无法验证App是否包含可能危害 Mac 安全或泄漏隐私的恶意软件"
                                    MalwareCheckFixView(title: sheetTitle) {
                                        showMalwareFixSheet = false
                                    }
                                }
                            } else if issue.title == "无法打开XXX，因为它不是从 App Store下载" {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(issue.title)
                                        .font(.title2)
                                        .bold()
                                    ScrollView {
                                        Text("　　" + issue.description)
                                            .font(.body)
                                            .fixedSize(horizontal: false, vertical: true)
                                    }
                                    .frame(minHeight: 0, maxHeight: 120)

                                    Image(issue.imageName)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: issue.title == "启动软件时一直弹窗输入密码或存储密码/钥匙串" || issue.title == "安装 Adobe软件时运行 Install文件后报错" ? 170 : 220)
                                        .frame(maxWidth: .infinity)

                                    Divider()

                                    HStack {
                                        Spacer()
                                        HStack {
    Spacer()
    VStack {
        Spacer()
        Button(action: {
            showAppStoreFixSheet = true
        }) {
            Text("查看解决方案")
                .font(.system(size: 16, weight: .semibold))
                .frame(minWidth: 180)
        }
        .padding()
        .background(Color.accentColor.opacity(0.12))
        .cornerRadius(10)
        Spacer()
    }
    Spacer()
}
                                        .padding()
                                        .background(Color.accentColor.opacity(0.1))
                                        .cornerRadius(8)
                                        Spacer()
                                    }
                                }
                                .padding(.top, 6)
                                .sheet(isPresented: $showAppStoreFixSheet) {
                                    AppStoreFixView {
                                        showAppStoreFixSheet = false
                                    }
                                }
                            } else if issue.title == "无法打开XXX，因为无法验证开发者" {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(issue.title)
                                        .font(.title2)
                                        .bold()
                                    ScrollView {
                                        Text("　　" + issue.description)
                                            .font(.body)
                                            .fixedSize(horizontal: false, vertical: true)
                                    }
                                    .frame(minHeight: 0, maxHeight: 120)

                                    Image(issue.imageName)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: issue.title == "启动软件时一直弹窗输入密码或存储密码/钥匙串" || issue.title == "安装 Adobe软件时运行 Install文件后报错" ? 170 : 220)
                                        .frame(maxWidth: .infinity)

                                    Divider()

                                    HStack {
                                        Spacer()
                                        HStack {
    Spacer()
    VStack {
        Spacer()
        Button(action: {
            showUnverifiedDeveloperFixSheet = true
        }) {
            Text("查看解决方案")
                .font(.system(size: 16, weight: .semibold))
                .frame(minWidth: 180)
        }
        .padding()
        .background(Color.accentColor.opacity(0.12))
        .cornerRadius(10)
        Spacer()
    }
    Spacer()
}
                                        .padding()
                                        .background(Color.accentColor.opacity(0.1))
                                        .cornerRadius(8)
                                        Spacer()
                                    }
                                }
                                .padding(.top, 6)
                                .sheet(isPresented: $showUnverifiedDeveloperFixSheet) {
                                    UnverifiedDeveloperFixView {
                                        showUnverifiedDeveloperFixSheet = false
                                    }
                                }
                            } else if issue.title == "未能打开磁盘映像。磁盘映像格式已过时。请使用命令行工具“hdiutil”将其转换为新格式" {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(issue.title)
                                        .font(.title2)
                                        .bold()
                                    ScrollView {
                                        Text("　　" + issue.description)
                                            .font(.body)
                                            .fixedSize(horizontal: false, vertical: true)
                                    }
                                    .frame(minHeight: 0, maxHeight: 120)

                                    Image(issue.imageName)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: issue.title == "启动软件时一直弹窗输入密码或存储密码/钥匙串" || issue.title == "安装 Adobe软件时运行 Install文件后报错" ? 170 : 220)
                                        .frame(maxWidth: .infinity)

                                    Divider()

                                    HStack {
                                        Spacer()
                                        HStack {
    Spacer()
    VStack {
        Spacer()
        Button(action: {
            showDiskImageFixSheet = true
        }) {
            Text("查看解决方案")
                .font(.system(size: 16, weight: .semibold))
                .frame(minWidth: 180)
        }
        .padding()
        .background(Color.accentColor.opacity(0.12))
        .cornerRadius(10)
        Spacer()
    }
    Spacer()
}
                                        .padding()
                                        .background(Color.accentColor.opacity(0.1))
                                        .cornerRadius(8)
                                        Spacer()
                                    }
                                }
                                .padding(.top, 6)
                            .sheet(isPresented: $showDiskImageFixSheet) {
                                DiskImageFixView {
                                    showDiskImageFixSheet = false
                                }
                            }
                            } else if issue.title == "无法打开XXX，因为“安全策略”已设为“某某安全性”" {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(issue.title)
                                        .font(.title2)
                                        .bold()
                                    ScrollView {
                                        Text("　　" + issue.description)
                                            .font(.body)
                                            .fixedSize(horizontal: false, vertical: true)
                                    }
                                    .frame(minHeight: 0, maxHeight: 120)

                                    Image(issue.imageName)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: issue.title == "启动软件时一直弹窗输入密码或存储密码/钥匙串" || issue.title == "安装 Adobe软件时运行 Install文件后报错" ? 170 : 220)
                                        .frame(maxWidth: .infinity)

                                    Divider()

                                    HStack {
                                        Spacer()
                                        HStack {
    Spacer()
    VStack {
        Spacer()
        Button(action: {
            showSecurityPolicyFixSheet = true
        }) {
            Text("查看解决方案")
                .font(.system(size: 16, weight: .semibold))
                .frame(minWidth: 180)
        }
        .padding()
        .background(Color.accentColor.opacity(0.12))
        .cornerRadius(10)
        Spacer()
    }
    Spacer()
}
                                        .padding()
                                        .background(Color.accentColor.opacity(0.1))
                                        .cornerRadius(8)
                                        Spacer()
                                    }
                                }
                                .padding(.top, 6)
                            .sheet(isPresented: $showSecurityPolicyFixSheet) {
                                SecurityPolicyFixView {
                                    showSecurityPolicyFixSheet = false
                                }
                            }
                            } else if issue.title == "启动软件时一直弹窗输入密码或存储密码/钥匙串" {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(issue.title)
                                        .font(.title2)
                                        .bold()
                                    ScrollView {
                                        Text("　　" + issue.description)
                                            .font(.body)
                                            .fixedSize(horizontal: false, vertical: true)
                                    }
                                    .frame(minHeight: 0, maxHeight: 120)

                                    Image(issue.imageName)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: issue.title == "启动软件时一直弹窗输入密码或存储密码/钥匙串" || issue.title == "安装 Adobe软件时运行 Install文件后报错" ? 170 : 220)
                                        .frame(maxWidth: .infinity)

                                    Divider()

                                    HStack {
                                        Spacer()
                                        HStack {
    Spacer()
    VStack {
        Spacer()
        Button(action: {
            showKeychainFixSheet = true
        }) {
            Text("查看解决方案")
                .font(.system(size: 16, weight: .semibold))
                .frame(minWidth: 180)
        }
        .padding()
        .background(Color.accentColor.opacity(0.12))
        .cornerRadius(10)
        Spacer()
    }
    Spacer()
}
                                        .padding()
                                        .background(Color.accentColor.opacity(0.1))
                                        .cornerRadius(8)
                                        Spacer()
                                    }
                                }
                                .padding(.top, 6)
                                .sheet(isPresented: $showKeychainFixSheet) {
                                    KeychainFixView {
                                        showKeychainFixSheet = false
                                    }
                                }
                            } else if issue.title == "安装 Adobe软件时运行 Install文件后报错" {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(issue.title)
                                        .font(.title2)
                                        .bold()
                                    ScrollView {
                                        Text("　　" + issue.description)
                                            .font(.body)
                                            .fixedSize(horizontal: false, vertical: true)
                                    }
                                    .frame(minHeight: 0, maxHeight: 120)

                                    Image(issue.imageName)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: issue.title == "启动软件时一直弹窗输入密码或存储密码/钥匙串" || issue.title == "安装 Adobe软件时运行 Install文件后报错" ? 170 : 220)
                                        .frame(maxWidth: .infinity)

                                    Divider()

                                    HStack {
                                        Spacer()
                                        HStack {
    Spacer()
    VStack {
        Spacer()
        Button(action: {
            showAdobeInstallFixSheet = true
        }) {
            Text("查看解决方案")
                .font(.system(size: 16, weight: .semibold))
                .frame(minWidth: 180)
        }
        .padding()
        .background(Color.accentColor.opacity(0.12))
        .cornerRadius(10)
        Spacer()
    }
    Spacer()
}
                                        .padding()
                                        .background(Color.accentColor.opacity(0.1))
                                        .cornerRadius(8)
                                        Spacer()
                                    }
                                }
                                .padding(.top, 6)
                                .sheet(isPresented: $showAdobeInstallFixSheet) {
                                    AdobeInstallFixView {
                                        showAdobeInstallFixSheet = false
                                    }
                                }
                            } else {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(issue.title)
                                        .font(.title2)
                                        .bold()
                                        .layoutPriority(1)

                                    ScrollView {
                                        Text("　　" + issue.description)
                                            .font(.body)
                                            .fixedSize(horizontal: false, vertical: true)
                                    }
                                    .frame(minHeight: 0, maxHeight: 120)

                                    Image(issue.imageName)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: issue.title == "启动软件时一直弹窗输入密码或存储密码/钥匙串" || issue.title == "安装 Adobe软件时运行 Install文件后报错" ? 170 : issue.title == "XXX已损坏，无法打开。您应该推出磁盘映像/移到废纸篓" ? 180 : 220)
                                        .frame(maxWidth: .infinity)

                                    Divider()

                                    if issue.title == "XXX已损坏，无法打开。您应该推出磁盘映像/移到废纸篓" {
                                        HStack(spacing: 8) {
                                            Image(systemName: "shield.lefthalf.filled")
                                                .imageScale(.medium)
                                                .foregroundColor(.blue)
                                            Text("如果你之前使用过“永久禁用”选项，可一键恢复 Gatekeeper：")
                                                .font(.callout)
                                                .foregroundColor(.secondary)
                                                .lineLimit(nil)
                                                .fixedSize(horizontal: false, vertical: true)
                                                .layoutPriority(1)
                                            Spacer()
                                            Button("恢复 Gatekeeper") {
                                                Unlocker.restoreGatekeeper()
                                            }
                                            .font(.system(size: 13, weight: .semibold))
                                            .padding(.vertical, 4)
                                            .padding(.horizontal, 10)
                                            .background(Color.blue.opacity(0.1))
                                            .cornerRadius(6)
                                        }
                                        .padding(.vertical, 2)
                                    }

                                    DropAreaView(
                                        allowedExtensions: selectedIssue?.title == "文件XXX.command无法执行，因为您没有正确的访问权限" ? ["command"] : ["app"],
                                        instruction: selectedIssue?.title == "文件XXX.command无法执行，因为您没有正确的访问权限" ? "拖入或点按以选择需要修复的.command文件" : "拖入或点按以选择需要修复的 App"
                                    ) { url in
                                        selectedAppURL = url
                                    }
                                    .frame(height: 180)
                                    .padding(.top, 10)
                                    .sheet(item: $selectedAppURL) { url in
                                        if selectedIssue?.title == "应用程序XXX无法打开" {
                                            UPXFixModalView(appURL: url)
                                        } else {
                                            FixAppModalView(
                                                appURL: url,
                                                issue: selectedIssue ?? knownIssues[0],
                                                selectedMethod: $selectedUnlockMethod
                                            )
                                        }
                                    }
                                }
                            }
                        } else {
                            Text("请选择左侧的问题类型")
                                .foregroundColor(.gray)
                        }

                        Spacer()

                        HStack {
                            Spacer()
                            Text("如果这些都没用，请点击：")
                                .foregroundColor(.secondary)
                            Button("关闭 SIP") {
                                showSIPSheet = true
                            }
                            .font(.system(size: 13, weight: .semibold))
                            .padding(.vertical, 4)
                            .padding(.horizontal, 8)
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(6)
                        }
                        .padding(.trailing, 12)
                        .padding(.bottom, 12)

                        Text("部分信息与素材转载于https://foxirj.com及其他网站。GatekeeperHelper开源免费，仅供学习交流，侵权请联系删除。")
                            .font(.footnote)
                            .foregroundColor(.gray)
                            .lineLimit(1)
                            .multilineTextAlignment(.trailing)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .padding(.bottom, 12)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(minWidth: 960, minHeight: 640)
        }
        .sheet(isPresented: $showSIPSheet) {
            SheetWrapperView(title: "关闭 SIP") {
                showSIPSheet = false
            }
        }
        .sheet(isPresented: $showDonateSheet) {
            SheetWrapperView(title: "捐赠作者") {
                showDonateSheet = false
            }
        }
        .sheet(isPresented: $showFeedbackSheet) {
            SheetWrapperView(title: "联系&反馈") {
                showFeedbackSheet = false
            }
        }
        .sheet(isPresented: $showHistorySheet) {
            HistorySheetView()
        }
        .sheet(isPresented: $showSettingsSheet) {
            SheetWrapperView(title: "设置界面（待补充）") {
                showSettingsSheet = false
            }
        }
    }
}
