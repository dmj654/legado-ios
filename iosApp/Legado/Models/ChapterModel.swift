import Foundation
import SwiftData

@Model
final class ChapterModel {
    var bookUrl: String
    var index: Int
    var title: String
    var url: String
    var isVolume: Bool
    var isVip: Bool
    var isRead: Bool
    var content: String?
    var updateTime: String?

    init(bookUrl: String, index: Int, title: String, url: String = "") {
        self.bookUrl = bookUrl
        self.index = index
        self.title = title
        self.url = url
        self.isVolume = false
        self.isVip = false
        self.isRead = false
    }
}
