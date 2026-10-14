import Foundation
import SwiftData
import Combine

@MainActor
final class BookShelfViewModel: ObservableObject {
    @Published var books: [BookModel] = []
    @Published var searchText: String = ""
    @Published var selectedGroup: String? = nil
    @Published var viewMode: String = "grid"
    @Published var sortBy: String = "recent"
    @Published var showDeleteConfirmation = false
    @Published var bookToDelete: BookModel?

    private var storage: StorageManager { StorageManager.shared }

    var groups: [String] {
        let groupSet = Set(books.compactMap { $0.group }.filter { !$0.isEmpty })
        return Array(groupSet).sorted()
    }

    var filteredBooks: [BookModel] {
        var result = books
        if let group = selectedGroup {
            result = result.filter { $0.group == group }
        }
        if !searchText.isEmpty {
            result = result.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                ($0.author.localizedCaseInsensitiveContains(searchText))
            }
        }
        switch sortBy {
        case "recent":
            result.sort { ($0.lastReadTime ?? $0.addTime) > ($1.lastReadTime ?? $1.addTime) }
        case "name":
            result.sort { $0.name.localizedCompare($1.name) == .orderedAscending }
        case "addTime":
            result.sort { $0.addTime > $1.addTime }
        case "progress":
            result.sort { $0.readProgress > $1.readProgress }
        default:
            break
        }
        return result
    }

    func loadBooks() {
        books = storage.fetchBooks(inShelf: true)
    }

    func deleteBook(_ book: BookModel) {
        storage.deleteBook(book)
        loadBooks()
    }

    func moveBookToTop(_ book: BookModel) {
        if let index = books.firstIndex(where: { $0.bookUrl == book.bookUrl }) {
            books[index].order = (books.map { $0.order }.max() ?? 0) + 1
            try? storage.context.save()
            loadBooks()
        }
    }

    func updateGroup(book: BookModel, group: String?) {
        if let index = books.firstIndex(where: { $0.bookUrl == book.bookUrl }) {
            books[index].group = group
            try? storage.context.save()
        }
    }
}
