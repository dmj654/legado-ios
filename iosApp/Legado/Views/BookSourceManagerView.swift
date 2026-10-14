import SwiftUI

struct BookSourceManagerView: View {
    @State private var sources: [BookSourceModel] = []
    @State private var searchText = ""
    @State private var selectedGroup: String? = nil
    @State private var showImport = false
    @State private var importUrl = ""
    @State private var showEdit = false
    @State private var editingSource: BookSourceModel? = nil
    @State private var showDeleteConfirmation = false
    @State private var sourceToDelete: BookSourceModel? = nil

    private var groups: [String] {
        let set = Set(sources.compactMap { $0.sourceGroup }.filter { !$0.isEmpty })
        return Array(set).sorted()
    }

    private var filteredSources: [BookSourceModel] {
        var result = sources
        if let group = selectedGroup {
            result = result.filter { $0.sourceGroup == group }
        }
        if !searchText.isEmpty {
            result = result.filter {
                $0.sourceName.localizedCaseInsensitiveContains(searchText) ||
                $0.sourceUrl.localizedCaseInsensitiveContains(searchText)
            }
        }
        return result
    }

    private var enabledCount: Int { sources.filter { $0.enabled }.count }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                SearchBar(text: $searchText, placeholder: "搜索书源")
                    .padding(.horizontal)
                    .padding(.vertical, 8)

                if !groups.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            FilterChip(title: "全部(\(sources.count))", isSelected: selectedGroup == nil) {
                                selectedGroup = nil
                            }
                            ForEach(groups, id: \.self) { group in
                                FilterChip(title: group, isSelected: selectedGroup == group) {
                                    selectedGroup = selectedGroup == group ? nil : group
                                }
                            }
                        }
                        .padding(.horizontal, 12)
                    }
                    .padding(.bottom, 8)
                }

                HStack {
                    Text("共 \(sources.count) 个书源，启用 \(enabledCount) 个")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                    Menu {
                        Button(action: { enableAll(true) }) { Label("全部启用", systemImage: "checkmark.circle") }
                        Button(action: { enableAll(false) }) { Label("全部禁用", systemImage: "circle") }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)

                if filteredSources.isEmpty {
                    EmptyStateView(
                        icon: "square.stack.3d.up",
                        title: "还没有书源",
                        message: "导入书源后即可搜索小说，支持 legado 格式的 JSON 书源",
                        actionTitle: "导入书源",
                        action: { showImport = true }
                    )
                    Spacer()
                } else {
                    List {
                        ForEach(filteredSources) { source in
                            sourceRow(source)
                        }
                        .onDelete(perform: deleteSource)
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("书源管理")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: { showImport = true }) {
                            Label("网络导入", systemImage: "globe")
                        }
                        Button(action: {}) {
                            Label("本地导入", systemImage: "folder")
                        }
                        Button(action: {}) {
                            Label("导出书源", systemImage: "square.and.arrow.up")
                        }
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .alert("导入书源", isPresented: $showImport) {
                TextField("书源 JSON URL", text: $importUrl)
                Button("取消", role: .cancel) { }
                Button("导入") { importFromUrl() }
            } message: {
                Text("输入 legado 格式书源的网络地址")
            }
            .sheet(item: $editingSource) { source in
                BookSourceEditView(source: source) { updated in
                    saveSource(updated)
                }
            }
            .onAppear { loadSources() }
        }
        .navigationViewStyle(.stack)
    }

    private func sourceRow(_ source: BookSourceModel) -> some View {
        HStack {
            Toggle(isOn: Binding(
                get: { source.enabled },
                set: { newValue in
                    if let index = sources.firstIndex(where: { $0.sourceUrl == source.sourceUrl }) {
                        sources[index].enabled = newValue
                        StorageManager.shared.saveSource(sources[index])
                    }
                }
            )) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(source.sourceName)
                            .font(.headline)
                        if source.sourceType == 1 {
                            Text("音频")
                                .font(.caption2)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.orange.opacity(0.2))
                                .foregroundColor(.orange)
                                .cornerRadius(4)
                        } else if source.sourceType == 2 {
                            Text("图片")
                                .font(.caption2)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.purple.opacity(0.2))
                                .foregroundColor(.purple)
                                .cornerRadius(4)
                        }
                    }
                    if let group = source.sourceGroup, !group.isEmpty {
                        Text(group)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Text(source.sourceUrl)
                        .font(.caption2)
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }
            }
            .toggleStyle(.switch)
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
        .onTapGesture {
            editingSource = source
        }
        .contextMenu {
            Button(action: { editingSource = source }) {
                Label("编辑", systemImage: "pencil")
            }
            Button(action: {}) {
                Label("校验", systemImage: "checkmark.shield")
            }
            Button(role: .destructive, action: {
                sourceToDelete = source
                showDeleteConfirmation = true
            }) {
                Label("删除", systemImage: "trash")
            }
        }
    }

    private func loadSources() {
        sources = StorageManager.shared.fetchSources()
    }

    private func saveSource(_ source: BookSourceModel) {
        StorageManager.shared.saveSource(source)
        loadSources()
    }

    private func deleteSource(at offsets: IndexSet) {
        offsets.forEach { index in
            let source = filteredSources[index]
            StorageManager.shared.deleteSource(source)
        }
        loadSources()
    }

    private func enableAll(_ enabled: Bool) {
        for source in sources {
            source.enabled = enabled
            StorageManager.shared.saveSource(source)
        }
        loadSources()
    }

    private func importFromUrl() {
        guard !importUrl.isEmpty, let url = URL(string: importUrl) else { return }
        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data, let json = String(data: data, encoding: .utf8) {
                let count = StorageManager.shared.importSources(from: json)
                DispatchQueue.main.async {
                    loadSources()
                    importUrl = ""
                }
            }
        }.resume()
    }
}

#Preview {
    BookSourceManagerView()
}
