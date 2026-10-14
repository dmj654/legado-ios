package io.legado.core

import io.ktor.client.HttpClient
import io.ktor.client.request.header
import io.ktor.client.request.get
import io.ktor.client.request.post
import io.ktor.client.request.setBody
import io.ktor.client.statement.HttpResponse
import io.ktor.client.statement.bodyAsText
import io.ktor.http.ContentType
import io.ktor.http.HttpHeaders
import io.ktor.http.contentType

class NetworkManager {
    private val client = HttpClient {
        expectSuccess = false
    }

    suspend fun get(url: String, headers: Map<String, String> = emptyMap()): String {
        val response: HttpResponse = client.get(url) {
            headers.forEach { (key, value) -> header(key, value) }
            header(HttpHeaders.UserAgent, "Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15")
        }
        return response.bodyAsText()
    }

    suspend fun post(url: String, body: String, headers: Map<String, String> = emptyMap()): String {
        val response: HttpResponse = client.post(url) {
            headers.forEach { (key, value) -> header(key, value) }
            header(HttpHeaders.UserAgent, "Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15")
            contentType(ContentType.Application.Json)
            setBody(body)
        }
        return response.bodyAsText()
    }

    fun close() {
        client.close()
    }
}
