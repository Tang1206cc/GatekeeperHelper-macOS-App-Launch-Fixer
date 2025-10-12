import Foundation
import SwiftUI

struct HistorySheetView: View {
    @Environment(\.dismiss) var dismiss
    @State private var history: [RepairRecord] = RepairHistoryManager.shared.loadHistory()

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("最近修复记录")
                    .font(.title2)
                    .bold()
                Spacer()
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                        .imageScale(.large)
                }
                .buttonStyle(.plain)
            }

            ScrollView {
                if history.isEmpty {
                    Text("暂无记录")
                        .foregroundColor(.gray)
                        .padding(.top, 20)
                } else {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(history) { record in
                            HStack {
                                Text(formattedDate(record.date))
                                    .foregroundColor(.secondary)
                                    .frame(width: 130, alignment: .leading)

                                Text(record.appName)
                                    .font(.body)
                                    .frame(width: 160, alignment: .leading)

                                Text(record.method)
                                    .foregroundColor(.secondary)
                                    .frame(width: 100, alignment: .leading)

                                Text(record.success ? "修复成功" : "修复失败")
                                    .fontWeight(.bold)
                                    .foregroundColor(record.success ? .green : .red)
                            }
                            .padding(.vertical, 4)
                        }

                        Text("仅展示最近 20 条记录")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                            .padding(.top, 8)
                    }
                }
            }
            .frame(maxHeight: 300)

            Divider()

            HStack {
                Spacer()
                Button("清空记录") {
                    RepairHistoryManager.shared.clearHistory()
                    history = []
                }
                .foregroundColor(.red)
            }
        }
        .padding()
        .frame(width: 540, height: 440)
    }

    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        return formatter.string(from: date)
    }
}
