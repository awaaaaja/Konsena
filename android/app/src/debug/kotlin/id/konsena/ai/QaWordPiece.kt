package id.konsena.ai

import org.json.JSONObject
import java.util.regex.Pattern

/** Supports the supplied case-sensitive BertNormalizer / WordPiece contract.
 * Rejects unsupported normalizers instead of silently changing token rules.
 */
class QaWordPiece(json: JSONObject) {
    private val vocab = json.getJSONObject("model").getJSONObject("vocab")
    private val special: List<String>
    init {
        val n = json.getJSONObject("normalizer")
        require(n.getString("type") == "BertNormalizer" && !n.getBoolean("lowercase") &&
            n.getBoolean("clean_text") && n.getBoolean("handle_chinese_chars") &&
            (n.isNull("strip_accents") || !n.getBoolean("strip_accents")))
        require(json.getJSONObject("model").getString("type") == "WordPiece")
        require(json.getJSONObject("pre_tokenizer").getString("type") == "BertPreTokenizer")
        val tokens = json.getJSONArray("added_tokens")
        special = (0 until tokens.length()).map { tokens.getJSONObject(it).getString("content") }
    }
    private fun chinese(c: Int) = c in 0x4e00..0x9fff || c in 0x3400..0x4dbf ||
        c in 0x20000..0x2a6df || c in 0x2a700..0x2b73f || c in 0x2b740..0x2b81f ||
        c in 0x2b820..0x2ceaf || c in 0xf900..0xfaff || c in 0x2f800..0x2fa1f
    private fun punctuation(c: Int): Boolean = c in 33..47 || c in 58..64 || c in 91..96 || c in 123..126 ||
        Character.getType(c) in listOf(Character.CONNECTOR_PUNCTUATION.toInt(), Character.DASH_PUNCTUATION.toInt(),
            Character.START_PUNCTUATION.toInt(), Character.END_PUNCTUATION.toInt(), Character.INITIAL_QUOTE_PUNCTUATION.toInt(),
            Character.FINAL_QUOTE_PUNCTUATION.toInt(), Character.OTHER_PUNCTUATION.toInt())
    private fun tokenize(text: String): MutableList<Long> {
        val result = mutableListOf<Long>()
        val matcher = Pattern.compile(special.joinToString("|") { Pattern.quote(it) }).matcher(text)
        var start = 0
        fun plain(value: String) {
            val cleaned = StringBuilder()
            value.codePoints().forEach { c ->
                when {
                    c == 0 || c == 0xfffd -> Unit
                    c == 9 || c == 10 || c == 13 || Character.isWhitespace(c) || Character.isSpaceChar(c) -> cleaned.append(' ')
                    Character.getType(c) == Character.CONTROL.toInt() || Character.getType(c) == Character.FORMAT.toInt() -> Unit
                    chinese(c) || punctuation(c) -> { cleaned.append(' '); cleaned.appendCodePoint(c); cleaned.append(' ') }
                    else -> cleaned.appendCodePoint(c)
                }
            }
            for (word in cleaned.toString().trim().split(Regex("\\s+"))) {
                if (word.isEmpty()) continue
                val cps = word.codePoints().toArray()
                if (cps.size > 100) { result.add(100); continue }
                val parts = mutableListOf<Long>()
                var index = 0
                var failed = false
                while (index < cps.size) {
                    var end = cps.size
                    var found: Long? = null
                    while (end > index) {
                        val piece = (if (index == 0) "" else "##") + String(cps, index, end - index)
                        if (vocab.has(piece)) { found = vocab.getLong(piece); break }
                        end--
                    }
                    if (found == null) { failed = true; break }
                    parts.add(found); index = end
                }
                result.addAll(if (failed) listOf(100L) else parts)
            }
        }
        while (matcher.find()) {
            plain(text.substring(start, matcher.start()))
            result.add(vocab.getLong(matcher.group()))
            start = matcher.end()
        }
        plain(text.substring(start))
        return result
    }
    fun encode(text: String, pair: String?): Pair<LongArray, LongArray> {
        val a = tokenize(text)
        val b = pair?.let { tokenize(it) }
        val budget = if (b == null) 254 else 253
        while (a.size + (b?.size ?: 0) > budget) {
            if (b != null && b.size >= a.size) b.removeAt(b.lastIndex) else a.removeAt(a.lastIndex)
        }
        val values = mutableListOf(101L)
        values.addAll(a); values.add(102)
        if (b != null) { values.addAll(b); values.add(102) }
        val mask = LongArray(256) { if (it < values.size) 1 else 0 }
        val ids = LongArray(256) { values.getOrElse(it) { 0 } }
        return Pair(ids, mask)
    }
}
