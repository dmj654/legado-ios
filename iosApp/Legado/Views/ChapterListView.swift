import SwiftUI

struct ChapterListView: View {
    let book: BookModel
    let currentIndex: Int
    let onSelect: (Int) -> Void

    @State private var searchText = ""
    @State private var isReversed = false
    @State private var chapters: [ChapterModel] = []

    private var filteredChapters: [ChapterModel] {
        var result = chapters
        if !searchText.isEmpty {
            result = result.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
        }
        if isReversed {
            result.reverse()
        }
        return result
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                SearchBar(text: $searchText, placeholder: "搜索章节")
                    .padding(.horizontal)
                    .padding(.vertical, 8)

                HStack {
                    Text("共 \(chapters.count) 章")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                    Button(action: { isReversed.toggle() }) {
                        Label(isReversed ? "正序" : "倒序", systemImage: isReversed ? "arrow.up" : "arrow.down")
                            .font(.subheadline)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)

                List {
                    ForEach(filteredChapters) { chapter in
                        Button(action: { onSelect(chapter.index) }) {
                            HStack {
                                if chapter.isVolume {
                                    Image(systemName: "folder")
                                        .foregroundColor(.orange)
                                }
                                Text(chapter.title)
                                    .font(.body)
                                    .foregroundColor(chapter.index == currentIndex ? .blue : .primary)
                                    .lineLimit(1)
                                Spacer()
                                if chapter.index == currentIndex {
                                    Image(systemName: "book.fill")
                                        .foregroundColor(.blue)
                                }
                                if chapter.isRead {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                        .font(.caption)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
                .listStyle(.plain)
            }
            .navigationTitle("目录")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("跳转当前") {
                        onSelect(currentIndex)
                    }
                    .font(.subheadline)
                }
            }
        }
        .navigationViewStyle(.stack)
        .onAppear {
            chapters = StorageManager.shared.fetchChapters(bookUrl: book.bookUrl)
            if chapters.isEmpty {
                for i in 0..<20 {
                    chapters.append(ChapterModel(bookUrl: book.bookUrl, index: i, title: "第\(i + 1)章 示例章节"))
                }
            }
        }
    }
}

#Preview {
    ChapterListView(book: BookModel(bookUrl: "test", name: "test"), currentIndex: 0) { _ in }
}
