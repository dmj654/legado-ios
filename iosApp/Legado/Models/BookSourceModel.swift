import Foundation
import SwiftData

@Model
final class BookSourceModel {
    @Attribute(.unique) var sourceUrl: String
    var sourceName: String
    var sourceGroup: String?
    var sourceType: Int
    var enabled: Bool
    var enabledExplore: Bool
    var searchUrl: String?
    var exploreUrl: String?
    var bookUrlPattern: String?
    var header: String?
    var loginUrl: String?
    var comment: String?
    var lastUpdateTime: Date
    var respondTime: Int
    var weight: Int
    var customOrder: Int
    var addTime: Date

    init(sourceUrl: String, sourceName: String) {
        self.sourceUrl = sourceUrl
        self.sourceName = sourceName
        self.sourceType = 0
        self.enabled = true
        self.enabledExplore = true
        self.lastUpdateTime = Date()
        self.respondTime = 180000
        self.weight = 0
        self.customOrder = 0
        self.addTime = Date()
    }

    var displayName: String {
        if let group = sourceGroup, !group.isEmpty {
            return "\(sourceName) (\(group))"
        }
        return sourceName
    }
}
