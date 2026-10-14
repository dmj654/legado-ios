package io.legado.model.analyzeRule

import io.legado.utils.JsExtensions

class AnalyzeRule(
    private val pageUrl: String? = null,
    private val body: Any? = null,
    private val jsExtensions: JsExtensions? = null
) {
    private var content: String? = null

    fun setContent(content: Any?) {
        this.content = when (content) {
            is String -> content
            else -> content?.toString()
        }
    }

    fun getString(ruleStr: String?, isContent: Boolean = false): String? {
        if (ruleStr.isNullOrBlank()) return null
        val rules = ruleStr.split("&&").map { it.trim() }.filter { it.isNotBlank() }
        var result: String? = null
        for (rule in rules) {
            result = analyzeSingleRule(rule, isContent)
            if (!result.isNullOrBlank()) break
        }
        return result
    }

    fun getStringList(ruleStr: String?, isContent: Boolean = false): List<String> {
        if (ruleStr.isNullOrBlank()) return emptyList()
        val result = mutableListOf<String>()
        val rules = ruleStr.split("&&").map { it.trim() }.filter { it.isNotBlank() }
        for (rule in rules) {
            val list = analyzeRuleList(rule, isContent)
            if (list.isNotEmpty()) {
                result.addAll(list)
                break
            }
        }
        return result
    }

    private fun analyzeSingleRule(rule: String, isContent: Boolean): String? {
        return when {
            rule.startsWith("@css:") || rule.startsWith("css.") -> {
                val cssRule = rule.substringAfter(":")
                analyzeByCss(cssRule)
            }
            rule.startsWith("@xpath:") || rule.startsWith("//") -> {
                analyzeByXPath(rule)
            }
            rule.startsWith("@json:") || rule.startsWith("$.") -> {
                val jsonRule = if (rule.startsWith("@json:")) rule.substring(6) else rule
                analyzeByJsonPath(jsonRule)
            }
            rule.startsWith("@regex:") -> {
                val regexRule = rule.substring(7)
                analyzeByRegex(regexRule)
            }
            rule.startsWith("{{") && rule.endsWith("}}") -> {
                analyzeByJs(rule.removeSurrounding("{{", "}}"))
            }
            else -> analyzeByRegex(rule)
        }
    }

    private fun analyzeRuleList(rule: String, isContent: Boolean): List<String> {
        return listOfNotNull(analyzeSingleRule(rule, isContent))
    }

    private fun analyzeByCss(rule: String): String? {
        val content = this.content ?: return null
        val parts = rule.split("@", limit = 2)
        val selector = parts[0].trim()
        val attr = if (parts.size > 1) parts[1].trim() else "text"
        return extractByCss(content, selector, attr)
    }

    private fun extractByCss(html: String, selector: String, attr: String): String? {
        val tagPattern = Regex("""<\s*([a-zA-Z][a-zA-Z0-9]*)\b[^>]*>""")
        val classPattern = Regex("""class\s*=\s*["']([^"']+)["']""")
        val idPattern = Regex("""id\s*=\s*["']([^"']+)["']""")

        if (selector.startsWith(".")) {
            val className = selector.substring(1)
            val matches = classPattern.findAll(html).filter { it.groupValues[1].split(" ").contains(className) }
            for (match in matches) {
                val tagStart = html.lastIndexOf('<', match.range.first)
                if (tagStart >= 0) {
                    return extractElementContent(html, tagStart, attr)
                }
            }
        } else if (selector.startsWith("#")) {
            val idName = selector.substring(1)
            val match = idPattern.find(html) { it.groupValues[1] == idName }
            if (match != null) {
                val tagStart = html.lastIndexOf('<', match.range.first)
                if (tagStart >= 0) {
                    return extractElementContent(html, tagStart, attr)
                }
            }
        } else {
            val tagMatch = Regex("""<\s*$selector\b[^>]*>""").find(html)
            if (tagMatch != null) {
                return extractElementContent(html, tagMatch.range.first, attr)
            }
        }
        return null
    }

    private fun extractElementContent(html: String, startIndex: Int, attr: String): String? {
        val tagMatch = Regex("""<\s*([a-zA-Z][a-zA-Z0-9]*)\b""").find(html, startIndex) ?: return null
        val tagName = tagMatch.groupValues[1]

        if (attr == "text" || attr == "text()") {
            val closeTag = "</$tagName>"
            val endIndex = html.indexOf(closeTag, startIndex)
            if (endIndex > 0) {
                val contentStart = html.indexOf('>', startIndex) + 1
                return html.substring(contentStart, endIndex)
                    .replace(Regex("""<[^>]+>"""), "")
                    .trim()
            }
        } else {
            val attrMatch = Regex("""$attr\s*=\s*["']([^"']*)["']""", RegexOption.IGNORE_CASE)
                .find(html, startIndex)
            return attrMatch?.groupValues?.get(1)
        }
        return null
    }

    private fun analyzeByXPath(rule: String): String? {
        val content = this.content ?: return null
        val parts = rule.split("/@")
        val path = parts[0]
        val attr = if (parts.size > 1) parts[1] else null
        val segments = path.split("/").filter { it.isNotBlank() }
        var current = content
        for (segment in segments) {
            if (segment.startsWith("@")) continue
            val tagName = segment.substringBefore("[")
            val match = Regex("""<\s*$tagName\b[^>]*>""").find(current)
            if (match != null) {
                val closeTag = "</$tagName>"
                val endIndex = current.indexOf(closeTag, match.range.first)
                current = if (endIndex > 0) {
                    current.substring(match.range.first, endIndex + closeTag.length)
                } else {
                    current.substring(match.range.first)
                }
            }
        }
        return if (attr != null) {
            Regex("""$attr\s*=\s*["']([^"']*)["']""", RegexOption.IGNORE_CASE)
                .find(current)?.groupValues?.get(1)
        } else {
            current.replace(Regex("""<[^>]+>"""), "").trim()
        }
    }

    private fun analyzeByJsonPath(rule: String): String? {
        val content = this.content ?: return null
        return try {
            val cleanRule = rule.removePrefix("$.")
            val parts = cleanRule.split(".")
            var current: Any? = parseJson(content)
            for (part in parts) {
                if (current is Map<*, *>) {
                    current = current[part]
                } else if (current is List<*> && part == "*") {
                    current = current.firstOrNull()
                } else {
                    return null
                }
            }
            current?.toString()
        } catch (e: Exception) {
            null
        }
    }

    private fun parseJson(json: String): Any? {
        return try {
            val trimmed = json.trim()
            when {
                trimmed.startsWith("{") -> parseJsonObject(trimmed)
                trimmed.startsWith("[") -> parseJsonArray(trimmed)
                else -> trimmed
            }
        } catch (e: Exception) {
            null
        }
    }

    private fun parseJsonObject(json: String): Map<String, Any?> {
        val result = mutableMapOf<String, Any?>()
        val content = json.trim().removeSurrounding("{", "}")
        var i = 0
        while (i < content.length) {
            while (i < content.length && content[i] in " \t\n\r") i++
            if (i >= content.length) break
            if (content[i] == '"') {
                val keyEnd = findStringEnd(content, i + 1)
                val key = content.substring(i + 1, keyEnd)
                i = keyEnd + 1
                while (i < content.length && content[i] in " \t\n\r:") i++
                val valueEnd = findValueEnd(content, i)
                val valueStr = content.substring(i, valueEnd).trim()
                result[key] = parseJsonValue(valueStr)
                i = valueEnd
                while (i < content.length && content[i] in " \t\n\r,") i++
            } else {
                i++
            }
        }
        return result
    }

    private fun parseJsonArray(json: String): List<Any?> {
        val result = mutableListOf<Any?>()
        val content = json.trim().removeSurrounding("[", "]")
        var i = 0
        while (i < content.length) {
            while (i < content.length && content[i] in " \t\n\r") i++
            if (i >= content.length) break
            val valueEnd = findValueEnd(content, i)
            val valueStr = content.substring(i, valueEnd).trim()
            if (valueStr.isNotEmpty()) {
                result.add(parseJsonValue(valueStr))
            }
            i = valueEnd
            while (i < content.length && content[i] in " \t\n\r,") i++
        }
        return result
    }

    private fun parseJsonValue(value: String): Any? {
        return when {
            value.startsWith("\"") -> value.removeSurrounding("\"")
            value.startsWith("{") -> parseJsonObject(value)
            value.startsWith("[") -> parseJsonArray(value)
            value == "true" -> true
            value == "false" -> false
            value == "null" -> null
            value.toLongOrNull() != null -> value.toLong()
            value.toDoubleOrNull() != null -> value.toDouble()
            else -> value
        }
    }

    private fun findStringEnd(s: String, start: Int): Int {
        var i = start
        while (i < s.length) {
            if (s[i] == '\\') {
                i += 2
                continue
            }
            if (s[i] == '"') return i
            i++
        }
        return s.length
    }

    private fun findValueEnd(s: String, start: Int): Int {
        var i = start
        var depth = 0
        var inString = false
        while (i < s.length) {
            val c = s[i]
            if (inString) {
                if (c == '\\') {
                    i += 2
                    continue
                }
                if (c == '"') inString = false
            } else {
                when (c) {
                    '"' -> inString = true
                    '{', '[' -> depth++
                    '}', ']' -> {
                        depth--
                        if (depth == 0) return i + 1
                    }
                    ',' -> if (depth == 0) return i
                }
            }
            i++
        }
        return i
    }

    private fun analyzeByRegex(rule: String): String? {
        val content = this.content ?: return null
        return try {
            val regex = Regex(rule)
            val match = regex.find(content)
            match?.groupValues?.getOrNull(1) ?: match?.value
        } catch (e: Exception) {
            null
        }
    }

    private fun analyzeByJs(js: String): String? {
        return jsExtensions?.evalJS(js, content ?: "", pageUrl ?: "")
    }
}
