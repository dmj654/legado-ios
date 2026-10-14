import Foundation
import SwiftData

@Model
final class BookModel {
    @Attribute(.unique) var bookUrl: String
    var name: String
    var author: String
    var kind: String?
    var coverUrl: String?
    var intro: String?
    var lastChapterName: String?
    var lastUpdateTime: Date?
    var totalChapterNum: Int
    var durChapterIndex: Int
    var durChapterPos: Int
    var durChapterTitle: String?
    var inBookShelf: Bool
    var group: String?
    var order: Int
    var addTime: Date
    var lastReadTime: Date?
    var sourceUrl: String?
    var sourceName: String?

    init(bookUrl: String, name: String, author: String = "未知") {
        self.bookUrl = bookUrl
        self.name = name
        self.author = author
        self.totalChapterNum = 0
        self.durChapterIndex = 0
        self.durChapterPos = 0
        self.inBookShelf = true
        self.order = 0
        self.addTime = Date()
    }

    var readProgress: Double {
        guard totalChapterNum > 0 else { return 0 }
        return Double(durChapterIndex) / Double(totalChapterNum)
    }

    var isLocalBook: Bool {
        sourceUrl == nil || sourceUrl == "loc_book"
    }
}
