//
//  RepairHistory.swift
//  GatekeeperHelper
//
//  Created by 唐梓耀 on 2025/7/26.
//

import Foundation

struct RepairRecord: Identifiable, Codable {
    let id = UUID()
    let date: Date
    let appName: String
    let method: String
    let success: Bool
}

class RepairHistoryManager {
    static let shared = RepairHistoryManager()
    private let historyFileURL: URL

    private init() {
        let supportDir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let folder = supportDir.appendingPathComponent("GatekeeperHelper", isDirectory: true)
        try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        historyFileURL = folder.appendingPathComponent("repairHistory.json")
    }

    func loadHistory() -> [RepairRecord] {
        guard let data = try? Data(contentsOf: historyFileURL) else { return [] }
        return (try? JSONDecoder().decode([RepairRecord].self, from: data)) ?? []
    }

    func saveHistory(_ history: [RepairRecord]) {
        guard let data = try? JSONEncoder().encode(history) else { return }
        try? data.write(to: historyFileURL)
    }

    func addRecord(appName: String, method: String, success: Bool) {
        var history = loadHistory()
        history.insert(
            RepairRecord(date: Date(), appName: appName, method: method, success: success),
            at: 0
        )
        if history.count > 20 {
            history = Array(history.prefix(20))
        }
        saveHistory(history)
    }

    func clearHistory() {
        saveHistory([])
    }
}
