import SwiftUI

@main
struct GatekeeperHelperApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @AppStorage("themeMode") private var themeMode = ThemeMode.system.rawValue

    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 1020, minHeight: 580)
                .preferredColorScheme(currentColorScheme)
                .macOS26RoundedWindowStyle()
        }
        .defaultSize(width: 1120, height: 775)
        .windowStyle(DefaultWindowStyle())
        .commands {
            CommandGroup(replacing: .appSettings) {
                Button("偏好设置…") {
                    NSApp.sendAction(#selector(AppDelegate.showPreferencesWindow(_:)), to: nil, from: nil)
                }
                .keyboardShortcut(",", modifiers: [.command])
            }
        }
    }

    private var currentColorScheme: ColorScheme? {
        switch ThemeMode(rawValue: themeMode) ?? .system {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}

