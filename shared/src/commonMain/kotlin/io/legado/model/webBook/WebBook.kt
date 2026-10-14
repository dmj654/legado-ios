package io.legado.model.webBook

import io.legado.data.entities.BookChapter
import io.legado.data.entities.BookSource
import io.legado.data.entities.SearchBook

interface WebBook {
    val source: BookSource

    suspend fun searchBook(keyword: String, page: Int = 1): List<SearchBook>

    suspend fun getBookInfo(bookUrl: String): io.legado.data.entities.Book

    suspend fun getChapterList(bookUrl: String): List<BookChapter>

    suspend fun getContent(chapterUrl: String): String
}
