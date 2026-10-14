import SwiftUI

struct BookSourceManagerView: View {
    @State private var sources: [BookSource] = []
    @State private var showingImport = false
    @State private var importUrl = ""

    var body: some View {
        NavigationView {
            Group {
                if sources.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "square.stack.3d.up")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text("还没有书源")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        Text("导入书源后即可搜索小说")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Button("导入书源") {
                            showingImport = true
                        }
                        .buttonStyle(.borderedProminent)
                    }
                } else {
                    List {
                        ForEach($sources) { $source in
                            BookSourceRow(source: $source)
                        }
                        .onDelete(perform: deleteSource)
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("书源管理")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: { showingImport = true }) {
                            Label("网络导入", systemImage: "globe")
                        }
                        Button(action: {}) {
                            Label("本地导入", systemImage: "folder")
                        }
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .alert("导入书源", isPresented: $showingImport) {
                TextField("书源 URL", text: $importUrl)
                Button("取消", role: .cancel) { }
                Button("导入") {
                    importSource()
                }
            } message: {
                Text("输入书源 JSON 文件的网络地址")
            }
        }
    }

    private func importSource() {
        guard !importUrl.isEmpty else { return }
        // 调用 KMP shared 模块导入书源
        let newSource = BookSource(
            bookSourceUrl: importUrl,
            bookSourceName: "导入的书源",
            enabled: true
        )
        sources.append(newSource)
        importUrl = ""
    }

    private func deleteSource(at offsets: IndexSet) {
        sources.remove(atOffsets: offsets)
    }
}

struct BookSource: Identifiable {
    let id = UUID()
    var bookSourceUrl: String
    var bookSourceName: String
    var enabled: Bool
    var bookSourceGroup: String?
}

struct BookSourceRow: View {
    @Binding var source: BookSource

    var body: some View {
        HStack {
            Toggle(isOn: $source.enabled) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(source.bookSourceName)
                        .font(.headline)
                    if let group = source.bookSourceGroup, !group.isEmpty {
                        Text(group)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Text(source.bookSourceUrl)
                        .font(.caption2)
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }
            }
            .toggleStyle(.switch)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    BookSourceManagerView()
}
