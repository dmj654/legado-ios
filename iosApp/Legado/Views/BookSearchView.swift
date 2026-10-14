import SwiftUI

struct BookSearchView: View {
    @State private var keyword = ""
    @State private var isSearching = false
    @State private var results: [SearchResult] = []
    @State private var searchHistory: [String] = []

    var body: some View {
        NavigationView {
            VStack {
                SearchBar(text: $keyword, onSearch: performSearch)
                    .padding(.horizontal)

                if isSearching {
                    ProgressView("正在搜索...")
                        .padding()
                } else if !results.isEmpty {
                    List(results) { result in
                        SearchResultRow(result: result)
                    }
                    .listStyle(.plain)
                } else if !searchHistory.isEmpty {
                    List {
                        Section("搜索历史") {
                            ForEach(searchHistory, id: \.self) { history in
                                Button(action: {
                                    keyword = history
                                    performSearch()
                                }) {
                                    HStack {
                                        Image(systemName: "clock.arrow.circlepath")
                                            .foregroundColor(.gray)
                                        Text(history)
                                    }
                                }
                            }
                        }
                    }
                    .listStyle(.plain)
                } else {
                    Spacer()
                    VStack(spacing: 12) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        Text("输入书名开始搜索")
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                }
            }
            .navigationTitle("搜索")
        }
    }

    private func performSearch() {
        guard !keyword.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        isSearching = true
        searchHistory.insert(keyword, at: 0)
        if searchHistory.count > 20 {
            searchHistory.removeLast()
        }

        // 模拟搜索结果（实际调用 KMP shared 模块）
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            results = [
                SearchResult(title: "\(keyword)（示例结果1）", author: "作者A", source: "示例书源", lastChapter: "第100章"),
                SearchResult(title: "\(keyword)（示例结果2）", author: "作者B", source: "示例书源2", lastChapter: "第50章"),
                SearchResult(title: "\(keyword)（示例结果3）", author: "作者C", source: "示例书源3", lastChapter: "第200章")
            ]
            isSearching = false
        }
    }
}

struct SearchBar: UIViewRepresentable {
    @Binding var text: String
    var onSearch: () -> Void

    func makeUIView(context: Context) -> UISearchBar {
        let searchBar = UISearchBar(frame: .zero)
        searchBar.delegate = context.coordinator
        searchBar.placeholder = "搜索书名"
        searchBar.searchBarStyle = .minimal
        return searchBar
    }

    func updateUIView(_ uiView: UISearchBar, context: Context) {
        uiView.text = text
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text, onSearch: onSearch)
    }

    class Coordinator: NSObject, UISearchBarDelegate {
        @Binding var text: String
        var onSearch: () -> Void

        init(text: Binding<String>, onSearch: @escaping () -> Void) {
            _text = text
            self.onSearch = onSearch
        }

        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            text = searchText
        }

        func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
            searchBar.resignFirstResponder()
            onSearch()
        }
    }
}

struct SearchResult: Identifiable {
    let id = UUID()
    let title: String
    let author: String
    let source: String
    let lastChapter: String
}

struct SearchResultRow: View {
    let result: SearchResult

    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 6)
                .fill(LinearGradient(colors: [.blue.opacity(0.4), .purple.opacity(0.4)], startPoint: .top, endPoint: .bottom))
                .frame(width: 60, height: 80)

            VStack(alignment: .leading, spacing: 4) {
                Text(result.title)
                    .font(.headline)
                    .lineLimit(1)
                Text(result.author)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text(result.lastChapter)
                    .font(.caption)
                    .foregroundColor(.gray)
                Text(result.source)
                    .font(.caption2)
                    .foregroundColor(.blue)
            }
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    BookSearchView()
}
