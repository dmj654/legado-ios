package io.legado.utils

interface JsExtensions {
    fun evalJS(jsStr: String, body: String, pageUrl: String): String?
    fun put(key: String, value: Any?)
    fun get(key: String): Any?
}
