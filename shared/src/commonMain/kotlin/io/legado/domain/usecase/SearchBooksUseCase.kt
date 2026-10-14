package io.legado.domain.usecase

import io.legado.data.entities.SearchBook
import io.legado.data.repository.BookSourceRepository
import kotlinx.coroutines.async
import kotlinx.coroutines.coroutineScope

class SearchBooksUseCase(
    private val repository: BookSourceRepository
) {
    suspend fun execute(keyword: String, sourceUrls: List<String>? = null): List<SearchBook> = coroutineScope {
        val sources = if (sourceUrls != null) {
            sourceUrls.mapNotNull { repository.getSource(it) }
        } else {
            repository.getEnabledSources()
        }

        val deferredResults = sources.map { source ->
            async {
                try {
                    val webBook = repository.getWebBook(source)
                    webBook.searchBook(keyword)
                } catch (e: Exception) {
                    emptyList()
                }
            }
        }

        val allResults = mutableListOf<SearchBook>()
        for (deferred in deferredResults) {
            allResults.addAll(deferred.await())
        }

        allResults.distinctBy { it.bookUrl to it.name }
    }
}
