import Foundation
import SwiftData

@Model
final class SearchHistory {
    @Attribute(.unique) var keyword: String
    var searchTime: Date
    var count: Int

    init(keyword: String) {
        self.keyword = keyword
        self.searchTime = Date()
        self.count = 1
    }
}

@Model
final class ReadProgress {
    @Attribute(.unique) var bookUrl: String
    var chapterIndex: Int
    var positionInChapter: Int
    var chapterTitle: String?
    var updateTime: Date

    init(bookUrl: String) {
        self.bookUrl = bookUrl
        self.chapterIndex = 0
        self.positionInChapter = 0
        self.updateTime = Date()
    }
}
