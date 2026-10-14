package io.legado.data.entities

import io.legado.data.entities.rule.BookInfoRule
import io.legado.data.entities.rule.ContentRule
import io.legado.data.entities.rule.ExploreRule
import io.legado.data.entities.rule.SearchRule
import io.legado.data.entities.rule.TocRule
import kotlinx.serialization.Serializable
import kotlinx.serialization.Transient

@Serializable
data class BookSource(
    var bookSourceUrl: String = "",
    var bookSourceName: String = "",
    var bookSourceGroup: String? = null,
    var bookSourceType: Int = 0,
    var bookUrlPattern: String? = null,
    var customOrder: Int = 0,
    var enabled: Boolean = true,
    var enabledExplore: Boolean = true,
    override var jsLib: String? = null,
    override var enabledCookieJar: Boolean? = true,
    override var concurrentRate: String? = null,
    override var header: String? = null,
    override var loginUrl: String? = null,
    override var loginUi: String? = null,
    var loginCheckJs: String? = null,
    var coverDecodeJs: String? = null,
    var bookSourceComment: String? = null,
    var variableComment: String? = null,
    var lastUpdateTime: Long = 0,
    var respondTime: Long = 180000L,
    var weight: Int = 0,
    var exploreUrl: String? = null,
    var exploreScreen: String? = null,
    var ruleExplore: ExploreRule? = null,
    var searchUrl: String? = null,
    var ruleSearch: SearchRule? = null,
    var ruleBookInfo: BookInfoRule? = null,
    var ruleToc: TocRule? = null,
    var ruleContent: ContentRule? = null,
    var eventListener: Boolean = false,
    var customButton: Boolean = false,
    var homepageModules: String? = null
) : BaseSource {

    @Transient
    private var temporaryVariable: String? = null

    override val sourceUrl: String get() = bookSourceUrl
    override val sourceName: String get() = bookSourceName

    override fun setTemporaryVariable(variable: String?) {
        temporaryVariable = variable
    }

    override fun getTemporaryVariable(): String? = temporaryVariable

    fun getSearchRule(): SearchRule {
        ruleSearch?.let { return it }
        val rule = SearchRule()
        ruleSearch = rule
        return rule
    }

    fun getExploreRule(): ExploreRule {
        ruleExplore?.let { return it }
        val rule = ExploreRule()
        ruleExplore = rule
        return rule
    }

    fun getBookInfoRule(): BookInfoRule {
        ruleBookInfo?.let { return it }
        val rule = BookInfoRule()
        ruleBookInfo = rule
        return rule
    }

    fun getTocRule(): TocRule {
        ruleToc?.let { return it }
        val rule = TocRule()
        ruleToc = rule
        return rule
    }

    fun getContentRule(): ContentRule {
        ruleContent?.let { return it }
        val rule = ContentRule()
        ruleContent = rule
        return rule
    }

    fun getDisplayNameGroup(): String {
        return if (bookSourceGroup.isNullOrBlank()) {
            bookSourceName
        } else {
            "$bookSourceName ($bookSourceGroup)"
        }
    }

    override fun hashCode(): Int = bookSourceUrl.hashCode()

    override fun equals(other: Any?): Boolean {
        return if (other is BookSource) other.bookSourceUrl == bookSourceUrl else false
    }
}
