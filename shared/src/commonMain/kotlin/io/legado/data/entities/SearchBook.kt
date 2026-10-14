package io.legado.data.entities

import kotlinx.serialization.Serializable

@Serializable
data class SearchBook(
    var bookUrl: String = "",
    var bookSourceUrl: String? = null,
    var bookSourceName: String? = null,
    var name: String = "",
    var author: String? = null,
    var kind: String? = null,
    var coverUrl: String? = null,
    var intro: String? = null,
    var lastChapter: String? = null,
    var updateTime: String? = null,
    var wordCount: String? = null,
    var origin: String? = null,
    var originName: String? = null,
    var infoHtml: String? = null,
    var tocHtml: String? = null,
    var variable: String? = null
) {
    fun toBook(): Book {
        return Book(
            bookUrl = bookUrl,
            bookSourceUrl = bookSourceUrl,
            bookSourceName = bookSourceName,
            name = name,
            author = author,
            kind = kind,
            coverUrl = coverUrl,
            intro = intro,
            lastChapterName = lastChapter,
            lastUpdateTime = updateTime?.toLongOrNull(),
            origin = origin,
            originName = originName,
            infoHtml = infoHtml,
            tocHtml = tocHtml,
            variable = variable
        )
    }
}
