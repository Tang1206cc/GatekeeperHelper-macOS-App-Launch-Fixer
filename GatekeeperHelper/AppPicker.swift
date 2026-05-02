//
//  AppPicker.swift
//  GatekeeperHelper
//
//  Created by 唐梓耀 on 2025/7/24.
//

import Foundation
import AppKit

struct AppPicker {
    static func chooseApp(allowedExtensions: [String] = ["app"]) -> URL? {
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = allowedExtensions.contains("app")
        panel.allowsMultipleSelection = false
        panel.allowedFileTypes = allowedExtensions
        panel.allowsOtherFileTypes = false

        return panel.runModal() == .OK ? panel.url : nil
    }
}
