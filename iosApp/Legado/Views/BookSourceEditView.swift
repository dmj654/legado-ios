import SwiftUI

struct BookSourceEditView: View {
    let source: BookSourceModel
    let onSave: (BookSourceModel) -> Void
    @Environment(\.dismiss) private var dismiss

    @State private var sourceName: String
    @State private var sourceUrl: String
    @State private var sourceGroup: String
    @State private var sourceType: Int
    @State private var enabled: Bool
    @State private var searchUrl: String
    @State private var exploreUrl: String
    @State private var header: String
    @State private var comment: String

    init(source: BookSourceModel, onSave: @escaping (BookSourceModel) -> Void) {
        self.source = source
        self.onSave = onSave
        _sourceName = State(initialValue: source.sourceName)
        _sourceUrl = State(initialValue: source.sourceUrl)
        _sourceGroup = State(initialValue: source.sourceGroup ?? "")
        _sourceType = State(initialValue: source.sourceType)
        _enabled = State(initialValue: source.enabled)
        _searchUrl = State(initialValue: source.searchUrl ?? "")
        _exploreUrl = State(initialValue: source.exploreUrl ?? "")
        _header = State(initialValue: source.header ?? "")
        _comment = State(initialValue: source.comment ?? "")
    }

    var body: some View {
        NavigationView {
            Form {
                Section("基本信息") {
                    HStack {
                        Text("名称")
                        TextField("书源名称", text: $sourceName)
                            .multilineTextAlignment(.trailing)
                    }
                    HStack {
                        Text("地址")
                        TextField("书源地址", text: $sourceUrl)
                            .multilineTextAlignment(.trailing)
                            .autocapitalization(.none)
                    }
                    HStack {
                        Text("分组")
                        TextField("分组", text: $sourceGroup)
                            .multilineTextAlignment(.trailing)
                    }
                    Picker("类型", selection: $sourceType) {
                        Text("文本").tag(0)
                        Text("音频").tag(1)
                        Text("图片").tag(2)
                        Text("文件").tag(3)
                        Text("视频").tag(4)
                    }
                    Toggle("启用", isOn: $enabled)
                }

                Section("搜索") {
                    HStack {
                        Text("搜索URL")
                        TextField("搜索地址", text: $searchUrl)
                            .multilineTextAlignment(.trailing)
                            .autocapitalization(.none)
                    }
                }

                Section("发现") {
                    HStack {
                        Text("发现URL")
                        TextField("发现地址", text: $exploreUrl)
                            .multilineTextAlignment(.trailing)
                            .autocapitalization(.none)
                    }
                }

                Section("请求头") {
                    TextEditor(text: $header)
                        .frame(minHeight: 80)
                        .font(.system(size: 14))
                }

                Section("备注") {
                    TextEditor(text: $comment)
                        .frame(minHeight: 60)
                        .font(.system(size: 14))
                }
            }
            .navigationTitle("编辑书源")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        let updated = BookSourceModel(sourceUrl: sourceUrl, sourceName: sourceName)
                        updated.sourceGroup = sourceGroup.isEmpty ? nil : sourceGroup
                        updated.sourceType = sourceType
                        updated.enabled = enabled
                        updated.searchUrl = searchUrl.isEmpty ? nil : searchUrl
                        updated.exploreUrl = exploreUrl.isEmpty ? nil : exploreUrl
                        updated.header = header.isEmpty ? nil : header
                        updated.comment = comment.isEmpty ? nil : comment
                        onSave(updated)
                        dismiss()
                    }
                    .fontWeight(.bold)
                }
            }
        }
    }
}

#Preview {
    BookSourceEditView(source: BookSourceModel(sourceUrl: "https://example.com", sourceName: "示例书源")) { _ in }
}
