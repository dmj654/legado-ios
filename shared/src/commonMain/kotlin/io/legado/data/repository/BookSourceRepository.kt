package io.legado.data.repository

import io.legado.core.NetworkManager
import io.legado.data.entities.BookSource
import io.legado.model.webBook.WebBook
import io.legado.model.webBook.WebBookImpl
import kotlinx.serialization.json.Json
import kotlinx.serialization.json.JsonArray
import kotlinx.serialization.json.jsonArray

class BookSourceRepository(
    private val network: NetworkManager
) {
    private val json = Json {
        ignoreUnknownKeys = true
        isLenient = true
        prettyPrint = false
    }

    private val sources = mutableListOf<BookSource>()

    fun getAllSources(): List<BookSource> = sources.toList()

    fun getEnabledSources(): List<BookSource> = sources.filter { it.enabled }

    fun addSource(source: BookSource) {
        val index = sources.indexOfFirst { it.bookSourceUrl == source.bookSourceUrl }
        if (index >= 0) {
            sources[index] = source
        } else {
            sources.add(source)
        }
    }

    fun removeSource(sourceUrl: String) {
        sources.removeAll { it.bookSourceUrl == sourceUrl }
    }

    fun getSource(sourceUrl: String): BookSource? {
        return sources.firstOrNull { it.bookSourceUrl == sourceUrl }
    }

    fun importSources(json: String): Int {
        return try {
            val element = json.parseToJsonElement()
            val array = if (element is JsonArray) element else json.parseToJsonElement().jsonArray
            var count = 0
            for (item in array) {
                try {
                    val source = this.json.decodeFromString<BookSource>(item.toString())
                    addSource(source)
                    count++
                } catch (e: Exception) {
                    // skip invalid source
                }
            }
            count
        } catch (e: Exception) {
            0
        }
    }

    suspend fun importFromUrl(url: String): Int {
        return try {
            val content = network.get(url)
            importSources(content)
        } catch (e: Exception) {
            0
        }
    }

    fun getWebBook(source: BookSource): WebBook {
        return WebBookImpl(source, network)
    }

    fun getWebBook(sourceUrl: String): WebBook? {
        val source = getSource(sourceUrl) ?: return null
        return getWebBook(source)
    }
}
