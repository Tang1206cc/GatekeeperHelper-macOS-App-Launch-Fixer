import AppKit

extension NSAlert {
    private func applySystemButtonStyle() {
        if #available(macOS 11.0, *) {
            for (index, button) in buttons.enumerated() {
                button.isBordered = true
                button.bezelStyle = .rounded
                button.controlSize = .large
                button.keyEquivalent = index == 0 ? "\r" : ""
                if index == 0 {
                    button.bezelColor = .controlAccentColor
                    button.contentTintColor = .white
                } else {
                    button.bezelColor = nil
                    button.contentTintColor = .labelColor
                }
            }
        } else {
            buttons.first?.keyEquivalent = "\r"
        }
    }

    @discardableResult
    func runModalWithSystemStyle() -> NSApplication.ModalResponse {
        applySystemButtonStyle()
        if !NSApp.isActive {
            NSApp.activate(ignoringOtherApps: true)
        }
        return runModal()
    }
}
