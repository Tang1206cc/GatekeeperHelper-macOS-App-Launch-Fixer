import SwiftUI
import AppKit

private struct RoundedWindowConfigurator: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        DispatchQueue.main.async {
            if let window = view.window {
                RoundedWindowStyleModifier.configure(window: window)
            }
        }
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        DispatchQueue.main.async {
            if let window = nsView.window {
                RoundedWindowStyleModifier.configure(window: window)
            }
        }
    }
}

struct RoundedWindowStyleModifier: ViewModifier {
    func body(content: Content) -> some View {
        content.background(RoundedWindowConfigurator())
    }

    static func configure(window: NSWindow) {
        window.titlebarAppearsTransparent = true
        window.styleMask.insert(.fullSizeContentView)
        window.isMovableByWindowBackground = true
        if #available(macOS 11.0, *) {
            window.toolbarStyle = .expanded
        }
        window.invalidateShadow()
    }
}

extension View {
    func macOS26RoundedWindowStyle() -> some View {
        modifier(RoundedWindowStyleModifier())
    }
}
