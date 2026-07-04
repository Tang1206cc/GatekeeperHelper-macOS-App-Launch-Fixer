//
//  AppDelegate.swift
//  GatekeeperHelper
//
//  Created by 唐梓耀 on 2025/7/27.
//

import Cocoa
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    private var settingsWindow: NSWindow?
    private var escMonitor: Any?

    func applicationDidFinishLaunching(_ notification: Notification) {
        escMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            if event.keyCode == 53 && UserDefaults.standard.bool(forKey: "escToQuit") {
                NSApp.terminate(nil)
                return nil
            }
            return event
        }
        AppSettings.applyLaunchAtLogin(UserDefaults.standard.bool(forKey: "launchAtLogin"))

        // 保留的“最新方案”：递归本地化完整菜单
        if let mainMenu = NSApp.mainMenu {
            let appName = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String ?? ""
            let translations: [String: String] = [
                "File": "文件",
                "Edit": "编辑",
                "View": "查看",
                "Window": "窗口",
                "Help": "帮助",
                "About \(appName)": "关于 \(appName)",
                "Preferences…": "偏好设置…",
                "Preferences...": "偏好设置…",
                "Services": "服务",
                "Hide \(appName)": "隐藏 \(appName)",
                "Hide Others": "隐藏其他",
                "Show All": "显示全部",
                "Quit \(appName)": "退出 \(appName)",
                "Undo": "撤销",
                "Redo": "重做",
                "Cut": "剪切",
                "Copy": "复制",
                "Paste": "粘贴",
                "Paste and Match Style": "粘贴并匹配样式",
                "Delete": "删除",
                "Select All": "全选",
                "Find": "查找",
                "Find…": "查找…",
                "Find...": "查找…",
                "Find Next": "查找下一个",
                "Find Previous": "查找上一个",
                "Use Selection for Find": "用所选内容查找",
                "Start Dictation…": "开始听写…",
                "Start Dictation...": "开始听写…",
                "Emoji & Symbols": "表情与符号",
                "Emoji and Symbols": "表情与符号",
                "AutoFill": "自动填充",
                "Enter Full Screen": "进入全屏",
                "Minimize": "最小化",
                "Zoom": "缩放",
                "Bring All to Front": "全部置于顶层"
            ]
            localizeMenu(menu: mainMenu, translations: translations)
        }

        if AppSettings.shouldAutoCheckForUpdates {
            UpdateManager.shared.checkForUpdate(interactive: false)
        }
    }

    // 递归翻译菜单与子菜单
    private func localizeMenu(menu: NSMenu, translations: [String: String]) {
        for item in menu.items {
            if let title = translations[item.title] {
                item.title = title
            }
            if let submenu = item.submenu {
                localizeMenu(menu: submenu, translations: translations)
            }
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        if let monitor = escMonitor {
            NSEvent.removeMonitor(monitor)
        }
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return UserDefaults.standard.bool(forKey: "quitWhenLastWindowClosed")
    }

    @objc func showPreferencesWindow(_ sender: Any?) {
        if let window = settingsWindow {
            window.setContentSize(NSSize(width: 480, height: 320))
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        let window = NSWindow(
            contentRect: NSMakeRect(0, 0, 480, 320),
            styleMask: [.titled, .closable, .miniaturizable],
            backing: .buffered,
            defer: false
        )
        window.center()
        window.title = "偏好设置"
        window.isReleasedWhenClosed = false
        RoundedWindowStyleModifier.configure(window: window)
        window.contentView = NSHostingView(rootView: SettingsView())
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)

        self.settingsWindow = window
    }
}
