//
//  DropAreaView.swift
//  GatekeeperHelper
//
//  Created by 唐梓耀 on 2025/7/26.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers

struct DropAreaView: View {
    var allowedExtensions: [String] = ["app"]
    var instruction: String = "拖入或点按以选择需要修复的 App"
    var onAppPicked: (URL) -> Void

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .stroke(style: StrokeStyle(lineWidth: 2, dash: [6]))
                .foregroundColor(.gray)
                .background(Color.gray.opacity(0.05))
            
            VStack(spacing: 8) {
                Image(systemName: "plus.circle")
                    .font(.system(size: 32))
                    .foregroundColor(.accentColor)

                Text(instruction)
                    .font(.body)
                    .foregroundColor(.secondary)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            if let url = AppPicker.chooseApp(allowedExtensions: allowedExtensions) {
                onAppPicked(url)
            }
        }
        .onDrop(of: [UTType.fileURL], isTargeted: nil) { providers in
            providers.first?.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { item, _ in
                guard let data = item as? Data,
                      let url = URL(dataRepresentation: data, relativeTo: nil),
                      allowedExtensions.contains(url.pathExtension.lowercased()) else { return }
                DispatchQueue.main.async {
                    onAppPicked(url)
                }
            }
            return true
        }
    }
}
extension URL: Identifiable {
    public var id: String { self.absoluteString }
}
