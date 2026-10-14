package io.legado.model.webBook

import io.legado.core.NetworkManager
import io.legado.data.entities.Book
import io.legado.data.entities.BookChapter
import io.legado.data.entities.BookSource
import io.legado.data.entities.SearchBook
import io.legado.model.analyzeRule.AnalyzeRule

class WebBookImpl(
    override val source: BookSource,
    private val network: NetworkManager
) : WebBook {

    private val analyzeRule = AnalyzeRule()

    override suspend fun searchBook(keyword: String, page: Int): List<SearchBook> {
        val searchUrl = source.searchUrl ?: return emptyList()
        val url = searchUrl
            .replace("\${key}", keyword)
            .replace("\${page}", page.toString())
            .replace("{{key}}", keyword)
            .replace("{{page}}", page.toString())

        val html = network.get(url, parseHeaders(source.header))
        analyzeRule.setContent(html)

        val rule = source.getSearchRule()
        val bookListRule = rule.bookList ?: return emptyList()

        val books = mutableListOf<SearchBook>()
        val items = extractListItems(html, bookListRule)

        for (itemHtml in items) {
            val itemAnalyzer = AnalyzeRule()
            itemAnalyzer.setContent(itemHtml)
            val book = SearchBook(
                bookUrl = itemAnalyzer.getString(rule.bookUrl) ?: "",
                bookSourceUrl = source.bookSourceUrl,
                bookSourceName = source.bookSourceName,
                name = itemAnalyzer.getString(rule.name) ?: "",
                author = itemAnalyzer.getString(rule.author),
                kind = itemAnalyzer.getString(rule.kind),
                coverUrl = itemAnalyzer.getString(rule.coverUrl),
                intro = itemAnalyzer.getString(rule.intro),
                lastChapter = itemAnalyzer.getString(rule.lastChapter),
                updateTime = itemAnalyzer.getString(rule.updateTime),
                wordCount = itemAnalyzer.getString(rule.wordCount)
            )
            if (book.name.isNotBlank() && book.bookUrl.isNotBlank()) {
                books.add(book)
            }
        }
        return books
    }

    override suspend fun getBookInfo(bookUrl: String): Book {
        val html = network.get(bookUrl, parseHeaders(source.header))
        analyzeRule.setContent(html)
        val rule = source.getBookInfoRule()

        return Book(
            bookUrl = bookUrl,
            bookSourceUrl = source.bookSourceUrl,
            bookSourceName = source.bookSourceName,
            name = analyzeRule.getString(rule.name) ?: "",
            author = analyzeRule.getString(rule.author),
            kind = analyzeRule.getString(rule.kind),
            coverUrl = analyzeRule.getString(rule.coverUrl),
            intro = analyzeRule.getString(rule.intro),
            lastChapterName = analyzeRule.getString(rule.lastChapter),
            lastUpdateTime = analyzeRule.getString(rule.updateTime)?.toLongOrNull()
        )
    }

    override suspend fun getChapterList(bookUrl: String): List<BookChapter> {
        val html = network.get(bookUrl, parseHeaders(source.header))
        analyzeRule.setContent(html)
        val rule = source.getTocRule()

        val chapterListRule = rule.chapterList ?: return emptyList()
        val items = extractListItems(html, chapterListRule)
        val chapters = mutableListOf<BookChapter>()

        for ((index, itemHtml) in items.withIndex()) {
            val itemAnalyzer = AnalyzeRule()
            itemAnalyzer.setContent(itemHtml)
            val chapter = BookChapter(
                bookUrl = bookUrl,
                bookSourceUrl = source.bookSourceUrl,
                index = index,
                title = itemAnalyzer.getString(rule.chapterName) ?: "",
                url = itemAnalyzer.getString(rule.chapterUrl) ?: ""
            )
            if (chapter.title.isNotBlank()) {
                chapters.add(chapter)
            }
        }
        return chapters
    }

    override suspend fun getContent(chapterUrl: String): String {
        val html = network.get(chapterUrl, parseHeaders(source.header))
        analyzeRule.setContent(html)
        val rule = source.getContentRule()
        return analyzeRule.getString(rule.content) ?: ""
    }

    private fun parseHeaders(headerStr: String?): Map<String, String> {
        if (headerStr.isNullOrBlank()) return emptyMap()
        val headers = mutableMapOf<String, String>()
        headerStr.split("\n").forEach { line ->
            val parts = line.split(":", limit = 2)
            if (parts.size == 2) {
                headers[parts[0].trim()] = parts[1].trim()
            }
        }
        return headers
    }

    private fun extractListItems(html: String, rule: String): List<String> {
        return when {
            rule.startsWith("@css:") || rule.startsWith("css.") -> {
                val selector = rule.substringAfter(":")
                extractElementsByCss(html, selector)
            }
            rule.startsWith("@xpath:") || rule.startsWith("//") -> {
                extractElementsByXPath(html, rule)
            }
            rule.startsWith("@json:") || rule.startsWith("$.") -> {
                val jsonRule = if (rule.startsWith("@json:")) rule.substring(6) else rule
                extractJsonArray(html, jsonRule)
            }
            else -> listOf(html)
        }
    }

    private fun extractElementsByCss(html: String, selector: String): List<String> {
        val tagName = selector.substringBefore(".").substringBefore("#").ifBlank { "div" }
        val results = mutableListOf<String>()
        val openTag = Regex("""<\s*$tagName\b[^>]*>""")
        val matches = openTag.findAll(html).toList()
        for (match in matches.take(50)) {
            val closeTag = "</$tagName>"
            var depth = 1
            var pos = match.range.last + 1
            while (depth > 0 && pos < html.length) {
                val nextOpen = html.indexOf("<$tagName", pos, true)
                val nextClose = html.indexOf(closeTag, pos, true)
                if (nextClose == -1) break
                if (nextOpen != -1 && nextOpen < nextClose) {
                    depth++
                    pos = nextOpen + 1
                } else {
                    depth--
                    pos = nextClose + closeTag.length
                    if (depth == 0) {
                        results.add(html.substring(match.range.first, pos))
                        break
                    }
                }
            }
        }
        return results
    }

    private fun extractElementsByXPath(html: String, rule: String): List<String> {
        val segments = rule.split("/").filter { it.isNotBlank() }
        val tagName = segments.lastOrNull()?.substringBefore("[") ?: "div"
        return extractElementsByCss(html, tagName)
    }

    private fun extractJsonArray(json: String, rule: String): List<String> {
        return try {
            val analyzer = AnalyzeRule()
            analyzer.setContent(json)
            val result = analyzer.getString(rule)
            listOfNotNull(result)
        } catch (e: Exception) {
            emptyList()
        }
    }
}
