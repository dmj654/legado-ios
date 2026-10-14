package io.legado.data.entities

import kotlinx.serialization.Serializable

@Serializable
data class BookChapter(
    var bookUrl: String = "",
    var bookSourceUrl: String? = null,
    var index: Int = 0,
    var title: String = "",
    var url: String = "",
    var isVolume: Boolean = false,
    var isVip: Boolean = false,
    var isPay: Boolean = false,
    var updateTime: String? = null,
    var start: Int? = null,
    var end: Int? = null,
    var variable: String? = null
)
