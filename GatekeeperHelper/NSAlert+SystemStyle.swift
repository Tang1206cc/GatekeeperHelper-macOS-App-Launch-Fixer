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
                } else {
                    button.bezelColor = nil
                }
            }
        } else {
            buttons.first?.keyEquivalent = "\r"
        }

        for (index, button) in buttons.enumerated() {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = button.alignment
            let textColor: NSColor = index == 0 ? .white : .labelColor
            let attributes: [NSAttributedString.Key: Any] = [
                .foregroundColor: textColor,
                .paragraphStyle: paragraphStyle
            ]
            let attributedTitle = NSAttributedString(string: button.title, attributes: attributes)
            button.attributedTitle = attributedTitle
            button.attributedAlternateTitle = attributedTitle
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
