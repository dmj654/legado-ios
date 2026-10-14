import Foundation
import SwiftData

@MainActor
final class StorageManager {
    static let shared = StorageManager()

    let container: ModelContainer

    private init() {
        do {
            container = try ModelContainer(for: BookModel.self, ChapterModel.self, BookSourceModel.self, SearchHistory.self, ReadProgress.self)
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }

    var context: ModelContext { container.mainContext }

    // MARK: - Book Operations

    func fetchBooks(inShelf: Bool = true) -> [BookModel] {
        let descriptor = FetchDescriptor<BookModel>(
            predicate: #Predicate { $0.inBookShelf == inShelf },
            sortBy: [SortDescriptor(\.order, order: .reverse), SortDescriptor(\.addTime, order: .reverse)]
        )
        return (try? context.fetch(descriptor)) ?? []
    }

    func fetchBook(url: String) -> BookModel? {
        let descriptor = FetchDescriptor<BookModel>(predicate: #Predicate { $0.bookUrl == url })
        return (try? context.fetch(descriptor))?.first
    }

    func saveBook(_ book: BookModel) {
        if let existing = fetchBook(url: book.bookUrl) {
            existing.name = book.name
            existing.author = book.author
            existing.coverUrl = book.coverUrl
            existing.intro = book.intro
            existing.lastChapterName = book.lastChapterName
            existing.totalChapterNum = book.totalChapterNum
        } else {
            context.insert(book)
        }
        try? context.save()
    }

    func deleteBook(_ book: BookModel) {
        context.delete(book)
        try? context.save()
    }

    func updateProgress(bookUrl: String, chapterIndex: Int, position: Int, chapterTitle: String?) {
        if let book = fetchBook(url: bookUrl) {
            book.durChapterIndex = chapterIndex
            book.durChapterPos = position
            book.durChapterTitle = chapterTitle
            book.lastReadTime = Date()
            try? context.save()
        }
    }

    // MARK: - Chapter Operations

    func fetchChapters(bookUrl: String) -> [ChapterModel] {
        let descriptor = FetchDescriptor<ChapterModel>(
            predicate: #Predicate { $0.bookUrl == bookUrl },
            sortBy: [SortDescriptor(\.index)]
        )
        return (try? context.fetch(descriptor)) ?? []
    }

    func saveChapters(_ chapters: [ChapterModel], bookUrl: String) {
        let existing = fetchChapters(bookUrl: bookUrl)
        existing.forEach { context.delete($0) }
        chapters.forEach { context.insert($0) }
        try? context.save()
    }

    // MARK: - Source Operations

    func fetchSources(enabledOnly: Bool = false) -> [BookSourceModel] {
        let descriptor = FetchDescriptor<BookSourceModel>(
            predicate: enabledOnly ? #Predicate { $0.enabled == true } : nil,
            sortBy: [SortDescriptor(\.customOrder, order: .reverse), SortDescriptor(\.lastUpdateTime, order: .reverse)]
        )
        return (try? context.fetch(descriptor)) ?? []
    }

    func fetchSource(url: String) -> BookSourceModel? {
        let descriptor = FetchDescriptor<BookSourceModel>(predicate: #Predicate { $0.sourceUrl == url })
        return (try? context.fetch(descriptor))?.first
    }

    func saveSource(_ source: BookSourceModel) {
        if let existing = fetchSource(url: source.sourceUrl) {
            existing.sourceName = source.sourceName
            existing.sourceGroup = source.sourceGroup
            existing.enabled = source.enabled
            existing.searchUrl = source.searchUrl
        } else {
            context.insert(source)
        }
        try? context.save()
    }

    func deleteSource(_ source: BookSourceModel) {
        context.delete(source)
        try? context.save()
    }

    func importSources(from jsonString: String) -> Int {
        guard let data = jsonString.data(using: .utf8),
              let array = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] else {
            return 0
        }
        var count = 0
        for item in array {
            guard let url = item["bookSourceUrl"] as? String else { continue }
            let name = (item["bookSourceName"] as? String) ?? "未命名"
            let source = BookSourceModel(sourceUrl: url, sourceName: name)
            source.sourceGroup = item["bookSourceGroup"] as? String
            source.sourceType = (item["bookSourceType"] as? Int) ?? 0
            source.searchUrl = item["searchUrl"] as? String
            source.exploreUrl = item["exploreUrl"] as? String
            source.header = item["header"] as? String
            source.comment = item["bookSourceComment"] as? String
            source.enabled = (item["enabled"] as? Bool) ?? true
            saveSource(source)
            count += 1
        }
        return count
    }

    // MARK: - Search History

    func fetchSearchHistory(limit: Int = 20) -> [SearchHistory] {
        let descriptor = FetchDescriptor<SearchHistory>(
            sortBy: [SortDescriptor(\.searchTime, order: .reverse)]
        )
        let all = (try? context.fetch(descriptor)) ?? []
        return Array(all.prefix(limit))
    }

    func addSearchHistory(_ keyword: String) {
        let descriptor = FetchDescriptor<SearchHistory>(predicate: #Predicate { $0.keyword == keyword })
        if let existing = (try? context.fetch(descriptor))?.first {
            existing.searchTime = Date()
            existing.count += 1
        } else {
            context.insert(SearchHistory(keyword: keyword))
        }
        try? context.save()
    }

    func clearSearchHistory() {
        let all = (try? context.fetch(FetchDescriptor<SearchHistory>())) ?? []
        all.forEach { context.delete($0) }
        try? context.save()
    }
}
