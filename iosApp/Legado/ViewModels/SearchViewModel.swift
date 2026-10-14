import Foundation
import SwiftData
import Combine

struct SearchResultItem: Identifiable {
    let id = UUID()
    let title: String
    let author: String
    let sourceName: String
    let bookUrl: String
    let coverUrl: String?
    let intro: String?
    let lastChapter: String?
    let updateTime: String?
}

@MainActor
final class SearchViewModel: ObservableObject {
    @Published var keyword: String = ""
    @Published var results: [SearchResultItem] = []
    @Published var isSearching: Bool = false
    @Published var searchHistory: [SearchHistory] = []
    @Published var currentPage: Int = 1
    @Published var hasMore: Bool = true
    @Published var errorMessage: String? = nil

    private var storage: StorageManager { StorageManager.shared }
    private var searchTask: Task<Void, Never>? = nil

    let hotKeywords = ["斗破苍穹", "凡人修仙传", "诡秘之主", "庆余年", "雪中悍刀行", "剑来", "遮天", "完美世界"]

    func loadHistory() {
        searchHistory = storage.fetchSearchHistory()
    }

    func clearHistory() {
        storage.clearSearchHistory()
        searchHistory = []
    }

    func search(keyword: String) {
        guard !keyword.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        self.keyword = keyword
        self.currentPage = 1
        self.results = []
        self.hasMore = true
        self.errorMessage = nil

        storage.addSearchHistory(keyword)
        loadHistory()

        performSearch()
    }

    func loadMore() {
        guard hasMore, !isSearching else { return }
        currentPage += 1
        performSearch()
    }

    private func performSearch() {
        searchTask?.cancel()
        isSearching = true

        searchTask = Task {
            defer { isSearching = false }

            let sources = storage.fetchSources(enabledOnly: true)
            guard !sources.isEmpty else {
                errorMessage = "没有启用的书源，请先在书源管理中添加并启用书源"
                return
            }

            var newResults: [SearchResultItem] = []
            for source in sources.prefix(10) {
                if Task.isCancelled { break }
                let items = await searchInSource(source: source, keyword: keyword, page: currentPage)
                newResults.append(contentsOf: items)
                if newResults.count >= 50 { break }
            }

            if newResults.isEmpty && currentPage == 1 {
                errorMessage = "未找到相关书籍，请尝试其他关键词"
            } else {
                let existingUrls = Set(results.map { $0.bookUrl })
                let unique = newResults.filter { !existingUrls.contains($0.bookUrl) }
                await MainActor.run {
                    results.append(contentsOf: unique)
                    hasMore = newResults.count >= 10
                }
            }
        }
    }

    private func searchInSource(source: BookSourceModel, keyword: String, page: Int) async -> [SearchResultItem] {
        guard let searchUrl = source.searchUrl, !searchUrl.isEmpty else { return [] }

        let encodedKeyword = keyword.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? keyword
        let urlString = searchUrl
            .replacingOccurrences(of: "{{key}}", with: encodedKeyword)
            .replacingOccurrences(of: "{{page}}", with: "\(page)")
            .replacingOccurrences(of: "${key}", with: encodedKeyword)
            .replacingOccurrences(of: "${page}", with: "\(page)")

        guard let url = URL(string: urlString) else { return [] }

        do {
            var request = URLRequest(url: url)
            request.setValue("Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15", forHTTPHeaderField: "User-Agent")
            request.timeoutInterval = 15

            let (data, _) = try await URLSession.shared.data(for: request)
            let html = String(data: data, encoding: .utf8) ?? ""

            return parseSearchResults(html: html, sourceName: source.sourceName)
        } catch {
            return []
        }
    }

    private func parseSearchResults(html: String, sourceName: String) -> [SearchResultItem] {
        var results: [SearchResultItem] = []
        let pattern = #"<a[^>]*href="([^"]*)"[^>]*>([\s\S]*?)</a>"#
        let regex = try? NSRegularExpression(pattern: pattern, options: [])
        let nsRange = NSRange(html.startIndex..., in: html)
        regex?.enumerateMatches(in: html, range: nsRange) { match, _, _ in
            guard let match = match,
                  let urlRange = Range(match.range(at: 1), in: html),
                  let contentRange = Range(match.range(at: 2), in: html) else { return }
            let url = String(html[urlRange])
            let content = String(html[contentRange])
            let cleanContent = content.replacingOccurrences(of: #"<[^>]+>"#, with: "", options: .regularExpression).trimmingCharacters(in: .whitespacesAndNewlines)
            if !cleanContent.isEmpty && url.hasPrefix("http") && results.count < 20 {
                results.append(SearchResultItem(
                    title: cleanContent,
                    author: "",
                    sourceName: sourceName,
                    bookUrl: url,
                    coverUrl: nil,
                    intro: nil,
                    lastChapter: nil,
                    updateTime: nil
                ))
            }
        }
        return results
    }

    func addToShelf(result: SearchResultItem) {
        let book = BookModel(bookUrl: result.bookUrl, name: result.title, author: result.author)
        book.coverUrl = result.coverUrl
        book.intro = result.intro
        book.lastChapterName = result.lastChapter
        book.sourceName = result.sourceName
        StorageManager.shared.saveBook(book)
    }
}
