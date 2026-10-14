package io.legado.data.entities

import kotlinx.serialization.Serializable

@Serializable
data class Book(
    var bookUrl: String = "",
    var bookSourceUrl: String? = null,
    var bookSourceName: String? = null,
    var name: String = "",
    var author: String? = null,
    var kind: String? = null,
    var customTag: String? = null,
    var coverUrl: String? = null,
    var intro: String? = null,
    var lastChapterName: String? = null,
    var lastChapterTitle: String? = null,
    var lastUpdateTime: Long? = null,
    var totalChapterNum: Int = 0,
    var durChapterIndex: Int = 0,
    var durChapterPos: Int = 0,
    var durChapterTime: Long? = null,
    var durChapterTitle: String? = null,
    var type: Int = 0,
    var group: Int = 0,
    var inBookShelf: Boolean = false,
    var origin: String? = null,
    var originName: String? = null,
    var infoHtml: String? = null,
    var tocHtml: String? = null,
    var variable: String? = null,
    var latestCheckTime: Long? = null,
    var order: Int = 0
) {
    val isLocalBook: Boolean get() = bookSourceUrl == null || bookSourceUrl == "loc_book"
}
