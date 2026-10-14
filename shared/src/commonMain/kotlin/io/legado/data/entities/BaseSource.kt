package io.legado.data.entities

interface BaseSource {
    val sourceUrl: String
    val sourceName: String
    var jsLib: String?
    var enabledCookieJar: Boolean?
    var concurrentRate: String?
    var header: String?
    var loginUrl: String?
    var loginUi: String?
    fun getTag(): String = sourceName
    fun getKey(): String = sourceUrl
    fun setTemporaryVariable(variable: String?)
    fun getTemporaryVariable(): String?
}
